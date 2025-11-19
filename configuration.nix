{ config, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # --- BINARY CACHE (WICHTIG FÜR COSMIC) ---
  # Damit du nicht alles selbst kompilieren musst
  nix.settings = {
    substituters = [ "https://cosmic.cachix.org" ];
    trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
    experimental-features = [ "nix-command" "flakes" ];
  };

  # --- BOOTLOADER ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];
  
  # --- NETZWERK & HOSTNAME ---
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # --- ZEIT & SPRACHE (SCHWEIZ) ---
  time.timeZone = "Europe/Zurich"; 
  i18n.defaultLocale = "de_CH.UTF-8";

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Tastatur auf der Konsole
  console.keyMap = "sg"; 

  # Tastatur Layout
  services.xserver.xkb = {
    layout = "ch";
    variant = "";
  };

  # --- COSMIC DESKTOP ---
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  environment.sessionVariables =  {
    NIXOS_OZONE_WL = "1"; # Zwingt Electron Apps (wie Discord/VSCode) auf Wayland
    MOZ_ENABLE_WAYLAND = "1"; # Zwingt Firefox/Zen auf Wayland
  };

  programs.kdeconnect.enable = true;
  programs.adb.enable = true;

  # --- NVIDIA TREIBER (PRIME OFFLOAD) ---
  nixpkgs.config.allowUnfree = true;
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # --- SOUND ---
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- USER & PROGRAMME ---
  users.users.meo = { 
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" "adbusers" ];
    packages = with pkgs; [
      # Standard Tools
      kitty           # COSMIC hat auch 'cosmic-term', falls du wechseln willst
      starship
      git
      wl-clipboard
      brightnessctl
      playerctl
      libnotify
      
      # COSMIC Apps (Optional, da COSMIC sie oft schon mitbringt, 
      # aber hier kannst du sicherstellen, dass sie da sind)
      cosmic-files    # Ersetzt Thunar
      cosmic-term     # Ersetzt Kitty (optional)
      cosmic-edit     # Texteditor
      
      # Dev
      helix
      nil
      python3
      pyright
      rust-analyzer
      
      # Apps
      bitwarden-desktop
      scrcpy
      inputs.zen-browser.packages."${pkgs.system}".default
      rclone
      bottles
      pavucontrol
      tidal-hifi
      wasistlos
    ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    font-awesome
  ];

  programs.steam.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;

  system.stateVersion = "24.05"; 
}
