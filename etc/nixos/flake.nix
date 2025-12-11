{
  description = "What the sigma?";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colors.url = "github:misterio77/nix-colors";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    mywm.url = "github:dowlandaiello/mywm";
    proselint.url = "github:dowlandaiello/proselint.nix";
  };

  outputs = { nixpkgs, ... }@inputs:
  {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/default/configuration.nix
        inputs.nixos-hardware.nixosModules.framework-16-7040-amd
        ({ config, pkgs, ... }: {
          nixpkgs.config.allowUnfree = true;
        })
      ];
    };
  };
}
