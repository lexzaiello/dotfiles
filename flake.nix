{
  description = "My system config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixos-hardware }: {
    nixosModules.default = ./etc/nixos/hosts/default/configuration.nix;
    checks = {
      check-config-build = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.default
          nixos-hardware.nixosModules.framework-16-7040-amd
          ({ config, pkgs, ... }: {
            nixpkgs.config.allowUnfree = true;
          })
        ];
      };
    };
  };
}
