{
  inputs,
  cell,
}: {
  mkMyEmacs = {
    init-el-paths,
    emacsPackage,
  }: let
    inherit (builtins) concatStringsSep map readFile;
    parse = inputs.nixpkgs.callPackage "${inputs.emacs-overlay}/parse.nix" {};
    readFiles = map (x: readFile x.outPath);
    mkConfig = filePaths: concatStringsSep "\n" (readFiles filePaths);
  in
    inputs.emacs-overlay.lib.emacsWithPackagesFromUsePackage {
      package = emacsPackage;
      config = mkConfig init-el-paths;
      defaultInitFile = true;
      alwaysEnsure = true;
      override = epkgs: (import ./../packages/epkgs {
        inherit epkgs;
        inherit (inputs.nixpkgs) callPackage lib;
        inherit (parse) parsePackagesFromPackageRequires;
      });
      extraEmacsPackages = epkgs: [
        epkgs.bind-key
        epkgs.use-package
        epkgs.diminish
        epkgs.delight
        epkgs.org-contrib
        epkgs.vterm
        epkgs.treesit-grammars.with-all-grammars
      ];
    };
}
