# OpenCode Workflow Template

A structured agent workflow for [OpenCode](https://opencode.ai) that provides a repeatable process for software development:

**Create Ticket** → **Research Codebase** → **Create Plan** → **Implement** → **Commit** → **Code Review** → **Discuss**

Inspired and adapted from [Tobi Schlitt: context-engineering for LLM coding](https://schlitt.info/blog/0793_context_engineering_claude_code.html) for OpenCode's agent, command, skill, and plugin system.

## What's Included

| Component    | Count | Description                                                                                                                   |
| ------------ | ----- | ----------------------------------------------------------------------------------------------------------------------------- |
| **Commands** | 10    | `/create-ticket`, `/ticket-from-jira`, `/research`, `/plan`, `/implement`, `/commit`, `/review`, `/discuss`, `/init-workflow`, `/caveman` |
| **Agents**   | 7     | Specialized subagents for codebase analysis, pattern finding, documentation, web research, and code review                    |
| **Skills**   | 6     | Research documents, implementation plans, security checklist, caveman mode (terse output), caveman-commit, caveman-review      |
| **Plugin**   | 1     | Ticket status reminders on git operations + desktop notifications                                                             |
| **Scripts**  | 4     | Ticket management utilities + credentials access                                                                              |

## Prerequisites

- [OpenCode](https://opencode.ai) installed and configured
- Bash (scripts use `#!/bin/bash` — works regardless of your login shell)
- `notify-send` (optional, for Linux desktop notifications)

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/nhp/opencode-template.git ~/path/to/opencode-template
```

### 2. Run the installer

```bash
cd ~/path/to/opencode-template
./install.sh
```

This creates symlinks in `~/.config/opencode/` for `commands/`, `agents/`, `skills/`, and `plugins/`. Your `opencode.json` is never touched.

Use `./install.sh --dry-run` to preview changes, or `./install.sh --force` to replace existing directories.

### 3. Set environment variables

**fish:**

```fish
set -gx OPENCODE_TEMPLATE_DIR ~/path/to/opencode-template
set -gx OPENCODE_EXPERIMENTAL_LSP_TOOL true  # optional: enables LSP for agents
```

**bash/zsh:**

```bash
export OPENCODE_TEMPLATE_DIR="$HOME/path/to/opencode-template"
export OPENCODE_EXPERIMENTAL_LSP_TOOL=true  # optional
```

### 4. Initialize in a project

Open a project in OpenCode and run:

```
/init-workflow PROJ
```

Replace `PROJ` with your ticket prefix (e.g., `NHP`, `SHOP`, `APP`). This creates:

- `thoughts/shared/{tickets,discussions,plans,research,reviews}/`
- `scripts/{ticket.sh,next-ticket.sh,open_tickets.sh}`
- `thoughts/.ticket-prefix`
- `AGENTS.md` (starter template, if none exists)

## Workflow

### The 4-Step Development Cycle

1. **`/create-ticket`** — Interactive ticket creation through 7 collaborative phases. Produces a structured ticket in `thoughts/shared/tickets/`.

2. **`/research PROJ-0001`** — Spawns subagents to research the codebase: locate files, analyze code, find patterns, check documentation. Produces a research document in `thoughts/shared/research/`.

3. **`/plan PROJ-0001`** — Interactive plan creation using ticket + research as input. Produces a phased implementation plan with success criteria in `thoughts/shared/plans/`.

4. **`/implement PROJ-0001`** — Executes the plan phase by phase. Runs verification, commits after each phase, tracks progress.

### Supporting Commands

- **`/commit`** — Pre-commit checklist: runs tests, checks code style, reviews staged changes, creates a clean commit.
- **`/review PROJ-0001`** — Code review against ticket acceptance criteria. Produces review document.
- **`/discuss topic`** — Technical discussion with a senior engineer sparring partner. No code changes.
- **`/ticket-from-jira PROJ-1234`** — Import a Jira ticket into the local format. Requires Jira MCP.
- **`/init-workflow PREFIX`** — Set up the workflow in a new project.

## Ticket System

Tickets are local markdown files in `thoughts/shared/tickets/`. This works in every project, with or without external issue trackers.

For projects using Jira, `/ticket-from-jira` imports tickets into the same local format. All downstream commands (`/research`, `/plan`, `/implement`, `/review`) work against local ticket files — they don't care where the ticket originated.

### Ticket Scripts

```bash
./scripts/next-ticket.sh          # Get next available ticket number
./scripts/ticket.sh PROJ-0001     # Find all docs related to a ticket
./scripts/open_tickets.sh         # List open/in-progress tickets
```

### Credentials & Secrets

There are two credential systems, each serving a different purpose:

#### Agent Credentials (`thoughts/.credentials`)

TOML file for agent runtime access via `scripts/credentials.sh`. Used when the agent needs login credentials, API keys, or other secrets during tasks.

```toml
[basic-auth]
username = "joe"
password = "doe"
```

```bash
./scripts/credentials.sh                      # List credential sets
./scripts/credentials.sh basic-auth           # List keys in a set
./scripts/credentials.sh basic-auth username  # Get a specific value
```

Set up by copying the example: `cp thoughts/.credentials.example thoughts/.credentials`

#### MCP Server Secrets (`thoughts/.secrets/`)

Individual files for OpenCode config `{file:...}` substitution. Used to provide credentials to MCP servers configured in `opencode.json`. Each file contains a single value, no quotes, no trailing newline.

```bash
echo -n "your-email@example.com" > thoughts/.secrets/atlassian-email
echo -n "your-api-token"         > thoughts/.secrets/atlassian-api-token
```

Referenced in `opencode.json`:
```jsonc
"environment": {
  "ATLASSIAN_USER_EMAIL": "{file:thoughts/.secrets/atlassian-email}",
  "ATLASSIAN_API_TOKEN": "{file:thoughts/.secrets/atlassian-api-token}"
}
```

See `thoughts/.secrets.example` for a full list of supported files.

### Configuration (Global vs Project)

OpenCode merges configs from multiple locations. This template uses a two-layer pattern:

**Global config** (`~/.config/opencode/opencode.json`) — defines all MCP servers. Servers used everywhere (e.g., Playwright) are enabled. Project-specific servers (Jira, Kibana, Magento) are disabled by default.

**Project config** (`<project>/opencode.json`) — committed to git. Enables specific servers per project and provides credentials via `{file:...}` references to gitignored files in `thoughts/.secrets/`. Contains no real credentials — safe to commit. This also means git worktrees get the config automatically.

**Important:** Each MCP entry in the project config must include the **full definition** (`type`, `command`/`url`) — OpenCode does not deep-merge MCP server configs with the global config.

See `opencode.json.global.example` for the global config pattern and `project-skeleton/opencode.json.example` for the project-level pattern.

Config precedence (highest to lowest):
1. Project config (`opencode.json` in project root)
2. Global config (`~/.config/opencode/opencode.json`)
3. Remote config (organizational defaults)

See [OpenCode Config docs](https://opencode.ai/docs/config/) for full details.

### Parallel Workflow (Git Worktrees)

The template includes a worktree plugin that lets you run multiple OpenCode sessions in parallel, each working on a different ticket in isolation.

**How it works:** Each worktree is a separate checkout of your repo on its own branch. You work in it like a normal directory — `cd` there, run `opencode`, do your work. When done, the branch merges back via standard git workflow.

**Usage:** Run the worktree script directly in your terminal (no OpenCode needed):

```bash
# Create a worktree for a ticket
./scripts/worktree.sh create PROJ-0001 "checkout-fix"
# → Branch: feature/nhp/PROJ-0001/checkout-fix
# → Path:   ~/.opencode-worktrees/my-project/checkout-fix/

# List active worktrees
./scripts/worktree.sh list

# Delete a worktree (run /commit in the worktree first!)
./scripts/worktree.sh delete checkout-fix

# Delete without confirmation prompt
./scripts/worktree.sh delete -f checkout-fix
```

**Recommended workflow:**

```
1. /create-ticket    →  create ticket on main                      →  commit
2. /research TICKET  →  research on main                           →  commit
3. /plan TICKET      →  plan on main                               →  commit
4. ./scripts/worktree.sh create TICKET "description"               →  new branch
5. cd <worktree-path> && opencode                                  →  new terminal
6. /implement TICKET →  implement in worktree                      →  commits on branch
7. /commit           →  final commit with pre-flight               →  on branch
8. ./scripts/worktree.sh delete description                        →  cleanup
9. git merge <branch>                                              →  back on main
```

Steps 1-3 happen on main so the ticket, research, and plan are available in the worktree (it branches from main after they're committed). You can run multiple worktrees in parallel for different tickets.

**Process rules:**
- Always create tickets, research, and plans on main before branching
- Run `/commit` before deleting a worktree (the plugin never auto-pushes)
- `thoughts/.secrets/` is **symlinked** — changes in the worktree affect the main repo

**File sync:** The script symlinks the entire `thoughts/` directory to the worktree, so all tickets, research, plans, credentials, and secrets are shared.

| Content | Available via | Notes |
|---------|--------------|-------|
| `thoughts/` (entire dir) | Symlink | Shared: tickets, research, plans, credentials, secrets |
| `opencode.json` | Git | Committed to repo, available automatically |
| Source code | Git | Normal worktree checkout |

**Worktree storage:** `~/.opencode-worktrees/<project-name>/<description>/`

## Caveman Mode (Optional)

Token-efficient communication mode based on [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman). Cuts ~75% of output tokens while keeping full technical accuracy. Activate when you want faster, terser responses.

| Command | What it does |
|---------|-------------|
| `/caveman` | Activate caveman mode (default: full) |
| `/caveman lite` | Professional but no fluff — drop filler, keep grammar |
| `/caveman ultra` | Maximum compression — abbreviations, arrows, bare fragments |
| `/caveman-help` | Quick-reference card for all modes and skills |

Say "stop caveman" or "normal mode" to deactivate.

**Additional skills** loaded by `/caveman`:
- **caveman-commit** — terse commit messages in Conventional Commits format
- **caveman-review** — one-line code review comments: `L42: bug: user null. Add guard.`

## Model Routing (Optional)

By default, all commands and subagents inherit your primary model. This keeps the template provider-agnostic — it works with any provider you've configured.

To reduce costs, you can route lighter tasks to a cheaper model on a per-project basis. Add `agent` and `command` overrides to your project's `opencode.json`:

```jsonc
{
  "agent": {
    "codebase-locator":  { "model": "anthropic/claude-sonnet-4-20250514" },
    "codebase-analyzer": { "model": "anthropic/claude-sonnet-4-20250514" }
    // ... other subagents
  },
  "command": {
    "research": { "model": "anthropic/claude-sonnet-4-20250514" },
    "commit":   { "model": "anthropic/claude-sonnet-4-20250514" }
    // ... other commands
  }
}
```

See `opencode.json.example` for the full commented-out block you can uncomment and adjust.

**What to route where:**

| Component | Recommendation | Why |
|-----------|---------------|-----|
| Primary agent + `/implement` | Best model | Writes code — needs full reasoning |
| `/research`, `/plan`, `/review` | Mid-tier | Analysis and synthesis, no code changes |
| `/commit`, `/discuss`, `/create-ticket` | Mid-tier | Structured dialogue, mechanical checks |
| All 7 subagents | Mid-tier | Search, describe, read-only tasks |
| `/caveman`, `/init-workflow` | Mid-tier | Lightweight tasks |

## Agents

All subagents follow a strict "documentarian" rule — they describe what exists without suggesting improvements or expressing opinions.

| Agent                     | Purpose                                       |
| ------------------------- | --------------------------------------------- |
| `codebase-locator`        | Finds WHERE code lives (files, not contents)  |
| `codebase-analyzer`       | Understands HOW code works (reads and traces) |
| `codebase-pattern-finder` | Finds similar implementations as templates    |
| `thoughts-locator`        | Finds documents in `thoughts/`                |
| `thoughts-analyzer`       | Extracts high-value insights from docs        |
| `web-search-researcher`   | Web research from authoritative sources       |
| `code-reviewer`           | Pragmatic code review                         |

## Project Structure

```
~/.config/opencode/
├── opencode.json              # Your global config (not managed by this repo)
├── commands/ -> repo/commands/ # Symlink
├── agents/  -> repo/agents/   # Symlink
├── skills/  -> repo/skills/   # Symlink
└── plugins/ -> repo/plugins/  # Symlink

<your-project>/
├── opencode.json              # Project-level config (MCP overrides, credentials)
├── opencode.json.example      # Reference for project config structure
├── AGENTS.md                  # Project-specific instructions
├── scripts/                   # Ticket management scripts
│   ├── ticket.sh
│   ├── next-ticket.sh
│   ├── open_tickets.sh
│   └── credentials.sh
└── thoughts/
    ├── .ticket-prefix         # e.g., "PROJ"
    ├── .credentials.example   # Agent credentials format template
    ├── .credentials           # Agent credentials (gitignored)
    ├── .secrets.example       # MCP secrets format template
    ├── .secrets/              # MCP server secrets (gitignored)
    │   ├── .gitkeep
    │   ├── atlassian-email    # One value per file
    │   └── atlassian-api-token
    └── shared/
        ├── tickets/           # Ticket definitions
        ├── research/          # Codebase research documents
        ├── plans/             # Implementation plans
        ├── reviews/           # Code review documents
        └── discussions/       # Technical discussion records
```

## Acknowledgements

Based on [tobyS/claude-template](https://github.com/tobyS/claude-template), a context-engineering workflow originally built for Claude Code. Adapted for OpenCode's agent, command, skill, and plugin system.
