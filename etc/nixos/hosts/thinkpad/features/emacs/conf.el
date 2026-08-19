;;; conf.el --- my emacs configuration
;;; Commentary:
;;; not much to say
;;; Code:
(server-start)
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
;;(display-battery-mode 1)
(require 'bind-key)
(require 'exwm-randr)
(require 'exwm)
(require 'doom-modeline)
(require 'async)

(setq aw-scope 'global)

(defvar my/work-ids (number-sequence 0 8))

(defun my/doall-workspaces (fn)
  "Run FN for its side effects on all monitor IDs."
  (mapc fn my/work-ids))

(defun my/gen-workspace-toggles ()
  "Generate toggle for setting workspaces."
  (interactive)
  (my/doall-workspaces
   (lambda (mon)
     (exwm-input-set-key
      (kbd (format "s-%d" mon))
      `(lambda () (interactive)
	 (exwm-workspace-switch ,mon))))))

(setq exwm-workspace-number 9)

(defun my/get-monitors ()
  "Read connected monitor names."
  (let* ((output (shell-command-to-string "xrandr | grep ' connected '"))
         (lines (split-string output "\n" t)))
    (mapcar (lambda (x)
	      (car (split-string x "[ \t]+")))
	    lines)))

(defun my/launcher (&optional steal-window)
  "Alias: My launcher instead of rofi.  STEAL-WINDOW will show in the current window."
  (interactive)
  (unless steal-window
    (select-window (split-window-right)))
  (counsel-linux-app))

(defun my/set-monitor (disp-name &optional no-refresh)
  "Change the main monitor (DISP-NAME) EXWM displays workspaces on, don't refresh if NO-REFRESH."
  (interactive
   (list (completing-read "Monitor name: " (my/get-monitors))))
  (let* ((mon-plist (mapcan (lambda (x) (list x disp-name)) my/work-ids)))
    (setq exwm-randr-workspace-monitor-plist mon-plist)
    (unless no-refresh
      (exwm-randr-refresh))))

(defun my/gen-workspace-teleport ()
  "Generate toggle for teleporting windows to other workspaces."
  (interactive)
  (my/doall-workspaces
   (lambda (mon)
     (define-key exwm-mode-map
      (kbd (format "s-S-%d" mon))
      `(lambda () (interactive)
	 (exwm-workspace-move-window ,mon))))))

(my/gen-workspace-toggles)
(my/gen-workspace-teleport)

(defvar my/wifi-string "")

(defun my/refresh-wifi ()
  "Show the currrent WIFI network SSID."
  (interactive)
  (async-start
   (lambda ()
     (shell-command-to-string "LANG=C nmcli -t -f active,ssid dev wifi | grep ^yes | cut -d: -f2-"))
   (lambda (x)
     (setq my/wifi-string (string-trim x)))))

(my/refresh-wifi)

(defun my/spawn-vterm-buffer (&optional new-window)
  "Summon vterm as a new scratch-ish buffer, in a new window if NEW-WINDOW."
  (interactive)
  (when new-window
    (select-window (split-window-below)))
  (vterm (generate-new-buffer-name "*vterm*")))

; Docs, shortcut links
(defvar my/org-home "~/Documents/org/agenda/Main.org")

(defvar my/mono-font "IosevkaTerm Nerd Font Mono 10")

(defvar my/variable-font "Comic Neue")

(defun my/show-org-home ()
  "Show my Org master file."
  (interactive)
  (find-file my/org-home))

(bind-key* (kbd "s-i") 'my/refresh-wifi)
(bind-key* (kbd "s-w") 'my/set-monitor)
(bind-key* (kbd "s-<return>") 'my/spawn-vterm-buffer)
(bind-key* (kbd "s-e") 'my/show-org-home)
(bind-key* (kbd "C-S-SPC") 'my/launcher)
(bind-key* (kbd "C-S-s-SPC") (lambda () (interactive) (my/launcher t)))
(bind-key* (kbd "s-b") 'exwm-workspace-switch-to-buffer)
(bind-key* (kbd "C-c RET") 'exwm-workspace-move-window)

(my/set-monitor "eDP" t)

(setq exwm-input-global-keys `(([?\s-r] . exwm-reset)
			       (,(kbd "s-i") . my/refresh-wifi)
			       (,(kbd "s-b") . exwm-workspace-switch-to-buffer)
			       (,(kbd "s-w") . my/set-monitor)
			       (,(kbd "s-<return>") . my/spawn-vterm-buffer)
			       (,(kbd "s-e") . my/show-org-home)
			       (,(kbd "C-S-SPC") . my/launcher)
			       (,(kbd "M-S-v") . ace-swap-window)
			       (,(kbd "C-S-s-SPC") .
				(lambda () (interactive) (my/launcher t)))
			       (,(kbd "M-o") . ace-window)))

(require 'lean4-mode)
(require 'ace-jump-mode)

(exwm-wm-mode)
(exwm-randr-mode)

(set-frame-font my/mono-font)
(set-face-attribute 'variable-pitch nil
              :family my/variable-font
              :height 1.0)

(setq-default line-spacing 0.1)

(load "auctex.el" nil t t)

(setq TeX-auto-save t)
(setq TeX-parse-self t)

(setq gc-cons-threshold (* 256 1024 1024))
(setq read-process-output-max (* 1024 1024))

(add-hook 'LaTeX-mode-hook
    (lambda ()
      (local-set-key (kbd "C-c [") #'citar-insert-citation)))

(define-key global-map (kbd "C-c SPC") 'ace-jump-mode)
(bind-key* (kbd "M-S-v") 'ace-swap-window)

(setq gc-cons-percentage 0.1)

(add-to-list 'default-frame-alist '(inhibit-double-buffering . nil))

(setq imagemagick-enabled-types t)
(setq image-use-external-converter t)

(setq x-underline-at-descent-line t)
(setq x-use-underline-position-properties nil)

(add-to-list 'warning-suppress-log-types '(lsp-mode))
(add-to-list 'warning-suppress-types '(lsp-mode))

(defvar my/cpu-string "")
(defvar my/ram-string "")
(defvar my/volume-string "")
(defvar my/--last-cpu-stats nil)

(defun my/--cpu-usage ()
  "Show CPU % from /proc."
  (let* ((fields (with-temp-buffer
                    (insert-file-contents "/proc/stat")
                    (goto-char (point-min))
                    (forward-word) ; skip "cpu"
                    (mapcar #'string-to-number
                            (split-string (buffer-substring (point) (line-end-position))))))
         (idle (nth 3 fields))
         (total (apply #'+ fields)))
    (prog1
        (if my/--last-cpu-stats
            (let ((idle-d (- idle (car my/--last-cpu-stats)))
                  (total-d (- total (cdr my/--last-cpu-stats))))
              (if (> total-d 0) (round (* 100 (- 1 (/ (float idle-d) total-d)))) 0))
          0)
      (setq my/--last-cpu-stats (cons idle total)))))

(defun my/--ram-usage ()
  "Show RAM % from /proc."
  (let* ((meminfo (with-temp-buffer
                     (insert-file-contents "/proc/meminfo")
                     (buffer-string)))
         (total (progn (string-match "MemTotal:\\s-+\\([0-9]+\\)" meminfo)
                       (string-to-number (match-string 1 meminfo))))
         (avail (progn (string-match "MemAvailable:\\s-+\\([0-9]+\\)" meminfo)
                       (string-to-number (match-string 1 meminfo)))))
    (round (* 100 (/ (float (- total avail)) total)))))

(defun my/--wifi-ssid ()
  "Show WIFI network name."
  (let ((ssid (string-trim
               (shell-command-to-string
                "nmcli -t -f active,ssid dev wifi 2>/dev/null | awk -F: '$1==\"yes\"{print $2}'"))))
    (if (string-empty-p ssid) "offline" ssid)))

(defun my/--volume ()
  "Change volume."
  (let ((out (shell-command-to-string "pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null")))
    (if (string-match "\\([0-9]+\\)%" out) (match-string 1 out) "?")))

(defun my/--refresh-fast ()
  "CPU/RAM: cheap procfs read, poll often."
  (setq my/cpu-string (format "%d%%" (my/--cpu-usage)))
  (setq my/ram-string (format "%d%%" (my/--ram-usage))))

(run-with-timer 0 2 #'my/--refresh-fast)

;; --- doom-modeline segments (just read the cached vars, no I/O here) ---
(doom-modeline-def-segment my/cpu   (concat "  " my/cpu-string))
(doom-modeline-def-segment my/ram   (concat "  " my/ram-string))
(doom-modeline-def-segment my/wifi  (concat "  " my/wifi-string))
(doom-modeline-def-segment my/volume (concat "  " my/volume-string))

(doom-modeline-def-modeline 'main
  '(bar workspace-name window-number modals matches follow buffer-info remote-host
    buffer-position word-count parrot selection-info)
  '(compilation objed-state misc-info persp-name grip irc mu4e gnus github debug repl
    lsp minor-modes input-method indent-info buffer-encoding major-mode process vcs check
    ;; my/wifi my/volume my/cpu my/ram battery time))
    my/wifi my/volume my/cpu my/ram time))

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
;;(setq doom-modeline-battery t)
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
  (mixed-pitch-mode 1)
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
(bind-key* (kbd "M-o") 'ace-window)
(global-set-key (kbd "C-s") 'swiper)
(global-set-key (kbd "C-r") 'swiper-backward)
(global-set-key (kbd "C-c p f") #'consult-find)
(global-set-key (kbd "C-c p p") #'project-switch-project)
(global-set-key (kbd "C-c p s r") #'consult-ripgrep)
(global-set-key (kbd "C-c p e") #'project-eshell)

(global-set-key (kbd "C-c p e") 'vterm)
(global-set-key (kbd "C-c a") 'org-agenda)
(defun reopen-file-as-root ()
  "Use TRAMP to edit root files easier."
  (interactive)
  (when buffer-file-name
        (let ((file (concat "/su::" buffer-file-name)))
        (find-alternate-file file))))
(global-set-key (kbd "C-c r") 'reopen-file-as-root)

(setq whitespace-style '(face trailing space-before-tab empty))
(global-whitespace-mode 1)

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

(setenv "LEAN_NUM_THREADS" "16")

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

(setq org-agenda-files '(my/org-home))
(require 'org-agenda)
(find-file my/org-home)

(with-eval-after-load 'tex
                      (add-to-list 'TeX-command-list
                      '("NixBuild" "nix build"
                      TeX-run-command nil t :help "Run project-specific Nix build")
                      t))

(with-eval-after-load 'org
  ;; Force file links to open in the current window
  (setf (alist-get 'file org-link-frame-setup) 'find-file)
  (define-key org-mode-map (kbd "C-c RET") nil))

(load-theme 'base16-gruvbox-light t)
(set-face-attribute 'window-divider nil
              :foreground "#D5C4A1"
              :background nil)
(set-face-attribute 'window-divider-first-pixel nil
              :foreground "#D5C4A1")
(set-face-attribute 'window-divider-last-pixel nil
              :foreground "#D5C4A1")
;;; conf.el ends here
