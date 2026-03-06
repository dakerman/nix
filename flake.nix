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

  outputs = { nixpkgs, nixpkgs-unstable, ... }@inputs:
  {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;

      nixosConfigurations = {
        bits = import ./bits/default.nix { inherit inputs; };
      };

      #homeConfigurations = {
      #  "birgerrydback@bits" =
      #    mkHomeConfiguration ./hosts/bits/user-birgerrydback.nix;
      #};
  };
}
