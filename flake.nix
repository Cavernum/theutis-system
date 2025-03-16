{
  description = "Configuration NixOS avec partitions chiffrées via Disko";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, sops-nix, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = nixpkgs.lib;
    in {
      # Fonction pour créer une configuration avec un disque cible spécifique
      nixosConfigurations = {
        # Configuration par défaut, utilisant le premier disque comme exemple
        default = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit self; };
          modules = [
            ./configuration.nix
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            (import ./disko-config.nix { targetDisk = "/dev/sda"; })
            ./hardware-config.nix
            ./secrets.nix
          ];
        };
      };
      
      targetSystem = targetDisk: lib.nixosSystem {
        inherit system;
        specialArgs = { inherit self; };
        modules = [
          ./configuration.nix
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          (import ./disko-config.nix { inherit targetDisk; })
          ./hardware-config.nix
          ./secrets.nix
        ];
      };
    };
}
