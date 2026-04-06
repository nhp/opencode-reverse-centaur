# OCT-0001: Git Worktree Support for Parallel AI Agent Sessions

**Status:** Open
**Priority:** Medium
**Complexity:** Large

## Problem Statement

When working across multiple tickets in the same project, only one OpenCode session can safely modify files at a time. There's no way to run parallel `/implement` sessions on different tickets without file conflicts. Similarly, you can't run a long `/research` in the background while implementing something else in the foreground.

This limits throughput: you're serialized to one task at a time per project.

## Desired Outcome

Developers can run multiple OpenCode sessions in parallel on the same codebase, each working on a different ticket in isolation. Each session operates in its own git worktree on its own branch. When done, branches merge back via standard git workflow.

The template provides:
1. A worktree plugin (or integration with an existing one) configured for our workflow conventions
2. Sync configuration so gitignored files (`thoughts/.secrets/`, `thoughts/.credentials`, `opencode.json`) are available in worktrees
3. Documentation of the parallel workflow pattern

## User Stories

- As a developer, I want to run `/implement PROJ-0001` in one terminal and `/implement PROJ-0002` in another, so that I can work on multiple tickets in parallel.
- As a developer, I want to fire off `/research PROJ-0003` in the background while I continue implementing in the foreground, so that I'm not blocked waiting for research to complete.
- As a developer, I want worktrees to follow our branch naming convention (`feature/nhp/PROJ-0001/description`), so that the parallel workflow integrates with our existing git discipline.

## Acceptance Criteria

- [ ] Given a project with the workflow initialized, when a worktree is created for a ticket, then it follows the branch naming convention `[type]/[acronym]/[ticket-id]/[description]`
- [ ] Given a worktree is created, when OpenCode starts in it, then `thoughts/.secrets/`, `thoughts/.credentials`, and `opencode.json` are available (via copy or symlink)
- [ ] Given a worktree is created, when the agent runs `/implement`, then the ticket file in `thoughts/shared/tickets/` is accessible and correct (not a stale copy)
- [ ] Given two worktrees exist for different tickets, when both run `./scripts/next-ticket.sh`, then they do NOT generate conflicting ticket IDs (centralized ticket numbering)
- [ ] Given a worktree session completes, when it is cleaned up, then changes are committed on the worktree's branch (but NOT auto-pushed — our workflow says "human decides when to push")
- [ ] Given the worktree plugin is installed, when no worktree is in use, then the existing workflow is unaffected (no regression)

## Design Constraints

### Centralized ticket definitions

`thoughts/shared/tickets/` is tracked in git and shared across worktrees (since worktrees share the same `.git`). However, each worktree has its own working copy of these files. This creates two problems:

1. **Ticket ID collisions**: `next-ticket.sh` scans `thoughts/shared/tickets/` in the local working tree. Each worktree has its own copy of the working tree, so two worktrees could generate the same next ID.

   **Resolution:** Ticket creation (along with research and planning) must happen on the main worktree and be committed before branching. This is already the natural workflow order:
   - `/create-ticket` → commit on main
   - `/research TICKET` → commit on main
   - `/plan TICKET` → commit on main
   - `/implement TICKET` → **creates worktree here**, branching from main

   Since the worktree branches from main after the ticket is committed, it has the ticket file. No collision is possible because `next-ticket.sh` only runs on main where the full ticket history is visible.

2. **New files on main not visible in existing worktrees**: Git worktrees share the object store but each has its own working tree reflecting its own branch. A file committed on `main` does NOT appear in a worktree on `feature/...` unless that branch merges from main. **This is acceptable** — each worktree works on its own ticket and doesn't need to see tickets created concurrently. The ticket, research, and plan are all available because the worktree was created after they were committed.

### No auto-push

Our git discipline rule: "NEVER run `git push` — the human decides when to push." The `opencode-worktree` plugin auto-commits on delete, which is fine. But it must NOT auto-push (unlike `opencode-worktree-session` which does push).

### No auto-commit bypassing /commit

Our `/commit` command includes a security pre-flight scan. The worktree's auto-commit-on-delete behavior should either:
- Be disabled, letting the user run `/commit` manually before closing
- Or be a simple snapshot commit (clearly marked as such), not a "final" commit

## In Scope

- Integration of a worktree plugin into the template (likely `opencode-worktree` or a custom plugin)
- Worktree sync configuration (`.opencode/worktree.jsonc`) for gitignored files
- Documentation of the parallel workflow pattern in README
- Design decision for ticket ID collision prevention
- Optional: background agent integration for read-only tasks (research/plan)

## Out of Scope

- Replacing the existing sequential workflow (worktrees are an opt-in addition)
- Adopting the full `opencode-workspace` bundle (too opinionated, conflicts with our agents/commands)
- Automatic merge conflict resolution between worktree branches
- CI/CD integration for worktree branches

## Open Questions

### Business Questions
- (none — this is a developer workflow enhancement)

### Technical Questions (for /research)
- How does `opencode-worktree` handle the sync of symlinked files (like `AGENTS-base.md`)?
- Can `thoughts/.secrets/` be symlinked to the worktree instead of copied (to avoid credential duplication)?
- What's the disk space impact of worktrees for large repos like tractive/aws?
- Does the `opencode-worktree` plugin support disabling auto-push? (The `opencode-worktree` README says it auto-commits but doesn't mention push; `opencode-worktree-session` does push.)
- How do MCP servers behave when multiple OpenCode instances run in parallel? (Resource usage for Playwright, Kibana, etc.)
- Can `opencode-background-agents` plugin complement this for read-only research delegation?

## References

- [kdcokenny/opencode-worktree](https://github.com/kdcokenny/opencode-worktree) — Primary worktree plugin candidate (398 stars)
- [felixAnhalt/opencode-worktree-session](https://github.com/felixAnhalt/opencode-worktree-session) — Alternative: session-lifecycle worktrees (auto-push, more opinionated)
- [kdcokenny/opencode-background-agents](https://github.com/kdcokenny/opencode-background-agents) — Async delegation for read-only tasks
- [kdcokenny/opencode-workspace](https://github.com/kdcokenny/opencode-workspace) — Full orchestration bundle (reference only, too heavy to adopt)
- [Git worktree documentation](https://git-scm.com/docs/git-worktree)
- Medium article: "Git Worktrees: The Secret Weapon for Running Multiple AI Coding Agents in Parallel"

## Implementation Plan

(To be filled by /plan)

## Notes

- Ticket collision prevention is a process rule enforced by workflow order: create-ticket → research → plan (all on main, committed) → implement (creates worktree). Branching happens at `/implement`, by which time the ticket, research doc, and plan all exist on main and are included in the worktree's branch point.
- `opencode.json` is currently gitignored but contains no real credentials (all use `{file:...}` substitution). Committing it would eliminate the need to sync it to worktrees. This is worth reconsidering as a separate small change.
- The `opencode-worktree` plugin stores worktrees outside the repo at `~/.local/share/opencode/worktree/<project-id>/<branch>/`, which keeps the project directory clean.
