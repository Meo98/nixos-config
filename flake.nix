{
  description = "Meine Zaney-Inspired NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix";

    # Deine Apps
    ghostty.url = "github:ghostty-org/ghostty";
    yazi.url = "github:sxyazi/yazi";
  };

  outputs = { self, nixpkgs, home-manager, stylix, ... }@inputs: 
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations = {
      # Dein Hostname ist "nixos"
      nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          # HIER HABEN WIR DEN PFAD KORRIGIERT:
          ./hosts/default/configuration.nix 
          
          # ./options.nix  <-- Das liegt noch im Hauptordner, falls du es nutzen willst
          
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            
            # HIER AUCH KORRIGIERT:
            home-manager.users."meo" = import ./hosts/default/home.nix;
            
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
    };
  };
}
