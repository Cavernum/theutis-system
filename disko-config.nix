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
          swap = {
            size = "16G";
            content = {
              type = "swap";
              resumeDevice = true;
            };
          };
          root = {
            size = "100%";
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
      };
    };
  };
}
