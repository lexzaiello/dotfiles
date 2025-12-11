{ ... }:

let
  font = import ./font.nix;
  colorscheme = import ./colorscheme.nix;
in

{
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "${font}";
          style = "Light";
        };
        bold = {
          family = "${font}";
          style = "Medium";
        };
        italic = {
          family = "${font}";
          style = "Light Italic";
        };
        size = 5;
      };
      colors = {
        bright = {
          black = "${colorscheme.palette.base00}";
          blue = "${colorscheme.palette.base0D}";
          cyan = "${colorscheme.palette.base0C}";
          green = "${colorscheme.palette.base0B}";
          magenta = "${colorscheme.palette.base0E}";
          red = "${colorscheme.palette.base08}";
          white = "${colorscheme.palette.base06}";
          yellow = "${colorscheme.palette.base09}";
        };
        cursor = {
          cursor = "${colorscheme.palette.base06}";
          text = "${colorscheme.palette.base06}";
        };
        normal = {
          black = "${colorscheme.palette.base00}";
          blue = "${colorscheme.palette.base0D}";
          cyan = "${colorscheme.palette.base0C}";
          green = "${colorscheme.palette.base0B}";
          magenta = "${colorscheme.palette.base0E}";
          red = "${colorscheme.palette.base08}";
          white = "${colorscheme.palette.base06}";
          yellow = "${colorscheme.palette.base0A}";
        };
        primary = {
          background = "${colorscheme.palette.base00}";
          foreground = "${colorscheme.palette.base01}";
        };
      };
      terminal.shell.program = "nu";
    };
  };
}
