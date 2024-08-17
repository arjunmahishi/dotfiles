(use-package projectile
    :diminish projectile-mode
    :config
    (projectile-mode +1)
    ;; Recommended keymap prefix on Windows/Linux
    ;; (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
    ;; Recommended keymap prefix on macOS
    (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
    (setq projectile-switch-project-action #'projectile-dired)
	(setq projectile-enable-caching t)
	(setq projectile-indexing-method 'alien)
	(setq projectile-completion-system 'ido)
	;; (setq projectile-generic-command "fd . -0 --type f --color=never")
	(add-to-list 'projectile-globally-ignored-directories "node_modules"))

;; Integrate Projectile with Ivy
(use-package counsel-projectile
    :config
    (counsel-projectile-mode))

(use-package magit
  :ensure t
  :commands (magit-status magit-get-current-branch))
