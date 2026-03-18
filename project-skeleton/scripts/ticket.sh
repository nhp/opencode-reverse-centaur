#!/bin/bash

# Find all documents in thoughts/ that contain a ticket number in their filename
# Usage: ./scripts/ticket.sh PROJ-0001

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PREFIX_FILE="$PROJECT_ROOT/thoughts/.ticket-prefix"

if [ -z "$1" ]; then
    # Read prefix for usage example
    if [ -f "$PREFIX_FILE" ]; then
        TICKET_PREFIX="$(tr -d '[:space:]' < "$PREFIX_FILE")"
    else
        TICKET_PREFIX="PROJ"
    fi
    echo "Usage: $0 <ticket-number>"
    echo "Example: $0 ${TICKET_PREFIX}-0001"
    exit 1
fi

TICKET="$1"
THOUGHTS_DIR="$PROJECT_ROOT/thoughts"

if [ ! -d "$THOUGHTS_DIR" ]; then
    echo "Error: thoughts directory not found at $THOUGHTS_DIR"
    echo "Run /init-workflow to set up the project structure."
    exit 1
fi

find "$THOUGHTS_DIR" -type f -name "*${TICKET}*" | sort
