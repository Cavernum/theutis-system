{
  description = "NixOS flake for theutis";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, ... } @ inputs: {
    nixosConfigurations.theutis = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { disk = "/dev/nvme0n1"; };
      modules = [
        { nixpkgs.config.allowUnfree = true; }
        disko.nixosModules.disko
        ./disko-config.nix
        ./hardware-configuration.nix
        ./hosts/default.nix
      ];
    };
  };
}
