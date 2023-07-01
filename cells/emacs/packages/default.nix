{
  inputs,
  cell,
  ...
}: let
  baseOverride = inputs.emacs-overlay.packages.emacs-unstable.override {
    withNS = true;
    withTreeSitter = true;
    siteStart = ./static/site-start.el;
  };
  emacs-config = inputs.nixpkgs.substituteAll {
    src = ./emacs.el;
    dashboardLogo = ./static/imagine_happy.svg;
  };
  emacs-plus = baseOverride.overrideAttrs (old: {
    configureFlags = old.configureFlags ++ ["--with-poll"];
    patches =
      (old.patches or [])
      ++ [
        (inputs.nixpkgs.fetchpatch {
          url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/no-frame-refocus-cocoa.patch";
          sha256 = "sha256-QLGplGoRpM4qgrIAJIbVJJsa4xj34axwT3LiWt++j/c=";
        })
        (inputs.nixpkgs.fetchpatch {
          url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/fix-window-role.patch";
          sha256 = "sha256-+z/KfsBm1lvZTZNiMbxzXQGRTjkCFO4QPlEK35upjsE=";
        })
        (inputs.nixpkgs.fetchpatch {
          url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-29/poll.patch";
          sha256 = "sha256-jN9MlD8/ZrnLuP2/HUXXEVVd6A+aRZNYFdZF8ReJGfY=";
        })
        (inputs.nixpkgs.fetchpatch {
          url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-29/round-undecorated-frame.patch";
          sha256 = "sha256-uYIxNTyfbprx5mCqMNFVrBcLeo+8e21qmBE3lpcnd+4=";
        })
        (inputs.nixpkgs.fetchpatch {
          url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/system-appearance.patch";
          sha256 = "sha256-oM6fXdXCWVcBnNrzXmF0ZMdp8j0pzkLE66WteeCutv8=";
        })
      ];
    postFixup =
      (old.postFixup or '''')
      + ''
        rm $out/bin/ctags
        rm $out/bin/etags
        ln -sf ${inputs.nixpkgs.universal-ctags}/bin/ctags $out/bin/ctags
        ln -sf ${inputs.nixpkgs.universal-ctags}/bin/readtags $out/bin/readtags
        ln -sf ${inputs.nixpkgs.universal-ctags}/bin/optscript $out/bin/optscript
      '';
    # is this necessary?
    propagatedBuildInputs =
      (old.propagatedBuildInputs or [])
      ++ [
        inputs.nixpkgs.universal-ctags
      ];
  });
  my-emacs = cell.lib.mkMyEmacs {
    init-el-paths = [emacs-config];
    emacsPackage = emacs-plus;
  };
in {inherit my-emacs emacs-config emacs-plus;}
