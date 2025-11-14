{ config, pkgs, ... }:

{
  imports =
    [ # Importiert die Hardware-Erkennung (wichtig!)
      ./hardware-configuration.nix
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

  # Tastatur auf der Konsole (TTY)
  console.keyMap = "sg"; 

  # Tastatur im grafischen System (X11/Wayland)
  services.xserver.xkb = {
    layout = "ch";
    variant = "";
  };

  # --- GRAFIK & HYPRLAND ---
  # Login Manager (SDDM) aktivieren
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # Hyprland aktivieren
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  
  # Zwingt Apps (Electron) auf Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # --- NVIDIA TREIBER (PRIME OFFLOAD) ---
  nixpkgs.config.allowUnfree = true;
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false; # Wichtig für deinen Laptop Akku!
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # DEINE BUS-IDS (Vom vorherigen Chat)
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
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [
      # GUI Tools
      kitty             # Terminal
      xfce.thunar       # Datei-Manager
      wofi              # App Launcher (Startmenü)
      waybar            # Statusleiste
      swaynotificationcenter # Quick Settings & Nachrichten
      hyprlock              # Der Lockscreen
      hypridle              # Damit der Lockscreen automatisch angeht
      libnotify             # Damit Apps Nachrichten senden können
      dunst             # Benachrichtigungen

      # Browser
      google-chrome     # <-- Chrome statt Firefox

      # Deine Apps
      rclone            # Google Drive
      bottles           # Windows Apps
      notion-app-enhanced
      git
      pavucontrol
      swayosd
    ];
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    font-awesome
  ];

  # Steam
  programs.steam.enable = true;

  # --- BESSERES TERMINAL (ZSH) ---
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # Autosuggestions: Vorschläge basierend auf deiner History (grauer Text)
    autosuggestions.enable = true;
    # Syntax Highlighting: Befehle werden grün (richtig) oder rot (falsch)
    syntaxHighlighting.enable = true;
  };

  # Mache Zsh zur Standard-Shell für alle (oder spezifisch für dich)
  users.defaultUserShell = pkgs.zsh;

  # Flakes aktivieren
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.05"; 
}
