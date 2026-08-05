#!/usr/bin/env bash

set -u

# Lists processes with listening TCP ports, showing process name, CWD, and
# ports. Enter kills the selected process (SIGKILL).

list_listening() {
  # Collect PIDs with listening TCP sockets. lsof may require sudo for
  # processes owned by other users; we silently skip those.
  local pids
  pids="$(lsof -nP -iTCP -sTCP:LISTEN -F p 2>/dev/null | sed -n 's/^p//p' | sort -u)"

  if [ -z "$pids" ]; then
    return
  fi

  local pid name cwd ports
  for pid in $pids; do
    name="$(ps -p "$pid" -o comm= 2>/dev/null)" || continue
    [ -z "$name" ] && continue

    cwd="$(lsof -a -p "$pid" -d cwd -F n 2>/dev/null | sed -n 's/^n//p')"
    [ -z "$cwd" ] && cwd="-"

    ports="$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN -F n 2>/dev/null \
      | sed -En 's/^n.*:([0-9]+)$/\1/p' | sort -n -u | paste -sd, -)"
    [ -z "$ports" ] && continue

    printf "%s\t%s\t%s\t%s\n" "$pid" "$name" "$cwd" "$ports"
  done
}

run_picker() {
  local header="PID	COMMAND	CWD	PORTS"
  local entries
  entries="$(list_listening)"

  if [ -z "$entries" ]; then
    printf "No processes with listening ports found\n"
    exit 0
  fi

  printf "%s\n%s\n" "$header" "$entries" \
    | column -t -s $'\t' \
    | fzf \
        --header-lines=1 \
        --prompt="Kill > " \
        --header="enter: SIGKILL" \
        --layout=reverse
}

main() {
  local selection pid

  selection="$(run_picker)" || exit 0

  if [ -z "$selection" ]; then
    exit 0
  fi

  pid="$(echo "$selection" | awk '{print $1}')"

  if [ -z "$pid" ]; then
    printf "Failed to extract PID\n" >&2
    exit 1
  fi

  if kill -9 "$pid" 2>/dev/null; then
    printf "Killed PID %s\n" "$pid"
  else
    printf "Failed to kill PID %s (permission denied?)\n" "$pid" >&2
    return 1
  fi
}

main "$@"
