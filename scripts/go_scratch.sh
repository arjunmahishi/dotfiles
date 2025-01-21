#!/bin/bash

# Generate a random directory in /tmp/
DIR="/tmp/scratch_$(date +%s%N)"
mkdir -p "$DIR"
cd "$DIR" || exit

# Initialize Go module
go mod init scratch

# Create main.go file
cat <<EOF > main.go
package main

import "fmt"

func main() {
    fmt.Println("Hello, World!")
}
EOF

# Create or find the tmux session
SESSION="scratch"
tmux has-session -t $SESSION 2>/dev/null

if [ $? != 0 ]; then
    tmux new-session -d -s $SESSION -c "$DIR"
else
    tmux new-window -t $SESSION -c "$DIR"
fi

# Open main.go in Vim and split the pane
tmux send-keys -t $SESSION "vim main.go" C-m
tmux split-window -h -t $SESSION -c "$DIR"
tmux send-keys -t $SESSION "go run ." C-m

# Check if already inside a tmux session
if [ -n "$TMUX" ]; then
    tmux switch-client -t $SESSION
else
    tmux attach-session -t $SESSION
fi
