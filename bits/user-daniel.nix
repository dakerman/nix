{ pkgs, pkgs-unstable, ... }:

{
  home.username = "daniel";
  home.homeDirectory = "/home/daniel";
  home.stateVersion = "25.11";

  programs.vscode = {
    enable = true;
    # Track unstable for newer VS Code releases (stable lags behind upstream).
    package = pkgs-unstable.vscode;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        # Loads per-project direnv envs into VS Code so language servers
        # (gopls, etc.) find toolchains from flake/shell.nix dev shells.
        mkhl.direnv
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
      user.name = "daniel-bitsbi";
      user.email = "daniel.akerman@bits.bi";
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
    includes = [
      {
        condition = "gitdir:~/workspace/nix/";
        contents = {
          user.name = "dakerman";
          user.email = "a.daniel.akerman@gmail.com";
        };
      }
    ];
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  # Setup ssh and use ksshaskpass
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        identityFile = "~/.ssh/id_ed25519_bits";
        identitiesOnly = true;
        addKeysToAgent = "yes";
      };
      "github-personal" = {
        hostname = "github.com";
        identityFile = "~/.ssh/id_rsa";
        identitiesOnly = true;
        addKeysToAgent = "yes";
      };
      "*" = {
        addKeysToAgent = "yes";
      };
    };
  };

  home.packages = with pkgs; [
    kdePackages.ksshaskpass
    kdePackages.krohnkite
    nodejs_22
    pnpm
    postman
    awscli2
  ];

  home.sessionVariables = {
    SSH_ASKPASS = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  programs.firefox = {
    enable = true;
    profiles =
      let
        sharedSettings = {
          # Enable VA-API hardware video decoding (uses Intel iHD driver via LIBVA_DRIVER_NAME)
          "media.ffmpeg.vaapi.enabled" = true;
          # Restore previous session (open tabs) on startup
          "browser.startup.page" = 3;
          # Disable "ask to save passwords"
          "signon.rememberSignons" = false;
          # Disable "save and autofill payment methods"
          "extensions.formautofill.creditCards.enabled" = false;
        };
      in
      {
        work = {
          id = 0;
          isDefault = true;
          settings = sharedSettings;
        };
        private = {
          id = 1;
          settings = sharedSettings;
        };
      };
  };

  # Firefox profile launchers (for KRunner)
  xdg.desktopEntries = {
    firefox-work = {
      name = "Firefox (Work)";
      exec = "firefox -P work";
      icon = "firefox";
      terminal = false;
    };
    firefox-private = {
      name = "Firefox (Private)";
      exec = "firefox -P private";
      icon = "firefox";
      terminal = false;
    };
  };

  # GitHub CLI
  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  # Auto-load Nix dev environments when entering project directories
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Let Home Manager manage bash
  programs.bash.enable = true;

  # Context-aware shell prompt (git, nix, languages, etc.)
  programs.starship = {
    enable = true;
    settings = {
      directory = {
        truncation_length = 5;
        truncate_to_repo = false;
      };
    };
  };

  # Terminal
  programs.alacritty = {
    enable = true;
    settings.keyboard.bindings = [
      # Meta+K to clear terminal
      {
        key = "K";
        mods = "Super";
        chars = "\\u0015clear\\u000d";
      }
      # Shift+Enter → send ESC+CR so Claude Code (and other TUIs) treat it as newline
      {
        key = "Return";
        mods = "Shift";
        chars = "\\u001b\\r";
      }
    ];
  };

  # Home manager and KDE plasma manager
  programs.home-manager.enable = true;
  programs.plasma.enable = true;

  # Krohnkite tiling
  programs.plasma.configFile."kwinrc"."Plugins"."krohnkiteEnabled" = true;
  programs.plasma.configFile."kwinrc"."Desktops"."Number" = 6;

  # Dim inactive windows so the focused one stands out (title bars are hidden,
  # so the usual focus cue isn't visible).
  programs.plasma.configFile."kwinrc"."Plugins"."diminactiveEnabled" = true;
  programs.plasma.configFile."kwinrc"."Effect-diminactive"."Strength" = 40;

  # Track focus per-screen so "Switch to Next/Previous Screen" (Meta+,/Meta+.)
  # restores the last-focused window on the target screen instead of just
  # moving the cursor.
  programs.plasma.configFile."kwinrc"."Windows"."SeparateScreenFocus" = true;

  # Krohnkite gaps
  programs.plasma.configFile."kwinrc"."Script-krohnkite"."screenGapBetween" = 8;
  programs.plasma.configFile."kwinrc"."Script-krohnkite"."screenGapTop" = 8;
  programs.plasma.configFile."kwinrc"."Script-krohnkite"."screenGapBottom" = 8;
  programs.plasma.configFile."kwinrc"."Script-krohnkite"."screenGapLeft" = 8;
  programs.plasma.configFile."kwinrc"."Script-krohnkite"."screenGapRight" = 8;

  programs.plasma.shortcuts = {
    # Free Meta+N from task manager so desktop switching works
    "plasmashell"."activate task manager entry 1" = [ ];
    "plasmashell"."activate task manager entry 2" = [ ];
    "plasmashell"."activate task manager entry 3" = [ ];
    "plasmashell"."activate task manager entry 4" = [ ];
    "plasmashell"."activate task manager entry 5" = [ ];
    "plasmashell"."activate task manager entry 6" = [ ];

    # Virtual desktop switching: Meta+1-6
    "kwin"."Switch to Desktop 1" = "Meta+1";
    "kwin"."Switch to Desktop 2" = "Meta+2";
    "kwin"."Switch to Desktop 3" = "Meta+3";
    "kwin"."Switch to Desktop 4" = "Meta+4";
    "kwin"."Switch to Desktop 5" = "Meta+5";
    "kwin"."Switch to Desktop 6" = "Meta+6";

    # Send window to virtual desktop: Meta+Ctrl+1-6
    # (Meta+Shift+Number broken on Swedish keyboard — Shift changes the keysym)
    "kwin"."Window to Desktop 1" = "Meta+Ctrl+1";
    "kwin"."Window to Desktop 2" = "Meta+Ctrl+2";
    "kwin"."Window to Desktop 3" = "Meta+Ctrl+3";
    "kwin"."Window to Desktop 4" = "Meta+Ctrl+4";
    "kwin"."Window to Desktop 5" = "Meta+Ctrl+5";
    "kwin"."Window to Desktop 6" = "Meta+Ctrl+6";

    # Close window
    "kwin"."Window Close" = "Meta+Q";

    # Disable accidental maximize/minimize via PageUp/PageDown
    "kwin"."Window Maximize" = [ ];
    "kwin"."Window Minimize" = [ ];

    # Clear KWin shortcuts that conflict with Krohnkite defaults
    "kwin"."Edit Tiles" = [ ]; # freed from Meta+T
    "kwin"."Show Desktop" = [ ]; # freed from Meta+D
    "kwin"."Quick Tile Window to the Left" = [ ]; # freed from Meta+Left
    "kwin"."Quick Tile Window to the Right" = [ ]; # freed from Meta+Right
    "kwin"."Quick Tile Window to the Top" = [ ]; # freed from Meta+Up
    "kwin"."Quick Tile Window to the Bottom" = [ ]; # freed from Meta+Down
    "kwin"."Maximize Window" = [ ]; # freed from Meta+Up

    # Krohnkite: focus navigation (arrow keys)
    # Must be under "kwin" because Krohnkite registers as a KWin script (kwin component)
    "kwin"."KrohnkiteFocusLeft" = "Meta+Left";
    "kwin"."KrohnkiteFocusRight" = "Meta+Right";
    "kwin"."KrohnkiteFocusUp" = "Meta+Up";
    "kwin"."KrohnkiteFocusDown" = "Meta+Down";

    # Krohnkite: move/swap window (arrow keys)
    # Meta+Ctrl+Arrow to match the Meta=focus / Meta+Ctrl=move pattern
    "kwin"."KrohnkiteShiftLeft" = "Meta+Ctrl+Left";
    "kwin"."KrohnkiteShiftRight" = "Meta+Ctrl+Right";
    "kwin"."KrohnkiteShiftUp" = "Meta+Ctrl+Up";
    "kwin"."KrohnkiteShiftDown" = "Meta+Ctrl+Down";

    # Screens: Meta=focus, Meta+Ctrl=move  (mirrors desktop and window patterns)
    "kwin"."Switch to Next Screen" = "Meta+.";
    "kwin"."Switch to Previous Screen" = "Meta+,";
    "kwin"."Window to Next Screen" = "Meta+Ctrl+.";
    "kwin"."Window to Previous Screen" = "Meta+Ctrl+,";

    # Krohnkite: layouts
    "kwin"."KrohnkiteColumnsLayout" = "Meta+C";
    "kwin"."KrohnkiteBTreeLayout" = "Meta+T";
    "kwin"."KrohnkiteMonocleLayout" = "Meta+F"; # fullscreen (one window)
    "kwin"."KrohnkiteRotate" = "Meta+R"; # flip split direction in BTree
  };

  # Minimal top panel (on every screen)
  programs.plasma.panels =
    let
      topPanel = screen: {
        inherit screen;
        location = "top";
        height = 32;
        hiding = "normalpanel";
        widgets = [
          {
            pager.general = {
              displayedText = "desktopNumber";
              showWindowOutlines = true;
              showApplicationIconsOnWindowOutlines = false;
            };
          }
          "org.kde.plasma.panelspacer"
          {
            systemTray.items = {
              shown = [
                "org.kde.plasma.battery"
                "org.kde.plasma.networkmanagement"
                "org.kde.plasma.volume"
                "org.kde.plasma.bluetooth"
                "org.kde.plasma.brightness"
              ];
            };
          }
          {
            digitalClock = {
              time.format = "24h";
              calendar.firstDayOfWeek = "monday";
            };
          }
        ];
      };
    in
    [
      (topPanel 0) # laptop
      (topPanel 1) # external monitor
    ];

  # Hide title bars on all windows
  programs.plasma.window-rules = [
    {
      description = "No title bars";
      match = {
        window-types = [ "normal" ];
      };
      apply = {
        noborder = {
          value = true;
          apply = "force";
        };
      };
    }
  ];

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
