---
ticket: OCT-0002
title: "Plan: Add CONTEXT.md Shared Domain Language Pattern"
date: 2026-05-04
status: completed
research: thoughts/shared/research/OCT-0002-research.md
---

# Plan: Add CONTEXT.md Shared Domain Language Pattern

## Overview

Add `CONTEXT.md` as a first-class convention in the template. Create the format template, add the enforcement rule in `AGENTS-base.md`, wire it into all affected commands, update scaffold and docs. Single phase — all changes are small additive insertions following established patterns.

## References

- **Ticket:** thoughts/shared/tickets/OCT-0002-context-md-domain-language.md
- **Research:** thoughts/shared/research/OCT-0002-research.md

## Approach

Additive-only changes following the three established patterns identified in research:
- **Pattern A** (soft optional) for commands: "Read if present, continue normally if not"
- **Pattern B** (scaffolding) for init-workflow: "Check if exists → skip or copy"
- **Pattern C** (mandatory convention) for AGENTS-base.md: "If exists, follow its rules"

No new commands, no refactoring. All changes degrade gracefully when CONTEXT.md doesn't exist.

## Phases

### Phase 1: CONTEXT.md Convention — Template, Rule, Commands, and Docs

**Goal:** Complete implementation of the CONTEXT.md pattern across the entire template.

**Changes:**

*New file:*
- [ ] `project-skeleton/CONTEXT.md.example` — Format template with Language, Relationships, Example dialogue (optional), Flagged ambiguities sections. Include "How to Use" instructions and placeholder examples.

*Core rule:*
- [ ] `AGENTS-base.md` — Add `## Domain Language` section between "Development Conventions" and "Security Awareness". Pattern C: if CONTEXT.md exists, use its vocabulary; if not, continue normally.

*Command integration (Pattern A — soft optional):*
- [ ] `commands/research.md` — Add "Domain Language" substep after Memory Recall in "Before You Start"
- [ ] `commands/plan.md` — Add CONTEXT.md bullet to "Read ALL of the following" list in Step 1
- [ ] `commands/discuss.md` — Add "Before You Start" section with CONTEXT.md check + add inline update suggestion to "During the Discussion"
- [ ] `commands/create-ticket.md` — Add CONTEXT.md check to "Before You Start"
- [ ] `commands/implement.md` — Add CONTEXT.md bullet to "Before You Start" read list
- [ ] `commands/memory.md` — Add CONTEXT.md term check to capture mode process

*Scaffold (Pattern B):*
- [ ] `commands/init-workflow.md` — Add "Step 4c: Generate CONTEXT.md (optional)" after AGENTS.md generation + update summary

*Documentation:*
- [ ] `AGENTS.md.example` — Add CONTEXT.md to directory tree + add "Domain Language" section
- [ ] `README.md` — Add "Shared Domain Language" section + update project structure tree + update init-workflow output list
- [ ] `PLANNING.md` — Update component inventory and directory structure

**Success Criteria (Automated):**
- [ ] All files parse as valid markdown (no broken formatting)
- [ ] `grep -r "CONTEXT.md" commands/ AGENTS-base.md AGENTS.md.example README.md PLANNING.md` returns matches in all expected files
- [ ] `project-skeleton/CONTEXT.md.example` exists and contains all four sections

**Success Criteria (Manual):**
- [ ] CONTEXT.md.example follows Matt Pocock's format (Language with bold terms + Avoid, Relationships with cardinality, Flagged ambiguities with resolutions)
- [ ] AGENTS-base.md rule clearly states: use vocabulary, respect Avoid lists, continue normally if absent
- [ ] Each command insertion follows the correct pattern (A, B, or C) as identified in research
- [ ] init-workflow step uses existing "check if exists → skip or copy" pattern exactly
- [ ] README section follows the same structure as the "Cross-Ticket Memory Layer" section
- [ ] No existing functionality is broken — all changes are additive and conditional

**Commit after this phase passes verification.**

## Out of Scope

- New `/grill-with-docs` command (future work)
- `CONTEXT-MAP.md` for monorepos (future ticket)
- Automated CONTEXT.md linting
- Inline CONTEXT.md updates during sessions (OCT-0003)

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|-----------|
| init-workflow step numbering gets inconsistent | Low — confusing for agents reading the command | Verify step numbers are sequential after insertion |
| Existing projects get AGENTS-base.md rule via symlink | None — rule says "continue normally" if no CONTEXT.md | Already handled by conditional wording |

## Open Questions

None — all resolved during research.
