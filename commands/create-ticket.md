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

- Read `CONTEXT.md` if present at project root. Use its vocabulary when defining the problem, acceptance criteria, and user stories.
- If `CONTEXT.md` does not exist, continue normally.
- If acceptance criteria reveal a new domain term, relationship, or resolved ambiguity, suggest a small `CONTEXT.md` update with a source note pointing to the ticket question or constraint that clarified it.

## Process: 7 Phases

Work through each phase in order. Move to the next phase only when the user confirms the current one.

If the request is still a vague idea rather than ticket-ready work, offer to run `/grill-with-docs` first. Use ticket creation when the user is ready to capture scoped work.

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
- Criteria should describe end-to-end behavior, not isolated implementation layers

Push for specifics. "It should work correctly" is not an acceptance criterion.

When an acceptance criterion depends on domain vocabulary, confirm that the term exists in `CONTEXT.md` or propose the exact glossary addition.

### Phase 5: Defining Boundaries
Explicitly define:
- **In scope:** What IS included in this ticket
- **Out of scope:** What is NOT included (can be separate tickets)
- **Agent readiness:** AFK, HITL, or Human
- **Blocked by:** Any ticket, decision, prototype, or external input required first

This prevents scope creep and makes the ticket actionable.

Use readiness labels this way:
- **AFK:** Agent can implement from the ticket/research/plan without more human input
- **HITL:** Agent can do most work but needs a human checkpoint for design, access, QA, or a decision
- **Human:** Requires judgment, external coordination, or permissions that should not be delegated

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
**Agent Readiness:** [AFK | HITL | Human]
**Blocked By:** [None | Ticket/decision/prototype/external input]

## Problem Statement
[Clear description of the problem]

## Desired Outcome
[What success looks like]

## User Stories
- As a [role], I want [capability], so that [benefit].

## Acceptance Criteria
- [ ] Given [precondition], when [action], then [expected result]
- [ ] ...

## Vertical Slice
[The narrow complete behavior this ticket delivers end-to-end]

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

## Documentation Updates
- [Suggested or applied CONTEXT.md updates with source citations]
```
