{ config, lib, pkgs, ... }:

{
  sops = {
    # Utiliser une clé SSH comme clé age pour déchiffrer les secrets
    # age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    age.keyFile = "/etc/age/key.age";
    
    # Définition des secrets pour les clés LUKS (uniquement root et swap)
    secrets = {
      "luks-root-key" = {
        sopsFile = ./secrets/luks-keys.yaml;
        key = "root";
      };
      "luks-swap-key" = {
        sopsFile = ./secrets/luks-keys.yaml;
        key = "swap";
      };
    };
  };

  # Assurez-vous que les clés sont disponibles dans l'initrd
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = config.sops.secrets.luks-root-key.path;
  };
}
