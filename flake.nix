{
  description = "My system config";

  inputs = {
    nixpkgs = "github:NixOS/nixpkgs/addf7cf5f383a3101ecfba091b98d0a1263dc9b8";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colors.url = "github:misterio77/nix-colors/b01f024090d2c4fc3152cd0cf12027a7b8453ba1";
    nixos-hardware.url = "github:NixOS/nixos-hardware/9154f4569b6cdfd3c595851a6ba51bfaa472d9f3";
  };

  outputs = { self, nixpkgs, ... }: {
    nixosModules.default = ./etc/nixos/hosts/default/configuration.nix;
    checks = {
      x86_64-linux.check-config-build = (nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
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
