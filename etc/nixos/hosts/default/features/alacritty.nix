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
          black = "0x${colorscheme.palette.base00}";
          blue = "0x${colorscheme.palette.base0D}";
          cyan = "0x${colorscheme.palette.base0C}";
          green = "0x${colorscheme.palette.base0B}";
          magenta = "0x${colorscheme.palette.base0E}";
          red = "0x${colorscheme.palette.base08}";
          white = "0x${colorscheme.palette.base06}";
          yellow = "0x${colorscheme.palette.base09}";
        };
        cursor = {
          cursor = "0x${colorscheme.palette.base06}";
          text = "0x${colorscheme.palette.base06}";
        };
        normal = {
          black = "0x${colorscheme.palette.base00}";
          blue = "0x${colorscheme.palette.base0D}";
          cyan = "0x${colorscheme.palette.base0C}";
          green = "0x${colorscheme.palette.base0B}";
          magenta = "0x${colorscheme.palette.base0E}";
          red = "0x${colorscheme.palette.base08}";
          white = "0x${colorscheme.palette.base06}";
          yellow = "0x${colorscheme.palette.base0A}";
        };
        primary = {
          background = "0x${colorscheme.palette.base00}";
          foreground = "0x${colorscheme.palette.base01}";
        };
      };
      terminal.shell.program = "nu";
    };
  };
}
