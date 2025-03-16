{ config, lib, pkgs, ... }:

{
  # Région et langue
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "fr_FR.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "fr";
  };

  # Compte utilisateur
  users.users.theutis = {  # À remplacer par votre nom d'utilisateur
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "MonGrosPickle";
  };

  # Paquets de base
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    htop
  ];

  # Activer SSH
  services.openssh.enable = true;

  # Pour éviter les problèmes avec /tmp
  boot.tmp.cleanOnBoot = true;
}
