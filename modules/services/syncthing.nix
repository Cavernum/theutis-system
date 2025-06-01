{
  config,
  lib,
  pkgs,
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
    syncPort = mkOption {
      type = types.int;
      default = 22000;
      description = "Port for Syncthing synchronization.";
    };
    discoveryPort = mkOption {
      type = types.int;
      default = 21027;
      description = "Port for Syncthing local discovery.";
    };
  };
  
  config = {
    theutis_services.services = [
      {
        name = "syncthing";
        port = config.theutis_services.syncthing.port;
        protected = true;
      }
    ];
    
    # Open firewall ports for Syncthing sync
    networking.firewall.allowedTCPPorts = [ 
      config.theutis_services.syncthing.syncPort 
    ];
    networking.firewall.allowedUDPPorts = [ 
      config.theutis_services.syncthing.discoveryPort 
    ];
    
    virtualisation.oci-containers = {
      containers = {
        syncthing = {
          image = config.theutis_services.syncthing.image;
          autoStart = true;
          volumes = config.theutis_services.syncthing.volumes;
          ports = [
            "${toString config.theutis_services.syncthing.syncPort}:22000/tcp"
            "${toString config.theutis_services.syncthing.syncPort}:22000/udp"
            "${toString config.theutis_services.syncthing.discoveryPort}:21027/udp"
          ];
          environment = {
            PUID = "1000";
            PGID = "1000";
            TZ = "Etc/UTC";
            # Allow access from reverse proxy
            STGUIADDRESS = "0.0.0.0:${toString config.theutis_services.syncthing.port}";
            # Disable authentication (will be handled by Authentik)
            STNODEFAULTFOLDER = "true";
          };
          extraOptions = [
            "--name=syncthing"
            "--hostname=syncthing-${config.networking.hostName}"
          ];
        };
      };
    };
  };
}
