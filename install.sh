#!/bin/bash

# install.sh — Symlink opencode-template into ~/.config/opencode/
#
# Creates symlinks for: commands, agents, skills, plugins
# Does NOT touch opencode.json (your private config with credentials)
#
# Usage: ./install.sh [--dry-run] [--force]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME}/.config/opencode"

DRY_RUN=false
FORCE=false

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --force)   FORCE=true ;;
        --help|-h)
            echo "Usage: $0 [--dry-run] [--force]"
            echo ""
            echo "  --dry-run  Show what would be done without making changes"
            echo "  --force    Remove existing directories/symlinks before creating new ones"
            echo ""
            echo "Symlinks these directories into ~/.config/opencode/:"
            echo "  commands/  agents/  skills/  plugins/"
            echo ""
            echo "Does NOT touch opencode.json."
            exit 0
            ;;
        *)
            echo "Unknown argument: $arg"
            echo "Use --help for usage."
            exit 1
            ;;
    esac
done

DIRS=(commands agents skills plugins)

echo "opencode-template installer"
echo "==========================="
echo "Source: $SCRIPT_DIR"
echo "Target: $CONFIG_DIR"
echo ""

# Ensure config dir exists
if [ ! -d "$CONFIG_DIR" ]; then
    if $DRY_RUN; then
        echo "[dry-run] Would create $CONFIG_DIR"
    else
        mkdir -p "$CONFIG_DIR"
        echo "Created $CONFIG_DIR"
    fi
fi

ERRORS=0

for dir in "${DIRS[@]}"; do
    SOURCE="$SCRIPT_DIR/$dir"
    TARGET="$CONFIG_DIR/$dir"

    # Check source exists
    if [ ! -d "$SOURCE" ]; then
        echo "SKIP $dir/ — source directory not found (not yet created)"
        continue
    fi

    # Check if target already exists
    if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
        if [ -L "$TARGET" ]; then
            CURRENT_LINK="$(readlink "$TARGET")"
            if [ "$CURRENT_LINK" = "$SOURCE" ]; then
                echo "OK   $dir/ — already linked correctly"
                continue
            fi
        fi

        if $FORCE; then
            if $DRY_RUN; then
                echo "[dry-run] Would remove $TARGET"
                echo "[dry-run] Would symlink $TARGET -> $SOURCE"
            else
                # Backup if it's a real directory (not a symlink)
                if [ -d "$TARGET" ] && [ ! -L "$TARGET" ]; then
                    BACKUP="${TARGET}.backup.$(date +%Y%m%d-%H%M%S)"
                    mv "$TARGET" "$BACKUP"
                    echo "BACK $dir/ — backed up existing directory to $(basename "$BACKUP")"
                else
                    rm -f "$TARGET"
                fi
                ln -s "$SOURCE" "$TARGET"
                echo "LINK $dir/ -> $SOURCE"
            fi
        else
            echo "WARN $dir/ — already exists at $TARGET"
            echo "     Use --force to replace (existing dirs will be backed up)"
            ERRORS=$((ERRORS + 1))
        fi
    else
        if $DRY_RUN; then
            echo "[dry-run] Would symlink $TARGET -> $SOURCE"
        else
            ln -s "$SOURCE" "$TARGET"
            echo "LINK $dir/ -> $SOURCE"
        fi
    fi
done

echo ""
if [ $ERRORS -gt 0 ]; then
    echo "Done with $ERRORS warning(s). Re-run with --force to replace existing directories."
    exit 1
else
    if $DRY_RUN; then
        echo "Dry run complete. No changes made."
    else
        echo "Done. Symlinks created."
        echo ""
        echo "Next steps:"
        echo "  1. Add to your shell config:"
        echo "     fish: set -gx OPENCODE_TEMPLATE_DIR $SCRIPT_DIR"
        echo "     bash: export OPENCODE_TEMPLATE_DIR=\"$SCRIPT_DIR\""
        echo ""
        echo "  2. Optional: enable experimental LSP tool:"
        echo "     fish: set -gx OPENCODE_EXPERIMENTAL_LSP_TOOL true"
        echo "     bash: export OPENCODE_EXPERIMENTAL_LSP_TOOL=true"
    fi
fi
