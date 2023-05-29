{
  description = "sielicki personal emacs configuration.";

  nixConfig = {
    extra-trusted-substituters = [ "https://nix-community.cachix.org" "https://numtide.cachix.org" "https://sielicki.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      "sielicki.cachix.org-1:zeCLX9Sp6858+YldvEY1gKB9Qd10Y/dK6YEQN+HsXZk="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
    nvfetcher.url = "github:berberman/nvfetcher";
  };

  outputs = inputs @ {
    self,
    flake-parts,
    emacs-overlay,
    pre-commit-hooks,
    nvfetcher,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;}
    {
      imports = [
        inputs.pre-commit-hooks.flakeModule
      ];
      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux" ];
      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ inputs.emacs-overlay.overlays.default ];
          config = {};
        };
        pre-commit = {
          check.enable = true;
          settings.hooks = {
            shfmt.enable = true;
            shellcheck.enable = true;
            alejandra.enable = true;
            deadnix.enable = true;
            deadnix.excludes = ["pkgs/_sources/generated.nix"];
            nil.enable = true;
          };
        };
        packages = let
          parse = pkgs.callPackage "${inputs.emacs-overlay}/parse.nix" {};
          substitutedConfig = builtins.readFile (pkgs.substituteAll {
              src = ./emacs.el;
              dashboardLogo = ./static/imagine_happy.svg;
          }).outPath;
          overriddenEmacs = pkgs.emacsUnstable.override { siteStart = ./static/site-start.el; }; 
          emacs = pkgs.emacsWithPackagesFromUsePackage {
            package = overriddenEmacs;
            config = substitutedConfig;
            defaultInitFile = true;
            alwaysEnsure = true;
            override = epkgs: (import ./pkgs {
              inherit epkgs;
              inherit (pkgs) callPackage lib;
              inherit (parse) parsePackagesFromPackageRequires;
            });
            extraEmacsPackages = epkgs: [
              epkgs.bind-key
              epkgs.use-package
              epkgs.org-contrib
            ];
          };
        in {
          inherit emacs;
          bump-nvfetchers = pkgs.writeShellScriptBin "bump-nvfetchers" ''
            echo "${inputs.nvfetcher.packages.${system}.default}/bin/nvfetcher -o $1/pkgs/_sources -c $1/pkgs/nvfetcher.toml"
            ${inputs.nvfetcher.packages.${system}.default}/bin/nvfetcher -o $1/pkgs/_sources -c $1/pkgs/nvfetcher.toml
          '';
          default = emacs;
        };
        devShells.default = config.pre-commit.devShell;
      };
      flake = {
      };
    };
}
