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
        python-black
        lsp-mode
        lsp-ui
        doom-modeline
        nerd-icons
        all-the-icons
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
    extraConfig = ''
      (setq inhibit-x-resources t)
      (setq site-run-file nil)
      (setq custom-file (make-temp-name "/tmp/emacs-custom-"))
      (pdf-tools-install)
      (setq pdf-view-use-scaling t)
      (vertico-mode)
      (scroll-bar-mode -1)
      (tool-bar-mode -1)
      (tooltip-mode -1)
      (menu-bar-mode -1)
      (require 'lean4-mode)
      (require 'ace-jump-mode)

      (setq-default line-spacing 0.1)

      (load "auctex.el" nil t t)

      (setq TeX-auto-save t)
      (setq TeX-parse-self t)

      (setq gc-cons-threshold 100000000)
      (setq read-process-output-max (* 1024 1024))

      (add-hook 'LaTeX-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c [") #'citar-insert-citation)))

      (define-key global-map (kbd "C-c SPC") 'ace-jump-mode)

      (setq gc-cons-percentage 0.1)

      (add-to-list 'default-frame-alist '(inhibit-double-buffering . nil))

      (setq imagemagick-enabled-types t)
      (setq image-use-external-converter t)

      (setq x-underline-at-descent-line t)
      (setq x-use-underline-position-properties nil)

      (add-to-list 'warning-suppress-log-types '(lsp-mode))
      (add-to-list 'warning-suppress-types '(lsp-mode))

      (defun doom-defer-gc-h ()
        (setq gc-cons-threshold most-positive-fixnum))

      (defun doom-restore-gc-h ()
             (run-at-time 1 nil (lambda () (setq gc-cons-threshold (* 100 1024 1024)))))

      (add-hook 'minibuffer-setup-hook 'doom-defer-gc-h)
      (add-hook 'minibuffer-exit-hook 'doom-restore-gc-h)

      (setq doom-modeline-support-imenu t)
      (setq doom-modeline-height 25)
      (setq doom-modeline-hud nil)
      (setq doom-modeline-buffer-file-name-style 'auto)
      (setq doom-modeline-icon t)
      (setq doom-modeline-major-mode-icon t)
      (setq doom-modeline-major-mode-color-icon t)
      (setq doom-modeline-buffer-state-icon t)
      (setq doom-modeline-buffer-modification-icon t)
      (setq doom-modeline-lsp-icon t)
      (setq doom-modeline-time-icon t)
      (setq doom-modeline-time-live-icon t)
      (setq doom-modeline-battery t)
      (setq doom-modeline-time t)
      (doom-modeline-mode 1)

      (setq lsp-headerline-breadcrumb-enable nil)
      (lsp-headerline-breadcrumb-mode -1)

      (setq scroll-margin 3)
      (setq scroll-conservatively 100000)
      (setq scroll-preserve-screen-position 1)
      (setq auto-window-vscroll nil)

      (setq fast-but-imprecise-scrolling t)
      (setq jit-lock-defer-time 0)
      (setq redisplay-skip-fontification-on-input t)

      (xclip-mode 1)
      (direnv-mode)

      ;; Alert errors
      (setq visible-bell t)
      (setq inhibit-startup-screen t)
      (setq inhibit-startup-message t)
      (setq initial-scratch-message nil)
      (setq inhibit-splash-screen t)

      (set-fringe-mode 0)
      (window-divider-mode +1)
      (setq window-divider-default-right-width 1 window-divider-default-bottom-width 1)

      (setq vterm-max-scrollback 10000)
      (setq vterm-shell "nu")
      (add-hook 'eshell-mode-hook (lambda () (setenv "TERM" "dumb")))
      (add-to-list 'comint-output-filter-functions 'ansi-color-process-output)
      (add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

      (add-hook 'python-mode-hook 'auto-virtualenv-set-virtualenv)
      (add-hook 'haskell-mode-hook (lambda ()
                                   (lsp-deferred)))
      (add-hook 'web-mode-hook (lambda ()
                               (lsp-deferred)
                               (prettier-js-mode)))
      (add-hook 'typescript-mode-hook (lambda ()
                                      (prettier-js-mode)
                                      (lsp-deferred)))
      (add-hook 'python-mode-hook 'lsp)
      (add-hook 'python-mode-hook 'python-black-on-save-mode)
      (add-hook 'rust-mode-hook (lambda ()
        (lsp)))
      (setq
        org-auto-align-tags nil
        org-tags-column 0
        org-catch-invisible-edits 'show-and-error
        org-special-ctrl-a/e t
        org-insert-heading-respect-content t
        org-hide-emphasis-markers t
        org-pretty-entities t
        org-agenda-tags-column 0
        org-ellipsis "…")
      (setq-default line-spacing 0.3)
      (add-hook 'org-mode-hook (lambda ()
        (variable-pitch-mode 1)
        (set-face-attribute 'variable-pitch nil :family "Comic Neue" :height 1.0)
        (set-face-attribute 'fixed-pitch nil :family "IosevkaTerm Nerd Font Mono" :height 1.0)
        (face-remap-add-relative 'default 'variable-pitch)
        (dolist (face '(org-level-1
                  org-level-2
                  org-level-3
                  org-level-4
                  org-level-5
                  org-level-6
                  org-level-7
                  org-level-8
                  org-document-title
                  org-document-info
                  org-document-info-keyword
                  org-meta-line
                  org-drawer
                  org-quote))
                  (set-face-attribute face nil :inherit 'variable-pitch))
        (setq org-cycle-separator-lines 2)

        (org-superstar-mode 1)
        (org-indent-mode 1)
        (visual-line-mode 1)
        (setq prettify-symbols-alist '(("TODO" . "TODO 🐌") ("DONE" . "DONE ✅")))
        (setq org-superstar-headline-bullets-list '("🌺" "🌹" "🌸" "🌷" "🌿" "🌱" "🍃"))
        (prettify-symbols-mode 1)
      ))

      (set-frame-font "IosevkaTerm Nerd Font Mono 10")

      (setq rust-format-on-save t)
      (setq-default display-line-numbers-type 'relative)
      (add-hook 'pdf-view-mode-hook (lambda () (display-line-numbers-mode -1)))
      (global-display-line-numbers-mode)
      (add-hook 'prog-mode-hook (lambda ()
                                (line-number-mode)
                                (column-number-mode)
                                (setq display-line-numbers 'relative)))

      ;; Flycheck
      (global-flycheck-mode)
      (setq flycheck-command-wrapper-function
              (lambda (command) (apply 'nix-shell-command (nix-current-sandbox) command)))
      (setq
            flycheck-executable-find
              (lambda (cmd) (nix-executable-find (nix-current-sandbox) cmd)))

      ;; Keybindings
      (delete-selection-mode 1)
      (define-key key-translation-map [?\C-h] [?\C-?])
      (global-set-key [?\C-j] 'newline-and-indent)
      (global-set-key (kbd "M-x") 'counsel-M-x)
      (global-set-key (kbd "C-x C-f") 'counsel-find-file)
      (global-set-key (kbd "M-o") 'ace-window)
      (global-set-key (kbd "C-s") 'swiper)
      (global-set-key (kbd "C-r") 'swiper-backward)
      (global-set-key (kbd "C-c p f") #'consult-find)
      (global-set-key (kbd "C-c p p") #'project-switch-project)
      (global-set-key (kbd "C-c p s r") #'consult-ripgrep)
      (global-set-key (kbd "C-c p e") #'project-eshell)

      (global-set-key (kbd "C-c p e") 'vterm)
      (global-set-key (kbd "C-c a") 'org-agenda)
      (defun reopen-file-as-root ()
             (interactive)
             (when buffer-file-name
                   (let ((file (concat "/su::" buffer-file-name)))
                   (find-alternate-file file))))
      (global-set-key (kbd "C-c r") 'reopen-file-as-root)

      (setq auto-mode-alist
          (append
          '(("\\.tsx\\'" . web-mode)
          ("\\.rasi\\'" . prog-mode)) auto-mode-alist))
      (add-to-list 'auto-mode-alist '("\\.lean\\'" . (lambda ()
                                                     (lean4-mode)
                                                     (line-number-mode)
                                                     (column-number-mode)
                                                     (setq display-line-numbers 'relative)
                                                     (lsp-mode)
                                                     (global-set-key (kbd "C-c C-i") 'lean4-toggle-info))))

      (setq lsp-file-watch-ignored
        '("[/\\\\]\\.git$"
          "[/\\\\]\\.direnv$"
          "[/\\\\]dist-newstyle$"
          "[/\\\\]\\.cache$"
          "[/\\\\]\\.stack-work$"
          "[/\\\\]\\.nix$"
          "[/\\\\]\\.venv$"
          "[/\\\\]\\.lake\\'"
          "[/\\\\]build\\'"
          "[/\\\\]result\\'"
          "[/\\\\]result-\\*\\'"
          "[/\\\\]node_modules$"))

      ;; Buffer stuff
      (recentf-mode 1)
      (savehist-mode 1)
      (winner-mode 1)
      (setq history-length 25)

      ;; Xclip config
      (setq xclip-program "wl-copy")
      (setq xclip-select-enable-clipboard t)
      (setq xclip-mode t)
      (setq xclip-method (quote wl-copy))

      (setq org-agenda-files '("~/Documents/org/Todo.org"))
      (require 'org-agenda)
      (find-file "~/Documents/org/Todo.org")

      (set-face-attribute 'variable-pitch nil :font "Comic Neue" :height 140)

      (with-eval-after-load 'tex
                            (add-to-list 'TeX-command-list
                            '("NixBuild" "nix build"
                            TeX-run-command nil t :help "Run project-specific Nix build")
                            t))
      (load-theme 'base16-gruvbox-light t)
      (set-face-attribute 'window-divider nil
                    :foreground "#D5C4A1"
                    :background nil)
      (set-face-attribute 'window-divider-first-pixel nil
                    :foreground "#D5C4A1")
      (set-face-attribute 'window-divider-last-pixel nil
                    :foreground "#D5C4A1")
    '';
  };
  services.emacs = {
    enable = true;
    startWithUserSession = true;
  };
}
