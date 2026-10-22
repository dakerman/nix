# Home Manager for daniel on the desktop. Shared config is in
# modules/common/home.nix; this file has what only makes sense on this machine.

{ ... }:

{
  home.stateVersion = "26.05";

  # Never suspend on idle: training runs for hours with nobody at the keyboard.
  # (Only relevant while someone is logged in to Plasma; the login screen and
  # SSH sessions never suspend the machine by themselves.)
  programs.plasma.powerdevil.AC.autoSuspend.action = "nothing";
}
