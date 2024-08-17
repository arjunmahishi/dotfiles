(use-package lsp-mode
  :ensure t
  :hook ((go-mode . lsp-deferred))
  :config
  (setq lsp-enable-symbol-highlighting nil)
  (setq lsp-headerline-breadcrumb-enable nil)
  (setq lsp-lens-enable nil)
  (setq lsp-enable-snippet nil)
  (setq lsp-eldoc-enable-hover nil))

(use-package lsp-ui
  :ensure t
  :config
  (setq lsp-ui-doc-enable t)
  (setq lsp-file-watch-threshold 10000)
  (setq lsp-ui-doc-show-with-cursor nil))

(use-package go-mode
  :ensure t
  :hook (
	 (go-mode . lsp-deferred)
	 (go-mode . company-mode)
	 (go-mode . yas-minor-mode)
	 (before-save . gofmt-before-save))
  :config
  (require 'lsp-go)
  (add-to-list 'exec-path "~/go/bin")
  (setq gofmt-command "goimports"))
