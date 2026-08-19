#!/usr/bin/env bash

set -u

pause_on_error() {
  printf "\nPress Enter to close..." >&2
  read -r _
}

main() {
  if [ -z "${HERDR_ACTIVE_PANE_ID:-}" ]; then
    printf "No focused Herdr pane is available\n" >&2
    pause_on_error
    return 1
  fi

  if [ -z "${HERDR_BIN_PATH:-}" ]; then
    printf "HERDR_BIN_PATH is not available\n" >&2
    pause_on_error
    return 1
  fi

  local name status
  while true; do
    read -r -p "Agent name: " name || return 0

    if [ -z "$name" ]; then
      return 0
    fi

    if [[ "$name" =~ ^[a-z][a-z0-9_-]{0,31}$ ]]; then
      break
    fi

    printf "Use 1-32 characters matching [a-z][a-z0-9_-]*\n" >&2
  done

  "$HERDR_BIN_PATH" agent rename "$HERDR_ACTIVE_PANE_ID" "$name" || {
    status=$?
    pause_on_error
    return "$status"
  }
}

main "$@"
