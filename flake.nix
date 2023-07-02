{
  description = "On the internet, nobody knows you're a dog.";

  outputs = inputs @ {...}:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} ({flake-parts-lib, ...}: let
      inherit (flake-parts-lib) importApply;
      hiveBlockTypes = with inputs.hive.blockTypes;
      with inputs.std.blockTypes; [
        darwinConfigurations
        homeConfigurations
        (functions "homeProfiles")
      ];
      flakeModules.hive = importApply ./hive-flake-module.nix {inherit (inputs) hive;};
    in {
      imports = [
        flakeModules.hive

        inputs.std.flakeModule
        inputs.treefmt-nix.flakeModule
        inputs.devenv.flakeModule
      ];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        config,
        system,
        ...
      }: {
        treefmt.programs.alejandra.enable = true;
        treefmt.projectRootFile = ".git/config";
        devenv.shells.default = {
          pre-commit = {
            hooks = {
              shfmt.enable = true;
              shellcheck.enable = true;
              alejandra.enable = true;
              deadnix.enable = false;
              deadnix.excludes = ["cells/emacs/packages/epkgs/_sources/generated.nix"];
              nil.enable = true;
              black.enable = true;
              commitizen.enable = true;
            };
          };
          packages = [
            config.treefmt.build.wrapper
            inputs.std.packages.${system}.std
            inputs.colmena.packages.${system}.colmena
            inputs.nvfetcher.packages.${system}.default
          ];
        };
      };
      std = {
        grow = {
          cellsFrom = ./cells;
          cellBlocks =
            hiveBlockTypes
            ++ (with inputs.std.blockTypes; [
              (installables "packages" {ci.build = true;})
            ]);
          nixpkgsConfig = {allowUnfree = true;};
        };
        harvest = {
          packages = [
            ["emacs" "packages"]
          ];
        };
      };
      hive.collect = [
        "darwinConfigurations"
        "homeConfigurations"
      ];
      flake = {default = flakeModules.hive;};
    });

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nvfetcher.url = "github:berberman/nvfetcher";
    nvfetcher.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    haumea.url = "github:nix-community/haumea";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
    std.url = "github:divnix/std";
    std.inputs.nixpkgs.follows = "nixpkgs";

    colmena.url = "github:zhaofengli/colmena";
    hive.url = "github:divnix/hive";
    hive.inputs.nixpkgs.follows = "nixpkgs";
    hive.inputs.colmena.follows = "colmena";

    home.url = "github:nix-community/home-manager";
    home.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
  };

  nixConfig = {
    extra-substituters = [
      "https://numtide.cachix.org"
      "https://nix-community.cachix.org"
      "https://sielicki.cachix.org"
    ];
    extra-trusted-public-keys = [
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "sielicki.cachix.org-1:zeCLX9Sp6858+YldvEY1gKB9Qd10Y/dK6YEQN+HsXZk="
    ];
  };
}
