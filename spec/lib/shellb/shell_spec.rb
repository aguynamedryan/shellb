RSpec.describe ShellB::Shell do

  ShellB::Shell.def_system_command("foo")
  ShellB::Shell.def_system_command("bar")
  ShellB::Shell.def_system_command("baz")
  ShellB::Shell.alias_command("alli", "ls", "-l")

  let(:shb) do
    described_class.new
  end

  describe "#transact" do
    it "should instance_eval the block" do
      shb.transact do
        foo
      end
      expect(shb.to_sh).to match(/foo/)
    end

    it "should handle pipes" do
      shb.transact do
        foo | bar
      end
      script = shb.to_sh
      expect(script).to match(/foo/)
      expect(script).to match(/bar/)
      expect(script).to match(/\|/)
    end

    it "should handle sequential commands" do
      shb.transact do
        foo
        bar
      end
      script = shb.to_sh
      expect(script).to match(/foo/)
      expect(script).to match(/bar/)
      expect(script).not_to match(/\|/)
    end
  end

  describe "with method called directly on shell" do
    it "should handle sequential commands" do
      shb.foo
      shb.bar

      script = shb.to_sh
      expect(script).to match(/foo/)
      expect(script).to match(/bar/)
      expect(script).not_to match(/\|/)
    end

    it "should handle piped commands" do
      shb.foo | shb.bar

      script = shb.to_sh
      expect(script).to match(/foo/)
      expect(script).to match(/bar/)
      expect(script).to match(/\|/)
    end

    it "should handle direct commands and transacted" do
      shb.foo
      shb.transact do
        bar | baz
      end

      script = shb.to_sh
      expect(script).to match(/foo/)
      expect(script).to match(/bar/)
      expect(script).to match(/baz/)
      expect(script).to match(/\|/)
      expect(script).to match(/bar\s*\|\s*baz/)
    end

    it "should handle aliases" do
      shb.alli

      script = shb.to_sh
      expect(script).to match(/ls -l/)
    end
  end

  describe "#to_sh" do
    it "should support exit_on_errors option" do
      shb.foo
      script = shb.to_sh(exit_on_errors: true)
      expect(script).to match(/( foo )/)
      expect(script).to match(/exit \$\?/)
      expect(script).to match(/set -e/)
      expect(script).to match(/set -x/)
    end
  end

  describe "#run" do
    it "executes the command" do
      allow(shb).to receive(:`)
      shb.foo
      shb.run
    end
  end

  describe "#run!" do
    it "executes the command and exit on errors" do
      expect(shb).to receive(:to_sh).with(hash_including(exit_on_errors: true))
      shb.foo
      shb.run!
    end
  end

  describe "#attempt" do
    it "attempts to execute the command and ignore errors" do
      expect(shb).to receive(:to_sh).with(hash_including(ignore_errors: true))
      shb.foo
      shb.attempt
    end
  end
end

