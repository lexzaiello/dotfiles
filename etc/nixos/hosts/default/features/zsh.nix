{ pkgs, inputs, ... }:

let
  system = "x86_64-linux";
in {
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "direnv" ];
      theme = "robbyrussell";
    };
  };
}
