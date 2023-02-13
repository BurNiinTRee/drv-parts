{
  config,
  lib,
  options,
  ...
}: let
  l = lib // builtins;
  t = l.types;

  makeLegacyModule = pkg: ({config, ...}: {
    options = {
      overrideAttrs = l.mkOption {
        type = t.nullOr (t.listOf (t.functionTo t.attrs));
        apply = x: if l.isNull x then x else l.toList x;
        default = null;
      };
      override = l.mkOption {
        type = t.nullOr t.attrs;
        default = null;
      };
      rootPkg = l.mkOption {
        type = t.attrs;
        default = pkg;
      };
    };
    config = let
      mergedOverrideAttrs =
        l.foldl
        (prev: this: x: this (prev x))
        l.id
        config.overrideAttrs;
      overriddenPackage = if l.isNull config.override then config.rootPkg else config.rootPkg.override config.override;
      attrOverriddenPackage = if l.isNull config.overrideAttrs then overriddenPackage else overriddenPackage.overrideAttrs mergedOverrideAttrs;
    in {
      rootPkg = pkg;
      final.derivation = attrOverriddenPackage;
    };
  });

  passAsFile =
    if config.passAsFile == null
    then {}
    else l.genAttrs config.passAsFile (var: true);

  keepArg = key: val:
    (config.argsForward.${key} or false || passAsFile ? ${key})
    && (val != null);

  finalArgs = l.filterAttrs keepArg config;

  # esure that none of the env variables collides with the top-level options
  envChecked =
    l.mapAttrs
    (key: val:
      if config.argsForward.${key} or false
      then throw (envCollisionError key)
      else val)
    config.env;

  drvDebugName =
    if config ? name && config.name != null
    then config.name
    else config.pname;

  # generates error message for env variable collision
  envCollisionError = key: ''
    Error while evaluating definitions for derivation ${drvDebugName}
    The environment variable defined via `env.${key}' collides with the top-level option `${key}'.
    Specify the top-level option instead, or rename the environment variable.
  '';

  # all args that are passed directly to mkDerivation
  args =
    finalArgs
    // envChecked;
in {
  config.deps = l.mapAttrs (_: makeLegacyModule) config.depsLegacy;
  config.final.derivation-args = args;
}
