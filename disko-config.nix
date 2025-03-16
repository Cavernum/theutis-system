{ targetDisk }: # Paramètre du disque cible avec valeur par défaut

{ config, lib, ... }:
{
  disko.devices = {
    disk = {
      main = {
        device = targetDisk;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";  # Partition EFI
              size = "1G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi";
                mountOptions = ["defaults"];
              };
            };

            boot = {
              size = "1G";
              # Boot non chiffré
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/boot";
                mountOptions = ["defaults"];
              };
            };

            root = {
              size = "100%-17G";
              content = {
                type = "luks";
                name = "cryptroot";
                settings = {
                  allowDiscards = true;
                };
                passwordFile = config.sops.secrets.luks-root-key.path;
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = ["compress=zstd" "noatime" "autodefrag"];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = ["compress=zstd" "noatime" "autodefrag"];
                    };
                    "/var" = {
                      mountpoint = "/var";
                      mountOptions = ["compress=zstd" "noatime" "autodefrag"];
                    };
                    "/var/log" = {
                      mountpoint = "/var/log";
                      mountOptions = ["compress=zstd" "noatime" "autodefrag"];
                    };
                    "/opt" = {
                      mountpoint = "/opt";
                      mountOptions = ["compress=zstd" "noatime" "autodefrag"];
                    };
                    "/srv" = {
                      mountpoint = "/srv";
                      mountOptions = ["compress=zstd" "noatime" "autodefrag"];
                    };
                    "/tmp" = {
                      mountpoint = "/tmp";
                      mountOptions = ["compress=zstd" "noatime" "autodefrag" "noexec" "nosuid" "nodev"];
                    };
                  };
                };
              };
            };

            swap = {
              size = "16G";
              content = {
                type = "luks";
                name = "cryptswap";
                settings = {
                  allowDiscards = true;
                };
                passwordFile = config.sops.secrets.luks-swap-key.path;
                content = {
                  type = "swap";
                  resumeDevice = true;
                };
              };
            };
          };
        };
      };
    };
  };
}
