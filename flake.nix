{
  description = "NixOS 24.11 avec disko, btrfs chiffré, grub et nix-sops";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    disko.url = "github:nix-community/disko";
    nix-sops.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, disko, nix-sops, ... } @ inputs: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { disk = "/dev/nvme0n1"; };
      modules = [
        disko.nixosModules.disko
        nix-sops.nixosModules.sops
        ./hosts/default.nix
      ];
    };

    nixosConfigurations.server = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { disk = "/dev/nvme0n1"; };
      modules = [
        disko.nixosModules.disko
        nix-sops.nixosModules.sops
        ./hosts/default.nix
        ./hosts/server.nix
      ];
    };
  };
}
