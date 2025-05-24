{
  config,
  lib,
  ...
}: {
  options.theutis_services.syncthing = with lib; {
    enable = mkEnableOption "Enable Syncthing container";
    image = mkOption {
      type = types.str;
      default = "docker.io/syncthing/syncthing:latest";
      description = "Docker image for Syncthing server.";
    };
    port = mkOption {
      type = types.int;
      default = 8384;
      description = "Port on which Syncthing web UI will run.";
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
  
  config = lib.mkIf config.theutis_services.syncthing.enable {
    theutis_services.services = lib.mkAfter [
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
          ports = [
            "${toString config.theutis_services.syncthing.syncPort}:22000/tcp"
            "${toString config.theutis_services.syncthing.syncPort}:22000/udp"
            "${toString config.theutis_services.syncthing.discoveryPort}:21027/udp"
          ];
          volumes = [
            "syncthing-config:/var/syncthing/config"
            "syncthing-data:/var/syncthing/data"
          ];
          environment = {
            PUID = "1000";
            PGID = "1000";
            # Allow access from reverse proxy
            STGUIADDRESS = "0.0.0.0:${toString config.theutis_services.syncthing.port}";
            # Disable authentication (will be handled by Authentik)
            STNODEFAULTFOLDER = "true";
          };
          extraOptions = [
            "--network=syncthing-network"
            "--name=syncthing"
            "--hostname=syncthing-${config.networking.hostName}"
          ];
        };
      };
    };
    
    # Create systemd service to configure Syncthing after startup
    systemd.services.syncthing-config = {
      description = "Configure Syncthing for OIDC";
      after = [ "docker-syncthing.service" ];
      wants = [ "docker-syncthing.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = let
          configScript = pkgs.writeShellScript "syncthing-config" ''
            set -e
            
            # Wait for Syncthing to be ready
            echo "Waiting for Syncthing to be ready..."
            for i in {1..30}; do
              if curl -f http://localhost:${toString config.theutis_services.syncthing.port}/ >/dev/null 2>&1; then
                echo "Syncthing is ready!"
                break
              fi
              echo "Waiting... ($i/30)"
              sleep 5
            done
            
            echo "Syncthing configuration completed!"
          '';
        in "${configScript}";
      };
    };
  };
}