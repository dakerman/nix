# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    #      ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-af657024-09f5-4039-9d50-8574d7726cbe".device =
    "/dev/disk/by-uuid/af657024-09f5-4039-9d50-8574d7726cbe";
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

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
      "docker"
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

  bluetooth.enable = true;
  fingerprint.enable = true;
  speaker-eq.enable = true;

  # Enable Thunderbolt device authorization (bolt daemon).
  # Required for monitors/docks that provide display and network over Thunderbolt/USB4.
  services.hardware.bolt.enable = true;

  power-management = {
    enable = true;
    cpuVendor = "intel"; # Intel Core Ultra 7 258V
  };

  graphics = {
    enable = true;
    intel = {
      enable = true;
      generation = "arc"; # Intel Arc 140V (Lunar Lake, Core Ultra 258V)
    };
  };

  docker.enable = true;

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
    nixfmt-rfc-style
    pkgs-unstable.claude-code
    btop
    usbutils # lsusb — useful for debugging USB devices
    yubikey-manager # ykman — manage YubiKey modes, FIDO2 PINs, etc.
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

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
