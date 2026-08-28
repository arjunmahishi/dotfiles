#!/usr/bin/env bash

set -uo pipefail

pause_on_error() {
  printf "\nPress Enter to close..." >&2
  read -r _
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf "%s is required\n" "$1" >&2
    return 1
  fi
}

list_review_requests() {
  local cutoff
  cutoff="$(date -v-1m +%Y-%m-%d)" || return 1

  gh search prs \
    --review-requested=@me \
    --state=open \
    --draft=false \
    --created=">=$cutoff" \
    --limit=1000 \
    --json author,repository,number,title,url \
    | jq -r '
        def pad($width):
          . + (" " * ([$width - length, 0] | max));

        sort_by([(.repository.nameWithOwner | ascii_downcase), .number])
        | map({
            url,
            repository: .repository.nameWithOwner,
            number: ("#" + (.number | tostring)),
            author: (.author.login // "ghost"),
            title: (.title | gsub("[\\t\\r\\n]"; " "))
          }) as $rows
        | if ($rows | length) == 0 then
            empty
          else
            ([$rows[].repository | length] + [10] | max) as $repository_width
            | ([$rows[].number | length] + [2] | max) as $number_width
            | ([$rows[].author | length] + [6] | max) as $author_width
            | (
                ["", "", "", (
                  ("REPOSITORY" | pad($repository_width)) + "  " +
                  ("PR" | pad($number_width)) + "  " +
                  ("AUTHOR" | pad($author_width)) + "  TITLE"
                )],
                ($rows[] | [
                  .url,
                  .repository,
                  .number,
                  (
                    (.repository | pad($repository_width)) + "  " +
                    (.number | pad($number_width)) + "  " +
                    (.author | pad($author_width)) + "  " +
                    .title
                  )
                ])
              )
            | @tsv
          end
      '
}

pick_reviews() {
  local entries
  entries="$(list_review_requests)" || return 2

  if [ -z "$entries" ]; then
    return 3
  fi

  printf "%s\n" "$entries" \
    | fzf \
        --multi \
        --delimiter=$'\t' \
        --with-nth=4 \
        --header-lines=1 \
        --no-sort \
        --prompt="Review PRs > " \
        --header="tab: select | enter: start reviews" \
        --layout=reverse
}

agent_name() {
  local url="$1"
  local number="$2"
  local checksum
  checksum="$(printf "%s" "$url" | cksum | awk '{print $1}')" || return 1
  printf "review-%s-%s" "$number" "$checksum"
}

pane_is_shell() {
  local pane_id="$1"
  local process_info
  process_info="$("$HERDR_BIN_PATH" pane process-info --pane "$pane_id")" || return 1

  jq -e '
    .result.process_info as $process
    | ($process.foreground_processes | length) == 1
      and $process.foreground_processes[0].pid == $process.shell_pid
  ' >/dev/null <<< "$process_info"
}

get_or_create_workspace() {
  local workspace_list workspace_count workspace_result
  workspace_list="$("$HERDR_BIN_PATH" workspace list)" || return 1
  workspace_count="$(jq '[.result.workspaces[] | select(.label == "reviews")] | length' <<< "$workspace_list")" || return 1

  case "$workspace_count" in
    0)
      workspace_result="$("$HERDR_BIN_PATH" workspace create --cwd "$HOME" --label reviews --no-focus)" || return 1
      reviews_workspace_id="$(jq -r '.result.workspace.workspace_id' <<< "$workspace_result")" || return 1
      available_tab_id="$(jq -r '.result.tab.tab_id' <<< "$workspace_result")" || return 1
      available_pane_id="$(jq -r '.result.root_pane.pane_id' <<< "$workspace_result")" || return 1
      ;;
    1)
      reviews_workspace_id="$(jq -r '.result.workspaces[] | select(.label == "reviews") | .workspace_id' <<< "$workspace_list")" || return 1
      ;;
    *)
      printf "Multiple workspaces named reviews exist; rename or close the extras\n" >&2
      return 1
      ;;
  esac
}

find_review_tab() {
  local label="$1"
  local tab_list tab_count
  tab_list="$("$HERDR_BIN_PATH" tab list --workspace "$reviews_workspace_id")" || return 1
  tab_count="$(jq --arg label "$label" '[.result.tabs[] | select(.label == $label)] | length' <<< "$tab_list")" || return 1

  if [ "$tab_count" -gt 1 ]; then
    printf "Multiple tabs named %s exist in reviews\n" "$label" >&2
    return 1
  fi

  if [ "$tab_count" -eq 1 ]; then
    jq -r --arg label "$label" '.result.tabs[] | select(.label == $label) | .tab_id' <<< "$tab_list"
  fi
}

find_tab_pane() {
  local tab_id="$1"
  local pane_list pane_count
  pane_list="$("$HERDR_BIN_PATH" pane list --workspace "$reviews_workspace_id")" || return 1
  pane_count="$(jq --arg tab_id "$tab_id" '[.result.panes[] | select(.tab_id == $tab_id)] | length' <<< "$pane_list")" || return 1

  if [ "$pane_count" -ne 1 ]; then
    printf "Expected one pane in review tab %s, found %s\n" "$tab_id" "$pane_count" >&2
    return 1
  fi

  jq -r --arg tab_id "$tab_id" '.result.panes[] | select(.tab_id == $tab_id) | .pane_id' <<< "$pane_list"
}

