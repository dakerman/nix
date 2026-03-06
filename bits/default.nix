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
  ];
 }

