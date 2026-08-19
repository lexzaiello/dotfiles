{ pkgs, inputs, ... }:
let
  system = "x86_64-linux";
  font = import ../../default/features/font.nix;
  lib = inputs.nixpkgs.lib;
  doom-modeline-exwm = pkgs.emacsPackages.trivialBuild {
    pname = "doom-modeline-exwm";
    version = "latest";
    src = pkgs.fetchFromGitHub {
      owner = "elken";
      repo = "doom-modeline-exwm";
      rev = "87bffb3dd8bd1290ac01b795c4fc291b472fc800";
      sha256 = "sha256-Xu15+PjW9PRqMfAJCGMXmvsNizPwsOP9sMR7MhY1EWU=";
    };
    packageRequires = with pkgs.emacsPackages; [ doom-modeline exwm ];
  };
in {
  programs.emacs = {
    enable = true;
    extraPackages = epkgs:
      with epkgs; [
        bind-key
        doom-modeline-exwm
        async
        ace-window
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
        (callPackage ../../default/features/lean4-mode.nix {
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
