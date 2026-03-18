#!/bin/bash

# List all open tickets (status: Open or In Progress) with their research & plan files
# Usage: ./scripts/open_tickets.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PREFIX_FILE="$PROJECT_ROOT/thoughts/.ticket-prefix"
THOUGHTS_DIR="$PROJECT_ROOT/thoughts"
TICKETS_DIR="$THOUGHTS_DIR/shared/tickets"

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
    echo "Error: tickets directory not found at $TICKETS_DIR"
    echo "Run /init-workflow to set up the project structure."
    exit 1
fi

# Find all ticket files sorted by ticket number descending
TICKET_FILES=$(find "$TICKETS_DIR" -type f -name "${TICKET_PREFIX}-*.md" | sort -t '-' -k2 -n -r)

if [ -z "$TICKET_FILES" ]; then
    echo "No tickets found"
    exit 0
fi

OPEN_COUNT=0

for TICKET_FILE in $TICKET_FILES; do
    # Extract status from file
    STATUS=$(grep -m1 '^\*\*Status:\*\*' "$TICKET_FILE" | sed 's/\*\*Status:\*\* //')

    # Only show open tickets (Open or In Progress)
    if [ "$STATUS" != "Open" ] && [ "$STATUS" != "In Progress" ]; then
        continue
    fi

    OPEN_COUNT=$((OPEN_COUNT + 1))

    # Extract ticket ID from filename (including optional letter suffix for sub-tickets)
    TICKET_ID=$(basename "$TICKET_FILE" | grep -oE "${TICKET_PREFIX}-[0-9]+[a-z]*")

    # Extract title from first line
    TITLE=$(head -1 "$TICKET_FILE" | sed 's/^# //' | sed "s/^$TICKET_ID: //")

    # Extract priority
    PRIORITY=$(grep -m1 '^\*\*Priority:\*\*' "$TICKET_FILE" | sed 's/\*\*Priority:\*\* //' || echo "Unknown")

    # Print ticket header
    echo "$TICKET_ID: $TITLE"
    echo "  Status: $STATUS | Priority: $PRIORITY"

    # Find research and plan files
    RESEARCH_FILE=$(find "$THOUGHTS_DIR/shared/research" -type f -name "*${TICKET_ID}-*" -o -name "*${TICKET_ID}.*" 2>/dev/null | head -1)
    PLAN_FILE=$(find "$THOUGHTS_DIR/shared/plans" -type f -name "*${TICKET_ID}-*" -o -name "*${TICKET_ID}.*" 2>/dev/null | head -1)

    if [ -n "$RESEARCH_FILE" ]; then
        echo "  RESEARCH: [x] $(basename "$RESEARCH_FILE")"
    else
        echo "  RESEARCH: [ ]"
    fi

    if [ -n "$PLAN_FILE" ]; then
        echo "  PLAN:     [x] $(basename "$PLAN_FILE")"
    else
        echo "  PLAN:     [ ]"
    fi

    echo ""
done

if [ $OPEN_COUNT -eq 0 ]; then
    echo "No open tickets found"
else
    echo "---"
    echo "Total open tickets: $OPEN_COUNT"
fi
