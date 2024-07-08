(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; Bootstrap `use-package`
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; (add-to-list load-path (expand-file-name "packages/quelpa.el" user-emacs-directory))
; (require 'quelpa)

(use-package quelpa
  :ensure t)

(quelpa
 '(quelpa-use-package
   :fetcher git
   :url "https://github.com/quelpa/quelpa-use-package.git"))
(require 'quelpa-use-package)

;; Load individual configuration files
(load (expand-file-name "config/ui.el" user-emacs-directory))
(load (expand-file-name "config/evil.el" user-emacs-directory))
(load (expand-file-name "config/kbd.el" user-emacs-directory))
(load (expand-file-name "config/file-management.el" user-emacs-directory))
(load (expand-file-name "config/auto-complete.el" user-emacs-directory))
(load (expand-file-name "config/lsp.el" user-emacs-directory))
(load (expand-file-name "config/cockroach.el" user-emacs-directory))
(load (expand-file-name "config/system.el" user-emacs-directory))

(require 'server)
(unless (server-running-p)
  (server-start))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("7c7026a406042e060bce2b56c77d715c3a4e608c31579d336cb825b09e60e827" "7342266ffff707cc104313c9153342e44a47a9f22ed7157e4893aac74091ad27" default))
 '(package-selected-packages
   '(lsp-ui git-gutter-fringe git-gutter editorconfig quelpa-use-package quelpa copilot magit nordic-night-theme go-mode company which-key lsp-mode key-chord evil-search-highlight-persist evil-leader evil-commentary evil-surround evil)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(button ((t (:background "#121212" :foreground "#88c0d0" :box (:line-width (1 . 1) :color "#121212" :style sunken-button))))))
