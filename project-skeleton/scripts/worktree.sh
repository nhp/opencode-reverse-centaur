#!/bin/bash

# Git worktree management for parallel OpenCode sessions.
#
# Supports both regular repos and bare repo layouts:
#
#   Regular:  project/ contains .git/, scripts/, thoughts/
#   Bare:     project/ contains .git/ (bare), thoughts/, main/, feature-x/
#
# Usage:
#   ./scripts/worktree.sh create <ticket-id> <description> [type]
#   ./scripts/worktree.sh list
#   ./scripts/worktree.sh delete [-f] <description>
#
# Examples:
#   ./scripts/worktree.sh create PROJ-0001 "add-dark-mode"
#   ./scripts/worktree.sh create PROJ-0002 "fix-checkout" bugfix
#   ./scripts/worktree.sh list
#   ./scripts/worktree.sh delete add-dark-mode
#
# In a regular repo, worktrees are stored at the project root.
# In a bare repo layout, worktrees are siblings of .git and thoughts/.
#
# File sync:
#   - thoughts/ → symlinked (shared context: tickets, research, plans, credentials)
#
# After creating a worktree:
#   cd <worktree-path>
#   opencode

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CALLER_DIR="$(dirname "$SCRIPT_DIR")"

# ── Detect project root ─────────────────────────────────────────────
# Find the common git dir, then derive the project root.
# - Bare repo:      git-common-dir = /path/to/project/.git (a directory)
#                    project root   = /path/to/project
# - Regular repo:   git-common-dir = /path/to/project/.git
#                    project root   = /path/to/project
# - Worktree of bare: git-common-dir points to the bare .git
#                    project root   = parent of that .git
GIT_COMMON_DIR="$(cd "$(git -C "$CALLER_DIR" rev-parse --git-common-dir)" && pwd)"
PROJECT_ROOT="$(dirname "$GIT_COMMON_DIR")"

# Where thoughts/ lives — always at project root
THOUGHTS_DIR="$PROJECT_ROOT/thoughts"

# Detect if this is a bare repo layout (worktrees are siblings of .git)
IS_BARE="$(git -C "$CALLER_DIR" rev-parse --is-bare-repository 2>/dev/null || echo false)"
if [ "$IS_BARE" = "true" ]; then
    # Script was called from within the bare repo dir itself
    WORKTREE_BASE="$PROJECT_ROOT"
elif [ -f "$CALLER_DIR/.git" ]; then
    # We're inside a worktree (linked worktree has .git as a file, not dir)
    WORKTREE_BASE="$PROJECT_ROOT"
else
    # Regular repo — worktrees go at project root level
    WORKTREE_BASE="$PROJECT_ROOT"
fi

PROJECT_NAME="$(basename "$PROJECT_ROOT")"

# ── Helpers ──────────────────────────────────────────────────────────

# Sanitize a string for use in branch names and directory names.
sanitize() {
    echo "$1" \
        | tr '[:upper:]' '[:lower:]' \
        | sed 's/[^a-z0-9-]/-/g' \
        | sed 's/-\+/-/g' \
        | sed 's/^-\|_$//g' \
        | cut -c1-50
}

# Read user acronym from thoughts/.user-acronym (if exists).
read_acronym() {
    local file="$THOUGHTS_DIR/.user-acronym"
    if [ -f "$file" ]; then
        tr -d '[:space:]' < "$file"
    fi
}

# ── Commands ─────────────────────────────────────────────────────────

