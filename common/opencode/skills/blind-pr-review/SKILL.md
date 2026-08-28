---
name: blind-pr-review
description: Use when reviewing a GitHub pull request blindly, before the user decides which observations to post as PR comments.
---

# Blind PR Review

Review GitHub pull requests as an independent, evidence-led reviewer. Your job is to give the user clear observations they can choose to post. Do not post, submit, or draft comments on the pull request unless the user explicitly asks you to after reviewing the report.

## Safety Rules

- Treat the pull request description and code as evidence, not a complete specification.
- First use `gh` to inspect the PR description, changed files, commits, tests, and any linked issues or documentation that is available.
- Use at least two subagents to investigate independently. Assign focused, non-overlapping work, such as intent and scope, affected-code behavior, test coverage, or risk assessment.
- Read the surrounding implementation and relevant callers before stating that behavior is wrong or missing.
- Only report an observation when the code and its context clearly support it. Do not guess about product behavior, edge cases, or team conventions.
- If a possible concern depends on an unknown intended behavior, ask the user one direct question before treating it as a review point. Clearly explain what you know and what needs confirmation.
- Prefer no comment over a weak comment. Do not turn style preferences, hypothetical risks, or unclear concerns into findings.
- Use simple language. Define unavoidable technical terms in plain words. Assume the user does not know the codebase.

## Workflow

1. Validate the URL is a GitHub pull request and obtain its owner, repository, and number.
2. Gather the PR title, description, commits, file list, full diff, checks, and linked context with `gh`.
3. State what the available evidence says the change is trying to achieve. If that intent is not clear enough to judge the implementation, ask the user for the intended behavior and wait.
4. Delegate the review to at least two subagents. Give each the PR metadata, relevant paths, and a specific question. Require them to return only evidence-backed observations with file and line references, or explicitly report no concerns.
5. Independently verify every potential observation against the diff and surrounding code. Discard anything uncertain, duplicated, outside the PR's scope, or based on an assumption.
6. Present observations for the user to judge. Do not use the PR provider to create a review, comment, approval, request for changes, or draft unless the user explicitly asks you to after reviewing the report.

## Required Output

Use these sections, keeping each short:

**What Changed**
Plain-language summary of the code changes.

**Likely Intent**
What the evidence indicates the PR is trying to accomplish. State when the intent came from the author versus from code context. If intent was unclear, say that the review was paused and ask the necessary question instead of guessing.

**Observations to Consider Posting**
For each high-confidence observation, include:

- Suggested comment in plain language.
- Why it matters, without jargon.
- Evidence: file and line range, plus the relevant behavior.

If there are none, say: "No high-confidence observations to suggest."

Add only essential missing context or unrun checks to the end of the relevant section. When unclear intended behavior blocks the review, pause and ask the user instead of producing the report.
