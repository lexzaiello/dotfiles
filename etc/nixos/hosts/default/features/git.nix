{
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings.user.name = "Alexandra Aiello";
    settings.user.email = "dowlandaiello@gmail.com";
    ignores = [
      "*~"
      "\\#*\\#"
      "/.emacs.desktop"
      "/.emacs.desktop.lock"
      "*.elc"
      "auto-save-list"
      "tramp"
      ".\\#*"
      ".org-id-locations"
      "*_archive"
      "*_flymake.*"
      "/eshell/history"
      "/eshell/lastdir"
      "/elpa/"
      "*.rel"
      "/auto/"
      ".cask/"
      "dist/"
      "flycheck_*.el"
      "/server/"
      ".projectile"
      ".dir-locals.el"
      "/network-security.data"
    ];
  };
}
