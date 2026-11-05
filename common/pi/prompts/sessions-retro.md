---
description: Analyze this project's Pi sessions for friction and propose skills/AGENTS.md fixes
argument-hint: "[since YYYY-MM-DD]"
---
I authorize reading this project's Pi session transcripts for a retrospective. Scope: sessions since ${1:-the beginning}.

1. Run `~/.pi/agent/scripts/session-digest.py "$PWD" /tmp/sessions-retro $1`. Read all of `/tmp/sessions-retro/users.txt` (page with offset) and `/tmp/sessions-retro/errors.json`.
2. Count recurring themes (corrections, frustration, "no tests", "too verbose", "plan first", re-explaining setup, stalls such as bare "continue"). Treat the counts as approximate.
3. Read the current global `~/.pi/agent/AGENTS.md`, the project's `AGENTS.md`, and the existing skills, so you don't propose what already exists or re-fix what earlier retros already addressed.
4. Report briefly: what is going well, the friction points (ranked, with counts), the hardest areas, and the smallest set of fixes. For each fix, say where it goes: a repo-local skill (`.agents/skills/<name>/`, excluded through `.git/info/exclude`, never committed), the global AGENTS.md (consolidate, don't append), or a global skill. Push back on fixes the evidence doesn't justify.
5. Stop and wait for my approval. Then apply only the approved fixes, and take commands and recipes only from tool calls that succeeded in the transcripts. Never copy secrets into the files.
