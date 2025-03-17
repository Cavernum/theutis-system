{ disk ? "/dev/nvme0n1", ... }:

{
  disko.devices = {
    disk.main = {
      device = disk;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot/efi";
            };
          };
          boot = {
            size = "1G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/boot";
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypted";
              extraOpenArgs = [ "--allow-discards" ];
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@" = { mountpoint = "/"; };
                  "@home" = { mountpoint = "/home"; };
                  "@var" = { mountpoint = "/var"; };
                  "@var_log" = { mountpoint = "/var/log"; };
                  "@opt" = { mountpoint = "/opt"; };
                  "@srv" = { mountpoint = "/srv"; };
                  "@tmp" = {
                    mountpoint = "/tmp";
                    mountOptions = [ "noexec" "nosuid" "nodev" ];
                  };
                };
                mountOptions = [ "compress=zstd" "noatime" "autodefrag" ];
              };
            };
          };
          swap = {
            size = "16G";
            content = {
              type = "luks";
              name = "cryptswap";
              extraOpenArgs = [ "--allow-discards" ];
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
}
