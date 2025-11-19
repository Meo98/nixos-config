{
  description = "NixOS Config mit COSMIC und Zen";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 1. Zen Browser Input hinzufügen
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs = { self, nixpkgs, nixos-cosmic, zen-browser, ... }@inputs: {
    nixosConfigurations = {
      nixos  = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        
        # WICHTIG: 'inputs' muss hier durchgereicht werden, 
        # damit wir es in configuration.nix nutzen können.
        specialArgs = { inherit inputs; };
        
        modules = [
          {
            nix.settings = {
              substituters = [ "https://cosmic.cachix.org" ];
              trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
            };
          }
          nixos-cosmic.nixosModules.default
          ./configuration.nix
        ];
      };
    };
  };
}
