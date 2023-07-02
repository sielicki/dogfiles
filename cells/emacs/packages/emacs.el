(use-package gcmh
  :config (gcmh-mode 1))

(use-package bind-key
  :config
  (add-to-list 'same-window-buffer-names "*Personal Keybindings*"))

(use-package exec-path-from-shell
  :config
  (dolist (var '("SSH_AUTH_SOCK" "SSH_AGENT_PID" "GPG_AGENT_INFO" "LANG" "LC_CTYPE" "NIX_SSL_CERT_FILE" "NIX_PATH"))
    (add-to-list 'exec-path-from-shell-variables var))
  (when (or (daemonp) (memq window-system '(mac ns x)))
    (exec-path-from-shell-initialize)))

(use-package posframe)

;; base configuration
(use-package emacs
  :ensure nil
  :diminish (
	     visual-line-mode
	     pixel-scroll-precision-mode
	     )
  :custom
  (tab-always-indent 'complete)
  (comropletion-cycle-threshold nil)
  :config

  (defmacro my~font-pref (fontname size)
    `((find-font (font-spec :name ,fontname)) (set-frame-font ,(concat ,fontname - ,size))))

  (defun my~load-graphics ()
    (when (window-system)
      (progn
	(menu-bar-mode -1)
	(scroll-bar-mode -1)
	(tool-bar-mode -1)
	(tab-bar-mode 1)
	(require 'burly)
	(burly-tabs-mode 1)

	(cond
	 ((find-font (font-spec :name "Iosevka Nerd Font"))
	  (progn (set-frame-font "Iosevka Nerd Font-16")))))))

  (my~load-graphics)
  (add-to-list 'initial-frame-alist '(fullscreen . maximized))
  (add-to-list 'default-frame-alist '(fullscreen . maximized))

  (defvar my~tmpfile-root (concat user-emacs-directory "tmpfiles/"))
  (defvar my~autosave-directory (concat my~tmpfile-root "autosaves/"))
  (defvar my~backup-directory (concat my~tmpfile-root "backups/"))
  (defvar my~lockfile-directory (concat my~tmpfile-root "lockfiles/"))
  (dolist (d `(,my~backup-directory ,my~lockfile-directory ,my~autosave-directory))
    (mkdir d 'parents))

  (setq lock-file-name-transforms `(("\\`/.*/\\([^/]+\\)\\'" ,(concat (file-name-as-directory my~lockfile-directory) "\\1") t)))
  (setq auto-save-file-name-transforms `(("\\`/.*/\\([^/]+\\)\\'" ,(concat (file-name-as-directory my~autosave-directory) "\\1") t)))

  (setq backup-directory-alist `(("." . ,my~backup-directory)))
  (setq make-backup-files t
	backup-by-copying t
	version-control t
	delete-old-versions t
	delete-by-moving-to-trash t
	kept-old-versions 6
	kept-new-versions 9
	auto-save-default t
	auto-save-timeout 20
	auto-save-interval 200
       )

  (delete-selection-mode 1)
  (save-place-mode 1)
  (blink-cursor-mode 0)
  (visual-line-mode)
  (pixel-scroll-precision-mode)

  (electric-pair-mode 1)
  (setq ring-bell-function 'ignore)

  ;; never warn about unsafe themes.
  (setq custom-safe-themes t)

  (setq scroll-margin 3
      scroll-conservatively 101
      scroll-up-aggressively 0.01
      scroll-down-aggressively 0.01
      scroll-preserve-screen-position t
      auto-window-vscroll nil)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Emacs 28: Hide commands in M-x which do not work in the current mode.
  ;; Vertico commands are hidden in normal buffers.
  (setq read-extended-command-predicate
        #'command-completion-default-include-p)

  (add-hook 'prog-mode-hook 'display-line-numbers-mode)
  (menu-bar-mode -1)
  (scroll-bar-mode -1)
  (tool-bar-mode -1)
  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t)


  (use-package dabbrev
    :ensure nil
    ;; Swap M-/ and C-M-/
    :bind (("M-/" . dabbrev-completion)
           ("C-M-/" . dabbrev-expand))
    ;; Other useful Dabbrev configurations.
    :custom
    (dabbrev-check-all-buffers t)
    (dabbrev-check-other-buffers t)
    (dabbrev-ignored-buffer-regexps '("\\.\\(?:pdf\\|jpe?g\\|png\\)\\'")))

  (use-package whitespace
    :ensure nil
    :diminish (global-whitespace-mode
               whitespace-mode
               whitespace-newline-mode)
    :commands (whitespace-buffer
               whitespace-cleanup
               whitespace-mode)
    :hook ((prog-mode-hook . whitespace-mode)
           (c-mode-common-hook . whitespace-mode)))

  (use-package compile
    :ensure nil
    :custom
    (compilation-scroll-output t))

  (use-package savehist
    :ensure nil
    :custom
    (savehist-save-minibuffer-history t)
    (savehist-autosave-interval 30)
    (history-length t)
    (savehist-additional-variables
     '(
	    kill-ring
	    compile-history
	    compile-command
	    shell-command-history
	    log-edit-comment-ring
	    Info-history-list
	    kmacro-ring
	    last-kbd-macro
            register-alist
            mark-ring
	    global-mark-ring
            search-ring
	    regexp-search-ring
      ))
    :config
    (savehist-mode 1))

  (use-package eshell
    :after (esh-mode consult)
    :commands eshell
    :bind (:map
	   eshell-command-map
	   ("M-r" . consult-history))
    :ensure nil
    :config
    (use-package eat
      :config
      (add-hook 'eshell-mode-hook #'eat-eshell-mode)
      (add-hook 'eshell-mode-hook #'eat-eshell-visual-command-mode))
    (use-package pcmpl-args)
    (use-package shrink-path
      :config
      (require 'eshell)

      (defun +eshell/prompt ()
	(let ((base/dir (shrink-path-prompt default-directory)))
	  (concat (propertize (car base/dir)
                              'face 'font-lock-comment-face)
		  (propertize (cdr base/dir)
                              'face 'font-lock-constant-face)
		  ;; (propertize (+eshell--current-git-branch)
		  ;;             'face 'font-lock-function-name-face)
		  (propertize " λ" 'face 'eshell-prompt-face)
		  ;; needed for the input text to not have prompt face
		  (propertize " " 'face 'default))))
      (setq eshell-prompt-regexp "^.* λ "
	    eshell-prompt-function #'+eshell/prompt))

    (use-package multi-eshell
     :commands (multi-eshell)
     :bind (("s-b c" . multi-eshell)
            ("s-b n" . multi-eshell-switch)
            ("s-b p" . multi-eshell-go-back))
     :custom
     (multi-eshell-shell-function '(eshell))
     (multi-eshell-name "*eshell*"))

    (use-package with-editor
      :after (eshell eat)
      :init
      (keymap-global-set "<remap> <async-shell-command>"
			 #'with-editor-async-shell-command)
      (keymap-global-set "<remap> <shell-command>"
			 #'with-editor-shell-command)
      :hook ((shell-mode-hook . with-editor-export-editor)
	     (term-exec-hook . with-editor-export-editor)
	     (eshell-mode-hook . with-editor-export-editor)))
    (add-hook 'eshell-mode-hook (lambda () (setq outline-regexp eshell-prompt-regexp)))))



(use-package treesit
  :ensure nil
  :config
  ;; note: any usage of python-mode-hooks requires amending to python-ts-mode-hooks
  (dolist (mapping '((python-mode . python-ts-mode)
                     (css-mode . css-ts-mode)
                     (typescript-mode . tsx-ts-mode)
                     (js-mode . js-ts-mode)
                     (css-mode . css-ts-mode)
                     (yaml-mode . yaml-ts-mode)))
    (add-to-list 'major-mode-remap-alist mapping))

  (use-package combobulate
    :preface
    (setq combobulate-key-prefix "C-c o")))


(use-package doom-themes
  :config
  (use-package solaire-mode
    :config
    (solaire-global-mode +1))
  ;; Global settings (defaults)
  (setq doom-themes-padded-modeline t
	doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config)

  (if (eq system-type 'darwin)
      (progn
	(add-hook 'ns-system-appearance-change-functions
		  (lambda (appearance)
		    (mapc #'disable-theme custom-enabled-themes)
		    (pcase appearance
		      ('light (load-theme 'doom-one-light t))
		      ('dark (load-theme 'doom-one t)))))
	(load-theme 'doom-one-light t)
	)
    (load-theme 'doom-one t))
  )


(use-package project
  :config
  ;; https://andreyor.st/posts/2022-07-16-project-el-enhancements/
  ;; https://andreyor.st/posts/2022-07-16-project-el-enhancements/
  (defun my~project-root-p (path)
    "Check if the current PATH has any of the project root markers."
    (catch 'found
      (dolist (marker '("../packageInfo" "flake.nix" ".envrc" "shell.nix"))
	(when (file-exists-p (concat path marker))
          (throw 'found marker)))))
  (defun my~project-find-root (path)
    "Search up the PATH for `project-root-markers'."
    (when-let ((root (locate-dominating-file path #'my~project-root-p)))
      (cons 'transient (expand-file-name root))))
  (add-to-list 'project-find-functions #'my~project-find-root))

(use-package telephone-line
  :config
  (setq telephone-line-primary-left-separator 'telephone-line-cubed-left
	telephone-line-secondary-left-separator 'telephone-line-cubed-hollow-left
	telephone-line-primary-right-separator 'telephone-line-cubed-right
	telephone-line-secondary-right-separator 'telephone-line-cubed-hollow-right)
  (setq telephone-line-height 24)
  (setq telephone-line-lhs
	'((accent . (telephone-line-vc-segment))
	  (accent . (telephone-line-project-segment))
	  (accent . (telephone-line-filesize-segment
                     telephone-line-process-segment))
	  (nil . (telephone-line-flycheck-segment))))
  (setq telephone-line-rhs
	'((nil    . (telephone-line-major-mode-segment
		     telephone-line-minor-mode-segment
		     telephone-line-buffer-modified-segment
		     telephone-line-misc-info-segment))
          (accent . (telephone-line-buffer-segment))))

  (telephone-line-mode 1))

(use-package mosey
  :bind (("C-a" . mosey-backward)
         ("C-e" . mosey-forward)))

(use-package burly
  :custom
  (burly-frameset-filter-alist '((name . nil)
                                 ;; posframe-parent-buffer
                                 ;; include #<xxx>, which can
                                 ;; not be handle by `read'.
                                 (posframe-parent-buffer . :never)))
  :diminish (burly-tabs-mode tab-bar-mode)
  :bind (("C-c b B f" . burly-bookmark-frames)
	 ("C-c b B w" . burly-bookmark-windows)
	 ("C-c b o"   . burly-open-bookmark)
	 ("C-c b c"   . burly-reset-tab)))

(use-package windsize
  :config
  (windsize-default-keybindings))







(use-package ement
  :commands (ement-connect)
  :config
  (setq ement-save-sessions t))

(use-package kind-icon
  :after corfu
  :custom
  (kind-icon-use-icons t)
  (kind-icon-default-face 'corfu-default)
  (kind-icon-blend-background nil)
  (kind-icon-blend-frac 0.08)
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package beardbolt
  :commands (beardbolt-mode beardbolt-starter beardbolt-compile))

(use-package dashboard
  :custom
  (dashboard-items '((projects . 10) (bookmarks . 25) (recents . 25)))
  (dashboard-image-banner-max-height 200)
  (dashboard-set-footer nil)
  (dashboard-center-content t)
  (dashboard-show-shortcuts nil)
  (dashboard-projects-backend 'project-el)
  (dashboard-banner-logo-title "He who despairs of the human condition is a coward, but he who has hope for it is a fool.")
  (dashboard-startup-banner "@dashboardLogo@")
  :config
  (dashboard-setup-startup-hook))

(use-package dirvish
  :config
  (dirvish-override-dired-mode))

(use-package consult-dir
  :after (vertico)
  :config
  (setq consult-dir-project-list-function nil)
  :bind (("C-x C-d" . consult-dir)
         :map vertico-map
         ("C-x C-d" . consult-dir)
         ("C-x C-j" . consult-dir-jump-file)))

;; (use-package age
;;   :config
;;   (age-file-enable))

(use-package avy
  :bind (("M-s a" . avy-goto-char-timer))
  :config
  (setq avy-timeout-seconds 0.5)
  )

(use-package flycheck
  :config (global-flycheck-mode))

(use-package sideline
  :diminish (sideline-mode)
  :hook (flycheck-mode . sideline-mode)
  :init
  (setq sideline-backends-skip-current-line t  ; don't display on current line
        sideline-order-left 'down              ; or 'up
        sideline-order-right 'up               ; or 'down
        sideline-format-left "%s   "           ; format for left aligment
        sideline-format-right "   %s"          ; format for right aligment
        sideline-priority 100                  ; overlays' priority
        sideline-display-backend-name t)      ; display the backend name
  (setq sideline-backends-right '(sideline-flycheck))
  :config
  (use-package sideline-flycheck
    :hook (flycheck-mode . sideline-flycheck-setup))
  )

(use-package editorconfig
  :diminish (editorconfig-mode)
  :config
  (editorconfig-mode 1))

(use-package wgrep
  :config
  (setq wgrep-auto-save-buffer t))

(use-package envrc
  :config
  (envrc-global-mode))

;; april 2023: affe is brittle.
;; (use-package affe
;;   :bind (("C-x C-f" . affe-find))
;;   :config
;;   (defun affe-orderless-regexp-compiler (input _type _ignorecase)
;;     (setq input (orderless-pattern-compiler input))
;;     (cons input (apply-partially #'orderless--highlight input)))
;;   (setq affe-regexp-compiler #'affe-orderless-regexp-compiler)
;;   (consult-customize affe-grep :preview-key "M-."))

(use-package orderless
  :demand t
  :config

  (defun +orderless--consult-suffix ()
    "Regexp which matches the end of string with Consult tofu support."
    (if (and (boundp 'consult--tofu-char) (boundp 'consult--tofu-range))
        (format "[%c-%c]*$"
                consult--tofu-char
                (+ consult--tofu-char consult--tofu-range -1))
      "$"))

  ;; Recognizes the following patterns:
  ;; * .ext (file extension)
  ;; * regexp$ (regexp matching at end)
  (defun +orderless-consult-dispatch (word _index _total)
    (cond
     ;; Ensure that $ works with Consult commands, which add disambiguation suffixes
     ((string-suffix-p "$" word)
      `(orderless-regexp . ,(concat (substring word 0 -1) (+orderless--consult-suffix))))
     ;; File extensions
     ((and (or minibuffer-completing-file-name
               (derived-mode-p 'eshell-mode))
           (string-match-p "\\`\\.." word))
      `(orderless-regexp . ,(concat "\\." (substring word 1) (+orderless--consult-suffix))))))

  (orderless-define-completion-style +orderless-with-initialism
    (orderless-matching-styles '(orderless-initialism orderless-literal orderless-regexp)))

  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        ;;; Enable partial-completion for files.
        ;;; Either give orderless precedence or partial-completion.
        ;;; Note that completion-category-overrides is not really an override,
        ;;; but rather prepended to the default completion-styles.
        ;; completion-category-overrides '((file (styles orderless partial-completion))) ;; orderless is tried first
        completion-category-overrides '((file (styles partial-completion)) ;; partial-completion is tried first
                                        ;; enable initialism by default for symbols
                                        (command (styles +orderless-with-initialism))
                                        (variable (styles +orderless-with-initialism))
                                        (symbol (styles +orderless-with-initialism)))
        orderless-component-separator #'orderless-escapable-split-on-space ;; allow escaping space with backslash!
        orderless-style-dispatchers (list #'+orderless-consult-dispatch
                                          #'orderless-affix-dispatch)))

;; (use-package haskell-mode
;;   :commands haskell-mode)
;; (use-package nasm-mode)
(use-package mips-mode
  :mode "\\.mips\\'")
(use-package verilog-mode
  :mode "\\.[ds]?vh?\\'")

(use-package yaml-mode
  :mode ("\\.yaml\\'" "\\.yml\\'"))
(use-package rust-mode
  :mode "\\.rs\\'")
(use-package nix-mode
  :mode ("\\.nix\\'" "\\.nix.in\\'" "\\.flake\\'"))

(use-package nix-drv-mode
  :ensure nix-mode
  :mode "\\.drv\\'")

(use-package nix-shell
  :ensure nix-mode
  :commands (nix-shell-unpack nix-shell-configure nix-shell-build))

(use-package nix-repl
  :ensure nix-mode
  :commands (nix-repl))

(use-package nix-flake
  :ensure nix-mode
  :commands (nix-flake-dispatch nix-flake-update nix-flake-lock nix-flake-build-default nix-flake-build-attribute))

(use-package feature-mode
  :mode "\\.feature$")
(use-package json-mode
  :mode "\\.json$")

;; Enable vertico
(use-package vertico
  :custom
  (vertico-scroll-margin 0)
  (vertico-count 20)
  (vertico-resize t)
  (vertico-cycle t)
  :config
  (vertico-mode))

(use-package vertico-posframe
  :config
  (vertico-posframe-mode 1))

(use-package corfu
  :custom
  (corfu-min-width 80)
  (corfu-preselect-first t)
  (corfu-preview-current 'insert)
  (corfu-quit-no-match 'separator)
  (corfu-separator ?\s)
  (corfu-quit-at-boundary 'separator)
  (corfu-popupinfo-delay '(0.25 . 0.1))
  :init
  (global-corfu-mode)
  (corfu-history-mode)
  (corfu-popupinfo-mode))


(use-package tempel-collection)
;; Configure Tempel
(use-package tempel
  :custom
  (tempel-trigger-prefix "<")
  :init
  (defun tempel-setup-capf ()
    (setq-local completion-at-point-functions
                (cons #'tempel-complete
                      completion-at-point-functions)))
  (add-hook 'conf-mode-hook 'tempel-setup-capf)
  (add-hook 'prog-mode-hook 'tempel-setup-capf)
  (add-hook 'text-mode-hook 'tempel-setup-capf)
  (global-tempel-abbrev-mode)
)


;;Add extensions
(use-package cape
  :config
  :init
  (add-to-list 'completion-at-point-functions (cape-super-capf #'cape-dabbrev
							       #'cape-abbrev
							       #'cape-symbol
							       #'cape-history
							       #'cape-keyword
							       #'cape-file
							       #'cape-dict)))

(use-package magit
  :custom
  (magit-save-repository-buffers nil)
  :bind (("C-x g" . magit-status)
         ("C-x C-g" . magit-status)))

(use-package marginalia
  ;; Either bind `marginalia-cycle' globally or only in the minibuffer
  :bind (("M-A" . marginalia-cycle))
  :custom
  (marginalia-max-relative-age 0)
  (marginalia-align 'right)
  :init
  (marginalia-mode))

(use-package all-the-icons-completion
  :after (marginalia all-the-icons)
  :hook (marginalia-mode . all-the-icons-completion-marginalia-setup)
  :init
  (all-the-icons-completion-mode))

(use-package goggles
  :diminish (goggles-mode)
  :hook ((prog-mode text-mode) . goggles-mode)
  :config
  (setq-default goggles-pulse t))

(use-package consult
  ;; Replace bindings. Lazily loaded due by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flycheck)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)
         ("M-s D" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init
  (require 'xref)
  (require 'consult-xref)
  (require 'orderless)

  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  (setq xref-prompt-for-identifier nil)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config


  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help))

(use-package flycheck
  :config (global-flycheck-mode))

(use-package ace-window
  :bind (("C-x o" . ace-window))
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (setq aw-scope 'frame)
  (require 'ace-window-posframe)
  (ace-window-posframe-enable))

(use-package consult-flycheck
  :after (consult flycheck))

(use-package vterm
  :config (use-package multi-vterm))

(use-package vundo
  :commands (vundo))

(use-package which-key
  :diminish (which-key-mode)
  :config
  (which-key-mode 1))

(use-package embark
  :defer t
  :bind
  (("C-."   . embark-act)
   ("C-;"   . embark-dwim)
   ("C-h B" . embark-bindings)
   ("M-n"   . embark-next-symbol)
   ("M-p"   . embark-previous-symbol)
   :map minibuffer-local-map
   ("C-c e" . embark-export))
  :init

  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  ;; Show the Embark target at point via Eldoc.  You may adjust the Eldoc
  ;; strategy, if you want to see the documentation from multiple providers.
  (require 'eldoc)


  :config
  (defun embark-which-key-indicator ()
    "An embark indicator that displays keymaps using which-key.
The which-key help message will show the type and value of the
current target followed by an ellipsis if there are further
targets."
    (lambda (&optional keymap targets prefix)
      (if (null keymap)
          (which-key--hide-popup-ignore-command)
	(which-key--show-keymap
	 (if (eq (plist-get (car targets) :type) 'embark-become)
             "Become"
           (format "Act on %s '%s'%s"
                   (plist-get (car targets) :type)
                   (embark--truncate-target (plist-get (car targets) :target))
                   (if (cdr targets) "…" "")))
	 (if prefix
             (pcase (lookup-key keymap prefix 'accept-default)
               ((and (pred keymapp) km) km)
               (_ (key-binding prefix 'accept-default)))
           keymap)
	 nil nil t (lambda (binding)
                     (not (string-suffix-p "-argument" (cdr binding))))))))
  (setq embark-indicators
	'(embark-which-key-indicator
	  embark-highlight-indicator
	  embark-isearch-highlight-indicator))
  (defun embark-hide-which-key-indicator (fn &rest args)
    "Hide the which-key indicator immediately when using the completing-read prompter."
    (which-key--hide-popup-ignore-command)
    (let ((embark-indicators
           (remq #'embark-which-key-indicator embark-indicators)))
      (apply fn args)))

  (advice-add #'embark-completing-read-prompter
              :around #'embark-hide-which-key-indicator)

  ;;(setq embark-verbose-indicator-display-action '((display-buffer-in-side-window (side . left))))
  (setq eldoc-idle-delay 0.25)
  (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)

  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package zoom
  :custom
  (zoom-size '(0.717 . 0.717))
  (temp-buffer-resize-mode t)
  :bind (("C-x +" . zoom))
  :config
  (zoom-mode 1))

(use-package ws-butler
  :diminish (ws-butler-mode)
  :hook ((prog-mode text-mode) . ws-butler-mode))

(use-package topsy
  :hook
  (prog-mode . topsy-mode)
  (magit-section-mode . topsy-mode))

(use-package dumb-jump
  :config
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate))

(use-package eglot
  :after (cape)
  :config
  (advice-add 'eglot-completion-at-point :around #'cape-wrap-buster)
  )


(use-package evil)

(use-package citre
  :init
  ;; recommended by readme
  (require 'citre-config)
  :config
  (setq
   citre-project-root-function (apply-partially #'consult--default-project-function nil)
   citre-default-create-tags-file-location 'project-cache
   citre-use-project-root-when-creating-tags t
   ;; default ctags args passes --objdir which fails if it doesn't exist, this is simpler.
   citre-gtags-args '("--compact")
   citre-auto-enable-citre-mode-modes '(prog-mode)))

;; Local Variables:
;; byte-compile-warnings: (not free-vars unresolved)
;; global-flycheck-mode: -1
;; flycheck-mode: -1
;; flycheck-disabled-checkers: (emacs-lisp-checkdoc)
;; End:
