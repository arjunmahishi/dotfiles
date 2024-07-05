(use-package which-key
  :ensure t
  :config
  (which-key-mode 1))

(use-package company
  :ensure t
  :init
  (global-company-mode 1)
  :config
  (setq company-idle-delay 0.1
		company-minimum-prefix-length 3))

(use-package copilot
  :quelpa (copilot :fetcher github
                   :repo "copilot-emacs/copilot.el"
                   :branch "main"
                   :files ("*.el"))
  :hook (prog-mode . copilot-mode)
  :config
  (define-key copilot-completion-map (kbd "<tab>") 'copilot-accept-completion)
  (setq copilot-indent-offset-warning-disable t)
  (setq copilot-idle-delay 1))
