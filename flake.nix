{
  description = "Meos NixOS Flake";

  inputs = {
    # Wir nutzen die Unstable-Version für aktuelles Hyprland & Treiber
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      # "nixos" muss mit networking.hostName in configuration.nix übereinstimmen
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
