{
  description = "My system config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = ./etc/nixos/hosts/default/configuration.nix;
  };
}
