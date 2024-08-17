(setq inhibit-startup-message t)

;; remove the toolbar, scrollbar, and menu bar
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)
(set-fringe-mode 10)

;; set the font
(set-face-attribute 'default nil :font "JetBrainsMono Nerd Font" :height 150)

(use-package nordic-night-theme
  :ensure t
  :config
  (load-theme 'nordic-night t))

;; Custom mode line
(setq-default mode-line-format
  (list
   ;; Evil state
   '(:eval (cond ((evil-normal-state-p) "NORMAL")
                 ((evil-insert-state-p) "INSERT")
                 ((evil-visual-state-p) "VISUAL")
                 ((evil-motion-state-p) "MOTION")
                 ((evil-replace-state-p) "REPLACE")
                 ((evil-operator-state-p) "OPERATOR")
                 (t "EMACS"))) "  "

   '(:eval (buffer-name)) "  "

   ;; float right
   ;'(:eval (propertize " " 'display '((space :align-to right-fringe)))) 
    
   ;; Position in buffer
   '(:eval (format "L%03d:%02d" (line-number-at-pos) (current-column))) "  "

   ;; File type
   '(:eval (symbol-name major-mode)) "  "

   ;; Percentage in buffer
   '(:eval (format " %3d%%%%" (/ (* 100 (point)) (point-max)))) "  "

   ;; git branch using magit
   '(:eval (when (and (buffer-file-name) (fboundp 'magit-get-current-branch))
			 (concat "  " (magit-get-current-branch))))
))

(use-package ivy
  :ensure t
  :bind (("C-n" . ivy-next-line)
         ("C-p" . ivy-previous-line))
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers nil)
  (setq ivy-count-format "(%d/%d) ")
  (setq ivy-initial-inputs-alist nil)
  (setq ivy-wrap t)
  (setq ivy-height 20))

(use-package counsel
  :ensure t
  :config
  (ivy-mode 1)
  (defun counsel-fd (&optional initial-input)
    "Search for a file using fd."
    (interactive)
    (counsel-require-program "fd")
    (let ((counsel-fd-base-command
           "fd --type f --hidden --follow --exclude .git --color never "))
      (ivy-read "Find file: "
                (split-string (shell-command-to-string counsel-fd-base-command) "\n" t)
                :initial-input initial-input
                :matcher #'counsel--find-file-matcher
                :action #'counsel-find-file-action
                :preselect (counsel--preselect-file)
                :require-match t
                :history 'file-name-history
                :keymap counsel-find-file-map
                :caller 'counsel-fd))))

;; Smooth scrolling
(setq scroll-margin 3
  scroll-conservatively 101
  scroll-step 1
  scroll-preserve-screen-position t)

(setq-default tab-width 4)

(setq treesit-language-source-alist
   '((bash "https://github.com/tree-sitter/tree-sitter-bash")
     (cmake "https://github.com/uyha/tree-sitter-cmake")
     (css "https://github.com/tree-sitter/tree-sitter-css")
     (elisp "https://github.com/Wilfred/tree-sitter-elisp")
     (go "https://github.com/tree-sitter/tree-sitter-go")
     (html "https://github.com/tree-sitter/tree-sitter-html")
     (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
     (json "https://github.com/tree-sitter/tree-sitter-json")
     (make "https://github.com/alemuller/tree-sitter-make")
     (markdown "https://github.com/ikatyang/tree-sitter-markdown")
     (python "https://github.com/tree-sitter/tree-sitter-python")
     (toml "https://github.com/tree-sitter/tree-sitter-toml")
     (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
     (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
     (yaml "https://github.com/ikatyang/tree-sitter-yaml")))

(use-package git-gutter
  :ensure t
  :hook (prog-mode . git-gutter-mode))

(use-package git-gutter-fringe
  :ensure t
  :config
  (define-fringe-bitmap 'git-gutter-fr:added [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:modified [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:deleted [224] nil nil '(center repeated)))

;; install and enable good-scroll
(use-package good-scroll
  :ensure t
  :config
  (good-scroll-mode 1))
