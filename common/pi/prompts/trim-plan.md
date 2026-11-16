---
description: Plan a change, estimate churn, then cut it to the smallest complete version
argument-hint: "[task or ticket]"
---
Task: ${@:-the task we've been discussing}

1. Read the task and the code it touches. Make a proper plan that lists every
   place the change must reach: callers, data/schema, tests, fixtures, config,
   docs, and rollout or ops steps.
2. Estimate the churn for each item (files, rough lines) and any ops cost.
3. Minimize it as much as possible (max ponytail). For each item, ask:
   - Does it need to exist at all? Can existing code or patterns do it?
   - Is there a simpler representation or design that removes work elsewhere?
   - Would a one-time manual step be cheaper than code, or the reverse?
   - Does each test cover lasting behavior, or only hard-code this one change?
4. Verify the assumptions the cuts depend on with read-only checks against
   real code, data, and environments. Don't guess.
5. Print the minimized plan: steps with files and churn, the initial and
   final churn estimates, what was cut and why, and remaining risks.

Planning only: make no changes.
