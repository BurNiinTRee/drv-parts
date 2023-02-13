{
  config,
  lib,
  ...
}: let
  l = lib // builtins;
  t = l.types;

  forwardedOptions = {
    depsDrvs = lib.mkOption {
      description = {
      };
      type = t.attrs;
      default = l.mapAttrs (mod: mod.final.derivation) config.deps;
    };
    # basic arguments
    builder = lib.mkOption {
      type = t.oneOf [t.str t.path t.package];
    };
    name = lib.mkOption {
      type = t.str;
    };
    system = lib.mkOption {
      type = t.str;
    };
  };
in rec {
  imports = [
    ../derivation-common/interface.nix
  ];

  # signal that all options should be passed to the final derivation function
  config.argsForward = l.mapAttrs (_: _: true) forwardedOptions;

  options =
    forwardedOptions
    // {
      depsDrvs = lib.mkOption {
        description = {
        };
        type = t.attrs;
        default = l.mapAttrs (mod: mod.final.derivation) config.deps;
      };
    };
}
