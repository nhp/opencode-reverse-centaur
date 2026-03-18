---
description: "Review code changes for quality, security, performance, and completeness. Supports ticket-based reviews and custom-scope reviews."
---

# Code Review

Review code for: **$ARGUMENTS**

## Determine Review Scope

### If $ARGUMENTS is a ticket ID:
Find all related documents and code:
```
!`./scripts/ticket.sh $1`
```

1. Read the **ticket** to understand the acceptance criteria
2. Read the **plan** to understand what was supposed to be implemented
3. Find the relevant commits:
   ```
   !`git log --oneline --all --grep="$1" | head -20`
   ```
4. Review the actual code changes across those commits

### If $ARGUMENTS is a file path, branch, or description:
Review the specified scope directly. If it's a branch:
```
!`git diff main...$1 --stat`
```

## Review Process

Use **@code-reviewer** to perform the detailed review. Provide it with:
- The code changes (diff or file contents)
- The acceptance criteria (if ticket-based)
- The implementation plan (if available)
- The research document (if available — gives context on patterns and impact)

## Review Dimensions

### Completeness (ticket-based only)
- Are ALL acceptance criteria met?
- Is anything from the plan missing or incomplete?
- Are there unchecked items in the plan?

### Code Quality
- Does the code follow project patterns (from AGENTS.md)?
- Is error handling comprehensive?
- Is the code testable and tested?

### Security
- Input validation and sanitization
- No sensitive data exposure
- Proper access control

### Performance
- No N+1 queries or unnecessary operations
- Proper caching usage
- No unbounded operations

### Side Effects
- Impact on existing functionality
- Backward compatibility
- Cache invalidation implications

### Cleanup
- No debug code, console.log, commented-out code
- No TODO comments that should have been addressed
- No unnecessary file changes

## Output

Write the review to: `thoughts/shared/reviews/[TICKET-ID]-review.md` (or `YYYY-MM-DD-[scope].md` for non-ticket reviews)

Format:
```markdown
# Review: [Ticket ID or Scope]

**Date:** YYYY-MM-DD
**Verdict:** Approved | Needs Changes | Blocked

## Summary
Overall assessment in one paragraph.

## Issues
### Critical
(Must fix before merge)

### Warnings
(Should fix, but not blocking)

### Suggestions
(Optional improvements)

## Completeness
(Ticket-based only: acceptance criteria checklist with pass/fail)

## What's Good
(Acknowledge solid work)
```

Present the summary to the user after writing.
