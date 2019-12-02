require_relative "command"

module ShellB
  class Commander
    attr_reader :shell

    class << self
      def def_system_command(name, path = nil)
        define_method(name) do |*args|
          Command.new(shell, path || name, *args)
        end
      end

      def alias_command(name, *args)
        define_method(name) do |*opts|
          Command.new(shell, *args, *opts)
        end
      end
    end

    DEFAULT_COMMANDS = %w[
      cd
      pwd
    ].each do |cmd|
      def_system_command(cmd)
    end

    def initialize(shell)
      @shell = shell
    end
  end
end
