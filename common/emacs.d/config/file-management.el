;; Install and configure Projectile
(use-package projectile
  :diminish projectile-mode
  :config
  (projectile-mode +1)
  ;; Recommended keymap prefix on Windows/Linux
  ;; (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  ;; Recommended keymap prefix on macOS
 (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (setq projectile-project-search-path '("~/projects/" "~/work/"))
  (setq projectile-switch-project-action #'projectile-dired))

;; Integrate Projectile with Ivy (optional but recommended)
(use-package counsel-projectile
  :config
  (counsel-projectile-mode))
