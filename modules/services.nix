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
      type = lib.types.listOf (lib.types.submodule {
        options = {
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
          protected = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Whether the service should be protected by OIDC authentication.
            '';
          };
        };
      });
      default = [];
      description = ''
        List of services to be reverse proxied.
      '';
    };
  };
  
  imports = [
    ./services/authentik.nix
    ./services/vaultwarden.nix
    ./services/syncthing.nix
  ];
  
  config = let
    genRProxyRule = {
      name,
      port,
     }: ''
#      protected ? true,
#    }: let
#      authBlock = lib.optionalString protected ''
#        # OIDC Authentication with Authentik
#        forward_auth authentik:9000 {
#          uri /outpost.goauthentik.io/auth/caddy
#          copy_headers X-Authentik-Username X-Authentik-Groups X-Authentik-Email X-Authentik-Name X-Authentik-Uid
#        }
#        
#        # Handle auth errors
#        handle_errors {
#          @401 expression {http.error.status_code} == 401
#          redir @401 https://authentik.${config.theutis_services.domain}/outpost.goauthentik.io/start?rd=https://${name}.${config.theutis_services.domain}/
#        }
#      '';
#      protectedBlock = lib.optionalString protected ''
#        route {
#          handle_path /health* {
#            reverse_proxy ${name}:${toString port}
#          }
#          handle_path /ping* {
#            reverse_proxy ${name}:${toString port}
#          }
#          handle {
#            ${authBlock}
#            reverse_proxy ${name}:${toString port} {
#              header_up X-Real-IP {remote_host}
#              header_up Host {host}
#              header_up X-Forwarded-For {remote}
#              header_up X-Forwarded-Proto {scheme}
#              header_up X-Forwarded-Port {server_port}
#            }
#          }
#        }
#      '';
#      # If not protected, just reverse proxy
#      unprotectedBlock = lib.optionalString (!protected) ''
#        reverse_proxy ${name}:${toString port} {
#          header_up X-Real-IP {remote_host}
#          header_up Host {host}
#          header_up X-Forwarded-For {remote}
#          header_up X-Forwarded-Proto {scheme}
#          header_up X-Forwarded-Port {server_port}
#        }
#      '';
#    in ''
      ${name}.${config.theutis_services.domain} {
#        ${authBlock}

        reverse_proxy ${name}:${toString port} {
          header_up X-Real-IP {remote_host}
          header_up Host {host}
          header_up X-Forwarded-For {remote}
          header_up X-Forwarded-Proto {scheme}
#          header_up X-Forwarded-Port {server_port}
        }

        log {
          level debug
          output file /var/log/caddy/${name}.log
        }
      }
    '';
    
    # Main domain redirect to Authentik
#    mainDomainRule = ''
#      ${config.theutis_services.domain} {
#        redir https://authentik.${config.theutis_services.domain}/if/admin/
#        
#        log {
#          output file /var/log/caddy/main.log
#        }
#      }
#    '';
    
#    allRules = [mainDomainRule] ++ (map genRProxyRule config.theutis_services.services);
#    caddyfile = pkgs.writeText "Caddyfile" (lib.concatStringsSep "\n\n" allRules);
    caddyfile = pkgs.writeText "Caddyfile" "${lib.concatStringsSep "\n\n" (map genRProxyRule config.theutis_services.services)}";
#    allNetworks = ["authentik-network"] #++ (map ({name, ...}: "${name}-network") config.theutis_services.services);
    
  in {
#    theutis_services.authentik.enable = true;
    theutis_services.vaultwarden.enable = true;
    theutis_services.syncthing.enable = true;
    
    # Ensure log directory exists
    systemd.tmpfiles.rules = [
      "d /var/log/caddy 0755 root root -"
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
            "caddy_data:/data"
            #"caddy_config:/config"
            "${caddyfile}:/etc/caddy/Caddyfile:ro"
            "/var/log/caddy:/var/log/caddy"
          ];
        };
      };
    };
  };
}
