{ pkgs, inputs, ... }:

let
  system = "x86_64-linux";
in pkgs.stdenv.mkDerivation {
  name = "gruvbox-plus";
  src = pkgs.fetchurl {
    url = "https://github.com/SylEleuth/gruvbox-plus-icon-pack/releases/download/v5.3.1/gruvbox-plus-icon-pack-5.3.1.zip";
    sha256 = "de764de7532fd0c7570b482410a6caad513ef75852dd0482a8d3f20c4f0a26d6";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
    ${pkgs.unzip}/bin/unzip $src -d $out/
  '';
}
