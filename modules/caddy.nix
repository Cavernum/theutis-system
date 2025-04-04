{ config, pkgs, ... }:

let
  # Define your Caddyfile content directly here
  caddyfileContent = ''
    vaultwarden.cavernum.ovh {
      # Enable HTTPS automatically tls { Caddy will automatically get and manage certificates }

      # Forward all traffic to Vaultwarden
      reverse_proxy vaultwarden:8009 {
        # Enable WebSocket support for sync
        header_up X-Real-IP {remote_host}
        header_up Host {host}
        header_up X-Forwarded-For {remote}
        header_up X-Forwarded-Proto {scheme}
      }

      # Optional logging
      log {
        output file /var/log/caddy/vaultwarden.log
      }
    }
  '';

  # Create the Caddyfile from the content defined above
  caddyfile = pkgs.writeText "Caddyfile" caddyfileContent;
in
{
  # systemd.services.create-podman-network = {
  #   description = "Create Podman network for containers";
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network-online.target" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #     ExecStart = "${pkgs.podman}/bin/podman network create --ignore caddy_network || true";
  #   };
  # };
  virtualisation.oci-containers = {
    containers = {
      caddy = {
        image = "docker.io/caddy:latest";
        autoStart = true;
        ports = [
          "80:80"
          "443:443"
        ];
        volumes = [
          # "/var/www:/srv"  # Mount your website files here (modify path as needed)
          "caddy_data:/data"
          "caddy_config:/config"
          "${caddyfile}:/etc/caddy/Caddyfile:ro"
        ];
        extraOptions = [
          "--network=caddy_network" 
          "--name=caddy"
        ];
      };
    };
  };
}
