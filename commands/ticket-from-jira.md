---
description: "Import a Jira ticket into the local ticket format. Requires Jira MCP to be configured."
---

# Import Ticket from Jira

Import the Jira ticket **$ARGUMENTS** into the local ticket system.

## Step 1: Check Jira Availability

Before proceeding, verify that Jira MCP tools are available. If they are not, tell the user:
> "Jira MCP is not configured for this project. Use `/create-ticket` to create a ticket manually instead."

## Step 2: Fetch the Jira Ticket

Use the Jira MCP to fetch the ticket with key `$ARGUMENTS`. Retrieve:
- Summary (title)
- Description
- Status
- Priority
- Issue type
- Acceptance criteria (if structured in the description)
- Linked issues
- Comments (for additional context)

## Step 3: Determine Ticket ID

**Use the original Jira ticket key as the local ticket ID.** The Jira key (e.g., `PROJ-1234`) becomes the canonical identifier — do NOT call `next-ticket.sh` or generate a new sequential ID.

This means:
- If the Jira key is `SHOP-42`, the local ticket ID is `SHOP-42`
- If the Jira key is `PROJ-1234`, the local ticket ID is `PROJ-1234`
- The prefix in the Jira key does NOT need to match `thoughts/.ticket-prefix`

## Step 4: Map to Local Format

Convert the Jira ticket data into the local ticket markdown format:

| Jira Field | Local Field |
|------------|-------------|
| Summary | Title (after ticket ID) |
| Description | Problem Statement + Desired Outcome |
| Priority (Highest/High/Medium/Low/Lowest) | Priority (Critical/High/Medium/Low) |
| Acceptance Criteria (if found in description) | Acceptance Criteria section |
| Linked issues | References section |
| Status | Map: "To Do"→"Open", "In Progress"→"In Progress", "Done"→"Done" |

## Step 5: Write the File

Write to: `thoughts/shared/tickets/$ARGUMENTS-[brief-description].md`

The filename uses the original Jira ticket key. Include a `Jira Reference:` field for traceability:

```markdown
# $ARGUMENTS: [Title from Jira]

**Status:** [Mapped status]
**Priority:** [Mapped priority]
**Complexity:** [Estimate from description, or ask user]
**Jira Reference:** $ARGUMENTS

## Problem Statement
[Extracted from Jira description]

## Desired Outcome
[Extracted from Jira description, or ask user if unclear]

## Acceptance Criteria
[Extracted if structured, otherwise ask user to define]

## Out of Scope
(To be defined — ask user)

## Open Questions
[Any unclear items from the Jira ticket]

## References
- Jira: $ARGUMENTS
- [Any linked Jira issues]

## Implementation Plan
(To be filled by /plan)

## Notes
[Any relevant comments from the Jira ticket]
```

## Step 6: Review with User

Present the generated ticket and ask:
- Are the acceptance criteria complete and specific enough?
- Is anything missing from the Jira ticket that should be captured?
- Should we define out-of-scope items now?

Make adjustments based on feedback before finalizing.
