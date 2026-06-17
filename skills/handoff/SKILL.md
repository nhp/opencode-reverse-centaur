---
name: handoff
description: Compact the current session into a temporary handoff document for another agent or worktree session. Use when the user says handoff, wants to continue in another session, or a task should be split out of scope.
---

# Handoff

Write a focused markdown handoff so a fresh agent session can continue without inheriting the whole conversation.

## Destination

Save the file outside the repository:

- Use `$TMPDIR` when set
- Otherwise use `/tmp` on Linux/macOS
- Name it `opencode-handoff-YYYYMMDD-HHMMSS.md`

Do not add the handoff to `thoughts/` unless the user explicitly asks to make it durable.

## What to Include

- Purpose of the next session
- Current status and key decisions
- Relevant artifact paths or URLs: tickets, research, plans, reviews, decisions, commits, diffs
- Suggested commands or skills for the next session, such as `/prototype`, `/grill-with-docs`, `diagnose`, `tdd`, or `/implement`
- Constraints, risks, and open questions
- Exact next action the new session should take

## What Not to Include

- Do not duplicate full ticket, plan, PRD, ADR, or diff contents. Link to them.
- Do not include secrets, API keys, cookies, tokens, passwords, or personal data.
- Do not mix unrelated follow-up tasks into the same handoff. Create separate handoffs for separate threads.

## Shape

```markdown
# Handoff: [Purpose]

## Next Session Goal

[One paragraph]

## Current State

- [Fact with path/source]

## Relevant Artifacts

- [path or URL] — [why relevant]

## Suggested Commands/Skills

- [command or skill] — [why]

## Constraints and Open Questions

- [constraint/question]

## First Action

[Exact first step]
```

After writing, tell the user the absolute path and the intended next-session goal.
