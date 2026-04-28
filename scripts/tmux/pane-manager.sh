#!/usr/bin/env bash

set -u

show_error() {
  tmux display-message "$1"
}

pane_rows() {
  local current_pane
  current_pane="$(tmux display-message -p '#{pane_id}')"

  tmux list-panes -a -F '#{pane_id}	#{window_id}	#{session_id}	#{session_name}:#{window_index}.#{pane_index}	#{pane_current_command}	#{pane_current_path}' \
    | grep -v "^${current_pane}"$'\t'
}

render_pane_preview() {
  local pane="$1"

  if [ -z "$pane" ]; then
    exit 0
  fi

  tmux capture-pane -t "$pane" -e -p 2>/dev/null
}

run_pane_picker() {
  pane_rows | fzf \
    --delimiter=$'\t' \
    --with-nth=4.. \
    --prompt="Pane > " \
    --header="enter: switch | ctrl-j: join | ctrl-b: break | ctrl-s: swap" \
    --expect=enter,ctrl-j,ctrl-b,ctrl-s \
    --preview="${BASH_SOURCE[0]} preview-pane {1}" \
    --preview-window=right:60%
}

parse_selection() {
  local output="$1"
  local row

  if [ -z "$output" ]; then
    return 1
  fi

  if [[ "$output" == *$'\n'* ]]; then
    row="${output#*$'\n'}"
    row="${row%%$'\n'*}"
  else
    row=""
  fi

  [ -n "$row" ] || return 1
  printf "%s" "$row"
}

switch_to_pane() {
  local pane="$1"
  local window="$2"
  local session="$3"

  tmux switch-client -t "$session" || return 1
  tmux select-window -t "$window" || return 1
  tmux select-pane -t "$pane"
}

join_pane() {
  local pane="$1"

  tmux move-pane -v -s "$pane"
}

break_pane() {
  local pane="$1"

  tmux break-pane -s "$pane"
}

swap_with_current_pane() {
  local pane="$1"
  local current_pane

  current_pane="$(tmux display-message -p '#{pane_id}')"
  tmux swap-pane -s "$current_pane" -t "$pane"
}

manage_panes() {
  local output key row pane window session display_target

  output="$(run_pane_picker)" || exit 0
  key="${output%%$'\n'*}"
  row="$(parse_selection "$output")" || exit 0

  IFS=$'\t' read -r pane window session display_target _ <<<"$row"

  case "$key" in
    ctrl-j)
      join_pane "$pane" || show_error "Failed to join pane $display_target"
      ;;
    ctrl-b)
      break_pane "$pane" || show_error "Failed to break pane $display_target"
      ;;
    ctrl-s)
      swap_with_current_pane "$pane" || show_error "Failed to swap pane $display_target"
      ;;
    enter|"")
      switch_to_pane "$pane" "$window" "$session" || show_error "Failed to switch to pane $display_target"
      ;;
    *)
      exit 0
      ;;
  esac
}

main() {
  local action="${1:-}"
  local target="${2:-}"

  case "$action" in
    preview-pane)
      render_pane_preview "$target"
      ;;
    "")
      manage_panes
      ;;
    *)
      show_error "Usage: pane-manager.sh [preview-pane <pane-id>]"
      exit 1
      ;;
  esac
}

main "$@"
