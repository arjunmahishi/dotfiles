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
))

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

;; (use-package ivy-rich
;;   :init
;;   (ivy-rich-mode 1))

;; Smooth scrolling
(setq scroll-margin 3
  scroll-conservatively 101
  scroll-step 1
  scroll-preserve-screen-position t)

(setq-default tab-width 4)
