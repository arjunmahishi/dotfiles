---
name: tmux
description: >
  Manage tmux sessions, windows, and panes via the tmux CLI. Use when the user
  asks to run background processes, set up multi-pane layouts, monitor commands,
  or work with tmux in any way.
---

# tmux CLI Skill

Use `tmux` commands via Bash to manage terminal sessions, windows, and panes.
Do NOT use the tmux MCP server — use the CLI directly.

All commands below are safe to run and do not require user confirmation unless
they kill sessions or panes containing unsaved work.

## Session Management

```bash
tmux list-sessions                          # list all sessions (alias: tmux ls)
tmux new-session -d -s myapp                # create detached session
tmux new-session -d -s myapp -c ~/project   # create with working directory
tmux kill-session -t myapp                  # kill a session (confirm first)
tmux rename-session -t old new              # rename a session
tmux has-session -t myapp 2>/dev/null       # check if session exists (exit code)
```

## Window Management

```bash
tmux new-window -t myapp                    # new window in session
tmux new-window -t myapp -n build           # new window with name
tmux new-window -t myapp -n build -c ~/src  # with name and working directory
tmux rename-window -t myapp:0 main          # rename window
tmux select-window -t myapp:1               # switch to window by index
tmux kill-window -t myapp:1                 # kill a window (confirm first)
tmux list-windows -t myapp                  # list windows in a session
```

## Pane Management

```bash
tmux split-window -t myapp -h               # split horizontally (side by side)
tmux split-window -t myapp -v               # split vertically (top/bottom)
tmux split-window -t myapp -h -c ~/src      # split with working directory
tmux select-pane -t myapp:0.1               # select pane (session:window.pane)
tmux kill-pane -t myapp:0.1                 # kill a pane
tmux list-panes -t myapp:0                  # list panes in a window
tmux resize-pane -t myapp:0.1 -R 20         # resize pane right by 20 cells
tmux resize-pane -t myapp:0.1 -D 10         # resize pane down by 10 cells
# Resize directions: -U (up), -D (down), -L (left), -R (right)
```

## Command Execution

```bash
# Send a command to a specific pane
tmux send-keys -t myapp:0.0 'make build' Enter

# Send keys without pressing Enter (useful for partial input)
tmux send-keys -t myapp:0.0 'echo hello'

# Send Ctrl-C to interrupt a running process
tmux send-keys -t myapp:0.0 C-c

# Run a command in a new window directly
tmux new-window -t myapp -n tests 'go test ./...'
```

## Content Capture

```bash
# Capture visible pane content
tmux capture-pane -t myapp:0.0 -p

# Capture with scrollback history (last 100 lines)
tmux capture-pane -t myapp:0.0 -p -S -100

# Capture entire scrollback
tmux capture-pane -t myapp:0.0 -p -S -

# Check if a command is still running (look for shell prompt in output)
tmux capture-pane -t myapp:0.0 -p | tail -5
```

## Layouts

```bash
tmux select-layout -t myapp:0 even-horizontal  # equal columns
tmux select-layout -t myapp:0 even-vertical     # equal rows
tmux select-layout -t myapp:0 main-horizontal   # large top, small bottom panes
tmux select-layout -t myapp:0 main-vertical     # large left, small right panes
tmux select-layout -t myapp:0 tiled             # equal grid
```

## Target Syntax

Targets follow the pattern `session:window.pane`:
- `myapp` — session named "myapp"
- `myapp:0` — first window in "myapp"
- `myapp:0.1` — second pane in first window of "myapp"
- `myapp:build` — window named "build" in "myapp"

## Common Workflows

### Run a background process and check on it

```bash
tmux new-session -d -s bg
tmux send-keys -t bg 'long-running-command' Enter
# ... later ...
tmux capture-pane -t bg -p | tail -20    # check output
```

### Start roachdev claude in a new pane with a prompt

```bash
tmux new-session -d -s dev -c ~/project
tmux send-keys -t dev "roachdev claude --prompt 'fix the failing tests'" Enter
```

### Monitor a long-running command

```bash
tmux new-window -t dev -n watch
tmux send-keys -t dev:watch 'watch -n 5 curl -s http://localhost:8080/health' Enter
# Check on it later:
tmux capture-pane -t dev:watch -p
```

### Multi-pane development layout

```bash
tmux new-session -d -s work -c ~/project
tmux split-window -t work -h              # editor | terminal
tmux split-window -t work:0.1 -v          # editor | terminal / logs
tmux send-keys -t work:0.1 'make watch' Enter
tmux send-keys -t work:0.2 'tail -f app.log' Enter
tmux select-layout -t work:0 main-vertical
```

### Wait for a command to finish

```bash
# Poll until the shell prompt reappears
while ! tmux capture-pane -t myapp:0.0 -p | tail -1 | grep -q '\$'; do
  sleep 2
done
echo "Command finished"
tmux capture-pane -t myapp:0.0 -p | tail -20
```
