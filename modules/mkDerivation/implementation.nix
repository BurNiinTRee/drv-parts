{
  config,
  lib,
  ...
}: let
  l = lib // builtins;
  t = l.types;
in {
  imports = [
    ../derivation-common/implementation.nix
  ];
  config.final.derivation = lib.mkDefault
    (config.stdenv.mkDerivation config.final.derivation-args);
}
