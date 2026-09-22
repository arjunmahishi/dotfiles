# Pi

My user-level Pi configuration: instructions, settings, keybindings, extensions,
and themes. Skills, model overrides, credentials, installed packages, and runtime
state stay outside this directory.

## Setup

Install [Pi](https://pi.dev), then link the selected files from this checkout:

```sh
# Run from the dotfiles repo root. Move any existing targets aside first.
mkdir -p "$HOME/.pi/agent"
for name in AGENTS.md settings.json keybindings.json extensions themes; do
  ln -s "$PWD/common/pi/$name" "$HOME/.pi/agent/$name"
done
```

Do not link the entire agent directory: it also holds credentials and session
history. Changes to the linked files are changes to this checkout.

The default provider/model in `settings.json` reflects my local setup and may
not be available on another account. Choose an available model and authenticate
with your own credentials. The configured npm package is `@narumitw/pi-btw`;
`pi update --extensions` reconciles package installations.

## Extensions

- `jj-bookmark.ts`: shows the JJ bookmark in the footer; requires `jj`.
- `rtk.ts`: rewrites shell commands through RTK; requires `rtk >= 0.23.0`.
- `nvim-editor/`: edits drafts with Ctrl+G; requires `nvim`. See its README.
- `session-tools/`: reads/searches local sessions when explicitly requested.
- `tui.ts`: opens local files in the default browser on macOS.
- `herdr-agent-state.ts`: Herdr-managed integration, enabled only in a Herdr
  environment. Herdr updates may overwrite this file.
