# OpenCode Workflow Template

A structured agent workflow for [OpenCode](https://opencode.ai) that provides a repeatable process for software development:

**Create Ticket** → **Research Codebase** → **Create Plan** → **Implement** → **Commit** → **Code Review** → **Discuss**

Inspired and adapted from [Tobi Schlitt: context-engineering for LLM coding](https://schlitt.info/blog/0793_context_engineering_claude_code.html) for OpenCode's agent, command, skill, and plugin system.

## What's Included

| Component    | Count | Description                                                                                                                   |
| ------------ | ----- | ----------------------------------------------------------------------------------------------------------------------------- |
| **Commands** | 9     | `/create-ticket`, `/ticket-from-jira`, `/research`, `/plan`, `/implement`, `/commit`, `/review`, `/discuss`, `/init-workflow` |
| **Agents**   | 7     | Specialized subagents for codebase analysis, pattern finding, documentation, web research, and code review                    |
| **Skills**   | 2     | Lazy-loaded templates for research documents and implementation plans                                                         |
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

See `opencode.json.global.example` for the global config pattern and `project-skeleton/opencode.json.example` for the project-level pattern.

Config precedence (highest to lowest):
1. Project config (`opencode.json` in project root)
2. Global config (`~/.config/opencode/opencode.json`)
3. Remote config (organizational defaults)

See [OpenCode Config docs](https://opencode.ai/docs/config/) for full details.

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
