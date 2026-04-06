---
description: "Initialize the workflow template in the current project. Creates thoughts/ directories, copies scripts, and optionally generates a starter AGENTS.md."
---

# Initialize Workflow

Set up the opencode workflow template in the current project with ticket prefix: **$ARGUMENTS**

## Validation

1. **Prefix is required.** If `$ARGUMENTS` is empty, ask the user for a ticket prefix (e.g., PROJ, MATI, HUB). Explain that this is used for ticket numbering like `MATI-0001`.

2. **Check for existing setup.** If `thoughts/shared/tickets/` already exists, warn the user and ask if they want to overwrite or skip.

3. **Check for OPENCODE_TEMPLATE_DIR.** The environment variable must be set to find the skeleton files. If not set, tell the user:
   > Set OPENCODE_TEMPLATE_DIR to your opencode-template repository path.
   > fish: `set -gx OPENCODE_TEMPLATE_DIR ~/path/to/opencode-template`
   > bash: `export OPENCODE_TEMPLATE_DIR="~/path/to/opencode-template"`

## Step 1: Create Directory Structure

Create these directories:
```
thoughts/shared/tickets/
thoughts/shared/discussions/
thoughts/shared/plans/
thoughts/shared/research/
thoughts/shared/reviews/
thoughts/.secrets/
scripts/
```

Create `.gitkeep` files in each `thoughts/shared/` subdirectory and in `thoughts/.secrets/`.

## Step 2: Write Ticket Prefix

Write the prefix to `thoughts/.ticket-prefix`:
```
$ARGUMENTS
```

(Just the prefix string, no newline or whitespace)

## Step 2b: User Acronym (optional)

Ask the user if they want to use a **user acronym** for branch naming. Explain:
> A user acronym is a short personal identifier (e.g., "nhp", "jd", "mw") used in branch names to identify who owns a branch. This is useful in team environments.
>
> With acronym: `feature/nhp/PROJ-0001/add-feature`
> Without acronym: `feature/PROJ-0001/add-feature`

- If the user wants an acronym: ask for the acronym string, then write it to `thoughts/.user-acronym` (just the acronym, no newline or whitespace).
- If the user does not want one: skip this step. Do NOT create `thoughts/.user-acronym`.

## Step 3: Copy Scripts

Copy the scripts from the template skeleton into `scripts/`:
- `$OPENCODE_TEMPLATE_DIR/project-skeleton/scripts/ticket.sh` → `scripts/ticket.sh`
- `$OPENCODE_TEMPLATE_DIR/project-skeleton/scripts/next-ticket.sh` → `scripts/next-ticket.sh`
- `$OPENCODE_TEMPLATE_DIR/project-skeleton/scripts/open_tickets.sh` → `scripts/open_tickets.sh`
- `$OPENCODE_TEMPLATE_DIR/project-skeleton/scripts/credentials.sh` → `scripts/credentials.sh`

Make them executable: `chmod +x scripts/*.sh`

## Step 3b: Credentials Setup (optional)

Copy the credentials example file:
- `$OPENCODE_TEMPLATE_DIR/thoughts/.credentials.example` → `thoughts/.credentials.example`

Copy the secrets example file:
- `$OPENCODE_TEMPLATE_DIR/project-skeleton/thoughts/.secrets.example` → `thoughts/.secrets.example`

Ask the user if they want to set up project credentials now. Explain:
> There are two credential systems:
>
> **1. Agent credentials** (`thoughts/.credentials`) — TOML format for agent runtime access via `./scripts/credentials.sh`. Used for login credentials, API keys the agent needs during tasks.
>
> **2. MCP server secrets** (`thoughts/.secrets/`) — Individual files for OpenCode config `{file:...}` substitution. Used to provide credentials to MCP servers in `opencode.json`.
>
> Example TOML format (thoughts/.credentials):
> ```toml
> [basic-auth]
> username = "joe"
> password = "doe"
> ```
>
> Example secrets files (thoughts/.secrets/):
> ```
> echo -n "your-email@example.com" > thoughts/.secrets/atlassian-email
> echo -n "your-api-token"         > thoughts/.secrets/atlassian-api-token
> ```

