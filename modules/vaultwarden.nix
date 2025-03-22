{ config, pkgs, lib, ... }:

{
  virtualisation.oci-containers = {
    containers = {
      vaultwarden = {
        image = "docker.io/vaultwarden/server:latest";
        autoStart = true;
        ports = [
          "8009:80"  # Expose on port 8009 as requested
        ];
        volumes = [
          "vw-data:/data"  # Persistent volume for all Vaultwarden data
        ];
        environment = {
          # Core settings
          ROCKET_PORT = "80";
          ROCKET_WORKERS = "10";
          
          # Web vault settings
          WEB_VAULT_ENABLED = "true";
          
          # Optional settings (uncomment and modify as needed)
          DOMAIN = "https://vaultwarden.cavernum.ovh";
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
          "--restart=unless-stopped"
        ];
      };
    };
  };
}
