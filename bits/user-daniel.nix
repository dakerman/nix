{ pkgs, ... }:

{
  home.username = "daniel";
  home.homeDirectory = "/home/daniel";
  home.stateVersion = "25.11";

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
    ];
    userSettings = {
      "nix.formatterPath" = "nixfmt";
      "[nix]" = {
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
        "editor.formatOnSave" = true;
      };
    };
  };

  programs.home-manager.enable = true;

  programs.plasma.enable = true;

  programs.plasma.input.touchpads = [
    {
      name = "SNSL0028:00 2C2F:0028 Touchpad";
      vendorId = "2c2f";
      productId = "0028";
      rightClickMethod = "twoFingers";
      tapToClick = true;
      scrollMethod = "twoFingers";
      disableWhileTyping = true;
      accelerationProfile = "none";
      pointerSpeed = 0;
    }
  ];
}
