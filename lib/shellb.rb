require "shellb/version"
require "shellb/shell"
require "pry-byebug" rescue nil

module ShellB
  class Error < StandardError; end
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
