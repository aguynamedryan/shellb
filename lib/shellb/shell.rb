require_relative "commander"

module ShellB
  class Shell
    class << self
      def def_system_command(name, path = nil)
        Commander.def_system_command(name, path)
      end
    end

    def initialize
      @commands = []
    end

    def transact(&block)
      sub_shell = self.class.new
      sub_shell.instance_eval(&block)
      add_command(sub_shell)
    end

    def add_command(command)
      @commands << command
      command
    end

    def drop_command(command)
      @commands -= [command]
    end

    def to_sh
      @commands.map do |command|
        command.to_sh
      end.join("\n\n")
    end

    def method_missing(meth, *args)
      return super unless commander.respond_to?(meth)
      add_command(commander.public_send(meth, *args))
    end

    def respond_to?(meth)
      super || commander.respond_to?(meth)
    end

    def commander
      @commander ||= Commander.new(self)
    end

    def check_point
      #no-op
    end

    def pretty_print(pp)
      pp.object_group(self) do
        pp.breakable
        pp.text "@commands="
        pp.pp @commands
      end
    end
  end
end
