{
  description = "Åkes's flake to rule them all";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs-unstable, ... }@inputs:
  {
      nixosConfigurations = {
        bits = import ./bits/default.nix { inherit inputs; };
      };

      #homeConfigurations = {
      #  "birgerrydback@bits" =
      #    mkHomeConfiguration ./hosts/bits/user-birgerrydback.nix;
      #};
  };
}
