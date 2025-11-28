{ config, pkgs, inputs, ... }:

{
  home.username = "meo";
  home.homeDirectory = "/home/meo";

  # --- DOTFILES SYNC ---
  xdg.configFile = {
    "kitty".source = ./dotfiles/kitty;
    "waybar".source = ./dotfiles/waybar;
    "hypr".source = ./dotfiles/hypr;
    "wofi".source = ./dotfiles/wofi;
    "swaync".source = ./dotfiles/swaync;
    "Thunar".source = ./dotfiles/Thunar;
    "yazi/yazi.toml".source = pkgs.lib.mkForce ./dotfiles/yazi/yazi.toml;
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
     ghostty # Jetzt einfach aus dem Standard-Repo
     #(yazi.override { _7zz = pkgs._7zz-rar; }) # Yazi mit RAR Support
     
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
     #helix
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

  # --- PROGRAMME MIT STYLIX SUPPORT ---
  
  # Helix Editor
  programs.helix = {
    enable = true;
    # Hier kannst du deine Helix-Einstellungen direkt in Nix machen
    settings = {
      editor = {
        line-number = "relative";
        mouse = false;
        # Stylix setzt das Theme automatisch, wir müssen es hier nicht angeben!
      };
    };
  };

  # Yazi File Manager
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    # Hier übergeben wir deine spezielle Version mit RAR-Support
    package = pkgs.yazi.override { _7zz = pkgs._7zz-rar; };
    
    # Stylix erstellt automatisch die theme.toml für Yazi!
    settings = {
      manager = {
        show_hidden = true;
        sort_by = "modified";
        sort_dir_first = true;
      };
    };
  };


# --- ZSH KONFIGURATION ---
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    shellAliases = {
      # System
      update = "sudo nixos-rebuild switch --flake ~/nixos-config";
      
      # Eza (besseres ls) - mit Icons und Git-Status
      ls = "eza --icons=always --group-directories-first";
      ll = "eza -al --icons=always --group-directories-first";
      tree = "eza --tree --icons=always";
      
      # Fastfetch statt Neofetch
      neofetch = "fastfetch";
      ff = "fastfetch";
      
      # Editor
      v = "nvim"; # oder "hx" für Helix, je nachdem was du nutzt
    };

    # Start-Skript (wird bei jedem Terminal-Öffnen ausgeführt)
    initExtra = ''
      fastfetch # Zeigt beim Start direkt das Logo an
    '';

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
