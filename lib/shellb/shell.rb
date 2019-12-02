require "tempfile"
require_relative "commander"

module ShellB
  class Shell
    class << self
      def def_system_command(name, path = nil)
        Commander.def_system_command(name, path)
      end

      def alias_command(name, *args)
        Commander.alias_command(name, *args)
      end
    end

    attr_reader :opts
    def initialize(opts = {})
      @commands = []
      @opts = opts
    end

    def transact(opts = {}, &block)
      sub_shell = self.class.new(opts)
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

    def run
      script = Tempfile.new("script.sh")
      script.write(to_sh)
      script.close
      system("sh", script.path)
    ensure
      script.close!
    end

    def to_sh
      str = @commands.map do |command|
        command.to_sh
      end.join("\n\n")
      wrap_it(str, opts[:parens])
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

    private

    def wrap_it(str, wrap_char)
      return str if wrap_char.nil?

      wrap_char = "(" if wrap_char == true
      end_char = {
        "(" => ")",
        "{" => "}",
        "[" => "]"
      }[wrap_char] || raise("No matching character for #{wrap_char}")
      "#{wrap_char} #{str} #{end_char}"
    end
  end
end
