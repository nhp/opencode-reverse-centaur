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

### Credentials Management

Store project credentials in `thoughts/.credentials` (TOML format, gitignored). Supports multiple named credential sets:

```toml
[basic-auth]
username = "joe"
password = "doe"

[frontend]
username = "jane"
password = "doe"
```

Access via `scripts/credentials.sh` — the agent never reads the raw file directly:

```bash
./scripts/credentials.sh                      # List credential sets
./scripts/credentials.sh basic-auth           # List keys in a set
./scripts/credentials.sh basic-auth username  # Get a specific value
```

Set up by copying the example: `cp thoughts/.credentials.example thoughts/.credentials`

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
├── opencode.json              # Your private config (not managed by this repo)
├── commands/ -> repo/commands/ # Symlink
├── agents/  -> repo/agents/   # Symlink
├── skills/  -> repo/skills/   # Symlink
└── plugins/ -> repo/plugins/  # Symlink

<your-project>/
├── AGENTS.md                  # Project-specific instructions
├── scripts/                   # Ticket management scripts
│   ├── ticket.sh
│   ├── next-ticket.sh
│   ├── open_tickets.sh
│   └── credentials.sh
└── thoughts/
    ├── .ticket-prefix         # e.g., "PROJ"
    ├── .credentials.example   # Credentials format template
    ├── .credentials           # Your credentials (gitignored)
    └── shared/
        ├── tickets/           # Ticket definitions
        ├── research/          # Codebase research documents
        ├── plans/             # Implementation plans
        ├── reviews/           # Code review documents
        └── discussions/       # Technical discussion records
```

## Acknowledgements

Based on [tobyS/claude-template](https://github.com/tobyS/claude-template), a context-engineering workflow originally built for Claude Code. Adapted for OpenCode's agent, command, skill, and plugin system.
