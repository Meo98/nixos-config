{ config, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # --- BOOTLOADER ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];
  boot.loader.systemd-boot.configurationLimit = 15;
   
  # --- NETZWERK & HOSTNAME ---
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # --- ZEIT & SPRACHE ---
  time.timeZone = "Europe/Zurich"; 
  i18n.defaultLocale = "de_CH.UTF-8";

  # --- HARDWARE ---
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  console.keyMap = "sg"; 
  services.xserver.xkb = {
    layout = "ch";
    variant = "";
  };

  # --- GRAFIK & HYPRLAND ---
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "catppuccin-mocha";
    package = pkgs.kdePackages.sddm;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Systemweite Variablen
  environment.sessionVariables =  {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
    EDITOR = "hx"; 
    VISUAL = "hx";
    TERMINAL = "kitty";
  };
  
  # Sicherheits-Ausnahme
  nixpkgs.config.permittedInsecurePackages = [
    "qtwebengine-5.15.19"
  ];

  programs.kdeconnect.enable = true;
  programs.adb.enable = true;

  # --- NVIDIA TREIBER ---
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

  # --- USER DEFINITION (Aber ohne Pakete!) ---
  users.users.meo = { 
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" "adbusers" ];
    shell = pkgs.zsh; # ZSH als Standard Shell
  };

  # Fonts
  fonts.packages = with pkgs; [
    font-awesome        
    nerd-fonts.jetbrains-mono
  ];

  programs.steam.enable = true;
  
  # Zsh Systemweit aktivieren (nötig für Pfade)
  programs.zsh.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "24.05"; 
}
