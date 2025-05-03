{
  config,
  pkgs,
  lib,
  ...
}: {
  options.theutis_services = {
    domain = lib.mkOption {
      type = lib.types.str;
      default = "cavernum.ovh";
      description = ''
        The domain name for the Caddy server.
      '';
    };
    services = lib.mkOption {
      type = lib.types.listOf (lib.types.attrsOf (lib.types.submodule {
        name = lib.mkOption {
          type = lib.types.str;
          description = ''
            The name of the service to be reverse proxied.
          '';
        };
        port = lib.mkOption {
          type = lib.types.int;
          description = ''
            The port on which the service is running.
          '';
        };
      }));
      default = [];
      description = ''
        List of services to be reverse proxied.
      '';
    };
  };
  config = let
    genRProxyRule = {
      name,
      port,
    }: ''
      ${name} {
        reverse_proxy ${name}.${config.theutis_services.domain}:${toString port} {
          header_up X-Real-IP {remote_host}
          header_up Host {host}
          header_up X-Forwarded-For {remote}
          header_up X-Forwarded-Proto {scheme}
        }

        log {
          output file /var/log/caddy/${name}.log
        }
      }
    '';
    caddyfile = pkgs.writeText "Caddyfile" lib.concatMapStrings genRProxyRule config.theutis_services.services;
  in {
    imports = [
      ./services/vaultwarden.nix
    ];
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
            "/var/log/caddy:/var/log/caddy"
          ];
          extraOptions = [
            "--network=${lib.concatMapStrings ({name, ...}: "${name}-network") config.theutis_services.services}"
            "--name=caddy"
          ];
        };
      };
    };
  };
}
