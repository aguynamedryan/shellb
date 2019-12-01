RSpec.describe ShellB::Commander do
  let(:shell) do
    ShellB::Shell.new
  end
  describe ".def_system_command" do
    it "should define a method for ALL new commanders" do
      cmd = :blat
      first_cmdr = ShellB::Commander.new(shell)
      expect(first_cmdr).not_to respond_to(cmd)

      ShellB::Commander.def_system_command(cmd)
      second_cmdr = ShellB::Commander.new(shell)
      expect(second_cmdr).to respond_to(cmd)
    end
  end
end


