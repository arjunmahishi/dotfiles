;; Install and configure key-chord
(use-package key-chord
  :ensure t
  :config
  (key-chord-mode 1)

  (key-chord-define evil-insert-state-map "jj" 'evil-normal-state)
  (key-chord-define evil-normal-state-map "vv" 'evil-window-vsplit))
