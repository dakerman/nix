{ inputs, ... }:

inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
     ../modules/system
     ./hardware-configuration.nix
     ./configuration.nix
  ];
 }

