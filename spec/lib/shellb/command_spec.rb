RSpec.describe ShellB::Command do
  let :sh do
    ShellB::Shell.new
  end

  describe "#>" do
    it "should add output redirect to end of command" do
      cmd = ShellB::Command.new(sh, "ls", "-l").>("dest.txt")
      expect(cmd.to_sh).to match(/ls -l > dest.txt/)
    end
  end

  describe "#<" do
    it "should add input redirect to end of command" do
      cmd = ShellB::Command.new(sh, "ls", "-l").<("source.txt")
      expect(cmd.to_sh).to match(/ls -l < source.txt/)
    end
  end

  describe "#>>" do
    it "should add append redirect to end of command" do
      cmd = ShellB::Command.new(sh, "ls", "-l").>>("append_dest.txt")
      expect(cmd.to_sh).to match(/ls -l >> append_dest.txt/)
    end
  end

  describe "#to_sh" do
    it "should quote what needs quoting" do
      cmd = ShellB::Command.new(sh, "awk", "{ print $1 }")
      expect(cmd.to_sh).to match('awk \\{\\ print\\ \\$1\\ \\}')
    end
  end
end


