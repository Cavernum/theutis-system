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
            ROCKET_PORT = "8009";
            ROCKET_WORKERS = "10";

            # Web vault settings
            WEB_VAULT_ENABLED = "true";

            WEBSOCKET_ENABLED = "true";

            # Optional settings (uncomment and modify as needed)
            DOMAIN = "vaultwarden.${config.theutis_services.domain}";
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
          };
          extraOptions = [
            "--network=vaultwarden-network"
            "--name=vaultwarden"
          ];
        };
      };
    };
  };
}
