# Work laptop (Intel Core Ultra 7 258V, Lunar Lake). Everything shared with the
# other hosts is in modules/common (wired in by lib/mk-host.nix); this file is
# only what is specific to this machine.

{ pkgs, ... }:

{
  networking.hostName = "nixos"; # Define your hostname.

  # Pin to 6.18 — the default 6.12 LTS hangs loading the xe (Lunar Lake) driver.
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # Encrypted swap (the root LUKS device is in hardware-configuration.nix).
  boot.initrd.luks.devices."luks-af657024-09f5-4039-9d50-8574d7726cbe".device =
    "/dev/disk/by-uuid/af657024-09f5-4039-9d50-8574d7726cbe";

  # Temporary: needed to resolve bits.beer (staging)
  networking.nameservers = [ "1.1.1.1" ];

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

  # Steam + GameMode + Gamescope + MangoHud (modules/system/gaming)
  gaming.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
