# Builds one nixosConfiguration from hosts/<name>/, by convention:
#
#   hardware-configuration.nix   nixos-generate-config output (disks, kernel modules)
#   configuration.nix            what is specific to this host (NixOS)
#   user-daniel.nix              what is specific to this host (Home Manager, daniel)
#
# Everything every host needs is wired here once: the shared base
# (modules/common), the opt-in feature modules (modules/system), pkgs-unstable
# as a module argument, and Home Manager.
#
# The shared files are listed here beside the host's files rather than imported
# *by* them: the module system orders list options (environment.systemPackages,
# home.packages, ...) by where a module sits in the import tree, and this
# placement keeps the bits closure byte-identical to before the split.
{ inputs }:
name:
let
  dir = ../hosts + "/${name}";

  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs pkgs-unstable; };
  modules = [
    ../modules/common
    ../modules/system
    (dir + "/hardware-configuration.nix")
    (dir + "/configuration.nix")
    inputs.home-manager.nixosModules.home-manager

    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        extraSpecialArgs = { inherit inputs pkgs-unstable; };
        sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];
        users.daniel = import (dir + "/user-daniel.nix");
      };
    }
    # Second definition of the same user: the shared Home Manager config, merged
    # with the host's file above.
    { home-manager.users.daniel = import ../modules/common/home.nix; }
  ];
}
