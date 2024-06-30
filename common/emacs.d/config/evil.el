(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Install and enable Evil Mode
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1)

  (define-key evil-insert-state-map (kbd "jj") 'evil-normal-state)
  (define-key evil-normal-state-map (kbd "J") 'previous-buffer)
  (define-key evil-normal-state-map (kbd "K") 'next-buffer)
  (define-key evil-normal-state-map (kbd "C-p") 'projectile-find-file)
  (define-key evil-normal-state-map (kbd "C-x") 'kill-buffer)
  (define-key evil-normal-state-map (kbd "vv") 'split-window-right))

;; Additional Evil Mode customizations
(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

(use-package evil-commentary
  :config
  (evil-commentary-mode))

(use-package evil-leader
  :config
  (global-evil-leader-mode)
  (evil-leader/set-leader "<SPC>")
  (evil-leader/set-key
    "b" 'switch-to-buffer
    "k" 'kill-buffer
    "w" 'save-buffer
    "h" 'evil-window-left
    "l" 'evil-window-right
    "j" 'evil-window-down
    "k" 'evil-window-up))

;; Enable relative line numbers
(use-package display-line-numbers
  :ensure nil ;; Built-in package, no need to install
  :hook (prog-mode . display-line-numbers-mode)
  :config
  (setq display-line-numbers-type 'relative))
