{ config, pkgs, inputs, ... }:

{
  home.username = "meo";
  home.homeDirectory = "/home/meo";

  # --- DOTFILES SYNC ---
  xdg.configFile = {
    "kitty".source = ./dotfiles/kitty;
    "helix".source = ./dotfiles/helix;
    "waybar".source = ./dotfiles/waybar;
    "hypr".source = ./dotfiles/hypr;
    "wofi".source = ./dotfiles/wofi;
    "swaync".source = ./dotfiles/swaync;
    "Thunar".source = ./dotfiles/Thunar;
    
    # "vivaldi" WURDE ENTFERNT (Verursachte den Fehler)
    
    "tidal-hifi".source = ./dotfiles/tidal-hifi;
  };

  # --- PAKETE ---
  home.packages = with pkgs; [
     # GUI Tools
     kitty                
     xfce.thunar
     wofi
     waybar
     swaynotificationcenter
     networkmanagerapplet
     blueman
     bitwarden-desktop
     bottles
     bibata-cursors
     starship
     hyprshot
     
     # Ghostty & Yazi
     inputs.ghostty.packages.${pkgs.system}.default
     (inputs.yazi.packages.${pkgs.system}.default.override { _7zz = pkgs._7zz-rar; })
     
     # Audio
     pavucontrol        
     alsa-utils         
     playerctl          

     # System & Power
     btop                
     wlogout             
  
     # Browser
     vivaldi
     
     # Hyprland Tools
     hyprlock
     hypridle
     libnotify
     brightnessctl
     wl-clipboard
     swayosd

     # Dev / CLI
     git
     helix
     nil
     python3
     pyright
     rust-analyzer
     rclone
     scrcpy
     remmina
     insync
     gparted
     mods
     
     # Misc
     tidal-hifi
     wasistlos
  ];

  # --- ZSH KONFIGURATION (User Level) ---
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch --flake ~/nixos-config";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "history" ];
    };
  };

  # --- STARSHIP ---
  programs.starship = {
    enable = true;
  };

  # Version nicht ändern
  home.stateVersion = "24.05";
}
