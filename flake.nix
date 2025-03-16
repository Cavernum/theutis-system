{
  description = "Configuration NixOS avec partitions chiffrées via Disko";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, ... }: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit self; };
      modules = [
        ./configuration.nix
        disko.nixosModules.disko
        ./disko-config.nix
        ./hardware-config.nix
      ];
    };
  };
}
