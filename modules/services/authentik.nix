{
  config,
  lib,
  pkgs,
  ...
}: {
  options.theutis_services.authentik = with lib; {
    enable = mkEnableOption "Enable Authentik OIDC provider";
    image = mkOption {
      type = types.str;
      default = "ghcr.io/goauthentik/server:2024.2.2";
      description = "Docker image for Authentik server.";
    };
    port = mkOption {
      type = types.int;
      default = 9000;
      description = "Port on which Authentik will run.";
    };
    secretKey = mkOption {
      type = types.str;
      default = "PleaseGenerateASecretKey50CharactersLongForAuthentik";
      description = "Secret key for Authentik (should be 50+ chars).";
    };
    bootstrapPassword = mkOption {
      type = types.str;
      default = "akadmin";
      description = "Bootstrap password for akadmin user.";
    };
    bootstrapToken = mkOption {
      type = types.str;
      default = "akadmin-bootstrap-token-theutis-system";
      description = "Bootstrap token for initial setup.";
    };
    bootstrapEmail = mkOption {
      type = types.str;
      default = "admin@cavernum.ovh";
      description = "Bootstrap email for akadmin user.";
    };
  };

  config = lib.mkIf config.theutis_services.authentik.enable {
    theutis_services.services = lib.mkAfter [
      {
        name = "authentik";
        port = config.theutis_services.authentik.port;
      }
    ];

    # Create bootstrap script for Authentik configuration
    environment.systemPackages = with pkgs; [
      curl
      jq
    ];

    # Create the bootstrap configuration script
    systemd.services.authentik-bootstrap = {
      description = "Bootstrap Authentik configuration";
      after = [ "docker-authentik.service" "docker-authentik-worker.service" ];
      wants = [ "docker-authentik.service" "docker-authentik-worker.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = let
          bootstrapScript = pkgs.writeShellScript "authentik-bootstrap" ''
            set -e
            
            # Wait for Authentik to be ready
            echo "Waiting for Authentik to be ready..."
            for i in {1..60}; do
              if curl -f http://localhost:${toString config.theutis_services.authentik.port}/if/admin/ >/dev/null 2>&1; then
                echo "Authentik is ready!"
                break
              fi
              echo "Waiting... ($i/60)"
              sleep 5
            done
            
            # Get auth token
            echo "Getting authentication token..."
            TOKEN=$(curl -s -X POST "http://localhost:${toString config.theutis_services.authentik.port}/api/v3/core/tokens/" \
              -H "Content-Type: application/json" \
              -H "Authorization: Bearer ${config.theutis_services.authentik.bootstrapToken}" \
              -d '{"identifier": "bootstrap-token", "description": "Bootstrap configuration token"}' | jq -r '.key' || echo "")
            
            if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
              echo "Using bootstrap token for initial setup"
              TOKEN="${config.theutis_services.authentik.bootstrapToken}"
            fi
            
            # Create OIDC Provider for Vaultwarden
            echo "Creating OIDC Provider for Vaultwarden..."
            VAULTWARDEN_PROVIDER=$(curl -s -X POST "http://localhost:${toString config.theutis_services.authentik.port}/api/v3/providers/oauth2/" \
              -H "Content-Type: application/json" \
              -H "Authorization: Bearer $TOKEN" \
              -d '{
                "name": "vaultwarden-oidc",
                "authorization_flow": "default-authorization-flow",
                "client_type": "confidential",
                "client_id": "vaultwarden",
                "client_secret": "vaultwarden-secret-key",
                "redirect_uris": "https://vaultwarden.${config.theutis_services.domain}/identity/connect/oidc-signin",
                "sub_mode": "hashed_user_id",
                "include_claims_in_id_token": true,
                "issuer_mode": "per_provider"
              }' || echo '{}')
            
            # Create OIDC Provider for Syncthing
            echo "Creating OIDC Provider for Syncthing..."
            SYNCTHING_PROVIDER=$(curl -s -X POST "http://localhost:${toString config.theutis_services.authentik.port}/api/v3/providers/oauth2/" \
              -H "Content-Type: application/json" \
              -H "Authorization: Bearer $TOKEN" \
              -d '{
                "name": "syncthing-oidc",
                "authorization_flow": "default-authorization-flow",
                "client_type": "confidential",
                "client_id": "syncthing",
                "client_secret": "syncthing-secret-key",
                "redirect_uris": "https://syncthing.${config.theutis_services.domain}/oidc/callback",
                "sub_mode": "hashed_user_id",
                "include_claims_in_id_token": true,
                "issuer_mode": "per_provider"
              }' || echo '{}')
            
            # Create Application for Vaultwarden
            echo "Creating Application for Vaultwarden..."
            curl -s -X POST "http://localhost:${toString config.theutis_services.authentik.port}/api/v3/core/applications/" \
              -H "Content-Type: application/json" \
              -H "Authorization: Bearer $TOKEN" \
              -d '{
                "name": "Vaultwarden",
                "slug": "vaultwarden",
                "provider": "vaultwarden-oidc",
                "launch_url": "https://vaultwarden.${config.theutis_services.domain}",
                "open_in_new_tab": true
              }' >/dev/null || true
            
            # Create Application for Syncthing
            echo "Creating Application for Syncthing..."
            curl -s -X POST "http://localhost:${toString config.theutis_services.authentik.port}/api/v3/core/applications/" \
              -H "Content-Type: application/json" \
              -H "Authorization: Bearer $TOKEN" \
              -d '{
                "name": "Syncthing",
                "slug": "syncthing",
                "provider": "syncthing-oidc",
                "launch_url": "https://syncthing.${config.theutis_services.domain}",
                "open_in_new_tab": true
              }' >/dev/null || true
            
            # Create default users from existing system users
            echo "Creating users..."
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList (username: userConfig: ''
              curl -s -X POST "http://localhost:${toString config.theutis_services.authentik.port}/api/v3/core/users/" \
                -H "Content-Type: application/json" \
                -H "Authorization: Bearer $TOKEN" \
                -d '{
                  "username": "${username}",
                  "name": "${username}",
                  "email": "${userConfig.description or (username + "@" + config.theutis_services.domain)}",
                  "is_active": true,
                  "groups": []
                }' >/dev/null || true
            '') (lib.filterAttrs (n: v: n != "root" && v.isNormalUser or false) config.users.users))}
            
            echo "Authentik bootstrap completed successfully!"
          '';
        in "${bootstrapScript}";
      };
    };

    virtualisation.oci-containers = {
      containers = {
        authentik-postgresql = {
          image = "docker.io/library/postgres:12-alpine";
          autoStart = true;
          volumes = [
            "authentik-database:/var/lib/postgresql/data"
          ];
          environment = {
            POSTGRES_PASSWORD = "authentik-db-password";
            POSTGRES_USER = "authentik";
            POSTGRES_DB = "authentik";
          };
          extraOptions = [
            "--name=authentik-postgresql"
            "--health-cmd=pg_isready -d authentik -U authentik"
            "--health-interval=30s"
            "--health-retries=5"
            "--health-start-period=30s"
            "--health-timeout=5s"
          ];
        };

        authentik-redis = {
          image = "docker.io/library/redis:alpine";
          autoStart = true;
          cmd = [ "--save" "60" "1" "--loglevel" "warning" ];
          volumes = [
            "authentik-redis:/data"
          ];
          environment = {
            REDIS_PASSWORD = "authentik-redis-password";
          };
          extraOptions = [
            "--name=authentik-redis"
            "--health-cmd=redis-cli ping || exit 1"
            "--health-interval=30s"
            "--health-retries=5"
            "--health-start-period=30s"
            "--health-timeout=3s"
          ];
        };

        authentik = {
          image = config.theutis_services.authentik.image;
          autoStart = true;
          cmd = [ "server" ];
          environment = {
            AUTHENTIK_SECRET_KEY = config.theutis_services.authentik.secretKey;
            AUTHENTIK_BOOTSTRAP_PASSWORD = config.theutis_services.authentik.bootstrapPassword;
            AUTHENTIK_BOOTSTRAP_TOKEN = config.theutis_services.authentik.bootstrapToken;
            AUTHENTIK_BOOTSTRAP_EMAIL = config.theutis_services.authentik.bootstrapEmail;
            
            # Database configuration
            AUTHENTIK_POSTGRESQL__HOST = "authentik-postgresql";
            AUTHENTIK_POSTGRESQL__NAME = "authentik";
            AUTHENTIK_POSTGRESQL__USER = "authentik";
            AUTHENTIK_POSTGRESQL__PASSWORD = "authentik-db-password";
            
            # Redis configuration
            AUTHENTIK_REDIS__HOST = "authentik-redis";
            AUTHENTIK_REDIS__PASSWORD = "authentik-redis-password";
            
            # Core settings
            AUTHENTIK_ERROR_REPORTING__ENABLED = "false";
            AUTHENTIK_LOG_LEVEL = "info";
            AUTHENTIK_DISABLE_UPDATE_CHECK = "true";
            
            # OIDC/OAuth settings
            AUTHENTIK_DEFAULT_USER_CHANGE_NAME = "true";
            AUTHENTIK_DEFAULT_USER_CHANGE_EMAIL = "true";
            AUTHENTIK_DEFAULT_USER_CHANGE_USERNAME = "true";
            
            # Trust proxy headers
            AUTHENTIK_LISTEN__TRUSTED_PROXY_CIDRS = "10.0.0.0/8,172.16.0.0/12,192.168.0.0/16";
          };
          volumes = [
            "authentik-media:/media"
            "authentik-custom-templates:/templates"
          ];
          extraOptions = [
            "--name=authentik"
            "--requires=authentik-postgresql"
            "--requires=authentik-redis"
          ];
        };

        authentik-worker = {
          image = config.theutis_services.authentik.image;
          autoStart = true;
          cmd = [ "worker" ];
          environment = {
            AUTHENTIK_SECRET_KEY = config.theutis_services.authentik.secretKey;
            
            # Database configuration
            AUTHENTIK_POSTGRESQL__HOST = "authentik-postgresql";
            AUTHENTIK_POSTGRESQL__NAME = "authentik";
            AUTHENTIK_POSTGRESQL__USER = "authentik";
            AUTHENTIK_POSTGRESQL__PASSWORD = "authentik-db-password";
            
            # Redis configuration
            AUTHENTIK_REDIS__HOST = "authentik-redis";
            AUTHENTIK_REDIS__PASSWORD = "authentik-redis-password";
            
            # Core settings
            AUTHENTIK_ERROR_REPORTING__ENABLED = "false";
            AUTHENTIK_LOG_LEVEL = "info";
            AUTHENTIK_DISABLE_UPDATE_CHECK = "true";
          };
          volumes = [
            "authentik-media:/media"
            "authentik-certs:/certs"
            "authentik-custom-templates:/templates"
          ];
          extraOptions = [
            "--name=authentik-worker"
            "--requires=authentik-postgresql"
            "--requires=authentik-redis"
          ];
        };
      };
    };
  };
}