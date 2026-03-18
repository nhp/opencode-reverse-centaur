---
description: "Step 1/4: Create a new ticket through collaborative dialogue. Captures business requirements, acceptance criteria, and scope."
---

# Create Ticket

You are facilitating a collaborative ticket creation process. Your goal is to help the user define a clear, actionable ticket through structured dialogue.

**This is an interactive process — do NOT rush through it. Ask questions, confirm understanding, and iterate.**

## Before You Start

Get the next available ticket number:
```
!`./scripts/next-ticket.sh`
```

## Process: 7 Phases

Work through each phase in order. Move to the next phase only when the user confirms the current one.

### Phase 1: Understanding the Problem
Ask the user:
- What problem are we solving? What's broken, missing, or suboptimal?
- Who is affected by this problem?
- How urgent is this?

Listen carefully. Restate the problem in your own words and confirm understanding before moving on.

### Phase 2: Defining the Desired Outcome
Ask the user:
- What does "done" look like?
- How will we know the problem is solved?
- What's the minimum viable solution vs. the ideal solution?

### Phase 3: Exploring User Stories
Help define user stories in the format:
> As a [role], I want [capability], so that [benefit].

Ask if there are different user types affected. Create a story for each.

### Phase 4: Defining Acceptance Criteria
For each user story, define specific, testable acceptance criteria:
- **Given** [precondition], **when** [action], **then** [expected result]
- Each criterion must be verifiable — either through automated tests or manual steps

Push for specifics. "It should work correctly" is not an acceptance criterion.

### Phase 5: Defining Boundaries
Explicitly define:
- **In scope:** What IS included in this ticket
- **Out of scope:** What is NOT included (can be separate tickets)

This prevents scope creep and makes the ticket actionable.

### Phase 6: Surfacing Open Questions
Separate questions into:
- **Business questions:** Need answers from stakeholders/product
- **Technical questions:** Need answers from research/codebase analysis (these go to `/research`)

### Phase 7: Final Review & Confirmation
Present the complete ticket to the user. Ask for final adjustments. Only write the file after explicit confirmation.

## Output

Write the ticket to: `thoughts/shared/tickets/[TICKET-ID]-[brief-description].md`

Use this format:

```markdown
# [TICKET-ID]: [Title]

**Status:** Open
**Priority:** [Critical | High | Medium | Low]
**Complexity:** [Small | Medium | Large | Epic]

## Problem Statement
[Clear description of the problem]

## Desired Outcome
[What success looks like]

## User Stories
- As a [role], I want [capability], so that [benefit].

## Acceptance Criteria
- [ ] Given [precondition], when [action], then [expected result]
- [ ] ...

## Out of Scope
- [What's explicitly excluded]

## Open Questions

### Business Questions
- [Questions needing stakeholder input]

### Technical Questions (for /research)
- [Questions needing codebase investigation]

## References
- [Related tickets, docs, links]

## Implementation Plan
(To be filled by /plan)

## Notes
[Any additional context]
```
