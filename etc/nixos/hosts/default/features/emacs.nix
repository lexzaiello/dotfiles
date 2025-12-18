{ pkgs, inputs, ... }:

let
  colorscheme = import ./colorscheme.nix;
  system = "x86_64-linux";
  font = import ./font.nix;
  lib = inputs.nixpkgs.lib;
in {
  programs.emacs = {
    enable = true;
    extraPackages = epkgs:
      with epkgs; [
        auctex
        consult
        modus-themes
        nix-mode
        nix-sandbox
        vterm
        python-mode
        python-black
        lsp-mode
        lsp-ui
        doom-modeline
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
        base16-theme
        web-mode
        typescript-mode
        prettier-js
        lsp-haskell
        haskell-mode
        flycheck
        company-coq
        ace-jump-mode
        poly-R
        ess
        (callPackage ./lean4-mode.nix {
          inherit (pkgs) fetchFromGitHub;
          inherit (pkgs.lib) fakeHash;
          inherit (epkgs) melpaBuild compat lsp-mode dash magit-section;
        })
        pdf-tools
      ];
    extraConfig = ''
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

      (add-hook 'latex-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c C-r") (lambda () compile "nix build"))))

      (define-key global-map (kbd "C-c SPC") 'ace-jump-mode)

      (setq gc-cons-threshold (* 100 1024 1024))
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

      (doom-modeline-mode 1)

      (custom-set-faces
        '(flycheck-fringe-error ((t (:foreground "#d9a9b2"))))
        '(flycheck-fringe-warning ((t (:foreground "#d9a9b2"))))
        '(flycheck-fringe-info ((t (:foreground "#d9a9b2"))))
        '(default ((t (:foreground "${colorscheme.palette.base05}" :background "${colorscheme.palette.base00}" ))))
        '(cursor ((t (:background "${colorscheme.palette.base06}" ))))
        '(fringe ((t (:background "${colorscheme.palette.base07}" ))))
        '(mode-line ((t (:foreground "${colorscheme.palette.base07}" :background "${colorscheme.palette.base01}" ))))
        '(mode-line-inactive ((t (:foreground "${colorscheme.palette.base04}" :background "${colorscheme.palette.base07}" ))))
        '(region ((t (:background "${colorscheme.palette.base02}" ))))
        '(secondary-selection ((t (:background "${colorscheme.palette.base02}" ))))
        '(font-lock-builtin-face ((t (:foreground "#a2a371" ))))
        '(font-lock-comment-face ((t (:foreground "${colorscheme.palette.base03}" ))))
        '(font-lock-function-name-face ((t (:foreground "${colorscheme.palette.base0D}" :bold t))))
        '(font-lock-keyword-face ((t (:foreground "${colorscheme.palette.base0E}" ))))
        '(font-lock-string-face ((t (:foreground "${colorscheme.palette.base0B}" ))))
        '(font-lock-type-face ((t (:foreground "${colorscheme.palette.base0A}" ))))
        '(font-lock-constant-face ((t (:foreground "${colorscheme.palette.base09}" ))))
        '(font-lock-variable-name-face ((t (:foreground "${colorscheme.palette.base0D}" ))))
        '(minibuffer-prompt ((t (:foreground "${colorscheme.palette.base01}" :bold t ))))
        '(font-lock-warning-face ((t (:foreground "${colorscheme.palette.base04}" :bold t ))))
        '(line-number ((t (:foreground "${colorscheme.palette.base04}" :background "${colorscheme.palette.base02}"))))
        '(line-number-current-line ((t (:background "${colorscheme.palette.base04}" :foreground "${colorscheme.palette.base02}"))))
        '(whitespace-space ((t (:background nil :foreground "${colorscheme.palette.base02}"))))
        '(whitespace-tab ((t (:background nil :foreground "${colorscheme.palette.base02}"))))
        '(whitespace-trailing ((t (:background "${colorscheme.palette.base02}" :foreground "#ffffff" :weight bold))))
        '(isearch ((t (:background "${colorscheme.palette.base02}" ))))
        '(swiper-line-face ((t (:background "${colorscheme.palette.base02}" ))))
        '(swiper-match-face-1 ((t (:background "${colorscheme.palette.base02}" ))))
        '(swiper-match-face-2/3/4 ((t (:background "${colorscheme.palette.base02}" ))))
        '(lazy-highlight ((t (:background "${colorscheme.palette.base02}" ))))
        '(match ((t (:background "${colorscheme.palette.base02}"))))
        '(ivy-current-match ((t (:background "${colorscheme.palette.base02}" :weight bold))))
        '(ivy-minibuffer-match-face-1 ((t (:"${colorscheme.palette.base02}" "#ffe0f0"))))
        '(ivy-minibuffer-match-face-2 ((t (:background "${colorscheme.palette.base02}"))))
        '(ivy-minibuffer-match-face-3 ((t (:background "${colorscheme.palette.base02}"))))
        '(ivy-minibuffer-match-face-4 ((t (:background "${colorscheme.palette.base02}"))))
        ;; Set base vterm text/background
        '(vterm ((t (:foreground "${colorscheme.palette.base01}" :background "${colorscheme.palette.base00}"))))
        ;; ANSI color remapping
        '(vterm-color-black   ((t (:foreground "${colorscheme.palette.base01}" :background "${colorscheme.palette.base01}"))))
        '(vterm-color-red     ((t (:foreground "#6b595c" :background "#6b595c"))))
        '(vterm-color-green   ((t (:foreground "#8f9e88" :background "#8f9e88"))))
        '(vterm-color-yellow  ((t (:foreground "#d1c6ab" :background "#d1c6ab"))))
        '(vterm-color-blue    ((t (:foreground "#5d5a6e" :background "#5d5a6e"))))
        '(vterm-color-magenta ((t (:foreground "#755a69" :background "#755a69"))))
        '(vterm-color-cyan    ((t (:foreground "#525d63" :background "#525d63"))))
        '(vterm-color-bright-red     ((t (:foreground "#9c767d" :background "#9c767d"))))
        '(vterm-color-bright-green   ((t (:foreground "#9ab38f" :background "#9ab38f"))))
        '(vterm-color-bright-yellow  ((t (:foreground "#d1c6ab" :background "#d1c6ab"))))
        '(vterm-color-bright-blue    ((t (:foreground "#5d5a6e" :background "#5d5a6e"))))
        '(vterm-color-bright-magenta ((t (:foreground "#755a69" :background "#755a69"))))
        '(vterm-color-bright-cyan    ((t (:foreground "#525d63" :background "#525d63"))))
        '(vterm-color-white   ((t (:foreground "${colorscheme.palette.base00}" :background "${colorscheme.palette.base00}"))))
        '(doom-modeline-buffer-path
          ((t (:foreground "${colorscheme.palette.base02}" :weight bold))))
        '(doom-modeline-project-dir
          ((t (:foreground "${colorscheme.palette.base02}" :weight bold))))
        '(doom-modeline-major-mode
          ((t (:foreground "${colorscheme.palette.base02}" :weight bold))))
        '(doom-modeline-minor-modes
          ((t (:foreground "#d9a9b2" :weight semi-bold))))
        '(doom-modeline-buffer-modified
          ((t (:foreground "#d9a9b2" :weight bold))))
        '(doom-modeline-buffer-state
          ((t (:foreground "#d9a9b2" :weight bold))))
        '(doom-modeline-info
          ((t (:foreground "#d9a9b2" :weight semi-bold))))
        '(window-divider ((t (:foreground "${colorscheme.palette.base07}" :background "${colorscheme.palette.base01}"))))
        '(window-divider-first-pixel ((t (:foreground "${colorscheme.palette.base07}" :background "${colorscheme.palette.base01}"))))
        '(window-divider-last-pixel ((t (:foreground "${colorscheme.palette.base07}" :background "${colorscheme.palette.base01}"))))
        '(doom-modeline-error ((t (:foreground "#d9a9b2"))))
        '(doom-modeline-warning ((t (:foreground "#d9a9b2"))))
        '(lsp-face-highlight-textual ((t (:foreground "${colorscheme.palette.base04}" :background "${colorscheme.palette.base02}")))))

      (setq lsp-headerline-breadcrumb-enable nil)
      (lsp-headerline-breadcrumb-mode -1)

      (setq nerd-icons-color-icons nil)
      (setq doom-modeline-major-mode-color-icon nil)

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
      (setq window-divider-default-right-width 2 window-divider-default-bottom-width 2)

      (setq vterm-max-scrollback 10000)
      (setq read-process-output-max (* 1024 1024)) ;; 1mb
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
      (set-cursor-color "${colorscheme.palette.base06}")
      (custom-set-faces
       '(org-link ((t (:foreground "${colorscheme.palette.base04}" :underline t)))))
      (add-hook 'org-mode-hook (lambda ()
        (set-face-attribute 'variable-pitch nil :family "Comic Neue" :height 140)
        (set-face-attribute 'fixed-pitch nil :family "IosevkaTerm Nerd Font Mono" :height 140)
        (set-face-attribute 'default nil :family "IosevkaTerm Nerd Font Mono" :height 140)
        (set-face-attribute 'variable-pitch nil :family "Comic Neue" :height 140)
        (set-face-attribute 'fixed-pitch nil :family "IosevkaTerm Nerd Font Mono" :height 140)
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
        (custom-set-faces
          '(org-level-1 ((t (:inherit variable-pitch :weight bold :height 1.5))))
          '(org-level-2 ((t (:inherit variable-pitch :weight bold :height 1.4))))
          '(org-level-3 ((t (:inherit variable-pitch :weight semi-bold :height 1.3))))
          '(org-block ((t (:inherit fixed-pitch :background "${colorscheme.palette.base02}" :foreground "${colorscheme.palette.base04}"))))
          '(org-block-begin-line ((t (:inherit fixed-pitch :background "${colorscheme.palette.base07}" :foreground "${colorscheme.palette.base01}" :slant italic))))
          '(org-block-end-line ((t (:inherit fixed-pitch :background "${colorscheme.palette.base07}" :foreground "${colorscheme.palette.base01}" :slant italic))))
          '(org-todo ((t (:inherit fixed-pitch :background "${colorscheme.palette.base02}" :foreground "${colorscheme.palette.base04}" :weight bold))))
          '(org-table ((t (:inherit fixed-pitch :foreground "${colorscheme.palette.base01}"))))
          '(org-done ((t (:inherit fixed-pitch :background "${colorscheme.palette.base02}" :foreground "${colorscheme.palette.base04}" :weight semi-bold))))
          '(org-agenda-structure ((t (:foreground "${colorscheme.palette.base04}"}))))
          '(org-agenda-date ((t (:foreground "${colorscheme.palette.base04}"}))))
          '(org-agenda-date-today ((t (:foreground "${colorscheme.palette.base04}" :weight bold :slant italic))))
          '(org-agenda-todo ((t (:foreground "${colorscheme.palette.base02}")))))
        (setq org-cycle-separator-lines 2)

        (org-superstar-mode 1)
        (org-indent-mode 1)
        (visual-line-mode 1)
        (setq prettify-symbols-alist '(("TODO" . "TODO 🐌") ("DONE" . "DONE ✅")))
        (setq org-superstar-headline-bullets-list '("🌺" "🌹" "🌸" "🌷" "🌿" "🌱" "🍃"))
        (prettify-symbols-mode 1)
      ))

      (setq rust-format-on-save t)
      (setq-default display-line-numbers-type 'relative)
      (global-display-line-numbers-mode)
      (add-hook 'prog-mode-hook (lambda ()
                                (set-face-attribute 'fixed-pitch nil :font "IosevkaTerm Nerd Font Mono" :height 140)
                                (whitespace-mode)
                                (line-number-mode)
                                (column-number-mode)
                                (setq display-line-numbers 'relative)
                                (setq whitespace-style '(face spaces space-mark tabs tab-mark trailing))
                                (setq whitespace-display-mappings
                                      '((tab-mark 9 [124 9] [92 9])
                                      (space-mark 32 [183] [46])
                                      (space-mark 160 [164] [95])
                                      (newline-mark 10 [36 10])))))

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
                                                     (set-face-attribute 'fixed-pitch nil :font "IosevkaTerm Nerd Font Mono" :height 140)
                                                     (whitespace-mode)
                                                     (line-number-mode)
                                                     (column-number-mode)
                                                     (setq display-line-numbers 'relative)
                                                     (setq whitespace-style '(face spaces space-mark tabs tab-mark trailing))
                                                     (setq whitespace-display-mappings
                                                           '((tab-mark 9 [124 9] [92 9])
                                                           (space-mark 32 [183] [46])
                                                           (space-mark 160 [164] [95])
                                                           (newline-mark 10 [36 10])))
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

      (setq org-agenda-files '("~/Documents/org/Todo.org" "~/Documents/org/BimboDiscipline.org"))
      (require 'org-agenda)
      (find-file "~/Documents/org/Todo.org")

      (set-face-attribute 'default nil :font "IosevkaTerm Nerd Font Mono" :height 140)
      (set-face-attribute 'fixed-pitch nil :font "IosevkaTerm Nerd Font Mono" :height 140)
      (set-face-attribute 'variable-pitch nil :font "Comic Neue" :height 140)
      (setq initial-frame-alist '((font . "IosevkaTerm Nerd Font Mono")))

      (with-eval-after-load 'tex
                            (add-to-list 'TeX-command-list
                            '("NixBuild" "nix build"
                            TeX-run-command nil t :help "Run project-specific Nix build")
                            t))
    '';
  };
  services.emacs = {
    enable = true;
    startWithUserSession = true;
  };
}
