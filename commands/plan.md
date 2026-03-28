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

## Step 2b: Security Assessment

Load the **security-checklist** skill. Using the **Quick Decision Matrix**, identify which security categories apply to this feature.

For each relevant category, evaluate the proposed approach:
- Does it follow the secure patterns? If not, **reject the approach and propose a secure alternative.**
- Are there security requirements that need to be explicit success criteria in the plan?
- Does the research document flag existing security patterns that must be followed?

**If the approach involves any of these, flag it to the user before proceeding:**
- User input flowing to database queries, shell commands, or HTML output
- Handling of credentials, tokens, or secrets
- File uploads or user-supplied paths
- New API endpoints or authentication flows
- HTTP client requests based on user input

Do not silently choose an insecure approach. If there is tension between convenience and security, discuss it explicitly.

## Step 3: Develop the Plan Structure

**This is interactive.** Present your proposed approach to the user and discuss:

1. **Approach:** What's the overall strategy? Are there alternative approaches? Why this one?
2. **Security:** Which security categories apply? What are the security requirements? (from Step 2b)
3. **Phases:** How should the work be broken down? Each phase must be:
   - Independently committable (working state after each phase)
   - Include both feature code AND its tests
   - Have clear, verifiable success criteria
4. **Risks:** What could go wrong? How do we mitigate? (include security risks)
5. **Open questions:** If anything is unclear, ask NOW — not during implementation.

**Do not proceed until all open questions are resolved.** Discuss every uncertainty with the user.

## Step 4: Write the Detailed Plan

Load the **implementation-plan** skill for the output template.

Write the plan to: `thoughts/shared/plans/[TICKET-ID]-implementation-plan.md`

Key requirements:
- Every phase has **automated** success criteria (tests, linter, build) AND **manual** success criteria where applicable
- **Security-relevant phases include explicit security success criteria** (e.g., "parameterized queries used for all DB access", "CSRF token validated on form submission")
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
