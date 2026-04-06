---
ticket: OCT-0001
title: "Plan: Git Worktree Support for Parallel AI Agent Sessions"
date: 2026-04-06
status: draft
research: thoughts/shared/research/OCT-0001-research.md
---

# Plan: Git Worktree Support for Parallel AI Agent Sessions

## Overview

Add git worktree support to the template so developers can run multiple OpenCode sessions in parallel, each working on a different ticket in isolation. This includes a custom lightweight worktree plugin (~200 lines, zero 3rd-party deps), worktree sync configuration, and documentation. A prerequisite change makes `opencode.json` committable by removing it from `.gitignore` (safe because all credentials now use `{file:...}` substitution).

## References

- **Ticket:** thoughts/shared/tickets/OCT-0001-git-worktree-parallel-sessions.md
- **Research:** thoughts/shared/research/OCT-0001-research.md

## Approach

**Custom lightweight plugin** over vendoring `opencode-worktree` (kdcokenny). Reasons:
- Zero 3rd-party dependencies — pure git commands + our conventions
- Ticket-aware branch naming — auto-generates from ticket ID + user acronym
- Integration with our `/commit` workflow — no blind auto-commit bypassing security pre-flight
- ~200 lines vs ~850 + supporting modules + `jsonc-parser` dependency
- Full control — no supply chain risk

**Prerequisite: commit `opencode.json`** — Since all credentials use `{file:...}` substitution, the file contains zero secrets. Committing it means worktrees get it automatically via git, eliminating the need for file sync config. This also benefits non-worktree workflows (config is versioned, teammates see which MCP servers are enabled).

## Phases

### Phase 1: Make `opencode.json` committable

**Goal:** Remove `opencode.json` from `.gitignore` so it can be tracked in git. This is a prerequisite for worktrees (they get the config automatically) and a standalone improvement (config is versioned).

**Changes:**
- [x] `.gitignore` — Remove `opencode.json` from the ignored patterns
- [x] `project-skeleton/opencode.json.example` — Add a comment header warning: credentials must always use `{file:...}` substitution, never hardcode values
- [x] `opencode.json.global.example` — Add same warning comment
- [x] `commands/init-workflow.md` — Update step 3c: `opencode.json` is now committed (not gitignored). Explain that it's safe because credentials use `{file:...}` refs. Remove the "gitignored" language.
- [x] `README.md` — Update "Configuration (Global vs Project)" section to note project config is committed
- [x] `PLANNING.md` — Update the credential isolation decision to reflect that `opencode.json` is committed

**Security criteria:**
- [x] `opencode.json` contains zero hardcoded credentials — only `{file:...}` or `{env:...}` references
- [x] `.gitignore` still protects `thoughts/.secrets/*`, `*.credentials`, and all other secret patterns
- [x] `/commit` security pre-flight (in `commands/commit.md`) would catch any accidentally hardcoded credentials

**Success Criteria (Automated):**
- [x] `grep -r "opencode.json" .gitignore` returns no match (removed from gitignore)
- [x] `grep -c "{file:" project-skeleton/opencode.json.example` confirms all credentials use substitution

**Success Criteria (Manual):**
- [x] Review the example files — no credential values, only `{file:...}` references
- [x] The warning comment is prominent and clear

**Commit after this phase passes verification.**

---

### Phase 1b: Migrate huber/co2os — commit opencode.json

**Goal:** Apply the Phase 1 change to the test project. Remove `opencode.json` from its `.gitignore` and commit it.

**Changes:**
- [ ] `~/projects/dev/huber/community/co2os/.gitignore` — Remove `opencode.json` from ignored patterns (if present)
- [ ] `~/projects/dev/huber/community/co2os/opencode.json` — Verify it contains no hardcoded credentials, then stage and commit

**Security criteria:**
- [ ] Verify `opencode.json` only contains `{file:...}` references for credentials, no real values
- [ ] `thoughts/.secrets/*` remains gitignored

**Success Criteria (Manual):**
- [ ] `git diff --cached` shows `opencode.json` with only `{file:...}` credential refs
- [ ] No secrets exposed in the committed file

**Commit after this phase passes verification.**

---

### Phase 2: Create the worktree plugin

**Goal:** Build a custom lightweight worktree plugin that provides `worktree_create` and `worktree_delete` tools for the agent.

**Changes:**
- [x] `plugins/worktree.ts` — New file: custom worktree plugin (~200 lines)
  - Tool: `worktree_create({ ticketId, description, type? })` 
    - Reads `thoughts/.ticket-prefix` and `thoughts/.user-acronym` (if exists)
    - Generates branch name: `[type]/[acronym]/[ticket-id]/[description]`
    - Determines worktree path (configurable base, default `~/.opencode-worktrees/<project-name>/`)
    - Runs `git worktree add <path> -b <branch>`
    - Syncs gitignored files: symlinks `thoughts/.secrets/`, copies `thoughts/.credentials`
    - Returns the worktree path for the user to navigate to
  - Tool: `worktree_delete({ path?, commit? })`
    - If `commit` is true (default false): runs `git add -A && git commit` with a snapshot message
    - Runs `git worktree remove <path>`
    - Reports the branch name for later merge/push
  - Tool: `worktree_list()`
    - Runs `git worktree list --porcelain`, parses output
    - Returns active worktrees with branch names and paths
- [x] `plugins/package.json` — No new dependencies needed (plugin uses only `node:*` and `git` CLI)

