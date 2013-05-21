require "test/unit"

require File.dirname(__FILE__) + "/string_ext"
require File.dirname(__FILE__) + "/module_ext"

require "test/unit/ui/console/testrunner"

module Etest
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
        end
      else
        super
      end
    end
  end
  
  class TestCase < Test::Unit::TestCase
    def self.etest=(etest)
      include @etest = etest
    end
    
    def self.suite
      suite      = super
      suite.name = @etest.name
      suite
    end
  end
  
  def self.run(etest)
    test_case_klass = Class.new(TestCase)
    test_case_klass.etest = etest
    TestRunner.new(test_case_klass).start
  end
end

class Test::Unit::TestSuite
  attr :name, true
end

__END__

  def self.autorun
    auto_run
  end
  
  def self.auto_run
    #
    # find all modules that are not named /::Etest$/, and try to load
    # the respective Etest module.
    etests = Module.instances.map { |mod|
      #next if mod.name =~ /\bEtest$/
      next if mod.name == "Object"
      
      Module.by_name "#{mod.name}::Etest"
    }.compact.uniq.sort_by(&:name)

    run(*etests)
  end

  def self.run(*etests)
    #
    # convert all Etest modules into a test case
    test_cases = etests.map { |etest|
      STDERR.puts "Running: #{etest}"
      to_test_case etest
    }
    
    MiniTest::Test.run_etests(*test_cases)
  end

  #
  # convert an Etest moodule into a MiniTest testcase
  def self.to_test_case(mod)
    klass = Class.new TestCase
    klass.send :include, mod
    klass.send :include, Assertions

    Kernel.silent do
      mod.const_set("TestCase", klass)
    end
    klass
  end
end

