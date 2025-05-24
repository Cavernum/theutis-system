{
  lib,
  pkgs,
  config,
  ...
}: {
  options.theutis_services.syncthing = with lib; {
    enable = mkEnableOption "Enable Syncthing container";
    image = mkOption {
      type = types.str;
      default = "docker.io/linuxserver/syncthing:latest";
      description = "Docker image for Syncthing server.";
    };
    volumes = mkOption {
      type = types.listOf types.str;
      default = [
        "syncthing-data:/var/syncthing"
        "syncthing-config:/config"
      ];
      description = "Volumes to mount in the container.";
    };
    port = mkOption {
      type = types.int;
      default = 8384;
      description = "Port on which Syncthing will run.";
    };
  };

  config = {
    theutis_services.services = [
      {
        name = "syncthing";
        port = config.theutis_services.syncthing.port;
      }
    ];
    virtualisation.oci-containers = {
      containers = {
        syncthing = {
          image = config.theutis_services.syncthing.image;
          autoStart = true;
          volumes = config.theutis_services.syncthing.volumes;
          environment = {
            PUID = "1000";  # Adjust to your user ID
            PGID = "1000";  # Adjust to your group ID
            TZ = "Etc/UTC";  # Set timezone
          };
          extraOptions = [
            "--network=syncthing-network"
            "--name=syncthing"
          ];
        };
      };
    };
  };
}
