# OpenCode Workflow Template — Planning Document

Adapted from [tobyS/claude-template](https://github.com/tobyS/claude-template) for [OpenCode](https://opencode.ai).

**Status:** Phases 0–7 complete. Remaining: remove inline code-reviewer from opencode.json (8).

## Goal

Provide a structured, repeatable agent workflow for OpenCode that works across all projects:

**Ticket creation** → **Codebase research** → **Implementation planning** → **Implementation** → **Commit** → **Code review** → **Technical discussion**

Local markdown tickets are the canonical format (works everywhere). An optional `/ticket-from-jira` command imports Jira tickets into the same local format for projects that use Jira.

## Repository Structure

```
opencode-template/
├── README.md                             # Public: what this is, install, usage
├── PLANNING.md                           # This document
├── .gitignore
├── install.sh                            # Symlinks to ~/.config/opencode/
├── opencode.json.global.example           # Global config: all MCP servers, project-specific disabled
├── AGENTS.md.example                     # Starter template for new projects
├── commands/
│   ├── create-ticket.md
│   ├── ticket-from-jira.md
│   ├── research.md
│   ├── plan.md
│   ├── implement.md
│   ├── commit.md
│   ├── review.md
│   ├── discuss.md
│   └── init-workflow.md                  # Scaffold command
├── agents/
│   ├── codebase-locator.md
│   ├── codebase-analyzer.md
│   ├── codebase-pattern-finder.md
│   ├── thoughts-locator.md
│   ├── thoughts-analyzer.md
│   ├── web-search-researcher.md
│   └── code-reviewer.md
├── skills/
│   ├── research-document/
│   │   └── SKILL.md
│   └── implementation-plan/
│       └── SKILL.md
├── plugins/
│   └── ticket-reminder.ts
└── project-skeleton/                     # Copied per-project by /init-workflow
    ├── opencode.json.example             # Project-level config: MCP overrides + file-based credentials
    ├── scripts/
    │   ├── ticket.sh
    │   ├── next-ticket.sh
    │   └── open_tickets.sh
    └── thoughts/
        ├── .gitignore                    # Ignores .secrets/*, .credentials, .ticket-prefix, .user-acronym
        ├── .secrets.example              # Documents which secret files to create
        ├── .secrets/
        │   └── .gitkeep
        └── shared/
            ├── tickets/.gitkeep
            ├── discussions/.gitkeep
            ├── plans/.gitkeep
            ├── research/.gitkeep
            └── reviews/.gitkeep
```

## Technical Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Ticket system | Local markdown (universal) + `/ticket-from-jira` (optional) | Not all projects use Jira. Local files give a unified interface for all downstream commands. |
| Scripts shell | Bash (`#!/bin/bash`) | Fish is blacklisted by OpenCode's bash tool (`shell.ts:42`). Bun's `$` shell for `!` injection is POSIX-like. All execution paths use bash/sh on Linux. |
| Install method | Symlinks for global dirs (commands, agents, skills, plugins) | Git pull = instant updates. `opencode.json` never symlinked — stays private. |
| Credential isolation | Repo contains zero credentials. `opencode.json.example` has placeholders. Defensive `.gitignore`. | Public repo safety. |
| Ticket prefix | Per-project `thoughts/.ticket-prefix` file | Scripts read it dynamically. Avoids hardcoding. Set during `/init-workflow`. |
| Jira ticket IDs | Use original Jira key as-is | `/ticket-from-jira` preserves the Jira ticket key (e.g., `SHOP-42`) instead of generating a sequential local ID. Scripts scan all `.md` files in tickets dir. |
| User acronym | Optional `thoughts/.user-acronym` file | Set during `/init-workflow`. Used in branch naming: `feature/nhp/PROJ-0001/desc`. Gitignored. |
| Skeleton location | `OPENCODE_TEMPLATE_DIR` env var | Portable. Set once in shell config. `/init-workflow` reads it. |
| Hook: ticket status reminder | OpenCode plugin (`tool.execute.after`) | Replaces template's `check-ticket-status.sh`. Watches `git add` calls, reminds agent to update ticket status. |
| Hook: status validation | Dropped | Agent follows instructions in command prompts. Not worth the plugin complexity. |
| Template extraction | Skills for research-document and implementation-plan | Saves tokens — loaded on demand instead of embedded in every command invocation. |
| Scaffold command | `/init-workflow PREFIX` | Creates dirs, copies scripts, writes `.ticket-prefix`, generates starter `AGENTS.md`. |
| AGENTS.md split | `AGENTS-base.md` (symlinked, universal) + `AGENTS.md` (copied, project-specific) | Universal rules (security, git discipline, conventions) update automatically via symlink. Project-specific config (tech stack, persona, commands) stays per-project. |
| Security awareness | Layered: AGENTS.md rules + security-checklist skill + command gates | AGENTS.md has always-on NEVER/ALWAYS rules (OWASP-inspired + AI-specific). Security skill loaded on demand by /research, /plan, /implement, /review. Commands embed security checkpoints at each workflow stage. /commit has a security pre-flight scan. |
| Config layering | Global config (all MCP servers, project-specific disabled) + project config (enables specific servers with credentials) | Different projects need different MCP servers with different credentials. Global defines the catalog, project enables what it needs. |
| MCP credentials | `thoughts/.secrets/` with one file per value, referenced via `{file:...}` in `opencode.json` | OpenCode's native `{file:path}` substitution. Avoids env var management. Gitignored. Separate from TOML `.credentials` (agent runtime) to avoid naming conflict (file vs directory). |

## Component Inventory

### Commands (9 files)

| File | Source | Status | Adaptation Notes |
|------|--------|--------|-----------------|
| `commands/create-ticket.md` | Template `create_ticket.md` | [ ] | Replace Task agent spawning → `@agent-name`. Keep 7-phase interactive dialogue. Call `!./scripts/next-ticket.sh`. |
| `commands/ticket-from-jira.md` | New | [ ] | Takes Jira ticket ID as `$ARGUMENTS`. Jira MCP fetch → map to local ticket template. Calls `!./scripts/next-ticket.sh`. Adds `Jira Reference:` field. Graceful failure if Jira MCP unavailable. |
| `commands/research.md` | Template `research_codebase.md` | [ ] | Replace subagent syntax. Move YAML research template → `research-document` skill (load on demand). Call `!./scripts/ticket.sh $1`. |
| `commands/plan.md` | Template `create_plan.md` | [ ] | Replace subagent/ticket refs. Move plan template → `implementation-plan` skill. |
| `commands/implement.md` | Template `implement_plan.md` | [ ] | Replace ticket script refs. Keep phase-by-phase with `todowrite`. |
| `commands/commit.md` | Template `commit.md` | [ ] | Adapt to branch naming (`feature/SHORTCODE/TICKET-ID/branch-name`). Add inline ticket status reminder. |
| `commands/review.md` | Template `code_review.md` | [ ] | Replace ticket refs with `!./scripts/ticket.sh`. Output to `thoughts/shared/reviews/`. |
| `commands/discuss.md` | Template `discuss.md` | [ ] | Nearly direct copy. Output to `thoughts/shared/discussions/`. |
| `commands/init-workflow.md` | New | [ ] | Takes PREFIX as `$ARGUMENTS`. Reads `$OPENCODE_TEMPLATE_DIR`. Creates dirs, copies scripts, writes `.ticket-prefix`, optionally generates starter `AGENTS.md`. |

### Agents (7 files)

| File | Mode | Status | Tools Allowed | Tools Denied | Prompt Notes |
|------|------|--------|---------------|--------------|-------------|
| `agents/codebase-locator.md` | subagent | [ ] | lsp, grep, glob, list | edit, write, bash (destructive), webfetch | "Documentarian only" — finds WHERE code lives, does NOT read contents. |
| `agents/codebase-analyzer.md` | subagent | [ ] | lsp, read, grep, glob, list | edit, write, webfetch | Understands HOW code works. Traces data flow. Never suggests improvements. |
| `agents/codebase-pattern-finder.md` | subagent | [ ] | lsp, read, grep, glob, list | edit, write, webfetch | Finds similar implementations as templates. Never recommends one over another. |
| `agents/thoughts-locator.md` | subagent | [ ] | grep, glob, list | edit, write, bash, webfetch, lsp | Finds documents in `thoughts/`. Does not read full contents. |
| `agents/thoughts-analyzer.md` | subagent | [ ] | read, grep, glob, list | edit, write, bash, webfetch, lsp | Extracts high-value insights from thoughts docs. Filters aggressively. |
| `agents/web-search-researcher.md` | subagent | [ ] | webfetch, websearch, read, grep, glob, todowrite | edit, write | Web research specialist. Preferred/excluded source lists. |
| `agents/code-reviewer.md` | subagent | [ ] | read, grep, glob, list, lsp | edit, write | Migrated from inline `opencode.json` definition. Full review prompt. |

### Skills (3 directories)

| Skill | Status | Contents | Loaded By |
|-------|--------|----------|-----------|
| `skills/research-document/SKILL.md` | [ ] | Research document YAML template, output format spec, section descriptions, quality checklist | `/research` command |
| `skills/implementation-plan/SKILL.md` | [ ] | Plan template structure, phase format, success criteria (automated vs manual), review checklist | `/plan` command |
| `skills/security-checklist/SKILL.md` | [ ] | OWASP/CWE-based security checklist with 9 categories, decision matrix, secure vs insecure patterns | `/research`, `/plan`, `/implement`, `/review` commands |

### Plugin (1 file)

| File | Status | Events | Logic |
|------|--------|--------|-------|
| `plugins/ticket-reminder.ts` | [ ] | `tool.execute.after` | Filters for bash calls containing `git add`/`git commit`. Finds ticket IDs in staged files or recent commits. Reads local ticket status. Surfaces reminder if status needs updating. Optional: `session.idle` → `notify-send` for Linux notifications. |

### Project Skeleton (3 scripts + directories)

| File | Status | Adaptation from Template |
|------|--------|------------------------|
| `project-skeleton/scripts/ticket.sh` | [ ] | Replace hardcoded `TICKET_PREFIX="PROJ"` → read from `thoughts/.ticket-prefix`. |
| `project-skeleton/scripts/next-ticket.sh` | [ ] | Same prefix change. |
| `project-skeleton/scripts/open_tickets.sh` | [ ] | Same prefix change. |
| `project-skeleton/thoughts/shared/*/` | [x] | 5 directories with `.gitkeep` files. Done in Phase 0. |

### Repo Infrastructure

| File | Status | Purpose |
|------|--------|---------|
| `PLANNING.md` | [x] | This document |
| `.gitignore` | [x] | Defensive credential blocking |
| `install.sh` | [x] | Symlink creation script |
| `opencode.json.global.example` | [x] | Global config: all MCP servers defined, project-specific disabled |
| `AGENTS.md.example` | [x] | Starter template for `/init-workflow` |
| `README.md` | [ ] | Public docs — last, after all components exist |

## OpenCode ↔ Claude Code Reference

| Claude Code | OpenCode | Notes |
|-------------|----------|-------|
| `.claude/commands/*.md` | `.opencode/commands/*.md` or `~/.config/opencode/commands/*.md` | Same markdown format, same `$ARGUMENTS`/`$1`, same `` !`cmd` `` and `@file` |
| `.claude/agents/*.md` | `.opencode/agents/*.md` | Different frontmatter: `tools` denylist + `permission` block replaces `tools:` allowlist |
| `tools: LSP, Read, Grep` (allowlist) | `tools: { write: false }` (denylist) + `permission: { bash: {...} }` | OpenCode uses denylist + permission globs |
| Spawn Task agent | `@agent-name` mention or automatic Task tool routing | Same concept, different invocation syntax in prompts |
| `settings.json` hooks | `.opencode/plugins/*.ts` with event hooks | TypeScript, richer event model (`tool.execute.after`, `session.idle`, etc.) |
| `CLAUDE.md` | `AGENTS.md` (preferred) or `CLAUDE.md` (fallback) | OpenCode reads both, prefers AGENTS.md |
| TodoWrite | `todowrite` / `todoread` | Same tool, available in OpenCode |
| WebSearch | `websearch` (requires Exa AI or OpenCode provider) | May need `OPENCODE_ENABLE_EXA=1` |
| LSP tool | `lsp` tool (experimental) | Needs `OPENCODE_EXPERIMENTAL_LSP_TOOL=true` |
| No equivalent | Skills (`.opencode/skills/*/SKILL.md`) | Lazy-loaded context — OpenCode unique |
| No equivalent | `question` tool | Ask user with structured options — OpenCode unique |

## Implementation Phases

| Phase | Components | Status | Depends On |
|-------|-----------|--------|------------|
| 0 | Repo scaffold, PLANNING.md, .gitignore, install.sh, examples, skeleton dirs | [x] | — |
| 1 | Agents (7 files) | [x] | Phase 0 |
| 2 | Skills (2 files) | [x] | Phase 0 |
| 3 | Commands (9 files) | [x] | Phase 1 + 2 (commands reference agents and skills) |
| 4 | Project skeleton scripts (3 files) | [x] | Phase 0 |
| 5 | Plugin (1 file) | [x] | Phase 3 |
| 6 | README.md | [x] | Phase 1–5 |
| 7 | Run install.sh, test in one project | [x] | Phase 0–6 |
| 8 | Remove inline code-reviewer from opencode.json | [ ] | Phase 1 |

## Pre-Publish Safety Checklist

Before any `git push` to a public remote:

- [ ] `grep -rE '(api.token|api.key|password|secret|cookie|sid=)' .` returns no real credentials
- [ ] `grep -rE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' .` — no real email addresses (only placeholders)
- [ ] `opencode.json` is NOT tracked (only `.example`)
- [ ] `.ticket-prefix` files are gitignored
- [ ] No project-specific paths (Tractive, Huber, company names) in template files
- [ ] `install.sh` doesn't reference private paths
- [ ] `git diff --cached` review before first push
- [ ] All placeholder values use obvious markers (`YOUR_`, `EXAMPLE_`, `CHANGEME`)

## Environment Setup

Add to fish config (`~/.config/fish/config.fish`):

```fish
set -gx OPENCODE_TEMPLATE_DIR ~/projects/dev/nhp/opencode-template
set -gx OPENCODE_EXPERIMENTAL_LSP_TOOL true
```
