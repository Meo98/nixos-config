{ config, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../options.nix
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

  # --- GRAFIK & LOGIN ---
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    package = pkgs.kdePackages.sddm; # Qt6 Version (aktuell)
    
    # Das Theme aktivieren
    theme = "catppuccin-mocha";
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  
  # --- SYSTEM-PAKETE (Für Dinge, die vor dem Login da sein müssen) ---
  environment.systemPackages = with pkgs; [
    # Das Theme muss HIER stehen, damit SDDM es findet!
    (catppuccin-sddm.override {
      flavor = "mocha";
      font  = "JetBrainsMono Nerd Font";
      loginBackground = true;
    })
    
    # Wichtig für den Mauszeiger im Login-Screen
    bibata-cursors 
  ];
  
  # Mauszeiger für SDDM erzwingen
  environment.variables = {
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
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
    
    # HIER IST DIE ÄNDERUNG:
    # Das muss auf TRUE stehen, damit Suspend/Sleep funktioniert!
    powerManagement.enable = true;  
    
    # Finegrained kann auf false bleiben (ist für komplettes Abschalten der GPU)
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


# --- STYLIX SETUP ---
  stylix.enable = true;
  
  # WICHTIG: Stelle sicher, dass wallpaper.jpg im selben Ordner liegt!
  stylix.image = ./wallpaper.jpg; 
  
  # Wir schreiben "catppuccin-mocha" direkt rein, statt ${config.theme}
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  stylix.polarity = "dark";
  
  # Stylix konfiguriert die Schriftarten UND installiert sie
  stylix.fonts = {
    serif = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Serif";
    };
    sansSerif = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Sans";
    };
    monospace = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font Mono";
    };
  };

  # --- USER DEFINITION ---
  # Das muss BLEIBEN, Stylix erstellt keine User.
  users.users.meo = { 
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" "adbusers" ];
    shell = pkgs.zsh; 
  };

  # --- FONTS ---
  # JetBrains Mono haben wir hier gelöscht, da Stylix es oben schon lädt.
  # Font-Awesome lassen wir drin, falls du spezielle Icons brauchst.
  fonts.packages = with pkgs; [
    font-awesome        
  ];
  programs.steam.enable = true;
  
  # Zsh Systemweit aktivieren (nötig für Pfade)
  programs.zsh.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "24.05"; 
}
