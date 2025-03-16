{ config, lib, pkgs, ... }:

{
  # Configuration du bootloader GRUB
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      enableCryptodisk = true;  # Activer le support pour les disques chiffrés
    };
  };

  # Configuration des périphériques LUKS (seulement root et swap, pas /boot)
  boot.initrd.luks.devices = {
    cryptroot = {
      device = "/dev/disk/by-partlabel/root";
      preLVM = true;
      allowDiscards = true;
    };
    cryptswap = {
      device = "/dev/disk/by-partlabel/swap";
      preLVM = true;
      allowDiscards = true;
    };
  };

  # Activer les firmwares non libres si nécessaire
  hardware.enableAllFirmware = true;
  
  # Activer les mises à jour du microcode (pour Intel, ajustez selon votre CPU)
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  
  # Activer NetworkManager
  networking.networkmanager.enable = true;
}
