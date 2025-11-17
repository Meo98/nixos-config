{ config, pkgs, inputs,  ... }:

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

  # Bluetooth und weiteres
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Tastatur auf der Konsole (TTY)
  console.keyMap = "sg"; 

  services.howdy = {
    enable = true;

    # adjust to your camera device, check with: v4l2-ctl --list-devices
    device = "/dev/video0";

    # optional: tune more settings via the module once it’s imported
    # e.g.:
    # threshold = 3.5;
  };

  # Tastatur im grafischen System (X11/Wayland)
  services.xserver.xkb = {
    layout = "ch";
    variant = "";
  };

  # --- GRAFIK & HYPRLAND ---
  # Display Manager (SDDM)
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "catppuccin-mocha"; # <--- Hier setzen wir das Theme
    package = pkgs.kdePackages.sddm; # Nutzen wir die moderne Version
  };
  # Hyprland aktivieren
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

    # --- Handy-Verbindung ---
  programs.kdeconnect = {
    enable = true;
  };

  # --- Android Debug Bridge (für Scrcpy) ---
  programs.adb.enable = true;

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
    extraGroups = [ "networkmanager" "wheel" "video" "adbusers" ];
    packages = with pkgs; [
      # GUI Tools
      kitty             # Terminal
      starship
      xfce.thunar       # Datei-Manager
      wofi              # App Launcher (Startmenü)
      waybar            # Statusleiste
      playerctl
      swaynotificationcenter # Quick Settings & Nachrichten
      hyprlock              # Der Lockscreen
      hypridle              # Damit der Lockscreen automatisch angeht
      libnotify             # Damit Apps Nachrichten senden können
      brightnessctl         # Steuert die Helligkeit
      blueman               # Bluetooth Manager
      networkmanagerapplet  # WLAN Manager (nm-connection- editor)
      helix
      nil           # Nix Language Server (für deine config.nix!)
      python3       # Python
      pyright       # Python Language Server
      rust-analyzer # Rust
      wl-clipboard  # WICHTIG für Hyprland Clipboard
      bitwarden-desktop

      # --- NEU: Screen Mirroring Tool ---
      scrcpy
      
      # Der Zen Browser (aus dem Flake Input)
      inputs.zen-browser.packages."${pkgs.system}".default # <-- Chrome statt Firefox

      # Deine Apps
      rclone            # Google Drive
      bottles           # Windows Apps
      git
      pavucontrol
      swayosd
      tidal-hifi

      
      # Das Theme für den Login-Screen
      (catppuccin-sddm.override {
        flavor = "mocha";
        font  = "JetBrainsMono Nerd Font";
        loginBackground = true;
     }) 
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
