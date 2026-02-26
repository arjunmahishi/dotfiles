# Board-specific Jira conventions

This file contains project-specific and board-specific conventions for managing Jira tickets. Keep it private (not in version control).

## Board: AI Supportability Kanban

Reference for creating and managing tickets on the AI Supportability Kanban board.

### Board details

| Field        | Value                    |
| ------------ | ------------------------ |
| Board ID     | 1267                     |
| Board type   | Kanban                   |
| Project      | CC (CockroachCloud)      |

### Required fields

| Field            | Value / How to set                                                    |
| ---------------- | --------------------------------------------------------------------- |
| Project          | `--project "CC"`                                                      |
| Type             | `--type "Task"` (or `"Bug"` for defects)                              |
| Label            | `--label "ai-supportability"` -- this is how tickets appear on the board |
| Engineering Team | `customfield_10089` with value `"Supportability"` -- must be set via `--from-json` (see example below) |

### Conventions

- **Issue types**: `Task` (default) or `Bug`. No Stories or Epics.
- **Statuses**: `Backlog` -> `To Do` -> `Dev in Progress` -> `Done`
- **Priority**: typically left as `None`.
- **Components / Parent / Epic**: not used on this board.
- **Summary style**: short, imperative descriptions (e.g., "Handle downloading state on the UI").

### Creating a ticket

Since the Engineering Team field requires `--from-json`, write a temporary JSON file and pass it:

```sh
cat <<'EOF' > /tmp/jira-ticket.json
{
  "projectKey": "CC",
  "type": "Task",
  "summary": "Your task description here",
  "description": {
    "type": "doc",
    "version": 1,
    "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Detailed description here"}]}]
  },
  "labels": ["ai-supportability"],
  "additionalAttributes": {
    "customfield_10089": {"value": "Supportability"}
  }
}
EOF
acli jira workitem create --from-json /tmp/jira-ticket.json --json
```

### Searching tickets on this board

```sh
acli jira workitem search --jql "project = CC AND labels = ai-supportability ORDER BY updated DESC" --json
```
