{ inputs, pkgs, ... }:

let
  system = "x86_64-linux";
in {
  gtk = {
    enable = true;
    theme = {
      name = "Gruvbox-Dark-Hard";
      package = pkgs.gruvbox-dark-gtk;
    };
  };
}
