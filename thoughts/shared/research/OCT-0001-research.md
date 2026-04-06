---
ticket: OCT-0001
title: "Research: Git Worktree Support for Parallel AI Agent Sessions"
date: 2026-04-05
status: complete
---

# Research: Git Worktree Support for Parallel AI Agent Sessions

## Context

OCT-0001 proposes adding git worktree support so multiple OpenCode sessions can work on different tickets in parallel. This research investigates the plugin ecosystem, answers the ticket's open technical questions, and documents the template's existing patterns that the implementation must integrate with.

## File Map

### Plugin System
- `plugins/peon-ping.ts` — Sound notification plugin; demonstrates full plugin API surface (`event`, `message.updated`, `session.idle` hooks)
- `plugins/ticket-reminder.ts` — Ticket status reminder; demonstrates `tool.execute.after` hook with `additionalContext` injection and `$` shell executor
- `plugins/package.json` — Declares `@opencode-ai/plugin` dependency for TypeScript types

### Config & Credentials
- `opencode.json.global.example` — Global config template; all MCP servers defined, project-specific disabled
- `project-skeleton/opencode.json.example` — Project config template; enables servers with `{file:...}` credential refs
- `project-skeleton/thoughts/.secrets.example` — Documents per-file secret format
- `project-skeleton/thoughts/.secrets/.gitkeep` — Keeps `.secrets/` directory tracked
- `thoughts/.credentials.example` — TOML credential template for agent runtime access

### File Sync & Init
- `commands/init-workflow.md` — Scaffold command; creates dirs, copies scripts/configs, symlinks AGENTS-base.md
- `install.sh` — Global install; symlinks `commands/`, `agents/`, `skills/`, `plugins/` into `~/.config/opencode/`

### Gitignore
- `.gitignore` — Root: protects `opencode.json`, `*.credentials`, `.secrets/*`, `.ticket-prefix`, `.user-acronym`
- `project-skeleton/thoughts/.gitignore` — Per-project thoughts: protects credentials and secrets

### Branch Naming & Git Discipline
- `AGENTS-base.md` — Defines branch convention `[type]/[acronym]/[ticket-id]/[description]`, git discipline rules
- `commands/commit.md` — Commit workflow with security pre-flight
- `commands/implement.md` — Implementation workflow; commits per phase

## Implementation Analysis

### OpenCode Plugin API

Plugins are async functions receiving `{ directory, $, project, client, worktree }` and returning an object of named event hooks. Key hooks relevant to worktree integration:

| Hook | Purpose | Used By |
|---|---|---|
| `session.created` | Detect new sessions, track subagents | peon-ping.ts |
| `session.idle` | Cleanup, notifications | peon-ping.ts, ticket-reminder.ts, opencode-worktree |
| `tool.execute.after` | Inject context after tool calls | ticket-reminder.ts |
| `shell.env` | Inject environment variables | (available, not used in template) |

Plugins can register custom tools that the agent can call. The worktree plugin registers `worktree_create` and `worktree_delete`.

**Loading**: Local plugins from `.opencode/plugins/` (project) and `~/.config/opencode/plugins/` (global), plus npm packages in `opencode.json` `"plugin"` array. Global plugins symlinked via `install.sh`.

### opencode-worktree Plugin Internals

**Sync mechanics** (from source code):

- `copyFiles`: Reads file from main worktree, writes independent copy to new worktree via `Bun.write()`. Validates paths against traversal attacks. Silently skips missing files.
- `symlinkDirs`: Creates absolute symlinks from worktree back to main repo directory. Removes any existing target first. **Shares state** — modifications in worktree affect main repo for symlinked dirs.
- `exclude`: Listed in schema but **not implemented** (reserved for future use).

**Auto-commit behavior** (from source code):

On `worktree_delete`, the plugin runs:
1. `preDelete` hooks
2. `git add -A`
3. `git commit -m "chore(worktree): session snapshot" --allow-empty`
4. `git worktree remove --force`

**No `git push` anywhere in the source code.** This aligns with our "human decides when to push" rule.

**Worktree storage**: `~/.local/share/opencode/worktree/{project-id}/{branch}/`
- `project-id` = first root commit SHA (stable across renames/clones), cached in `.git/opencode`
- Worktree-aware: follows `.git` file → `gitdir:` → `commondir` to find shared `.git`, so all worktrees of the same repo get the same project-id
- Path is configurable via `worktreePath` in `.opencode/worktree.jsonc`

**State storage**: `~/.local/share/opencode/plugins/worktree/{project-id}.sqlite` (WAL mode, 5s busy_timeout for concurrent access)