cmd_create() {
    local ticket_id="$1"
    local description="$2"
    local branch_type="${3:-feature}"

    if [ -z "$ticket_id" ] || [ -z "$description" ]; then
        echo "Usage: $0 create <ticket-id> <description> [type]" >&2
        echo "  type: feature (default), bugfix, hotfix, refactor, chore" >&2
        exit 1
    fi

    local slug
    slug="$(sanitize "$description")"
    if [ -z "$slug" ]; then
        echo "Error: description produced an empty slug after sanitization." >&2
        exit 1
    fi

    # Build branch name: feature/nhp/PROJ-0001/add-dark-mode
    local acronym
    acronym="$(read_acronym)"
    local branch="$branch_type"
    if [ -n "$acronym" ]; then
        branch="$branch/$acronym"
    fi
    branch="$branch/$ticket_id/$slug"

    # Worktree path — sibling of other worktrees/dirs at project root
    local wt_path="$WORKTREE_BASE/$slug"

    # Check if worktree already exists
    if git -C "$CALLER_DIR" worktree list --porcelain | grep -q "branch refs/heads/$branch"; then
        echo "Error: a worktree for branch '$branch' already exists." >&2
        exit 1
    fi

    if [ -d "$wt_path" ]; then
        echo "Error: directory already exists: $wt_path" >&2
        exit 1
    fi

    # Create worktree
    echo "Creating worktree..."
    git -C "$CALLER_DIR" worktree add "$wt_path" -b "$branch"

    # ── Sync: symlink thoughts/ ──
    # The thoughts/ directory contains all workflow context (tickets, research,
    # plans, credentials, secrets). Symlink it so the worktree shares everything.
    if [ -d "$THOUGHTS_DIR" ]; then
        # Remove the thoughts/ dir that git checkout created (tracked files only)
        rm -rf "$wt_path/thoughts"
        ln -s "$THOUGHTS_DIR" "$wt_path/thoughts"
    fi

    echo ""
    echo "Worktree created successfully."
    echo ""
    echo "  Branch: $branch"
    echo "  Path:   $wt_path"
    echo ""
    echo "To start working:"
    echo "  cd $wt_path"
    echo "  opencode"
    echo ""
    echo "When done:"
    echo "  Run /commit in the worktree session"
    echo "  ./scripts/worktree.sh delete $slug"
    echo ""
    echo "Note: thoughts/ is symlinked — shared across all worktrees."
}

cmd_list() {
    echo "Active worktrees:"
    echo ""
    git -C "$CALLER_DIR" worktree list
}

cmd_delete() {
    local force=false
    if [ "$1" = "--force" ] || [ "$1" = "-f" ]; then
        force=true
        shift
    fi

    local slug="$1"

    if [ -z "$slug" ]; then
        echo "Usage: $0 delete [-f|--force] <description>" >&2
        echo "" >&2
        echo "Active worktrees:" >&2
        git -C "$CALLER_DIR" worktree list >&2
        exit 1
    fi

    local wt_path="$WORKTREE_BASE/$slug"

    if [ ! -d "$wt_path" ]; then
        echo "Error: worktree not found at $wt_path" >&2
        echo "" >&2
        echo "Active worktrees:" >&2
        git -C "$CALLER_DIR" worktree list >&2
        exit 1
    fi

    # Get the branch name before removal
    local branch
    branch="$(git -C "$wt_path" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "(unknown)")"

    # Check for uncommitted changes (ignore the thoughts symlink — it's expected)
    local changes
    changes="$(git -C "$wt_path" status --porcelain 2>/dev/null | grep -v '^?? thoughts$' || true)"
    if [ -n "$changes" ] && [ "$force" = false ]; then
        echo "Warning: worktree has uncommitted changes:" >&2
        echo "$changes" | head -10 >&2
        echo "" >&2
        read -p "Remove anyway? (y/N) " confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            echo "Aborted."
            exit 1
        fi
    fi

    # Remove the thoughts symlink first (before git worktree remove tries to clean up)
    if [ -L "$wt_path/thoughts" ]; then
        rm "$wt_path/thoughts"
    fi

    # Remove worktree
    git -C "$CALLER_DIR" worktree remove "$wt_path" --force

    echo ""
    echo "Worktree removed."
    echo ""
    echo "  Branch: $branch (still exists)"
    echo "  Path:   $wt_path (removed)"
    echo ""
    echo "To merge:  git merge $branch"
    echo "To delete: git branch -d $branch"
}

# ── Main ─────────────────────────────────────────────────────────────

case "${1:-}" in
    create)
        shift
        cmd_create "$@"
        ;;
    list)
        cmd_list
        ;;
    delete)
        shift
        cmd_delete "$@"
        ;;
    *)
        echo "Usage: $0 {create|list|delete}" >&2
        echo "" >&2
        echo "Commands:" >&2
        echo "  create <ticket-id> <description> [type]  Create a worktree for a ticket" >&2
        echo "  list                                     List active worktrees" >&2
        echo "  delete [-f] <description>                 Remove a worktree (-f to skip confirmation)" >&2
        echo "" >&2
        echo "Examples:" >&2
        echo "  $0 create PROJ-0001 add-dark-mode" >&2
        echo "  $0 create PROJ-0002 fix-checkout bugfix" >&2
        echo "  $0 list" >&2
        echo "  $0 delete add-dark-mode" >&2
        exit 1
        ;;
esac
