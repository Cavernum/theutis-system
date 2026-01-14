{
  config,
  pkgs,
  lib,
  ...
}:
with lib; {
  options.theutis_services.ollama-webui = {
    enable = mkEnableOption "Ollama WebUI service";

    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Port on which Ollama WebUI will listen";
    };

    ollamaHost = mkOption {
      type = types.str;
      default = "host.containers.internal";
      description = "Hostname/IP of the Ollama API service";
    };

    ollamaPort = mkOption {
      type = types.port;
      default = 11434;
      description = "Port of the Ollama API service";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/ollama-webui";
      description = "Directory to store Ollama WebUI data";
    };
  };

  config = {
    theutis_services.services = [
      {
        name = "ollama";
        port = config.theutis_services.ollama-webui.port;
      }
    ];
    virtualisation.oci-containers = {
      containers = {
        vaultwarden = {
          image = "ollamawebui/ollama-webui";
          autoStart = true;
          volumes = config.theutis_services.ollama-webui.volumes;
          environment = {
            OLLAMA_BASE_URL = "";
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
