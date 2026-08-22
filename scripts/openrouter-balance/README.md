# OpenRouter balance menu bar app

A small native macOS menu bar app that displays the remaining OpenRouter credits as black text.

- Refreshes automatically every 5 minutes
- Supports manual refresh from the menu
- Reads the API token from `~/tokens/openrouter`
- Does not store or print the token
- Shows `ERR` in red when a refresh fails

## Install

Create a virtual environment outside this repository and install the dependency:

```sh
python3 -m venv ~/.venvs/openrouter-balance
~/.venvs/openrouter-balance/bin/pip install -r scripts/openrouter-balance/requirements.txt
```

The token file must contain an OpenRouter API token:

```sh
mkdir -p ~/tokens
chmod 700 ~/tokens
chmod 600 ~/tokens/openrouter
```

## Run

From the repository root:

```sh
~/.venvs/openrouter-balance/bin/python scripts/openrouter-balance/openrouter_balance.py
```

The balance text is always black, regardless of the remaining credit.

Click the menu bar balance to access **Refresh** and **Quit**.

## Run at login

Use a macOS LaunchAgent to start the app in your logged-in GUI session. The commands below use this checkout path:

```text
/Users/arjunmahishi/Documents/dev/projects/dotfiles
```

If you move the repository, update the second `ProgramArguments` path in the plist before loading it.

### Install the app

From the repository root:

```sh
cd /Users/arjunmahishi/Documents/dev/projects/dotfiles

python3 -m venv ~/.venvs/openrouter-balance
~/.venvs/openrouter-balance/bin/pip install \
  -r scripts/openrouter-balance/requirements.txt
```

### Create and load the LaunchAgent

```sh
mkdir -p ~/Library/LaunchAgents ~/Library/Logs

cat > ~/Library/LaunchAgents/com.arjunmahishi.openrouter-balance.plist <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.arjunmahishi.openrouter-balance</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/arjunmahishi/.venvs/openrouter-balance/bin/python</string>
        <string>/Users/arjunmahishi/Documents/dev/projects/dotfiles/scripts/openrouter-balance/openrouter_balance.py</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/Users/arjunmahishi/Library/Logs/openrouter-balance.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/arjunmahishi/Library/Logs/openrouter-balance.error.log</string>
</dict>
</plist>
EOF

plutil -lint ~/Library/LaunchAgents/com.arjunmahishi.openrouter-balance.plist
launchctl bootstrap gui/$(id -u) \
  ~/Library/LaunchAgents/com.arjunmahishi.openrouter-balance.plist
```

`RunAtLoad` starts it when you log in. `KeepAlive` is intentionally omitted, so selecting **Quit** does not immediately relaunch the app.

### Check status and logs

```sh
launchctl print gui/$(id -u)/com.arjunmahishi.openrouter-balance
tail -f ~/Library/Logs/openrouter-balance.error.log
```

### Restart after updating the code

```sh
launchctl bootout gui/$(id -u)/com.arjunmahishi.openrouter-balance 2>/dev/null || true
launchctl bootstrap gui/$(id -u) \
  ~/Library/LaunchAgents/com.arjunmahishi.openrouter-balance.plist
```

### Disable startup

```sh
launchctl bootout gui/$(id -u)/com.arjunmahishi.openrouter-balance
rm ~/Library/LaunchAgents/com.arjunmahishi.openrouter-balance.plist
```
