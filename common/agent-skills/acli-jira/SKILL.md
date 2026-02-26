---
name: acli-jira
description: Use acli to manage Jira tickets -- search, view, create, edit, transition, assign, comment, and more from the command line.
---

## Purpose

Use this skill when you need to interact with Jira: reading tickets, creating new work items, updating existing ones, searching with JQL, transitioning status, assigning, commenting, or browsing projects. `acli jira` provides full Jira Cloud management from the CLI.

## When to use what

- `acli jira workitem view`: View a specific ticket by key. Use to read ticket details, description, status, assignee, etc.
- `acli jira workitem search`: Find tickets using JQL queries. Use for any search, filtering, or listing of work items.
- `acli jira workitem create`: Create a new ticket. Use when the user wants to file a bug, task, story, or epic.
- `acli jira workitem edit`: Modify an existing ticket's summary, description, labels, type, or assignee.
- `acli jira workitem transition`: Move a ticket to a new status (e.g., "In Progress", "Done").
- `acli jira workitem assign`: Change or remove a ticket's assignee.
- `acli jira workitem comment create`: Add a comment to a ticket.
- `acli jira workitem comment list`: Read comments on a ticket.
- `acli jira project list`: List available projects. Use to discover project keys.
- `acli jira project view`: View details of a specific project.
- `acli jira sprint list-workitems`: List tickets in a sprint (requires `--sprint` and `--board` IDs).
- `acli jira board search`: Find boards by name or keyword.

## Core concepts

- **Always use `--json`** on read commands (`view`, `search`, `comment list`, `project list`, etc.) to get machine-readable output.
- **Always use `--yes`** on mutation commands (`edit`, `transition`, `assign`) to skip interactive confirmation prompts that would hang in a non-interactive shell.
- **JQL** (Jira Query Language) is used for searching. Pass it via `--jql "..."`.
- **`@me`** is a shorthand for the authenticated user (works in `--assignee`).
- **Labels** are comma-separated: `--label "bug,backend,urgent"`.
- **Work item types** use Jira issue types: `Task`, `Bug`, `Story`, `Epic`, `Sub-task`, etc. Pass via `--type`.
- **Keys** are project-prefixed IDs like `PROJ-123`. Multiple keys are comma-separated: `--key "PROJ-1,PROJ-2"`.

## Recommended workflow

1. **Discover projects**: `acli jira project list --json` to find available project keys.
2. **Search for tickets**: `acli jira workitem search --jql "project = PROJ AND ..." --json` to find relevant work items.
3. **View a ticket**: `acli jira workitem view PROJ-123 --json` to read full details.
4. **Create/edit/transition** as needed using the commands below.

## Common JQL patterns

```sh
# All open tickets in a project
--jql "project = PROJ AND status != Done"

# Tickets assigned to me
--jql "assignee = currentUser()"

# Bugs created this week
--jql "project = PROJ AND type = Bug AND created >= startOfWeek()"

# Tickets with a specific label
--jql "project = PROJ AND labels = backend"

# Search by summary text
--jql "project = PROJ AND summary ~ \"search term\""

# High priority open items
--jql "project = PROJ AND priority in (High, Highest) AND status != Done"

# Recently updated
--jql "project = PROJ AND updated >= -7d ORDER BY updated DESC"
```

## Examples

### View a ticket

```sh
acli jira workitem view PROJ-123 --json

# View specific fields only
acli jira workitem view PROJ-123 --fields "summary,status,assignee,labels,comment" --json
```

### Search for tickets

```sh
# Search with JQL, get JSON output
acli jira workitem search --jql "project = PROJ AND status = 'In Progress'" --json

# Search with specific fields and a result limit
acli jira workitem search --jql "project = PROJ AND assignee = currentUser()" \
  --fields "key,summary,status,priority,labels" --limit 20 --json

# Get count of matching tickets
acli jira workitem search --jql "project = PROJ AND type = Bug" --count
```

### Create a ticket

```sh
# Basic creation
acli jira workitem create \
  --project "PROJ" \
  --type "Task" \
  --summary "Implement feature X" \
  --description "Detailed description here" \
  --label "backend,feature" \
  --assignee "@me" \
  --json

# Create a bug with a parent (sub-task)
acli jira workitem create \
  --project "PROJ" \
  --type "Bug" \
  --summary "Fix login timeout" \
  --description "Users report timeout after 30s on the login page" \
  --label "bug,auth" \
  --parent "PROJ-100" \
  --json

# Create with description from a file
acli jira workitem create \
  --project "PROJ" \
  --type "Story" \
  --summary "User onboarding flow" \
  --description-file description.txt \
  --json
```

### Edit a ticket

```sh
# Edit summary and labels
acli jira workitem edit --key "PROJ-123" \
  --summary "Updated summary" \
  --labels "backend,urgent" \
  --yes --json

# Change assignee
acli jira workitem edit --key "PROJ-123" \
  --assignee "user@company.com" \
  --yes --json

# Remove labels
acli jira workitem edit --key "PROJ-123" \
  --remove-labels "stale" \
  --yes --json
```

### Transition a ticket

```sh
# Move to In Progress
acli jira workitem transition --key "PROJ-123" --status "In Progress" --yes --json

# Mark as Done
acli jira workitem transition --key "PROJ-123" --status "Done" --yes --json

# Transition multiple tickets
acli jira workitem transition --key "PROJ-1,PROJ-2,PROJ-3" --status "Done" --yes --json
```

### Assign a ticket

```sh
# Assign to self
acli jira workitem assign --key "PROJ-123" --assignee "@me" --yes --json

# Assign to someone else
acli jira workitem assign --key "PROJ-123" --assignee "user@company.com" --yes --json

# Remove assignee
acli jira workitem assign --key "PROJ-123" --remove-assignee --yes --json
```

### Comments

```sh
# Add a comment
acli jira workitem comment create --key "PROJ-123" --body "This is ready for review"

# List comments
acli jira workitem comment list --key "PROJ-123" --json
```

### Projects

```sh
# List all projects
acli jira project list --json

# View a specific project
acli jira project view --key "PROJ" --json

# List recently viewed projects
acli jira project list --recent --json
```

### Sprints and boards

```sh
# Find a board
acli jira board search --name "My Team" --json

# List sprints on a board
acli jira board list-sprints --id 42 --json

# List tickets in a sprint
acli jira sprint list-workitems --sprint 101 --board 42 --json
```

## Important tips

- When creating tickets, always ask the user for the **project key** if not already known. Use `acli jira project list --json` to discover available projects.
- When creating tickets, infer appropriate **labels** from context (e.g., the area of the codebase, the type of work). Labels help with discoverability.
- Prefer `--json` output for all read operations so you can parse and summarize results for the user.
- Use `--yes` on all write operations to avoid interactive prompts.
- For large result sets, use `--limit` to cap results or `--paginate` to fetch everything.
- Status names for transitions are project-specific. If a transition fails, the error message will list valid statuses.
- To set custom fields (not exposed as CLI flags), use `--from-json` with `additionalAttributes`. Generate a template with `acli jira workitem create --generate-json`.

## Board-specific conventions

For project-specific board conventions (required fields, custom field mappings, labels, templates), read the file `~/.config/opencode/skills/acli-jira/boards.md` if it exists. It contains board-specific conventions needed before creating or managing tickets on known boards.

This allows board conventions to be kept private (not checked into version control) while the core skill remains public.
