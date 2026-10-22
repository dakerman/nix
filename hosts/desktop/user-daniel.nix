# Home Manager for daniel on the desktop. Shared config is in
# modules/common/home.nix; this file has what only makes sense on this machine.

{ ... }:

{
  home.stateVersion = "26.05";

  # Never suspend on idle: training runs for hours with nobody at the keyboard.
  # (Only relevant while someone is logged in to Plasma; the login screen and
  # SSH sessions never suspend the machine by themselves.)
  programs.plasma.powerdevil.AC.autoSuspend.action = "nothing";

  # GitHub with the laptop's forwarded ssh-agent. The agent offers every key and
  # GitHub takes the first that authenticates (the Bits one), which cannot push
  # to personal repos. Same split as on the laptop: `github.com` is the work
  # identity, `github-personal` the personal one (use it as the host in remotes,
  # e.g. git@github-personal:dakerman/nix.git). Only the public halves live here;
  # with IdentitiesOnly, ssh uses them to pick the matching key in the agent.
  programs.ssh.settings = {
    "github.com" = {
      HostName = "github.com";
      IdentityFile = "~/.ssh/id_ed25519_bits.pub";
      IdentitiesOnly = true;
    };
    "github-personal" = {
      HostName = "github.com";
      IdentityFile = "~/.ssh/id_rsa.pub";
      IdentitiesOnly = true;
    };
  };
  home.file.".ssh/id_ed25519_bits.pub".text =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKaH14wd8pXiP29TbzUMro8fvbbAJ8DXKTPjePqEV1aT daniel.akerman@bits.bi\n";
  home.file.".ssh/id_rsa.pub".text =
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCmUs1CNNTAMo+4PchbSkRx4923CQowC+q6SEfiAn49Prt4HM4/ACwwBCE6iLj2sggO8Y/pwbfcGO/1YhLO/Gk08JWjrpBNaYreN9BFyg7quA84SyPX6gp7I80CSeNVGJVMkfgP0UNX7CKGqZB+kbXJaacVcgKtLENuHB1VmBBNXAh3ehukDad3wkT9qyOhU8AH7uPfAaEyVj8Vln+LS3FXCd3Bjejxr4m1QaIW8uhpKMW3dnVFXaxfggs8VSnUX/hrn/MZ0SGHiD67EQbxreGfXuCh/q16pTj0YfI7Q50/QLUW4S+xgtGSvYn03Lig+IdH8jZ6VFJkT2RNGEU9sPt7bbzHAzG5rgDo1acWzJKvdy84n4o4vGx5PCPGtMNu5jt4qpvcFxlypgftDxSG5ZMZ8LcOaUy1m1uXvRmvMu3u2A2YXgRhZQmxjM+jdDdToXtTDE67ywkI4e6gW2boMsT6taNooFrWCwIay3RT4qYN9zegoa3lpcYDsIJKIKUDeYmN6B/mjP4VgFCJTsRQR2oJ5Gk1d/0nxgcoRSoyEMpxe8vQlj6MgRa3i7gUA9lcYSdbhXmWBFoWP+W5pALk5YCLpggq8pLQeQOwAz2/ZnVsAkaz8t6K7MDKiGB1hIhkTENchrJI6s9Lbr/BdnfHEigdcuHnto4HrWYAwSCgDE1dow== daniel@nixos\n";
}
