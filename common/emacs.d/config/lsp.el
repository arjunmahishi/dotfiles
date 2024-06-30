(use-package lsp-mode
  :ensure t)

(use-package go-mode
  :ensure t
  :hook ((go-mode . lsp-deferred)
	 (go-mode . company-mode)
	 (before-save . gofmt-before-save))
  :config
  (require 'lsp-go)
  (add-to-list 'exec-path "~/go/bin")
  (setq gofmt-command "goimports"))
