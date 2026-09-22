# Neovim editor

Ctrl+G opens the current draft in Neovim with the latest text response from the
active session branch in an editable scratch upper split. Thinking and tool output are
excluded. Uses `nvim` on PATH and loads your normal Neovim configuration.

- Ctrl+W, K / Ctrl+W, J: move between the reference and draft.
- `:wq` in the draft: save and return to pi without submitting.
- `:wqa` from either split: save the draft and return to pi.
- `:cq`: cancel and keep the original pi draft, even if you saved in Neovim.

The reference is a separate scratch buffer and is never read back into the
prompt. Reference edits are discarded on exit without needing to save them;
`:wq` must be used in the draft, not the scratch split. Temporary files are
removed when Neovim exits.

The built-in `app.editor.external` binding must be disabled in
`~/.pi/agent/keybindings.json` so the extension can handle Ctrl+G. Run `/reload`
after installing. To uninstall, remove this directory and restore the built-in
binding by removing that keybindings override.

Tests (Node with TypeScript stripping and Neovim required):

```sh
node --test ~/.pi/agent/extensions/nvim-editor/context.test.mjs
```
