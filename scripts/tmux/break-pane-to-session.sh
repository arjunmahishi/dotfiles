#!/usr/bin/env bash

set -u

show_error() {
  tmux display-message "$1"
}

pick_session() {
  local bundled_fzf_tmux="$HOME/.tmux/plugins/tmux-fzf/scripts/.fzf-tmux"

  if [ -n "${FZF_BIN:-}" ]; then
    tmux list-sessions -F '#{session_id}	#{session_name}' \
      | "$FZF_BIN" \
        --delimiter=$'\t' \
        --with-nth=2 \
        --prompt="Session > "
    return
  fi

  if command -v fzf-tmux >/dev/null 2>&1; then
    tmux list-sessions -F '#{session_id}	#{session_name}' \
      | fzf-tmux -p -w 60% -h 40% \
        --delimiter=$'\t' \
        --with-nth=2 \
        --prompt="Session > "
    return
  fi

  tmux list-sessions -F '#{session_id}	#{session_name}' \
    | "$bundled_fzf_tmux" -p -w 60% -h 40% \
      --delimiter=$'\t' \
      --with-nth=2 \
      --prompt="Session > "
}

break_pane_to_session() {
  local source_pane="$1"
  local selection
  local session_id
  local session_name
  local source_session_id
  local source_window_id
  local source_window_panes
  local err

  selection="$(pick_session)" || exit 0
  [ -n "$selection" ] || exit 0

  IFS=$'\t' read -r session_id session_name <<<"$selection"

  if [ -z "$session_id" ]; then
    show_error "Failed to resolve selected session"
    exit 1
  fi

  source_session_id="$(tmux display-message -p -t "$source_pane" '#{session_id}')"
  source_window_id="$(tmux display-message -p -t "$source_pane" '#{window_id}')"
  source_window_panes="$(tmux display-message -p -t "$source_pane" '#{window_panes}')"

  if [ "$source_window_panes" = "1" ]; then
    if [ "$source_session_id" = "$session_id" ]; then
      show_error "Pane is already a standalone window in $session_name"
      exit 0
    fi

    if ! err="$(tmux move-window -s "$source_window_id" -t "$session_id:" 2>&1)"; then
      show_error "Failed to move window into $session_name: $err"
      exit 1
    fi
  else
    if ! err="$(tmux break-pane -s "$source_pane" -t "$session_id:" 2>&1)"; then
      show_error "Failed to break pane into $session_name: $err"
      exit 1
    fi
  fi

  tmux switch-client -t "$session_id" 2>/dev/null || true
}

main() {
  local source_pane="${1:-}"

  if [ -z "$source_pane" ]; then
    show_error "Usage: break-pane-to-session.sh <pane-id>"
    exit 1
  fi

  break_pane_to_session "$source_pane"
}

main "$@"
