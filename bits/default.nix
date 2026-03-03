{ inputs, ... }:

inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    {
      nixpkgs = {
        config = { allowUnfree = true; };
      };

    }
  ];
}
