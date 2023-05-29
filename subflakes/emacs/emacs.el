;; requirement of use-package, this comes first.
(use-package bind-key
  :config
  (add-to-list 'same-window-buffer-names "*Personal Keybindings*"))

;; base configuration
(use-package emacs
  :ensure nil
  :config

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

  ;; adopt sane backup settings.
  (defvar --backup-directory (concat user-emacs-directory "backups"))
  (if (not (file-exists-p --backup-directory))
          (make-directory --backup-directory t))
  (setq backup-directory-alist `(("." . ,--backup-directory)))
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

  (add-hook 'prog-mode-hook 'display-line-numbers-mode)
  (menu-bar-mode -1)
  (scroll-bar-mode -1)
  (tool-bar-mode -1)
  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t))

(use-package savehist
  :ensure nil
  :init
  (savehist-mode))

(use-package eshell)

(use-package modus-themes
  :config
  (require-theme 'modus-themes)
  (setq modus-themes-bold-constructs t
      modus-themes-italic-constructs t)
  (setq modus-themes-common-palette-overrides
      modus-themes-preset-overrides-faint)
  (setq modus-themes-subtle-line-numbers t
        modus-themes-syntax '(alt-syntax faint)
        modus-themes-diffs 'desaturated
        modus-themes-bold-constructs nil)
  (load-theme 'modus-operandi-tinted)
  ;;(load-theme 'modus-operandi-deuteranopia)
  )

(use-package treesit
  ;; Optional, but recommended. Tree-sitter enabled major modes are
  ;; distinct from their ordinary counterparts.
  ;;
  ;; You can remap major modes with `major-mode-remap-alist'. Note
  ;; that this does *not* extend to hooks! Make sure you migrate them
  ;; also
  (dolist (mapping '((python-mode . python-ts-mode)
                     (css-mode . css-ts-mode)
                     (typescript-mode . tsx-ts-mode)
                     (js-mode . js-ts-mode)
                     (css-mode . css-ts-mode)
                     (yaml-mode . yaml-ts-mode)))
    (add-to-list 'major-mode-remap-alist mapping))

  :config
  (use-package combobulate
    :demand t
    :hook ((python-ts-mode . combobulate-mode)
           (js-ts-mode . combobulate-mode)
           (css-ts-mode . combobulate-mode)
           (yaml-ts-mode . combobulate-mode)
           (typescript-ts-mode . combobulate-mode)
           (tsx-ts-mode . combobulate-mode))
    ))

(use-package display-line-numbers
  :ensure nil
  :hook  (prog-mode-hook . display-line-numbers-mode))

(use-package whitespace
  :diminish (global-whitespace-mode
             whitespace-mode
             whitespace-newline-mode)
  :commands (whitespace-buffer
             whitespace-cleanup
             whitespace-mode)
  :hook ((prog-mode-hook . whitespace-mode)
	 (c-mode-common-hook . whitespace-mode)))

(use-package mosey
  :demand t
  :bind (
         ("C-a" . mosey-backward-cycle)
         ("C-e" . mosey-forward-cycle)
         ))

(use-package eshell-vterm
  :demand t
  :after eshell
  :config
  (eshell-vterm-mode))

(use-package ement
  :demand t
  :commands (ement-connect)
  :config
  (require 'ement-tabulated-room-list)
  (setq ement-save-sessions t))

(use-package kind-icon
  :demand t
  :after corfu
  :custom
  (kind-icon-default-face 'corfu-default) ; to compute blended backgrounds correctly
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package eshell-p10k
  :demand t
  :after eshell
  :config
  (setq eshell-prompt-function #'eshell-p10k-prompt-function
        eshell-prompt-regexp eshell-p10k-prompt-string))

(use-package with-editor
  :demand t
  :after (eshell vterm)
  :init
  (keymap-global-set "<remap> <async-shell-command>"
                     #'with-editor-async-shell-command)
  (keymap-global-set "<remap> <shell-command>"
                     #'with-editor-shell-command)
  :hook ((shell-mode-hook . with-editor-export-editor)
	 (term-exec-hook . with-editor-export-editor)
	 (vterm-mode-hook . with-editor-export-editor)
	 (eshell-mode-hook . with-editor-export-editor)))

;; (use-package disaster
;;   :commands (disaster))

(use-package dashboard
  :demand t
  :custom
  (dashboard-image-banner-max-height 200)
  (dashboard-set-footer nil)
  (dashboard-projects-backend 'projectile)
  :init
  (setq dashboard-banner-logo-title
	"He who despairs of the human condition is a coward, but he who has hope for it is a fool.")
  (setq dashboard-startup-banner "@dashboardLogo@")
  :config
  (dashboard-setup-startup-hook))

(use-package dirvish
  :config
  (dirvish-override-dired-mode))

(use-package consult-dir
  :after (vertico projectile)
  :config
  (setq consult-dir-project-list-function #'consult-dir-projectile-dirs)
  :bind (("C-x C-d" . consult-dir)
         :map vertico-map
         ("C-x C-d" . consult-dir)
         ("C-x C-j" . consult-dir-jump-file)))

(use-package wgrep
  :demand t)

(use-package age
  :ensure t
  :demand t
  :config
  (age-file-enable))

(use-package avy
  :demand t
  :bind (("M-s a" . avy-goto-char-timer))
  :config
  (setq avy-timeout-seconds 0.25)
  )

(use-package flycheck
  :config (global-flycheck-mode))

(use-package sideline
  :after flycheck
  :hook (flycheck-mode . sideline-mode)
  :init
  (setq sideline-backends-skip-current-line t  ; don't display on current line
        sideline-order-left 'down              ; or 'up
        sideline-order-right 'up               ; or 'down
        sideline-format-left "%s   "           ; format for left aligment
        sideline-format-right "   %s"          ; format for right aligment
        sideline-priority 100                  ; overlays' priority
        sideline-display-backend-name t)      ; display the backend name  
  (setq sideline-backends-right '(sideline-flycheck)))

(use-package sideline-flycheck
  :hook (flycheck-mode . sideline-flycheck-setup))

(use-package wgrep
  :config
  (setq wgrep-auto-save-buffer t))

(use-package direnv
 :config
 (direnv-mode))

(use-package which-key
  :config (which-key-mode))

;; (use-package zenburn-emacs
;;   :demand t
;;   :config
;;   ;; use variable-pitch fonts for some headings and titles
;;   (setq zenburn-use-variable-pitch t)

;;   ;; scale headings in org-mode
;;   (setq zenburn-scale-org-headlines t)

;;   ;; scale headings in outline-mode
;;   (setq zenburn-scale-outline-headlines t)
;;   ;; Global settings (defaults)
;;   ;;(load-theme 'zenburn t)
;;   )

;; april 2023: affe is brittle.
;; (use-package affe
;;   :bind (("C-x C-f" . affe-find))
;;   :demand t
;;   :config
;;   (defun affe-orderless-regexp-compiler (input _type _ignorecase)
;;     (setq input (orderless-pattern-compiler input))
;;     (cons input (apply-partially #'orderless--highlight input)))
;;   (setq affe-regexp-compiler #'affe-orderless-regexp-compiler)
;;   (consult-customize affe-grep :preview-key "M-."))

(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
	completion-category-defaults nil
	completion-category-overrides '((file (styles partial-completion)))))

(use-package nix-mode
  :mode "\\.(nix|flake)$")
(use-package feature-mode
  :mode "\\.feature$")
(use-package json-mode
  :mode "\\.json$")

(use-package vertico-posframe
  :after vertico
  :config
  (setq vertico-posframe-poshandler #'posframe-poshandler-frame-top-center)
  (vertico-posframe-mode 1))

(use-package vterm)

;; Enable vertico
(use-package vertico
  :config
  (vertico-mode)
  ;; Different scroll margin
  (setq vertico-scroll-margin 0)
  ;; Show more candidates
  (setq vertico-count 20)
  ;; Grow and shrink the Vertico minibuffer
  (setq vertico-resize t)
  ;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
  (setq vertico-cycle t))

(use-package corfu
  :config
  (global-corfu-mode))

;;Add extensions
(use-package cape
  ;; Bind dedicated completion commands
  ;; Alternative prefix keys: C-c p, M-p, M-+, ...
  :bind (("C-c t p" . completion-at-point) ;; capf
         ("C-c t t" . complete-tag)        ;; etags
         ("C-c t d" . cape-dabbrev)        ;; or dabbrev-completion
         ("C-c t h" . cape-history)
         ("C-c t f" . cape-file)
         ("C-c t k" . cape-keyword)
         ("C-c t s" . cape-symbol)
         ("C-c t a" . cape-abbrev)
         ("C-c t l" . cape-line)
         ("C-c t w" . cape-dict)
         ("C-c t ^" . cape-tex)
         ("C-c t &" . cape-sgml)
         ("C-c t r" . cape-rfc1345))
  :init
  ;; Add `completion-at-point-functions', used by `completion-at-point'.
  ;; NOTE: The order matters!
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block)
  (add-to-list 'completion-at-point-functions #'cape-history)
  (add-to-list 'completion-at-point-functions #'cape-keyword)
  (add-to-list 'completion-at-point-functions #'cape-tex)
  (add-to-list 'completion-at-point-functions #'cape-sgml)
  (add-to-list 'completion-at-point-functions #'cape-rfc1345)
  (add-to-list 'completion-at-point-functions #'cape-abbrev)
  (add-to-list 'completion-at-point-functions #'cape-dict)
  (add-to-list 'completion-at-point-functions #'cape-symbol)
  (add-to-list 'completion-at-point-functions #'cape-line))

(use-package magit
  :bind (("C-x g" . magit-status)
         ("C-x C-g" . magit-status)))

(use-package telephone-line
  :demand t
  :custom
  (telephone-line-primary-left-separator 'telephone-line-cubed-left)
  (telephone-line-secondary-left-separator 'telephone-line-cubed-hollow-left)
  (telephone-line-primary-right-separator 'telephone-line-cubed-right)
  (telephone-line-secondary-right-separator 'telephone-line-cubed-hollow-right)
  (telephone-line-height 24)
  :config
  (require 'projectile)
  (require 'flycheck)
  (setq telephone-line-lhs '((accent . (
					telephone-line-vc-segment
					telephone-line-projectile-segment
					telephone-line-flycheck-segment
					telephone-line-process-segment))
			     (nil . (telephone-line-projectile-segment telephone-line-buffer-segment))))
  (telephone-line-mode t))

(use-package marginalia
  ;; Either bind `marginalia-cycle' globally or only in the minibuffer
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle)))

(use-package goggles
  :hook ((prog-mode text-mode) . goggles-mode)
  :config
  (setq-default goggles-pulse t))

(use-package consult
  :demand t
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
  (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

  (autoload 'projectile-project-root "projectile")
  (setq consult-project-function (lambda (_) (projectile-project-root))))

(use-package flycheck
  :config (global-flycheck-mode))

(use-package consult-flycheck
  :after (consult flycheck))

(use-package embark
  :bind
  (("C-."   . embark-act)
   ("C-;"   . embark-dwim)
   ("C-h B" . embark-bindings)
   ("M-n"   . embark-next-symbol)
   ("M-p"   . embark-prev-symbol)
  )

  :init

  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  ;; Show the Embark target at point via Eldoc.  You may adjust the Eldoc
  ;; strategy, if you want to see the documentation from multiple providers.
  (require 'eldoc)

  :config
  (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)

  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :ensure t
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package dumb-jump
  :config
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate))

(use-package projectile
  :config
  (projectile-mode +1)
  :bind
  (:map projectile-mode-map
	("C-c p" . projectile-command-map)
	;;("C-c p s" . affe-grep)
	;;("C-c p f" . affe-find)
	)
  )

(use-package org
  :mode (("\\.org$" . org-mode))
  :config
  (progn
    ;; config stuff
    ))

;; Local Variables:
;; byte-compile-warnings: (not free-vars unresolved)
;; global-flycheck-mode: -1
;; flycheck-mode: -1
;; flycheck-disabled-checkers: (emacs-lisp-checkdoc)
;; End:
