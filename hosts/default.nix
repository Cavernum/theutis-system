{ config, pkgs, ... }:

{
  imports = [
    ../modules/bootloader.nix
    ../modules/services.nix
  ];

  networking.hostName = "theutis";
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Paris";

  services.xserver.xkb.layout = "fr";
  #i18n.defaultLocale = "fr_FR.UTF-8";
  console.earlySetup = true;
  console.useXkbConfig = true;

  environment.systemPackages = with pkgs; [
    neovim
    git
    curl
    wget
    grub2_efi
    efibootmgr
    desktop-file-utils
    gnupg
    file

    podman
    podman-compose
    shadow
  ];

  services = {
    ntp.enable = true;
  };

  users.users.safenein = {
    name = "safenein";
    group = "safenein";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    description = "Account of Safenein <safenein@cavernum.ovh>";
    linger = true;
    subUidRanges = [
      # { startUid = 1000; count = 1; }
      { startUid = 100000; count = 65536; }
    ];
    subGidRanges = [
      # { startGid = 1000; count = 1; }
      { startGid = 100000; count = 65536; }
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7aUaa8QLaEMT1tSPyX667xftPGOBTJ2pWY+zPSMzHeeNgzL7tkhEX2YbLL3c0qinEffHkzOXVpbY0EDbtAoRYd0YY+o3u8QXtlYC944nR3GRW2nkOp0Yag55/Efv/OofjfKg9PTjRKEF7gNI1BuMFqhtDQX0RkP3zjSYG0kgksv2I4w3OLWVVKqKPmjIcxpe9/6zzkyaxxK131TCFI0eARGGHh5u9QeUo9wc+Jn+PlzeF5pE/nnWeG3u0YJnmo5osoesoI1x85+0/nlj/6atvZpBFhUqAChOqy/kXH+Ge3Gng54soJU3b7xIV9aNgkuFZ1uK/pnag5qokVkDT8S9Sf+K+qc2GxxX0dKH3QVx1J+JeL/kbhQuLW0NVT7pRA/arXGv9d+1FGmhcA37nybQrEinXewrf+qKAs5+t7diI8sLsFMMYj786jr5O88othkkuIgJZCbOSVjFj7Q52tPPYov1EGTY0O+Wd47dGe9t0MEgG1AKFwb4G40YVhEv6iaA2kM+KB+Jb0UXd4XMV3Xu6FvtehYV7vLdWohVDCKL99wFIZjSVcl0PoaFezmMLLxvJHapnX+2RrdRTVEXCN6dS/aL7gJ3JEh7c/EFdeytOGR2Eed3Q/k06P3n+1/RrqKpAm5xTQc4HZK79SPOWWwZuoeE8wGjoc5hK9R/UwKK6iQ== safenein@kribin" 
    ];
  };

  users.users.bolo = {
    name = "bolo";
    group = "bolo";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    description = "Account of Bolo <bolo@cavernum.ovh>";
    linger = true;
    subUidRanges = [
      # { startUid = 1000; count = 1; }
      { startUid = 100000; count = 65536; }
    ];
    subGidRanges = [
      # { startGid = 1000; count = 1; }
      { startGid = 100000; count = 65536; }
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHTrAsqnF/4mciFX150aH2ATlfYKTtFjZ2pv8UCvGAKO bolo@rocket" 
    ];
  };

  users.users.alex532h = {
    name = "alex532h";
    group = "alex532h";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    description = "Account of alex532h <alex532h@cavernum.ovh>";
    linger = true;
    subUidRanges = [
      # { startUid = 1000; count = 1; }
      { startUid = 100000; count = 65536; }
    ];
    subGidRanges = [
      # { startGid = 1000; count = 1; }
      { startGid = 100000; count = 65536; }
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDdvdgw+EnLYVR/UenTcFS5gSVKVMFNiiGX5fnb2Llso9bWXPRlp6Nu2rgUMKAegv2JwC2QyhHb3fMTd9IU7sIwo8ytJ1fp1BkTpnibNS63gCGUBmCU6/p1W8WRW8gHZ+GPEZD5WliH80em8+u08qjh847tWbkgqGBvCfvJunMA6UWq1iD8cJYvkyU6LessRba6Ah2C12GOzOoCkcTNtjE32E0mwDSarW35G8FLA6brHnD9saeu2EZePvIh9RO6EyQvgluykTH/xf/ywAmbdn2FXxA0fgO6tHUiHnvTTlX4yJGnPlZ+124w4Ev8iJ1ETwfVqo7Ddkt9B8tpVKTPisidRY9jYsfsoRAM4i0Et3xDthMXMrNUVoZ/I4kxSlwvwdg9DMcoWM4nrtp6kpgZ7mvEsuH66Qw8cOCaU8rtzwu8/qZbY6YXUVc1zXEhxuoLmm/NZSVg1GcydMyPjiJW/nFu+6ZDmRTxUy0SU+CdmZvvw+D8z7pi7CP2RvcluHFF8cB3PCwX6fAB7hNN5BFcuKO0ANo1Edz7d3RALXsxrEagWnJjLiobvGCP6F6Qe9hmyNx23FCOu3Yw+EhVcG3U+OjuEnPpHF4ysEiACxnIqoSJ4n3xbKqxxwvN32+JhuTJTWc289w/HeedmAmhHL2QtY/W18+lgpzxU5NclrGw26Qb+w== alex532h@deb"
    ];
  };

  users.users.lasmaw = {
    name = "lasmaw";
    group = "lasmaw";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    description = "Account of lasmaw <lasmaw@cavernum.ovh>";
    linger = true;
    subUidRanges = [
      # { startUid = 1000; count = 1; }
      { startUid = 100000; count = 65536; }
    ];
    subGidRanges = [
      # { startGid = 1000; count = 1; }
      { startGid = 100000; count = 65536; }
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA6OJMusrF25tNs3bHcSxxoXnNHmvSuaaGjkXo9VJ4CQ mateo.lachaize@gmail.com" 
    ];
  };

  users.groups = {
    safenein = { };
    bolo = { };
    alex532h = { };
    lasmaw = { };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings = {
    substituters = [
      "https://hyprland.cachix.org"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  programs.nh = {
    enable = true;
    #clean.enable = true;
    #clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/theutis-system";
  };

  boot.kernelParams = [ "systemd.unified_cgroup_hierarchy=1" ];

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    openssl
  ];

  services.openssh.enable = true;
  services.openssh.openFirewall = true;

  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {
      dns_enabled = true;  # Enable DNS resolution in the default network
      ipv6_enabled = true;
      dnsname.enable = true;
    };
  };
  virtualisation.oci-containers.backend = "podman";
  networking.firewall.interfaces."podman1" = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };

  services.openssh.settings.PermitRootLogin = "yes";  # TODO:: Change for production
  system.stateVersion = "24.11";
}
