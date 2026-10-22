# The base every host shares: boot loader, networking, locale, Plasma desktop,
# audio, the daniel account and the packages wanted everywhere. lib/mk-host.nix
# includes it for every host; host-specific hardware and services live in
# hosts/<name>/configuration.nix.

{ pkgs, pkgs-unstable, ... }:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Tailscale: a private network between my machines, reachable from anywhere.
  # Join a host once with `sudo tailscale up`; after that MagicDNS resolves the
  # other hosts by name (`ssh desktop`). systemd-resolved is what tailscaled
  # hands those names to; NetworkManager uses it as its resolver when enabled.
  services.tailscale.enable = true;
  services.resolved.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  # Despite the name, services.xserver.* is used by both X11 and Wayland on NixOS.
  # This enables the display server infrastructure that SDDM/Plasma 6 depend on.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Keyboard layout — applies to both X11 and Wayland (KWin reads XKB config).
  services.xserver.xkb = {
    layout = "se";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "sv-latin1";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.daniel = {
    isNormalUser = true;
    description = "Daniel Åkerman";
    extraGroups = [
      "networkmanager"
      "wheel"
      "gamemode" # required for GameMode's process-priority boost (see modules/system/gaming)
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # 1Password: CLI + desktop app. The GUI module sets up the polkit helper and
  # adds the user to the onepassword group (required for browser integration
  # and system auth prompts).
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "daniel" ];
  };

  # Nano settings
  programs.nano.nanorc = ''
    set linenumbers
    set autoindent
    set tabsize 2
    set tabstospaces
  '';

  programs.ssh.startAgent = true;

  environment.sessionVariables = {
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  # YubiKey support — smart card daemon + udev rules for non-root access
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    slack
    git
    jq
    nixfmt
    pkgs-unstable.claude-code
    btop
    usbutils # lsusb — useful for debugging USB devices
    yubikey-manager # ykman — manage YubiKey modes, FIDO2 PINs, etc.
    d2 # declarative diagramming language (d2lang.com)
  ];

  # Automatically garbage-collect old store paths weekly, keeping the last 100 generations.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than +100";
  };
  # Deduplicate identical files in the Nix store to save disk space.
  nix.optimise.automatic = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
