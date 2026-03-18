---
description: "Step 3/4: Create an implementation plan from a ticket and research document. Interactive — discusses approach and phases with the user."
---

# Create Implementation Plan

Create an implementation plan for: **$ARGUMENTS**

## Step 1: Gather Context

If `$ARGUMENTS` is a ticket ID, find all related documents:
```
!`./scripts/ticket.sh $1`
```

Read ALL of the following fully (do not skim):
- The **ticket file** — understand the acceptance criteria and scope
- The **research document** — understand the codebase, patterns, and impact analysis

If either is missing, tell the user:
- No ticket? → Suggest running `/create-ticket` first
- No research? → Suggest running `/research` first

You CAN proceed without them if the user explicitly wants to, but the plan quality will be lower.

## Step 2: Discovery (skip if research exists)

If no research document exists and the user wants to proceed anyway, do a quick discovery:
- Use **@codebase-locator** to find relevant files
- Use **@codebase-pattern-finder** to find similar implementations

This is a lighter version of `/research` — just enough to plan intelligently.

## Step 3: Develop the Plan Structure

**This is interactive.** Present your proposed approach to the user and discuss:

1. **Approach:** What's the overall strategy? Are there alternative approaches? Why this one?
2. **Phases:** How should the work be broken down? Each phase must be:
   - Independently committable (working state after each phase)
   - Include both feature code AND its tests
   - Have clear, verifiable success criteria
3. **Risks:** What could go wrong? How do we mitigate?
4. **Open questions:** If anything is unclear, ask NOW — not during implementation.

**Do not proceed until all open questions are resolved.** Discuss every uncertainty with the user.

## Step 4: Write the Detailed Plan

Load the **implementation-plan** skill for the output template.

Write the plan to: `thoughts/shared/plans/[TICKET-ID]-implementation-plan.md`

Key requirements:
- Every phase has **automated** success criteria (tests, linter, build) AND **manual** success criteria where applicable
- File paths reference real files (from research) or clearly mark new files to create
- Tests are in EVERY phase — never a separate "testing phase"
- Checkboxes on all actionable items (for progress tracking during implementation)

## Step 5: Review with User

Present the complete plan and ask for explicit approval before finalizing.

Specifically ask:
- Does the phasing make sense?
- Are the success criteria sufficient?
- Anything missing?
- Ready to proceed to `/implement`?

Update the ticket status to "In Progress" if the user approves the plan.
