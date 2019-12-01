RSpec.describe ShellB::Shell do

  ShellB::Shell.def_system_command("foo")
  ShellB::Shell.def_system_command("bar")
  ShellB::Shell.def_system_command("baz")

  let(:shb) do
    ShellB::Shell.new
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
  end
end

