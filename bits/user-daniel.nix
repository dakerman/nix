{ pkgs, ... }:

{
  home.username = "daniel";
  home.homeDirectory = "/home/daniel";
  home.stateVersion = "25.11";

  programs.vscode = {
    enable = true;
    profiles.default = {
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
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "dakerman";
      user.email = "a.daniel.akerman@gmail.com";
      alias = {
        aa = "add .";
        au = "add -u";
        br = "checkout -b";
        ca = "commit --amend";
        cm = "commit -m";
        co = "checkout";
        d = "diff";
        dn = "diff --name-only";
        f = "fetch -pt";
        fp = "push --force-with-lease";
        lgo = "log --oneline --graph";
        ln = "log -n";
        lo = "log --oneline";
        lon = "log --oneline -n";
        p = "push";
        r = "rebase";
        rh = "reset --hard";
        s = "status";
        tree = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
      };
      push.autoSetupRemote = true;
      url."ssh://git@github.com".insteadOf = "https://github.com";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  # Setup ssh and use ksshaskpass
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      addKeysToAgent = "yes";
    };
  };

  home.packages = with pkgs; [
    kdePackages.ksshaskpass
  ];

  home.sessionVariables = {
    SSH_ASKPASS = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  # Terminal
  programs.alacritty.enable = true;

  # Home manager and KDE plasma manager
  programs.home-manager.enable = true;
  programs.plasma.enable = true;

  # Plasma touchpad settings
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
      naturalScroll = true;
    }
  ];
}
