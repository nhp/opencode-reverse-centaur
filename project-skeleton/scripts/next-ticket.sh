#!/bin/bash

# Generate the next available ticket number
# Usage: ./scripts/next-ticket.sh
#
# Reads the ticket prefix from thoughts/.ticket-prefix
# Scans thoughts/shared/tickets/ for existing tickets and returns the next number
# Ignores sub-tickets (PREFIX-XXXXa, PREFIX-XXXXb, etc.)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PREFIX_FILE="$PROJECT_ROOT/thoughts/.ticket-prefix"
TICKETS_DIR="$PROJECT_ROOT/thoughts/shared/tickets"

# Read ticket prefix
if [ ! -f "$PREFIX_FILE" ]; then
    echo "Error: No ticket prefix configured at $PREFIX_FILE" >&2
    echo "Run /init-workflow to set up the project structure." >&2
    exit 1
fi

TICKET_PREFIX="$(tr -d '[:space:]' < "$PREFIX_FILE")"

if [ -z "$TICKET_PREFIX" ]; then
    echo "Error: Ticket prefix is empty in $PREFIX_FILE" >&2
    exit 1
fi

if [ ! -d "$TICKETS_DIR" ]; then
    echo "Error: tickets directory not found at $TICKETS_DIR" >&2
    echo "Run /init-workflow to set up the project structure." >&2
    exit 1
fi

# Find the highest main ticket number (ignore sub-tickets like PROJ-0057a)
HIGHEST=$(find "$TICKETS_DIR" -type f -name "${TICKET_PREFIX}-[0-9][0-9][0-9][0-9]*.md" \
    | xargs -n1 basename 2>/dev/null \
    | grep -oE "${TICKET_PREFIX}-[0-9]{4}" \
    | sort -t'-' -k2 -n \
    | uniq \
    | tail -1 \
    | grep -oE '[0-9]+' || echo "")

if [ -z "$HIGHEST" ]; then
    NEXT=1
else
    NEXT=$((10#$HIGHEST + 1))
fi

# Format with leading zeros (4 digits)
printf "%s-%04d\n" "$TICKET_PREFIX" "$NEXT"
