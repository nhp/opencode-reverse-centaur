# Discussion: Bare Repos and Worktree Directory Layout

**Date:** 2026-04-07

## Context

After implementing the worktree shell script (OCT-0001), the user noticed that OpenCode session history from the main checkout isn't available in worktrees. This prompted a question about whether switching to bare repository clones would solve session sharing and provide a cleaner directory structure.

## Key Points Discussed

- **Bare repos don't solve session sharing** — OpenCode stores sessions in `.opencode/` per working directory. Bare repos still have separate worktree directories, each with their own `.opencode/`. The git structure (bare vs normal) is irrelevant to session storage.

- **Session sharing isn't actually needed** — The `thoughts/` symlink already carries all structured context (tickets, research, plans, credentials). OpenCode sessions are ephemeral conversation history. If context matters, it should be captured in the workflow documents, not relied upon via session resumption.

- **Symlink `.opencode/` was considered but has problems** — File path references in sessions would point to wrong directories when resumed in a different worktree. Two OpenCode instances writing to the same `.opencode/` could corrupt state.

- **Directory layout is a separate concern from bare repos** — The desire for worktrees as siblings under a common parent can be achieved by changing the script's output path without switching to bare repos. Bare repos add complexity (different clone command, manual first worktree setup) for no functional benefit.

- **IDE integration matters for layout decisions** — PhpStorm has git worktree support. The directory layout should be guided by how the IDE handles worktrees rather than chosen independently and potentially fighting the IDE.

- **Current `~/.opencode-worktrees/` location keeps worktrees hidden** — This avoids cluttering the project file tree but makes worktrees less discoverable. Trade-off depends on IDE support.

## Decisions Made

- **No switch to bare repos** — Adds complexity without solving the actual problem. The worktree script with normal clones works fine.
- **No session sharing** — Not needed. The `thoughts/` symlink provides all necessary context. Sessions are ephemeral.
- **Directory layout deferred** — User will test PhpStorm's worktree handling before deciding where worktrees should live (hidden in `~/.opencode-worktrees/` vs siblings of main checkout).

## Open Questions

- How does PhpStorm handle git worktrees? Does it prefer them as siblings, or does it work with worktrees anywhere?
- Should the worktree script's output path be configurable (e.g., env var or config file) so users can adapt it to their IDE?

## Action Items

- [ ] Test PhpStorm's git worktree support to determine preferred directory layout
- [ ] Optionally make worktree base path configurable in `worktree.sh`

## References

- OCT-0001 ticket: `thoughts/shared/tickets/OCT-0001-git-worktree-parallel-sessions.md`
- Worktree script: `project-skeleton/scripts/worktree.sh`
