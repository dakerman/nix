{ inputs, ... }:
let
   pkgs-unstable = import inputs.nixpkgs-unstable { system = "x86_64-linux"; config.allowUnfree = true; };
in
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs pkgs-unstable; };
  modules = [
    ../modules/system
    ./hardware-configuration.nix
    ./configuration.nix
    inputs.home-manager.nixosModules.home-manager

    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        extraSpecialArgs = { inherit inputs pkgs-unstable; };
        sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];
        users.daniel = import ./user-daniel.nix;
      };
    }
  ];
 }

