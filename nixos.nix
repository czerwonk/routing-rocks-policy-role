{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.routing-rocks.bird2;
  birdConfig = (pkgs.callPackage ./package.nix {
    vars = cfg.configYML;
    as-sets = cfg.asSets;
  });

in {
  options = {
    routing-rocks.bird2 = {
      enable = mkEnableOption "Bird Routing Daemon";
      asSets = mkOption {
        type = types.lines;
        default = "";
        description = "AS sets in bird config format";
        example = ''
          define AS_FFE = [
            2a0c:efc0::/29
          ];
        '';
      };
      configYML = mkOption {
        type = types.lines;
        description = ''
          Configuration for routing-rocks policy
          (see https://github.com/czerwonk/routing-rocks-policy-role)

          This YAML based config is used as datasource to build the bird configuration
        '';
      };
    };
  }; 
 
  config = mkIf cfg.enable {
    services.bird2 = {
      enable = true;
      checkConfig = true;
      config = (builtins.readFile "${birdConfig}/bird.conf");
    };
  };
}
