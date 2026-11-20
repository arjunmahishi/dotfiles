# Pi

My user-level Pi configuration: instructions, settings, keybindings, extensions,
and themes. Skills, model overrides, credentials, installed packages, and runtime
state stay outside this directory.

## Setup

Install [Pi](https://pi.dev), then link the selected files from this checkout:

```sh
# Run from the dotfiles repo root. Move any existing targets aside first.
mkdir -p "$HOME/.pi/agent"
for name in AGENTS.md settings.json keybindings.json extensions themes prompts scripts; do
  ln -s "$PWD/common/pi/$name" "$HOME/.pi/agent/$name"
done
```

Do not link the entire agent directory: it also holds credentials and session
history. Changes to the linked files are changes to this checkout.

The default provider/model in `settings.json` reflects my local setup and may
not be available on another account. Choose an available model and authenticate
with your own credentials. The configured npm package is `@narumitw/pi-btw`;
`pi update --extensions` reconciles package installations.

## Prompts

- `sessions-retro.md`: `/sessions-retro [since]` analyzes the project's Pi
  sessions for friction and proposes skill/AGENTS.md fixes; uses
  `scripts/session-digest.py` (requires `python3`).

## Scripts

Run `~/.pi/agent/scripts/session-metrics.py [session-id]` for one PR-ready line
with human time, agent time, and logged cost by model (Python 3.11+). Omit the
ID to use `$PI_SESSION_FILE` inside Pi.

The script reads the latest persisted branch through its last user, assistant,
or tool-result entry. Agent time runs from a user message to a reply that
doesn't call tools, including the tools in between. Human time is the remaining
elapsed time, including the gap before the first prompt and any time away.
Costs are Pi's estimates, not bills; the total and model subtotals are rounded
independently.

## Extensions

- `jj-bookmark.ts`: shows the JJ bookmark in the footer; requires `jj`.
- `rtk.ts`: rewrites shell commands through RTK; requires `rtk >= 0.23.0`.
- `nvim-editor/`: edits drafts with Ctrl+G; requires `nvim`. See its README.
- `session-tools/`: reads/searches local sessions when explicitly requested.
- `session-metrics.ts`: `/session-metrics [session-id]` shows the same one-line
  summary without calling a model. Omit the ID for the active saved session.
- `tui.ts`: opens local files in the default browser on macOS.
- `herdr-agent-state.ts`: Herdr-managed integration, enabled only in a Herdr
  environment. Herdr updates may overwrite this file.
