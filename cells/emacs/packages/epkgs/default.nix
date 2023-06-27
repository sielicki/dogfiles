{
  lib,
  callPackage,
  epkgs,
  parsePackagesFromPackageRequires,
}: let
  mainElFileName = v: let val = "${v.src.outPath}/${v.pname}.el"; in builtins.traceVerbose "generating nix drv for package with entrypoint: ${val}" val;
  mainElFile = v: (builtins.readFile (mainElFileName v));
  parsePackages = v: let val = parsePackagesFromPackageRequires (mainElFile v); in builtins.traceVerbose "${builtins.toJSON val}" val;
  overrides = import ./specials.nix;
  genTrivial = k: v: {
    ${k} = epkgs.trivialBuild ({
        name = "${k}";
        packageRequires = builtins.map (n: epkgs.${n}) ((parsePackages v)
          ++ (
            if (lib.hasAttrByPath [k "missingRequires"] overrides)
            then overrides.${k}.missingRequires
            else []
          ));
      }
      // v);
  };
in
  lib.concatMapAttrs genTrivial (callPackage ./_sources/generated.nix {})
