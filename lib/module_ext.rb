module Kernel
  def self.silent(&block)
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old_verbose
  end
end

module EtestReloader
  extend self
  
  def reload(module_name)
    reload_file("#{module_name.underscore}.rb") || begin
      STDERR.puts("Warning: Cannot reload module #{module_name}")
      false
    end
  end

  private
  
  def reload_file(file)
    begin
      load(file) && file
    rescue LoadError
      nfile = file.gsub(/\/[^\/]+\.rb/, ".rb")
      nfile != file && reload_file(nfile)
    end
  end
end

# 
# TDD helpers for modules. 
class Module
  #
  # reloads the module, and runs the module's etests.
  def etest(*args)
    EtestReloader.reload(name)
    if etests = const_get("Etest")
      EtestReloader.reload(etests.name)
    end
  
    ::EtestUnit.run etests, *args
  end
  
  def reload
    EtestReloader.reload(name)
  end
  
  #
  # returns all instances of a module
  def instances                                           #:nodoc:
    r = []
    ObjectSpace.each_object(self) { |mod| r << mod }
    r
  end
  
  #
  # load a module by name. 
  def self.by_name(name)                                  #:nodoc:
    Kernel.silent do
      r = eval(name, nil, __FILE__, __LINE__)
      r if r.is_a?(Module) && r.name == name
    end
  rescue NameError, LoadError
    nil
  end
end
