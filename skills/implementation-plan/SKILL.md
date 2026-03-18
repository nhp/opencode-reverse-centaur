---
name: implementation-plan
description: "Template and format specification for implementation plans. Load this when creating a plan to get the phase structure, success criteria format, and review checklist."
---

# Implementation Plan Template

Use this template when writing implementation plans to `thoughts/shared/plans/`.

## File Naming

```
thoughts/shared/plans/PREFIX-XXXX-implementation-plan.md
```

## Document Structure

```markdown
---
ticket: PREFIX-XXXX
title: "Plan: [Feature/Change Name]"
date: YYYY-MM-DD
status: draft | approved | in-progress | completed
research: thoughts/shared/research/PREFIX-XXXX-topic-name.md
---

# Plan: [Feature/Change Name]

## Overview
One paragraph: what this plan achieves and why.

## References
- **Ticket:** thoughts/shared/tickets/PREFIX-XXXX-description.md
- **Research:** thoughts/shared/research/PREFIX-XXXX-topic-name.md

## Approach
Brief description of the chosen approach and why it was selected over alternatives.

## Phases

### Phase 1: [Phase Name]

**Goal:** What this phase achieves.

**Changes:**
- [ ] `path/to/file.ext` — Description of change
- [ ] `path/to/new-file.ext` — New file: description
- [ ] `path/to/test.ext` — Tests for this phase

**Success Criteria (Automated):**
- [ ] All existing tests pass
- [ ] New tests for [specific functionality] pass
- [ ] Linter/code style checks pass
- [ ] Build completes without errors

**Success Criteria (Manual):**
- [ ] [Describe manual verification step]

**Commit after this phase passes verification.**

---

### Phase 2: [Phase Name]

(Same structure as Phase 1)

---

## Out of Scope
Things explicitly NOT included in this plan.

## Risks & Mitigations
| Risk | Impact | Mitigation |
|------|--------|-----------|
| [Risk] | [Impact] | [How to handle] |

## Open Questions
(Should be empty before implementation starts. Discuss with user first.)
```

## Key Principles

### Tests Are Part of Every Phase
Each phase includes BOTH the feature implementation AND its tests. A phase is only complete when all tests pass. Never defer testing to a later phase.

### Phases Are Atomic
Each phase should result in a working, committable state. If a phase fails, you can revert to the previous commit without losing other work.

### Success Criteria Must Be Concrete
- **Automated:** Things that can be verified by running a command (tests, linter, build)
- **Manual:** Things that require human verification (UI behavior, business logic correctness)

### Checkboxes Track Progress
During implementation, check off completed items. This allows resuming from where you left off if the session is interrupted.

## Quality Checklist

Before starting implementation, verify the plan:

- [ ] All file paths reference real files (or clearly mark new files)
- [ ] Each phase has both automated and manual success criteria
- [ ] Tests are included in each phase (not deferred)
- [ ] No open questions remain — all discussed with user
- [ ] Research document has been consulted
- [ ] Impact analysis from research has been addressed
- [ ] Risks are identified with concrete mitigations
- [ ] Phases are ordered by dependency (no phase depends on a later phase)
