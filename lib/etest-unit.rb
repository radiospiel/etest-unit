require "test/unit"

require File.dirname(__FILE__) + "/string_ext"
require File.dirname(__FILE__) + "/module_ext"

require "test/unit/ui/console/testrunner"

module Etest
  class Error < ArgumentError; end
  
  class TestRunner < Test::Unit::UI::Console::TestRunner
    def setup_mediator
      super
      @mediator = Etest::TestRunnerMediator.new(@suite)
    end
  end

  class TestRunnerMediator < Test::Unit::UI::TestRunnerMediator
    def run
      if defined?(ActiveRecord)
        ActiveRecord::Base.transaction do
          super
          raise ActiveRecord::Rollback, "Rollback test transaction"
        end
      else
        super
      end
    end
  end
  
  class TestSuiteCreator < Test::Unit::TestSuiteCreator
    attr :tests, true
    
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
  
  class TestCase < Test::Unit::TestCase
    module ClassMethods
      def etest=(etest)
        @etest = etest
        include etest
      end
      
      attr :tests, true
    end

    extend ClassMethods
    
    def self.suite
      suite_creator = Etest::TestSuiteCreator.new(self)
      suite_creator.tests = tests
      suite = suite_creator.create
      suite.name = @etest.name
      suite
    end
  end
  
  def self.run(etest, *tests)
    test_case_klass = Class.new(TestCase)
    
    test_case_klass.etest = etest
    test_case_klass.tests = tests
    TestRunner.new(test_case_klass).start
  end
end

class Test::Unit::TestSuite
  attr :name, true
end
