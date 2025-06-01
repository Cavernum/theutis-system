{
  config,
  lib,
  ...
}: {
  options.theutis_services.vaultwarden = with lib; {
    enable = mkEnableOption "Enable Vaultwarden container";
    image = mkOption {
      type = types.str;
      default = "docker.io/vaultwarden/server:latest";
      description = "Docker image for Vaultwarden server.";
    };
    volumes = mkOption {
      type = types.listOf types.str;
      default = ["vw-data:/data"];
      description = "Volumes to mount in the container.";
    };
    port = mkOption {
      type = types.int;
      default = 8009;
      description = "Port on which Vaultwarden will run.";
    };
  };
  
  config = {
    theutis_services.services = [
      {
        name = "vaultwarden";
        port = config.theutis_services.vaultwarden.port;
        #protected = true;
      }
    ];
    
    virtualisation.oci-containers = {
      containers = {
        vaultwarden = {
          image = "docker.io/vaultwarden/server:latest";
          autoStart = true;
          volumes = config.theutis_services.vaultwarden.volumes;
          environment = {
            # Core settings
            ROCKET_PORT = toString config.theutis_services.vaultwarden.port;
            ROCKET_WORKERS = "10";

            # Web vault settings
            WEB_VAULT_ENABLED = "true";
            WEBSOCKET_ENABLED = "true";

            # Domain configuration
            DOMAIN = "https://vaultwarden.${config.theutis_services.domain}";
            
            # OIDC Configuration with Authentik
#            SSO_ENABLED = "true";
#            SSO_ONLY = "false";
#            SSO_CLIENT_ID = "vaultwarden";
#            SSO_CLIENT_SECRET = "vaultwarden-secret-key";
#            SSO_AUTHORITY = "https://authentik.${config.theutis_services.domain}/application/o/vaultwarden/";
#            SSO_SCOPES = "openid profile email";
#            
#            # Additional OIDC settings
#            SSO_MASTER_KEY_FROM_AUTH_CLAIMS = "true";
#            SSO_AUTH_ONLY_NOT_SESSION = "false";
#            SSO_ROLES_DEFAULT_TO_USER = "true";
            
            # Security settings
            SIGNUPS_ALLOWED = "false";  # Only allow OIDC sign-ins
            INVITATIONS_ALLOWED = "true";
            
            # Optional admin settings
            # ADMIN_TOKEN = "your_admin_token_here";
            # Optional settings (uncomment and modify as needed)
            # ADMIN_TOKEN = "your_admin_token_here";  # Generate this securely
            # SIGNUPS_ALLOWED = "false";  # Disable new sign-ups

            # SMTP configuration for email
            # SMTP_HOST = "smtp.example.com";
            # SMTP_FROM = "vaultwarden@example.com";
            # SMTP_PORT = "587";
            # SMTP_SECURITY = "starttls";
            # SMTP_USERNAME = "username";
            # SMTP_PASSWORD = "password";

            # Logging settings
            LOG_LEVEL = "warn";
#            EXTENDED_LOGGING = "true";
            
            # Trust proxy headers (for proper IP forwarding)
#            IP_HEADER = "X-Forwarded-For";
#            ICON_SERVICE = "internal";
          };
          extraOptions = [
            "--name=vaultwarden"
          ];
        };
      };
    };
  };
}
