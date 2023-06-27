{hive}: {
  inputs,
  config,
  options,
  lib,
  ...
}: let
  inherit
    (hive)
    collect
    ;
  inherit
    (lib)
    mkIf
    genAttrs
    mkOption
    literalExpression
    ;

  std-opt = options.std;
  opt = options.hive;
  cfg = config.hive;
in {
  _file = ./hive-flake-module.nix;
  options = {
    hive = {
      collect = mkOption {
        type = with lib.types; listOf str;
        example = literalExpression ''[ "nixosConfigurations" ]; '';
      };
    };
  };
  config = {
    flake = mkIf (opt.collect.isDefined && std-opt.grow.isDefined) (genAttrs cfg.collect (n: collect inputs.self n));
    perInput = system: flake: {hives = flake.${system} or {};};
  };
}
