#!/usr/bin/env bash

set -u

show_error() {
  tmux display-message "$1"
}

pick_session() {
  tmux list-sessions -F "#{session_name}" | fzf --prompt="Session > "
}

window_search_rows() {
  tmux list-windows -a -F "#{session_name}:#{window_index} #{session_name}  #{window_name}"
}

active_pane_for_window() {
  local window_target="$1"

  tmux list-panes -t "$window_target" -F "#{?pane_active,#{pane_id},}" 2>/dev/null | sed -n '/./{p;q;}'
}

render_window_preview() {
  local window_target="$1"
  local pane
  local preview

  if [ -z "$window_target" ]; then
    exit 0
  fi

  pane="$(active_pane_for_window "$window_target")"

  if [ -z "$pane" ]; then
    printf "No active pane found for %s\n" "$window_target"
    exit 0
  fi

  preview="$(tmux capture-pane -a -t "$pane" -e -p -J -S -2000 2>/dev/null | tail -n 120)"
  if [ -z "$preview" ]; then
    preview="$(tmux capture-pane -t "$pane" -e -p -J -S -2000 2>/dev/null | tail -n 120)"
  fi

  printf "%s\n" "$preview"
}

run_window_picker() {
  window_search_rows | fzf \
    --prompt="Window > " \
    --with-nth=2.. \
    --header="enter: open | ctrl-r: rename | ctrl-d: delete" \
    --expect=enter,ctrl-r,ctrl-d \
    --preview="${BASH_SOURCE[0]} preview-window {1}" \
    --preview-window=right:60%
}

create_window_in_session() {
  local session="$1"
  local window_name="$2"
  local current_path="$3"

  if [ -z "$window_name" ]; then
    tmux new-window -t "$session:" -c "$current_path"
  else
    tmux new-window -t "$session:" -n "$window_name" -c "$current_path"
  fi
}

window_name_exists_in_session() {
  local session="$1"
  local window_name="$2"

  tmux list-windows -t "$session:" -F "#{window_name}" | grep -Fx -- "$window_name" >/dev/null
}

window_session_name() {
  local target="$1"

  tmux display-message -p -t "$target" "#{session_name}" 2>/dev/null
}

window_display_name() {
  local target="$1"

  tmux display-message -p -t "$target" "#{window_name}" 2>/dev/null
}

prompt_window_name() {
  local session="$1"
  local name

  while true; do
    IFS= read -r -p "Enter window name (leave empty for tmux default): " name || return 1

    if [ -z "$name" ]; then
      printf "%s" "$name"
      return 0
    fi

    if ! window_name_exists_in_session "$session" "$name"; then
      printf "%s" "$name"
      return 0
    fi

    printf "Name '%s' already exists in session '%s'. Try again.\n" "$name" "$session" >&2
  done
}

rename_window_interactive() {
  local target="$1"
  local session
  local current_name
  local new_name

  session="$(window_session_name "$target")"
  current_name="$(window_display_name "$target")"

  if [ -z "$session" ] || [ -z "$current_name" ]; then
    show_error "Unable to resolve selected window"
    return 1
  fi

  while true; do
    IFS= read -r -p "Rename '$current_name' to: " new_name || return 0

    if [ -z "$new_name" ] || [ "$new_name" = "$current_name" ]; then
      return 0
    fi

    if window_name_exists_in_session "$session" "$new_name"; then
      printf "Name '%s' already exists in session '%s'. Try again.\n" "$new_name" "$session" >&2
      continue
    fi

    if ! tmux rename-window -t "$target" "$new_name"; then
      show_error "Failed to rename window in $session"
      return 1
    fi

    return 0
  done
}

delete_window_interactive() {
  local target="$1"
  local session
  local name
  local answer

  session="$(window_session_name "$target")"
  name="$(window_display_name "$target")"

  if [ -z "$session" ] || [ -z "$name" ]; then
    show_error "Unable to resolve selected window"
    return 1
  fi

  IFS= read -r -p "Delete window '$session / $name'? [y/N]: " answer || return 0

  case "$answer" in
    y|Y)
      ;;
    *)
      return 0
      ;;
  esac

  if ! tmux kill-window -t "$target"; then
    show_error "Failed to delete window '$session / $name'"
    return 1
  fi

  return 0
}

create_window() {
  local current_path
  local session
  local window_name

  current_path="$(tmux display-message -p "#{pane_current_path}")"
  session="$(pick_session)" || exit 0

  if [ -z "$session" ]; then
    exit 0
  fi

  window_name="$(prompt_window_name "$session")" || exit 0

  if ! create_window_in_session "$session" "$window_name" "$current_path"; then
    show_error "Failed to create window in $session"
    exit 1
  fi

  tmux switch-client -t "$session:" || {
    show_error "Created window in $session but failed to switch client"
    exit 1
  }
}

search_windows() {
  local output
  local key
  local row
  local target

  while true; do
    output="$(run_window_picker)" || exit 0

    if [ -z "$output" ]; then
      exit 0
    fi

    key="${output%%$'\n'*}"
    if [[ "$output" == *$'\n'* ]]; then
      row="${output#*$'\n'}"
      row="${row%%$'\n'*}"
    else
      row=""
    fi

    if [ -z "$row" ]; then
      exit 0
    fi

    target="${row%% *}"

    case "$key" in
      ctrl-r)
        rename_window_interactive "$target"
        ;;
      ctrl-d)
        delete_window_interactive "$target"
        ;;
      enter|"")
        if ! tmux switch-client -t "$target"; then
          show_error "Failed to switch to $target"
          exit 1
        fi
        exit 0
        ;;
      *)
        exit 0
        ;;
    esac
  done
}

main() {
  local action="${1:-}"
  local target="${2:-}"

  case "$action" in
    preview-window)
      render_window_preview "$target"
      ;;
    create-window)
      create_window
      ;;
    search-windows)
      search_windows
      ;;
    *)
      show_error "Usage: named-session-manager.sh <create-window|search-windows|preview-window>"
      exit 1
      ;;
  esac
}

main "$@"
