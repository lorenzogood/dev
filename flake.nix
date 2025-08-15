{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra/3.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    systems.url = "github:nix-systems/default";
  };

  outputs = inputs @ {self, ...}:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} (toplevel @ {withSystem, ...}: let
      getPackages = system:
        import inputs.nixpkgs {
          localSystem = system;
          config = {
            allowUnfree = true;
            allowAliases = true;
          };

          overlays = [
          ];
        };
    in {
      systems = ["aarch64-linux" "aarch64-linux" "x86_64-linux"];

      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        _module.args.pkgs = getPackages system;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [inputs'.home-manager.packages.default];
        };

        formatter = inputs'.alejandra.packages.default;
      };

      flake = {
        lib = import ./lib;

        homeConfigurations.default = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = getPackages "x86_64-linux";
          modules = [
            self.homeModules.default
            self.homeModules.nvim
            self.homeModules.graphical
            {
              home = {
                username = "foehammer";
                uid = 1000;

                homeDirectory = "/home/foehammer";
                stateVersion = "24.11";
              };
            }
          ];
        };

        homeModules = {
          default = {...}: {
            imports = self.lib.utils.findNixFiles ./common;
          };

          nvim = {...}: {
            imports = [./nvim/default.nix];
          };

          graphical = {...}: {
            imports = self.lib.utils.findNixFiles ./graphical;
          };
        };
      };
    });
}
