{
  description = "My system config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colors.url = "github:misterio77/nix-colors";
    mywm.url = "github:dowlandaiello/mywm";
    proselint.url = "github:dowlandaiello/proselint.nix";
  };

  outputs = { self, nixpkgs, ... }: {
    nixosModules.default = ./etc/nixos/hosts/default/configuration.nix;
    checks = {
      check-config-build = (nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit (self) inputs; # or just 'inherit inputs;' depending on scope
        };
        modules = [
          self.nixosModules.default
          self.inputs.nixos-hardware.nixosModules.framework-16-7040-amd
          ({ config, pkgs, ... }: {
            nixpkgs.config.allowUnfree = true;
          })
        ];
      }).config.system.build.toplevel;
    };
  };
}
