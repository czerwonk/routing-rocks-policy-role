{
  description = "routing-rocks routing policy";

  outputs =
    { self }:
    {
      nixosModule = import ./nixos.nix;
    };
}