### Comparison: opencode-worktree vs opencode-worktree-session

| Feature | opencode-worktree (kdcokenny) | opencode-worktree-session (felixAnhalt) |
|---|---|---|
| Commit message | Fixed: `"chore(worktree): session snapshot"` | AI-generated via OpenCode API |
| Auto-push | **No** | **Yes** (to origin) |
| Worktree location | `~/.local/share/opencode/worktree/` (outside repo) | `.opencode/worktrees/` (inside repo) |
| Branch safety | Validates against git ref rules + shell metacharacters | Refuses to run on `main` |
| Terminal spawning | Auto-detects terminal, spawns new window | Configurable terminal + post-create hooks |
| File sync | Config-based `copyFiles`/`symlinkDirs` | Manual config file |
| Install method | OCX or manual copy | npm package |
| Stars | 398 | 26 |

**Recommendation**: opencode-worktree (kdcokenny) is the better fit — no auto-push, external storage, config-based sync, larger community.

### Multiple OpenCode Instances

OpenCode uses client/server architecture. Each `opencode` invocation starts its own server on a random port. Two instances against different worktrees of the same repo work independently — no shared state at the HTTP level. The worktree plugin's SQLite state uses WAL mode for concurrent access from multiple instances.

## Existing Patterns

### Pattern: Plugin with event hooks
**Location**: `plugins/ticket-reminder.ts:67-149`
The template already has two plugins demonstrating the full lifecycle. New worktree plugin follows the same pattern: async function returning hook handlers.

### Pattern: File sync via init-workflow
**Location**: `commands/init-workflow.md:55-118`
Four conditional copy patterns: unconditional, skip-if-exists, suggest-append, warn-and-ask. Worktree sync config (`.opencode/worktree.jsonc`) needs to be added to init-workflow following the skip-if-exists pattern.

### Pattern: Symlink for auto-updating shared files
**Location**: `commands/init-workflow.md:120-129` (AGENTS-base.md), `install.sh:62-110` (global dirs)
Symlinks keep shared content in sync. Relevant for worktree's `symlinkDirs` — `node_modules` and potentially `thoughts/.secrets/` could be symlinked rather than copied.

### Pattern: Credential isolation via {file:...} substitution
**Location**: `project-skeleton/opencode.json.example:21-36`
`opencode.json` uses `{file:thoughts/.secrets/...}` to read credentials from gitignored files. This is relevant because if `opencode.json` is committed (since it has no real credentials), worktrees get it for free.

## Impact Analysis

### Files that need modification

| File | Change | Impact |
|---|---|---|
| `commands/init-workflow.md` | Add worktree config step (`.opencode/worktree.jsonc`) | New step, no existing functionality affected |
| `project-skeleton/` | Add `.opencode/worktree.jsonc` template | New file |
| `README.md` | Document parallel workflow pattern | Documentation only |
| `PLANNING.md` | Record worktree design decisions | Documentation only |
| `.gitignore` | Add `.opencode/` if not already present | Already present (line 32) |

### Backward compatibility

- **No breaking changes**: Worktree support is additive. Existing sequential workflow is unaffected.
- **Plugin is opt-in**: Only active when installed. Template can ship the config without the plugin.
- **Branch naming**: Worktrees create branches. Our naming convention (`[type]/[acronym]/[ticket-id]/[description]`) must be passed to `worktree_create(branch)` — this is the agent's responsibility, not the plugin's.

### Potential side effects

- **Disk space**: Each worktree is a full checkout minus symlinked dirs. For tractive/aws (~300MB with node_modules), `symlinkDirs: ["node_modules"]` is essential.
- **MCP server resource usage**: Each OpenCode instance spawns its own MCP servers. Two instances = two Playwright browsers, two Kibana connections, etc. Resource-heavy for machines with limited RAM.
- **SQLite contention**: The worktree plugin shares a SQLite DB across all instances. WAL mode handles this, but extreme concurrency (5+ parallel sessions) could see occasional busy timeouts.

## Answers to Ticket's Open Technical Questions

### 1. How does opencode-worktree handle symlinked files (like AGENTS-base.md)?

Symlinked files in the main repo are **checked out as regular files** by `git worktree add`. Git resolves symlinks during checkout. The worktree gets the content, not the symlink. This means AGENTS-base.md in a worktree is a **regular file** with the current content — it won't auto-update if the template changes. This is acceptable since worktrees are short-lived (one implementation session).

### 2. Can thoughts/.secrets/ be symlinked to the worktree?