prepare_review() {
  local url="$1"
  local repository="$2"
  local number="$3"
  local label tab_id pane_id tab_result agent_result agent_kind existing_name expected_name
  label="$repository #$number"
  expected_name="$(agent_name "$url" "$number")" || return 1
  tab_id="$(find_review_tab "$label")" || return 1

  if [ -n "$tab_id" ]; then
    pane_id="$(find_tab_pane "$tab_id")" || return 1

    if ! pane_is_shell "$pane_id"; then
      agent_result="$("$HERDR_BIN_PATH" agent get "$pane_id")" || return 1
      agent_kind="$(jq -r '.result.agent.agent // empty' <<< "$agent_result")" || return 1
      existing_name="$(jq -r '.result.agent.name // empty' <<< "$agent_result")" || return 1

      if [ "$agent_kind" = "opencode" ] && [ "$existing_name" = "$expected_name" ]; then
        skipped_count=$((skipped_count + 1))
        return 0
      fi

      if [ "$agent_kind" != "opencode" ]; then
        printf "Review tab %s is occupied by %s\n" "$label" "${agent_kind:-another process}" >&2
        return 1
      fi

      pending_names+=("$expected_name")
      pending_labels+=("$label")
      pending_pane_ids+=("$pane_id")
      return 0
    fi
  elif [ -n "$available_tab_id" ]; then
    tab_id="$available_tab_id"
    pane_id="$available_pane_id"
    "$HERDR_BIN_PATH" tab rename "$tab_id" "$label" >/dev/null || return 1
    available_tab_id=""
    available_pane_id=""
  else
    tab_result="$("$HERDR_BIN_PATH" tab create --workspace "$reviews_workspace_id" --cwd "$HOME" --label "$label" --no-focus)" || return 1
    tab_id="$(jq -r '.result.tab.tab_id' <<< "$tab_result")" || return 1
    pane_id="$(jq -r '.result.root_pane.pane_id' <<< "$tab_result")" || return 1
  fi

  "$HERDR_BIN_PATH" pane run "$pane_id" "cd \"$HOME\" && ro --prompt \"/blind-pr-review $url\"" || return 1
  pending_names+=("$expected_name")
  pending_labels+=("$label")
  pending_pane_ids+=("$pane_id")
}

wait_for_opencode() {
  local pane_id="$1"
  local label="$2"
  local attempts=0 agent_result agent_kind

  while [ "$attempts" -lt 120 ]; do
    if agent_result="$("$HERDR_BIN_PATH" agent get "$pane_id" 2>/dev/null)"; then
      agent_kind="$(jq -r '.result.agent.agent // empty' <<< "$agent_result")" || return 1
      if [ "$agent_kind" = "opencode" ]; then
        return 0
      fi
    fi

    sleep 0.25
    attempts=$((attempts + 1))
  done

  printf "OpenCode did not start for %s within 30 seconds\n" "$label" >&2
  return 1
}

start_reviews() {
  local index
  index=0

  while [ "$index" -lt "${#pending_pane_ids[@]}" ]; do
    wait_for_opencode "${pending_pane_ids[$index]}" "${pending_labels[$index]}" || return 1
    "$HERDR_BIN_PATH" agent rename "${pending_pane_ids[$index]}" "${pending_names[$index]}" >/dev/null || return 1
    index=$((index + 1))
  done
}

main() {
  if [ -z "${HERDR_BIN_PATH:-}" ]; then
    printf "HERDR_BIN_PATH is not available\n" >&2
    return 1
  fi

  require_command gh || return 1
  require_command jq || return 1
  require_command fzf || return 1

  local selection picker_status url repository number
  picker_status=0
  selection="$(pick_reviews)" || picker_status=$?
  case "$picker_status" in
    0)
      ;;
    1|130)
      return 0
      ;;
    3)
      printf "No review requests from the last month found\n"
      return 0
      ;;
    *)
      return "$picker_status"
      ;;
  esac

  get_or_create_workspace || return 1

  while IFS=$'\t' read -r url repository number _; do
    number="${number#\#}"
    prepare_review "$url" "$repository" "$number" || return 1
  done <<< "$selection"

  start_reviews || return 1

  printf "Started %s review(s)" "${#pending_pane_ids[@]}"
  if [ "$skipped_count" -gt 0 ]; then
    printf "; skipped %s existing review(s)" "$skipped_count"
  fi
  printf "\n"
}

declare reviews_workspace_id=""
declare available_tab_id=""
declare available_pane_id=""
declare -a pending_names=()
declare -a pending_labels=()
declare -a pending_pane_ids=()
declare skipped_count=0

status=0
main "$@" || status=$?
if [ "$status" -ne 0 ]; then
  pause_on_error
fi
exit "$status"
