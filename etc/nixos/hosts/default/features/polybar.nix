{ pkgs, inputs, ... }:

let
  system = "x86_64-linux";
  colorscheme = import ./colorscheme.nix;
  icons = {
    cpu = "CPU: ";
    memory = "RAM: ";
    date = "DATE: ";
    wifi = "WIFI: ";
  };
  fonts = {
    font-0 = "IosevkaTerm Nerd Font:pixelsize=10;1";
    font-1 = "IosevkaTerm Nerd Font:pixelsize=10;1";
    font-2 = "IosevkaTerm Nerd Font:pixelsize=10;1";
    font-3 = "IosevkaTerm Nerd Font:pixelsize=10;1";
    font-4 = "IosevkaTerm Nerd Font:pixelsize=10;1";
    font-5 = "IosevkaTerm Nerd Font:pixelsize=10;1";
  };
in {
  services.polybar = {
    package = pkgs.polybar.override {
      mpdSupport = true;
      pulseSupport = true;
    };
    enable = true;
    config = {
      "bar/main" = fonts // {
        height = 30;
        radius = 0;
        fixed-center = true;

        bottom = false;
        top = true;
        background = "#${colorscheme.palette.base00}";
        foreground = "#${colorscheme.palette.base01}";

        modules-left = "ewmh";

        modules-center = "xwindow";

        module-margin = 3;

        modules-right = "battery date volume filesystem wlan memory cpu";
        override-redirect = true;
        wm-restack = "i3";

        border-bottom-size = 1;
        border-bottom-color = "#${colorscheme.palette.base02}";
        border-top-color = "#${colorscheme.palette.base02}";
        line-size = 1;
      };

      "module/xwindow" = fonts // {
        type = "internal/xwindow";
        label = "%title:0:30:...%";
      };

      "module/cpu" = fonts // {
        type = "internal/cpu";
        interval = 2;

        label = "%percentage:3%%";
        format-prefix = icons.cpu;

        ramp-coreload-0 = "▁";
        ramp-coreload-1 = "▂";
        ramp-coreload-2 = "▃";
        ramp-coreload-3 = "▄";
        ramp-coreload-4 = "▅";
        ramp-coreload-5 = "▆";
        ramp-coreload-6 = "▇";
        ramp-coreload-7 = "█";

        ramp-used-0 = "▁";
        ramp-used-1 = "▂";
        ramp-used-2 = "▃";
        ramp-used-3 = "▄";
        ramp-used-4 = "▅";
        ramp-used-5 = "▆";
        ramp-used-6 = "▇";
        ramp-used-7 = "█";
      };

      "module/filesystem" = {
        type = "internal/fs";
        interval = 10;

        mount-0 = "/";
        label-mounted = "%mountpoint%: %free%";
      };

      "module/volume" = {
        type = "internal/alsa";
        format-volume = "<label-volume> <bar-volume>";
        label-volume = "VOL";

        label-muted = "sound muted";

        bar-volume-width = "10";
        bar-volume-foreground-0 = "#${colorscheme.palette.base04}";
        bar-volume-foreground-1 = "#${colorscheme.palette.base04}";
        bar-volume-foreground-2 = "#${colorscheme.palette.base04}";
        bar-volume-foreground-3 = "#${colorscheme.palette.base04}";
        bar-volume-foreground-4 = "#${colorscheme.palette.base04}";
        bar-volume-foreground-5 = "#${colorscheme.palette.base05}";
        bar-volume-foreground-6 = "#${colorscheme.palette.base06}";
        bar-volume-indicator = "|";
        bar-volume-indicator-font = "2";
        bar-volume-fill = "─";
        bar-volume-fill-font = "2";
        bar-volume-empty = "─";
        bar-volume-empty-font = "2";
      };

      "module/wlan" = {
        type = "internal/network";
        interval = "3.0";
        interface-type = "wireless";

        format-connected = "<label-connected>";
        label-connected = "${icons.wifi} %essid%";

        ramp-signal-0 = "▁";
        ramp-signal-1 = "▂";
        ramp-signal-2 = "▃";
        ramp-signal-3 = "▄";
        ramp-signal-4 = "▅";
        ramp-signal-5 = "▆";
        ramp-signal-6 = "▇";
        ramp-signal-7 = "█";
      };

      "module/date" = {
        type = "internal/date";
        interval = "5";

        date = "%a %b %d";
        date-alt = "%Y-%m-%d";

        time = "%I:%M";
        time-alt = "%H:%M";

        label = "${icons.date} %date% %time%";
      };

      "module/battery" = {
        type = "internal/battery";
        battery = "BAT1";
        adapter = "AC";
        full-at = "98";

        format-charging = "CHARGE(+): <label-charging>";
        format-discharging = "CHARGE(-): <label-discharging>";
      };

      "module/memory" = fonts // {
        type = "internal/memory";
        format-prefix = icons.memory;
        interval = 3;
      };

      "module/ewmh" = fonts // {
        type = "internal/xworkspaces";

        label-active-foreground = "#${colorscheme.palette.base01}";
        label-inactive-foreground = "#${colorscheme.palette.base02}";
        label-active-underline = "#${colorscheme.palette.base01}";

        pin-workspaces = true;
        group-by-monitor = false;
        enable-click = false;
        enable-scroll = false;
      };
    };
    script = "";
  };
}
