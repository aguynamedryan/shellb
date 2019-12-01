module ShellB
  class Command
    attr_reader :name, :opts, :shell, :block
    attr_accessor :downstream

    def initialize(shell, name, *opts)
      @shell = shell
      @name = name
      @opts = opts
    end

    def |(command)
      shell.drop_command(command)
      self.downstream = command
    end

    def >(to)
      @output = to
    end

    def >>(to)
      @append = to
    end

    def <(from)
      @input = from
    end

    def redirection_parts
      return [">", @output.to_s] if @output
      return [">>", @append.to_s] if @append
      return []
    end

    def children
      @piper ? @piper.to_set : []
    end

    def to_s
      "<Command: #{name} #{opts.join(" ")}>"
    end

    def to_sh
      parts = []
      parts << [name, *opts, *redirection_parts].join(" ")
      parts << downstream.to_sh if downstream
      parts.join(" | ")
    end

    def pretty_print(pp)
      pp.object_group(self) do
        pp.breakable
        pp.text "@name="
        pp.pp @name

        pp.breakable
        pp.text "@opts="
        pp.pp @opts
      end
    end
  end
end
