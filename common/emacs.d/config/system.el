(defun confirm-exit-emacs ()
  "Ask for confirmation before quitting Emacs."
  (interactive)
  (if (y-or-n-p "Are you sure you want to quit Emacs?")
      (save-buffers-kill-terminal)
    (message "Quit canceled")))

(global-set-key (kbd "s-q") 'confirm-exit-emacs)

(defun reload-emacs-config ()
  "Reload the configuration file."
  (interactive)
  (load-file user-init-file))
