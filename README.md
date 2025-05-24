# Installation

~/Documents/theutis-system]$ nixos-anywhere --flake .#theutis --generate-hardware-config nixos-generate-config ./hardware-configuration.nix 'root@192.168.0.198'

nixos-rebuild switch --refresh --flake github:Cavernum/theutis-system
