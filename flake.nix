{
  description = "routing-rocks routing policy";

  outputs = { pkgs, ... }: {
    birdConfig = { vars, as-sets }: pkgs.pkgs.callPackage ./default.nix { inherit vars as-sets; };
  };
}
