{ pkgs, inputs, ... }:
let
  system = "x86_64-linux";
  font = import ./font.nix;
  lib = inputs.nixpkgs.lib;
in {
  programs.emacs = {
    enable = true;
    extraPackages = epkgs:
      with epkgs; [
        xelb
        exwm
        jinx
        vertico
        citar
        auctex
        consult
        base16-theme
        nix-mode
        nix-sandbox
        vterm
        python-mode
        mixed-pitch
        python-black
        lsp-mode
        lsp-ui
        doom-modeline
        nerd-icons
        treesit-grammars.with-all-grammars
        leerzeichen
        org-superstar
        rainbow-delimiters
        which-key
        helpful
        editorconfig
        magit
        company
        ace-window
        ivy
        swiper
        counsel
        auto-virtualenv
        xclip
        rust-mode
        direnv
        solidity-mode
        web-mode
        typescript-mode
        prettier-js
        lsp-haskell
        haskell-mode
        flycheck
        company-coq
        ace-jump-mode
        ess
        agda2-mode
        (callPackage ./lean4-mode.nix {
          inherit (pkgs) fetchFromGitHub;
          inherit (pkgs.lib) fakeHash;
          inherit (epkgs) melpaBuild compat lsp-mode dash magit-section;
        })
        pdf-tools
      ];
    extraConfig = builtins.readFile ./emacs/conf.el;
  };
  services.emacs.enable = false;
}
