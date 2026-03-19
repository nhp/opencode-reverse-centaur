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
scripts/
```

Create `.gitkeep` files in each `thoughts/shared/` subdirectory.

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

Copy the 3 scripts from the template skeleton into `scripts/`:
- `$OPENCODE_TEMPLATE_DIR/project-skeleton/scripts/ticket.sh` → `scripts/ticket.sh`
- `$OPENCODE_TEMPLATE_DIR/project-skeleton/scripts/next-ticket.sh` → `scripts/next-ticket.sh`
- `$OPENCODE_TEMPLATE_DIR/project-skeleton/scripts/open_tickets.sh` → `scripts/open_tickets.sh`

Make them executable: `chmod +x scripts/*.sh`

## Step 4: Generate AGENTS.md (optional)

Check if an `AGENTS.md` file exists in the project root.

- **If it exists:** Skip this step. Tell the user their existing AGENTS.md is preserved.
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
  [thoughts/.user-acronym (if configured)]
  scripts/{ticket.sh,next-ticket.sh,open_tickets.sh}
  [AGENTS.md (if generated)]

Next steps:
  1. Customize AGENTS.md for your project
  2. Create your first ticket: /create-ticket
  3. View open tickets: run ./scripts/open_tickets.sh
```
