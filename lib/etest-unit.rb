require "test/unit"

require File.dirname(__FILE__) + "/string_ext"
require File.dirname(__FILE__) + "/module_ext"

require "test/unit/ui/console/testrunner"

# The Etest::Helper module will be included in all etests.
module Etest
  module Helper
    def etest?
      true
    end
  end
end

module EtestUnit
  class Error < ArgumentError; end
  
  class TestRunner < Test::Unit::UI::Console::TestRunner
    def setup_mediator
      super
      @mediator = EtestUnit::TestRunnerMediator.new(@suite)
    end
  end

  class TestRunnerMediator < Test::Unit::UI::TestRunnerMediator
  end
  
  class TestSuiteCreator < Test::Unit::TestSuiteCreator
    attr :tests, true
    
    module ActiveRecordAdditions
      def set_log_level(level)
        return unless ActiveRecord::Base.logger
        
        r = ActiveRecord::Base.logger.level
        ActiveRecord::Base.logger.level = level
        r
      end
      
      def in_transaction(&block)
        old_log_level = set_log_level(Logger::ERROR)
        ActiveRecord::Base.transaction do
          begin
            set_log_level(old_log_level)
            yield
          ensure
            set_log_level(Logger::ERROR)
            raise ActiveRecord::Rollback, "Rollback test transaction"
          end
        end
      rescue
        STDERR.puts "Could not run etest in transaction: #{$!}"
      ensure
        set_log_level(old_log_level)
      end
      
      def run_test(test, result)
        running_tests_in_transaction = nil
        
        in_transaction do
          running_tests_in_transaction = true
          super(test, result)
        end

        if !running_tests_in_transaction
          super(test, result)
        end
      end
    end

    module MochaAdditions
      def run_test(test, result)
        test.mocha_setup
        super(test, result)
      ensure
        test.mocha_verify
        test.mocha_teardown
      end
    end

    def create
      suite = super
      suite.extend ActiveRecordAdditions if defined?(::ActiveRecord)
      suite.extend MochaAdditions if defined?(::Mocha)
      suite
    end
    
    private

    def collect_test_names
      return super if tests.empty?
      
      public_instance_methods = @test_case.public_instance_methods(true).map(&:to_s)
      method_names = tests.map(&:to_s)

      missing_tests = method_names - public_instance_methods
      unless missing_tests.empty?
        raise Error, "Missing test(s): #{missing_tests.join(", ")}"
      end

      send("sort_test_names_in_#{@test_case.test_order}_order", method_names)
    end
  end
  
  module TestCase
    def etest=(etest)
      @etest = etest
      include etest
    end
    
    attr :tests, true
    
    def suite
      suite_creator = EtestUnit::TestSuiteCreator.new(self)
      suite_creator.tests = tests
      suite = suite_creator.create
      suite.name = @etest.name
      suite
    end
  end
  
  def self.run(etest, *tests)
    test_case_klass = Class.new(Test::Unit::TestCase)
    test_case_klass.extend EtestUnit::TestCase
    test_case_klass.send :include, Etest::Helper
    
    test_case_klass.etest = etest
    test_case_klass.tests = tests
    TestRunner.new(test_case_klass).start
  end
end

class Test::Unit::TestSuite
  attr :name, true
end
