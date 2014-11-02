module Kernel
  def self.silent(&block)
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old_verbose
  end
end

# 
# TDD helpers for modules. 
class Module
  #
  # reloads the module, and runs the module's etests.
  def etest(*args)
    reload
    if etests = const_get("Etest") rescue nil
      etests.reload
    end
  
    ::EtestUnit.run etests, *args
  end
  
  module Reloader
    def self.reload(mod)
      source_files = mod.source_files

      # Skip files that live in .gem and .rvm directories.
      source_files.reject! do |source_file|
        source_file =~ /\/\.gem\// ||
        source_file =~ /\/\.rvm\//
      end

      source_files.each do |source_file|
        reload_file(source_file)
      end
    end

    def self.reload_file(file)
      r = load(file)
      STDERR.puts("load #{file.inspect}: #{r ? "OK" : r.inspect}")
      !!r
    rescue LoadError
      STDERR.puts "load #{file.inspect}: raised #{$!}"
      false
    end
  end

  def reload
    Reloader.reload(self)
    self
  end
  
  def source_files
    public_instance_methods(false).
      map do |method_name| instance_method(method_name) end.
      map(&:source_location).compact.
      map(&:first).
      uniq.
      sort
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
