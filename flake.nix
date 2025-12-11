{
  description = "My system config";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs?rev=addf7cf5f383a3101ecfba091b98d0a1263dc9b8";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/43ffe9ac82567512abb83187cb673de1091bdfa8";
  };

  outputs = inputs@{ nixpkgs, ... }: let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        pulseaudio = true;
      };
    };
    defaultModule = ./etc/nixos/hosts/default/configuration.nix;
  in {
    nixosModules.default = defaultModule;
    checks = {
      x86_64-linux.check-config-build = (lib.nixosSystem {
        inherit system;
        inherit pkgs;
        specialArgs = {
          inputs = inputs;
        };
        modules = [
          defaultModule
          inputs.nixos-hardware.nixosModules.framework-16-7040-amd
        ];
      }).config.system.build.toplevel;
    };
  };
}
