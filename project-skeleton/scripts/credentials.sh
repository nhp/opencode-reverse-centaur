#!/bin/bash

# Read credentials from thoughts/.credentials (TOML format)
#
# Usage:
#   ./scripts/credentials.sh                     # List all sections
#   ./scripts/credentials.sh <section>           # List keys in a section
#   ./scripts/credentials.sh <section> <key>     # Get a specific value

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CREDS_FILE="$PROJECT_ROOT/thoughts/.credentials"

if [ ! -f "$CREDS_FILE" ]; then
    echo "ERROR: No credentials file found at thoughts/.credentials" >&2
    echo "" >&2
    echo "Create one from the example:" >&2
    echo "  cp thoughts/.credentials.example thoughts/.credentials" >&2
    echo "  # Then edit thoughts/.credentials with your values" >&2
    exit 1
fi

SECTION="${1:-}"
KEY="${2:-}"

# List all sections
if [ -z "$SECTION" ]; then
    grep -E '^\[.+\]$' "$CREDS_FILE" | sed 's/\[//;s/\]//' | sort
    exit 0
fi

# Extract a section's content (lines between [section] and next [section] or EOF)
section_content() {
    local target="$1"
    local in_section=false

    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue

        # Check for section headers
        if [[ "$line" =~ ^\[(.+)\]$ ]]; then
            if [ "${BASH_REMATCH[1]}" = "$target" ]; then
                in_section=true
            else
                $in_section && break
            fi
            continue
        fi

        # Output key = value lines within the target section
        if $in_section && [[ "$line" =~ ^[[:space:]]*([a-zA-Z0-9_-]+)[[:space:]]*=[[:space:]]*\"?([^\"]*)\"?$ ]]; then
            echo "${BASH_REMATCH[1]}=${BASH_REMATCH[2]}"
        fi
    done < "$CREDS_FILE"
}

CONTENT="$(section_content "$SECTION")"

if [ -z "$CONTENT" ]; then
    echo "ERROR: Section [$SECTION] not found in thoughts/.credentials" >&2
    echo "" >&2
    echo "Available sections:" >&2
    grep -E '^\[.+\]$' "$CREDS_FILE" | sed 's/\[//;s/\]//' | sort >&2
    exit 1
fi

# List keys in a section
if [ -z "$KEY" ]; then
    echo "$CONTENT"
    exit 0
fi

# Get a specific key's value
VALUE="$(echo "$CONTENT" | grep -E "^${KEY}=" | head -1 | cut -d= -f2-)"

if [ -z "$VALUE" ]; then
    echo "ERROR: Key '$KEY' not found in [$SECTION]" >&2
    echo "" >&2
    echo "Available keys in [$SECTION]:" >&2
    echo "$CONTENT" | cut -d= -f1 >&2
    exit 1
fi

echo "$VALUE"
