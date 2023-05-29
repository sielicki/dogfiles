{
  lib,
  callPackage,
  epkgs,
  parsePackagesFromPackageRequires,
}:
lib.concatMapAttrs (k: v: {
  ${k} = epkgs.trivialBuild (v
    // {
      name = "${k}";
      packageRequires = (builtins.map (n: epkgs.${n}) (builtins.trace "${v.src}/${v.pname}.el}" (parsePackagesFromPackageRequires (builtins.readFile "${v.src}/${v.pname}.el")))) ++ [epkgs.dash epkgs.s];
    });
}) (callPackage ./_sources/generated.nix {})
