{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "nixpkgs/nixos-unstable";
    drv-parts.url = "github:DavHau/drv-parts";
  };

  outputs = {
    self,
    flake-parts,
    drv-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      # enable the drv-parts plugin for flake-parts
      imports = [drv-parts.flakeModule];

      perSystem = {config, pkgs, system, ...}: {
        checks = config.packages;
        drvs.test = {

          # select mkDerivation as a backend for this package
          imports = [drv-parts.modules.drv-parts.derivation];

          # set options
          name = "test";
          builder = "/bin/sh";
          args = ["-c" "echo $name > $out"];
          system = system;
        };
      };
    };
}
