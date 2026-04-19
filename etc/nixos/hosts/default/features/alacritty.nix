{ ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      terminal.shell.program = "zsh";
      font.size = 10;
    };
  };
}
