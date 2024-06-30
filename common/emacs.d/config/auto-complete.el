(use-package ivy
  :ensure t
  :bind (("C-n" . ivy-next-line)
	 ("C-p" . ivy-previous-line))
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (setq ivy-re-builders-alist
	'((t . ivy--regex-ignore-order)))
  (setq ivy-initial-inputs-alist nil)
  (setq ivy-wrap t)
  (setq ivy-height 20))

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
