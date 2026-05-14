---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "What will the next session be used for?"
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work. Save it to `/tmp/` with a descriptive filename (e.g. `/tmp/handoff-refactor-auth-flow.md`).

Organize changes into logical milestones, but don't over-split. Keep milestones coarse unless the scope or complexity genuinely warrants separation -- a single milestone is fine if the work can be completed in one shot.

Do not duplicate content already captured in other artifacts (PRDs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.
