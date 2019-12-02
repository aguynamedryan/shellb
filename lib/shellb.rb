require "shellb/version"
require "shellb/shell"
begin
  require "pry-byebug"
rescue LoadError
end

module ShellB
  class Error < StandardError; end
  class ExecutionError < StandardError; attr_accessor :script ; end
  # Your code goes here...
  class << self
    def new(*args)
      Shell.new(*args)
    end

    def def_system_command(*args)
      Shell.def_system_command(*args)
    end

    def alias_command(*args)
      Shell.alias_command(*args)
    end
  end
end
