{
  description = "Åkes's flake to rule them all";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    { nixpkgs, nixpkgs-unstable, ... }@inputs:
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;

      nixosConfigurations = {
        bits = import ./bits/default.nix { inherit inputs; };
      };

      #homeConfigurations = {
      #  "birgerrydback@bits" =
      #    mkHomeConfiguration ./hosts/bits/user-birgerrydback.nix;
      #};
    };
}
