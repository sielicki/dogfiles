{
  inputs,
  cell,
}: {
  dogleg = {pkgs, ...}: {
    bee = let
      system = "aarch64-darwin";
    in {
      inherit system;
      darwin = inputs.darwin;
      home = inputs.home;
      pkgs = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
        overlays = [];
      };
    };

    networking.hostName = "dogleg";

    users.users.sielicki = {
      shell = pkgs.zsh;
      description = "Nicholas Sielicki";
      home = "/Users/sielicki";
    };

    home-manager.users.sielicki = {imports = with cell.homeProfiles; [base personal graphical];};

    security.pam.enableSudoTouchIdAuth = true;

    environment.systemPackages = [
      pkgs.vim
      pkgs.git
      pkgs.gcc
      pkgs.alacritty
      pkgs.direnv
      pkgs.xcbuild
      pkgs.python3

      pkgs.raycast
      pkgs.discord
      pkgs.spotify

      inputs.cells.emacs.packages.my-emacs
    ];

    services.emacs = {
      enable = true;
      package = inputs.cells.emacs.packages.my-emacs;
    };

    services.nix-daemon.enable = true;
    nix.package = pkgs.nix;
    nix = {
      configureBuildUsers = true;
      settings = {
        trusted-users = ["@admin"];
        allowed-users = ["@wheel" "@admin" "root"];
        experimental-features = ["nix-command" "flakes"];
        accept-flake-config = true;
        auto-optimise-store = false;
        trusted-substituters = [
          "https://numtide.cachix.org"
          "https://nix-community.cachix.org"
          "https://sielicki.cachix.org"
        ];
        trusted-public-keys = [
          "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "sielicki.cachix.org-1:zeCLX9Sp6858+YldvEY1gKB9Qd10Y/dK6YEQN+HsXZk="
        ];
      };
      useDaemon = true;
    };

    fonts = {
      fontDir.enable = true;
      fonts = [pkgs.nerdfonts];
    };

    programs.zsh.enable = true;
    system.stateVersion = 4;
  };
}
