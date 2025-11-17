{
  description = "NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    # nixpkgs fork that contains howdy + module
    nixpkgs-howdy.url = "github:fufexan/nixpkgs/howdy";
  };

  # `inputs@{ ... }` -> damit `inputs` in specialArgs verfügbar ist
  outputs = inputs@{ self, nixpkgs, nixpkgs-howdy, ... }: let
    system = "x86_64-linux";
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;

      # Damit du in configuration.nix z.B. `inputs.zen-browser` benutzen kannst
      specialArgs = { inherit inputs; };

      modules = [
        ./configuration.nix

        # Extra inline module that wires in Howdy
        ({ ... }: let
          # Package set from the howdy fork
          howdyPkgs = nixpkgs-howdy.legacyPackages.${system};
        in {
          # 1) Import the Howdy NixOS module
          imports = [
            "${nixpkgs-howdy}/nixos/modules/services/security/howdy/default.nix"
            # Wenn deine IR-Kamera den Emitter braucht:
            # "${nixpkgs-howdy}/nixos/modules/services/misc/linux-enable-ir-emitter.nix"
          ];

          # 2) Overlay the howdy packages so you can use them as pkgs.howdy
          nixpkgs.overlays = [
            (final: prev: {
              howdy = howdyPkgs.howdy;
              linux-enable-ir-emitter = howdyPkgs.linux-enable-ir-emitter;
            })
          ];
        })
      ];
    };
  };
}
