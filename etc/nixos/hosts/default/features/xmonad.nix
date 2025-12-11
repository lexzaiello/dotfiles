{ pkgs, inputs, ... }:

let
  system = "x86_64-linux";
in {
  xsession.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    config = pkgs.writeText "xmonad.hs" ''
            import XMonad
            import XMonad.Util.SpawnOnce (spawnOnce)
            import XMonad.Hooks.EwmhDesktops
            import XMonad.Util.EZConfig (additionalKeysP)

            myStartupHook :: X ()
            myStartupHook = do
              spawnOnce "${pkgs.feh}/bin/feh --bg-scale ~/Images/wallpapers/mac.png"
              spawnOnce "${pkgs.polybar}/bin/polybar main >>/home/dowlandaiello/.config/polybar/logfile 2>&1"

            main = xmonad $ def
                { terminal    = "${pkgs.alacritty}/bin/alacritty"
                , modMask     = mod4Mask
                , startupHook = myStartupHook
                , borderWidth = 1
                }
          '';
  };
}
