{ config, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      inputs.oblichey.nixosModules.default
    ];

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

  # Bluetooth und weiteres
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Tastatur auf der Konsole (TTY)
  console.keyMap = "sg"; 

  # Tastatur im grafischen System (X11/Wayland)
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

    programs.oblichey = {
    enable = true;

    # In welchen PAM-Services Oblichey greifen soll:
    pamServices = [ "sudo" "login" ];
    # später kannst du hier z.B. auch "hyprlock" reinnehmen

    settings = {
      camera = {
        path = "/dev/video2"; # ggf. anpassen (siehe nächster Abschnitt)
      };
      # hier könntest du weitere Settings ergänzen, falls nötig
    };
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.sessionVariables = rec {
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";
    NIXOS_OZONE_WL = "1";
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
      kitty
      starship
      xfce.thunar
      wofi
      waybar
      playerctl
      swaynotificationcenter
      hyprlock
      hypridle
      libnotify
      brightnessctl
      blueman
      networkmanagerapplet
      helix
      nil
      python3
      pyright
      rust-analyzer
      wl-clipboard
      bitwarden-desktop
      scrcpy

      inputs.zen-browser.packages."${pkgs.system}".default

      rclone
      bottles
      git
      pavucontrol
      swayosd
      tidal-hifi

      (catppuccin-sddm.override {
        flavor = "mocha";
        font  = "JetBrainsMono Nerd Font";
        loginBackground = true;
      })
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

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.05"; 
}