**Plugin behavior details:**
- Path validation: reject absolute paths and `..` traversal in description
- Branch validation: sanitize description for git ref naming (replace spaces with `-`, strip invalid chars)
- Symlink `thoughts/.secrets/` (shared state, single source of truth)
- Copy `thoughts/.credentials` (independent per worktree — agent may modify during tasks)
- No auto-push (ever)
- No auto-commit on delete by default — user runs `/commit` first. Optional `commit: true` flag for snapshot commits.

**Security criteria:**
- [ ] Branch name generation sanitizes input against shell metacharacters
- [ ] Worktree path construction rejects traversal attacks (`..`, absolute paths)
- [ ] No `git push` anywhere in the code
- [ ] Symlinked `thoughts/.secrets/` — user warned that changes affect main repo

**Success Criteria (Automated):**
- [ ] Plugin file has valid TypeScript (no syntax errors)
- [ ] `git worktree list` shows correct output after `worktree_create`
- [ ] `git worktree list` shows worktree removed after `worktree_delete`
- [ ] `ls -la <worktree>/thoughts/.secrets` confirms it's a symlink to the main repo
- [ ] `cat <worktree>/thoughts/.credentials` confirms it's an independent copy

**Success Criteria (Manual):**
- [ ] `opencode` loads the plugin without errors (visible in startup output)
- [ ] Agent can call `worktree_create` and receives a valid path
- [ ] Agent can call `worktree_list` and sees active worktrees
- [ ] Agent can call `worktree_delete` and the worktree is cleaned up
- [ ] Running `opencode` in the worktree directory works normally — agent has access to ticket files, AGENTS.md, scripts

**Commit after this phase passes verification.**

---

### Phase 3: Test with huber/co2os

**Goal:** Verify the worktree plugin works end-to-end in a real project.

**Changes:**
- [ ] No file changes — this is a manual integration test

**Test procedure:**
1. [ ] Open `opencode` in `~/projects/dev/huber/community/co2os`
2. [ ] Ask the agent to create a worktree for a test ticket (or use an existing one)
3. [ ] Verify the worktree was created with correct branch name
4. [ ] Verify `thoughts/.secrets/` is symlinked, `thoughts/.credentials` is copied (if exists)
5. [ ] Verify `opencode.json` is present (from git, not synced)
6. [ ] Open a new terminal, `cd` to the worktree path, run `opencode`
7. [ ] Verify the agent can read ticket files, run scripts, access MCP servers
8. [ ] Make a small change, run `/commit` in the worktree
9. [ ] Back in the main worktree session, ask the agent to list worktrees — verify it shows
10. [ ] Delete the worktree (without auto-commit, since we already committed)
11. [ ] Verify `git worktree list` no longer shows it
12. [ ] Verify `git branch` still shows the branch with the commit

**Success Criteria (Manual):**
- [ ] Full workflow works: create → navigate → work → commit → delete
- [ ] No data loss — committed changes are on the branch
- [ ] Main worktree unaffected during and after the test
- [ ] MCP servers work in the worktree (playwright, etc.)

**No commit for this phase — it's a test.**

---

### Phase 4: Documentation

**Goal:** Document the parallel workflow pattern so users can adopt it.

**Changes:**
- [x] `README.md` — Add "Parallel Workflow (Git Worktrees)" section:
  - How it works (create ticket on main → research → plan → branch via worktree → implement)
  - Process rules (tickets on main before branching, `/commit` before `worktree_delete`)
  - Commands the agent provides (`worktree_create`, `worktree_list`, `worktree_delete`)
  - Example workflow walkthrough
  - MCP resource considerations (each instance spawns its own servers)
- [x] `PLANNING.md` — Add worktree design decisions:
  - Custom plugin over vendored (supply chain, simplicity, control)
  - `opencode.json` committed (no secrets, simplifies worktree sync)
  - Symlink `.secrets/`, copy `.credentials`
  - No auto-push, no auto-commit by default
- [x] `AGENTS-base.md` — Add worktree rules to git discipline section:
  - "Create tickets, research, and plans on main — commit before branching"
  - "Run `/commit` before deleting a worktree"
  - "Never push worktree branches automatically"
- [x] `commands/init-workflow.md` — Update summary to mention worktree plugin availability

**Success Criteria (Manual):**
- [ ] README parallel workflow section is clear and actionable
- [ ] A new user could follow the documentation to set up and use worktrees
- [ ] Process rules (tickets on main, commit before delete) are documented in all relevant locations

**Commit after this phase passes verification.**

---

## Out of Scope

- Migrating tractive/aws, tractive/magento, tractive/blog (later, after co2os test)
- Background agents for async research delegation (separate feature, complementary)
- Terminal auto-spawning (user opens terminal manually)
- Auto-merge between worktree branches
- CI/CD integration for worktree branches

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|-----------|
| User hardcodes credentials in `opencode.json` after it's committed | Secrets in git | Warning comment in file header; `/commit` pre-flight scans for secrets; `.secrets.example` documents the correct pattern |
| User deletes files in symlinked `thoughts/.secrets/` thinking it's a copy | Secrets deleted from main repo | Plugin prints a clear warning on create; document in README that symlinked dirs are shared |
| Worktree left orphaned after crash | Disk space, stale branches | `worktree_list` shows all worktrees; `git worktree remove` cleans up; user can resume with `opencode -c` |
| Branch name conflicts (two worktrees for same ticket) | Git error on create | Plugin checks `git worktree list` before creating; clear error message |
| MCP servers double resource usage | RAM/CPU pressure | Document in README; suggest disabling unused MCP servers in worktree sessions |

## Open Questions

(None — all resolved during planning discussion.)
