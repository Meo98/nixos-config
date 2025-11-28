{ lib, ... }:

with lib;
{
  options = {
    username = mkOption {
      type = types.str;
      default = "meo"; # <--- HIER DEINEN USER EINTRAGEN
      description = "Der Benutzername";
    };
    hostname = mkOption {
      type = types.str;
      default = "default"; # So heißt dein Host-Ordner aktuell
      description = "Der Hostname";
    };
    theme = mkOption {
      type = types.str;
      default = "catppuccin-mocha"; # Das Zaney-Standard-Theme
      description = "Das Farbschema für Stylix";
    };
  };
}