- If yes: copy `thoughts/.credentials.example` to `thoughts/.credentials` and let the user edit it. Ask which MCP servers they want to configure and create the corresponding secret files.
- If no: skip. They can set it up later by copying the example files.

## Step 3c: Project Config (opencode.json)

Copy the project-level OpenCode config example:
- `$OPENCODE_TEMPLATE_DIR/project-skeleton/opencode.json.example` → `opencode.json.example`

Check if an `opencode.json` file exists in the project root.

- **If it exists:** Skip. Tell the user their existing config is preserved. Remind them they can reference `opencode.json.example` for the MCP server configuration pattern.
- **If it doesn't exist:** Copy `opencode.json.example` to `opencode.json`. Tell the user to review and customize it — enable only the MCP servers they need and populate `thoughts/.secrets/` with the corresponding credential files.

Explain the layered config pattern:
> OpenCode merges configs from multiple locations. Your global config (`~/.config/opencode/opencode.json`) defines all MCP servers with project-specific ones disabled. This project-level config enables specific servers and points their credentials to gitignored files in `thoughts/.secrets/`.
>
> This file is **committed to git** — it contains no real credentials (all use `{file:...}` substitution). This means teammates can see the MCP server configuration, and git worktrees get it automatically.
>
> See `opencode.json.global.example` in the template repo for the global config pattern.

## Step 3d: Thoughts .gitignore

Copy the thoughts gitignore:
- `$OPENCODE_TEMPLATE_DIR/project-skeleton/thoughts/.gitignore` → `thoughts/.gitignore`

This ensures `.ticket-prefix`, `.user-acronym`, `.credentials`, and `.secrets/*` contents are gitignored while keeping the `.secrets/.gitkeep` tracked.

**If the file already exists:** Check if it already covers `.secrets/*`. If not, suggest appending the missing patterns.

## Step 4: Symlink AGENTS-base.md

Create a symlink for the shared development standards file:
```
ln -sf $OPENCODE_TEMPLATE_DIR/AGENTS-base.md AGENTS-base.md
```

This file contains universal rules (security, git discipline, implementation discipline, conventions) and stays up-to-date automatically via the symlink.

**If the symlink already exists and points to the correct target:** Skip and confirm it's correct.

## Step 4b: Generate AGENTS.md (optional)

Check if an `AGENTS.md` file exists in the project root.

- **If it exists:** Skip this step. Tell the user their existing AGENTS.md is preserved. Remind them it should reference `AGENTS-base.md` at the top.
- **If it doesn't exist:** Copy `$OPENCODE_TEMPLATE_DIR/AGENTS.md.example` to `AGENTS.md` in the project root. Tell the user to customize it for their project.

## Step 5: Update .gitignore (optional)

If a `.gitignore` file exists, check if it already contains `thoughts/.ticket-prefix`. If not, suggest adding:
```
# Workflow template
thoughts/.ticket-prefix
thoughts/.user-acronym
```

If `thoughts/.user-acronym` was created in Step 2b, make sure it's included too.

Ask the user before modifying `.gitignore`.

## Step 6: Summary

Tell the user what was created and suggest next steps:

```
Workflow initialized with prefix: [PREFIX]

Created:
  thoughts/shared/{tickets,discussions,plans,research,reviews}/
  thoughts/.ticket-prefix
  thoughts/.gitignore
  thoughts/.credentials.example
  thoughts/.secrets.example
  thoughts/.secrets/.gitkeep
  [thoughts/.user-acronym (if configured)]
  [thoughts/.credentials (if configured)]
  scripts/{ticket.sh,next-ticket.sh,open_tickets.sh,credentials.sh}
  opencode.json.example
  [opencode.json (if generated)]
  AGENTS-base.md → $OPENCODE_TEMPLATE_DIR/AGENTS-base.md (symlink)
  [AGENTS.md (if generated)]

Next steps:
  1. Customize AGENTS.md for your project
  2. Review opencode.json — enable MCP servers you need
  3. Set up MCP secrets: see thoughts/.secrets.example
  4. Set up agent credentials: cp thoughts/.credentials.example thoughts/.credentials
  5. Create your first ticket: /create-ticket
  6. View open tickets: run ./scripts/open_tickets.sh
```
