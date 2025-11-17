{ config, pkgs, inputs,  ... }:

let
  # Nixpkgs-Branch mit Howdy-Modul & -Package
  howdyRepo = builtins.fetchTarball
    "https://api.github.com/repos/fufexan/nixpkgs/tarball/howdy";

  # Paket-Set aus diesem Repo, mit gleichem System wie dein aktuelles pkgs
  howdyPkgs = import howdyRepo {
    system = pkgs.stdenv.hostPlatform.system;
  };
in
{
  imports =
    [
      # Importiert die Hardware-Erkennung (wichtig!)
      ./hardware-configuration.nix

      # Importiert das Howdy-NixOS-Modul
      "${howdyRepo}/nixos/modules/services/security/howdy/default.nix"
      # Wenn du den IR-Emitter brauchst, zusätzlich:
      # "${howdyRepo}/nixos/modules/services/misc/linux-enable-ir-emitter.nix"
    ];

  # Howdy-Pakete aus dem Fork in dein pkgs einhängen
  nixpkgs.overlays = [
    (final: prev: {
      howdy = howdyPkgs.howdy;
      linux-enable-ir-emitter = howdyPkgs.linux-enable-ir-emitter;
    })
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

  services.howdy = {
    enable = true;
    device = "/dev/video0"; # ggf. anpassen, `v4l2-ctl --list-devices`
  };
  
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

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.kdeconnect.enable = true;
  programs.adb.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

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
