---
description: "Step 4/4: Execute an approved implementation plan phase by phase. Verifies each phase before committing and moving on."
---

# Implement Plan

Implement the plan for: **$ARGUMENTS**

## Before You Start

Find all related documents:
```
!`./scripts/ticket.sh $1`
```

Read ALL of these fully — do not skim:
- The **implementation plan** — your roadmap
- The **ticket** — the acceptance criteria you must satisfy
- The **research document** — the codebase context and patterns to follow

## Implementation Process

Use `todowrite` to track progress across phases.

### For Each Phase:

1. **Read the phase requirements** from the plan
2. **Security pre-check** — Load the **security-checklist** skill and identify which categories apply to this phase using the Quick Decision Matrix. Keep the relevant rules in mind while implementing.
3. **Implement the changes** listed in the phase
   - Follow patterns identified in the research document
   - Include tests as part of the phase (not separately)
   - For security-relevant code: follow the secure patterns from the checklist, not the convenient ones
4. **Run verification** — execute the automated success criteria:
   - Run tests
   - Run linter/code style checks
   - Run build if applicable
5. **Security post-check** — Before committing, verify against the security checklist:
   - No hardcoded secrets, API keys, or passwords
   - All user input parameterized/escaped (no string concatenation into queries/commands/HTML)
   - Authorization checks present on new endpoints
   - No disabled security features (`verify=False`, missing CSRF, permissive CORS)
   - Error responses don't leak internals
6. **Check off completed items** in the plan file (update the checkboxes)
7. **Commit** with a conventional commit message referencing the ticket ID
8. **Move to the next phase**

### If Something Goes Wrong

- **Tests fail:** Fix the issue before moving on. Do not skip failing tests.
- **Reality doesn't match the plan:** STOP. Explain to the user what's different and discuss how to adjust the plan. Do not silently deviate.
- **A phase is more complex than expected:** Break it into sub-phases. Update the plan file to reflect this.
- **You discover something the research missed:** Document it. Consider whether it affects later phases.

### Resuming After Interruption

If resuming a partially completed implementation:
1. Read the plan file and check which phases have checked-off items
2. Find the last committed phase (check git log)
3. Resume from the next unchecked item

## Commit Discipline

After each phase passes verification:
- Create a commit with format: `[TICKET-ID] phase N: brief description`
- Use conventional commit prefixes: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`
- Example: `feat: [PROJ-0001] phase 1: add customer service with repository pattern`
- **NEVER** run `git push` — the user decides when to push
- **NEVER** use `git commit --amend`

## Completion

After all phases are complete:
1. Update the ticket status to "Done" (if all acceptance criteria are met)
2. Update the plan status to "completed"
3. Present a summary to the user:
   - What was implemented
   - What tests were added
   - Any deviations from the plan
   - Any follow-up items or technical debt
4. Suggest running `/review` for a final quality check
