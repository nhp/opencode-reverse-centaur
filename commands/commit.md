---
description: "Pre-commit checklist and commit workflow. Runs tests, checks code style, reviews staged changes, and creates a clean commit."
---

# Commit

Create a commit for the current changes.

## Step 1: Determine Commit Type

Check what's staged and what's changed:
```
!`git status`
```
```
!`git diff --cached --stat`
```

Determine if this is:
- **Code commit:** Includes source code changes → run full verification
- **Docs-only commit:** Only markdown, comments, or documentation → skip tests/build

## Step 2: Verification (code commits only)

Run the project's verification commands. Check the AGENTS.md for project-specific commands. Common checks:

1. **Tests:** Run the project's test suite. All tests must pass.
2. **Code style:** Run the project's linter/formatter. Fix any issues.
3. **Build:** If applicable, verify the build succeeds.

If any check fails, fix the issue before committing. Do not commit broken code.

## Step 3: Review Staged Changes

Review the staged diff for:
- Accidentally staged files (debug code, temporary files, credentials)
- Incomplete changes (half-finished refactoring, TODO comments that should be addressed)
- Files that don't belong in this commit (separate concerns → separate commits)

## Step 4: Ticket Status Check

Check if any staged files or recent commits reference a ticket ID. If so:
```
!`./scripts/ticket.sh $(git diff --cached --name-only | grep -oE '[A-Z]+-[0-9]+' | head -1)`
```

If a ticket is found and its status is "Open", consider whether it should be updated to "In Progress" or "Done". If updating, edit the ticket file and stage it with this commit.

## Step 5: Create the Commit

Use conventional commit format with ticket ID:

```
[TICKET-ID] type: concise description

* Why this change was needed
* Key decisions made
```

- **type:** `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `style`
- Focus on WHAT and WHY, not HOW
- Keep the first line under 72 characters

If there's no ticket ID, use the appropriate type prefix without a ticket reference.

## Rules

- **NEVER** run `git push` — the user decides when to push
- **NEVER** use `git commit --amend`
- Keep commits atomic — one logical change per commit
- Always create new commits, even for small fixes
