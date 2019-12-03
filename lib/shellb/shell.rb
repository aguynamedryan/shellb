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
      instance_eval(&block) if block
      check_point(opts) if opts[:execute]
    end

    def run(opts = {}, &block)
      transact(opts.merge(execute: true), &block)
    end

    def run!(opts = {}, &block)
      run(opts.merge(exit_on_errors: true), &block)
    end

    def attempt(opts = {}, &block)
      run(opts.merge(ignore_errors: true), &block)
    end

    def add_command(command)
      @commands << command
      command
    end

    def drop_command(command)
      @commands -= [command]
    end

    def check_point(opts = {})
      script = Tempfile.new("script.sh")
      script.write(to_sh(opts))
      script.close
      output = `bash #{script.path}`
      unless $?.exitstatus.zero?
        ee = ShellB::ExecutionError.new(output)
        ee.script = File.read(script)
        raise ee
      end
    rescue ShellB::ExecutionError => ee
      raise(ee) unless opts[:ignore_errors]
    ensure
      @commands = []
      script.close!
    end
    alias execute check_point

    def to_sh(opts = {})
      str = make_preamble(opts)
      str += @commands.map do |command|
        decorate_command(command, opts)
      end.join("\n\n")
      str
    end

    def decorate_command(command, opts)
      cmd_str = command.to_sh
      append = if opts[:exit_on_errors]
                 "exit $?"
               elsif opts[:ignore_errors]
                 "true"
               else
                 nil
               end
      cmd_str = wrap_it(cmd_str, "(") unless command.name == "cd"
      [cmd_str, append].compact.join(" || ")
    end

    def method_missing(meth, *args)
      return super unless commander.respond_to?(meth)
      add_command(commander.public_send(meth, *args))
    end

    def make_preamble(opts)
      preamble = []
      if opts[:exit_on_errors]
        preamble << %w[set -x]
        preamble << %w[set -e]
        preamble << []
      end
      preamble = preamble.map { |pream| Shellwords.join(pream) }
      preamble.join("\n")
    end

    def respond_to?(meth)
      super || commander.respond_to?(meth)
    end

    def commander
      @commander ||= Commander.new(self)
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