**Yes.** Use `symlinkDirs: ["thoughts/.secrets"]` in the worktree config. This creates an absolute symlink from the worktree back to the main repo's `thoughts/.secrets/`. Changes to secrets in the main repo are immediately visible in all worktrees. No credential duplication.

### 3. Disk space impact for large repos?

A worktree is a full working tree checkout. For tractive/aws: ~300MB with node_modules. Mitigation: `symlinkDirs: ["node_modules"]` shares the dependency directory. Remaining checkout is typically 10-50MB for source code. Three parallel worktrees ≈ 30-150MB additional (with node_modules symlinked).

### 4. Does the plugin support disabling auto-push?

**There is no auto-push.** The plugin runs `git add -A` + `git commit` on worktree delete. No `git push` call exists in the source code. This matches our workflow requirement.

### 5. How do MCP servers behave with multiple instances?

Each OpenCode instance spawns its own MCP server processes. Two parallel sessions = two sets of MCP servers. For lightweight servers (Jira, Bitbucket), this is fine. For resource-heavy ones (Playwright, Kibana), this doubles resource usage. Consider disabling unnecessary MCP servers in worktree configs if resource-constrained.

### 6. Can opencode-background-agents complement this?

**Yes, for read-only tasks.** Background agents run in isolated sessions with `edit=deny, write=deny, bash=deny`. They persist results to `~/.local/share/opencode/delegations/` as markdown. Ideal for `/research` — fire off research in the background, continue working, retrieve results later. Not suitable for `/implement` (needs write access). This is a separate, complementary feature — can be added independently of worktree support.

## Security Assessment

### Relevant categories (per security checklist quick decision matrix)

| Category | Why Relevant | Assessment |
|---|---|---|
| **Cat 1: Injection** | Branch names passed to shell commands (`git worktree add`) | **Mitigated**: Plugin validates branch names against git ref rules and shell metacharacters |
| **Cat 2: Crypto (secrets)** | Credentials synced to worktrees | **Mitigated**: `copyFiles` creates independent copies; `symlinkDirs` shares via symlink. Both keep files gitignored. The `.gitignore` patterns protect `thoughts/.secrets/*` in all worktrees. |
| **Cat 3: Access Control (file paths)** | `copyFiles`/`symlinkDirs` resolve user-provided paths | **Mitigated**: Plugin validates paths — rejects absolute paths, `..` traversal, and any resolved path outside the base directory |
| **Cat 6: Misconfiguration** | 3rd-party plugin runs with full agent context | **Risk**: Plugin has access to `$` (shell), `client` (OpenCode SDK), filesystem. Source code is open and reviewable. Mitigate by reviewing source before installation. |
| **Cat 9: AI-specific** | Auto-commit on worktree delete bypasses `/commit` security pre-flight | **Risk**: The fixed commit message `"chore(worktree): session snapshot"` skips our security scan. Mitigate by either: (a) running `/commit` before `worktree_delete`, or (b) treating snapshot commits as intermediate, not final. |

### Security constraints for implementation

1. Worktree sync config must NOT include paths outside the project directory
2. `thoughts/.secrets/` should use `symlinkDirs` (not `copyFiles`) to avoid credential duplication and ensure single source of truth
3. The `/commit` command should be run before worktree cleanup to ensure security pre-flight scan
4. Branch names should be generated from ticket IDs (controlled input), not arbitrary user strings

## Summary

- **opencode-worktree (kdcokenny) is the right plugin**: No auto-push, config-based file sync, external worktree storage, good community adoption (398 stars). Source code is clean with proper input validation.
- **Sync strategy for our workflow**: Use `symlinkDirs` for `thoughts/.secrets` and `node_modules`; use `copyFiles` for `thoughts/.credentials`. Consider committing `opencode.json` (no real credentials) to eliminate the need to sync it.
- **No auto-push, no auto-commit conflict**: The plugin commits with a snapshot message but does not push. Our `/commit` pre-flight can run before `worktree_delete`. The snapshot commit is acceptable as an intermediate safety net.
- **Multiple instances work**: OpenCode's client/server architecture supports independent instances per worktree. The plugin's SQLite state handles concurrent access via WAL mode.
- **The `opencode.json` commitment question is a key simplification**: Since `opencode.json` now uses `{file:...}` substitution for all credentials, it contains zero secrets. Committing it means worktrees get it automatically — no sync needed. This should be a prerequisite change.
- **Background agents are a complementary feature**: Can be added separately for async read-only research. Not a dependency for the worktree implementation.
