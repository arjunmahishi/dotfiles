(add-to-list 'lsp-file-watch-ignored-directories "\\.bazel$")
(add-to-list 'lsp-file-watch-ignored-directories "_bazel$")
(add-to-list 'lsp-file-watch-ignored-directories "\\.cache$")
(add-to-list 'lsp-file-watch-ignored-directories "\\.git$")
(add-to-list 'lsp-file-watch-ignored-directories "c-deps$")

(setq lsp-go-directory-filters
      ["-pkg/ui/node_modules"
       "-c-deps"
       ;; this line should not be needed as gopls should already ignore dot directories.
       "-.bazel"
       "-_bazel"
       ;; The following 4 things are not needed after https://github.com/cockroachdb/cockroach/pull/65327
       ;; is merged.
       "-bazel-bin"
       "-bazel-out"
       "-bazel-cockroach"
       "-bazel-testlogs"])
