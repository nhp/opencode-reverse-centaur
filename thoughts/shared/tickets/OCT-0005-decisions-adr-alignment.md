# OCT-0005: Align memory/decisions/ Template with ADR Best Practices

**Status:** Open
**Priority:** Medium
**Type:** Enhancement
**Depends on:** OCT-0002

## Problem Statement

The `thoughts/shared/memory/decisions/` template added in the memory layer is minimal. It doesn't help users decide when a decision record is worth writing vs. noise, and it lacks supersession tracking. Without a quality gate, decision records will either be over-produced (noise) or under-produced (knowledge loss).

## Solution

Adopt Matt Pocock's three-gate test for when to write a decision record, and enhance our existing decisions template with cleaner structure and supersession chain support. Wire the gate test into `/memory capture` and `/plan` so agents apply it automatically.

## Scope

### In Scope

- Update `project-skeleton/thoughts/shared/memory/index.md.example` decision entry format
- Create a dedicated decision record template in `project-skeleton/thoughts/shared/memory/decisions/` (or update existing example)
- Add three-gate test to `/memory capture` command
- Add three-gate test reference to `/plan` command (when suggesting decision records)
- Add Supersedes / Superseded by chain support to decision format
- Update `AGENTS-base.md` or memory docs with decision-writing guidance

### Out of Scope

- Separate `docs/adr/` directory (decisions stay in `thoughts/shared/memory/decisions/`)
- Automated decision linting or staleness detection
- Migration of existing decisions to new format

## Acceptance Criteria

- [ ] Decision record template includes sections: Context, Decision, Consequences, Alternatives considered, Supersedes / Superseded by, Sources
- [ ] Three-gate test documented in decision template preamble:
  1. Hard to reverse — cost of changing mind later is meaningful
  2. Surprising without context — future reader will wonder "why did they do it this way?"
  3. Result of a real trade-off — genuine alternatives existed and one was picked for specific reasons
  - Rule: only write a decision when ALL THREE are true
- [ ] `/memory capture` applies the three-gate test before creating a decision record
- [ ] `/plan` references the three-gate test when suggesting inline decision records
- [ ] Supersedes chain format: each decision links to the decision it supersedes (if any) and can be superseded by a future decision
- [ ] Decision records link back to source ticket/research/plan/review files
- [ ] `README.md` or `AGENTS.md.example` explains when to write vs. skip a decision record

## Technical Notes

- Decision file naming: `dec-YYYY-MM-DD-short-title.md` (consistent with discussion naming)
- Superseded decisions should NOT be deleted — they remain as historical context with a `**Status:** superseded` marker and a link to the replacing decision
- Experimental decisions (from abandoned tickets) should be marked `**Status:** experimental`
- Template should be under 30 lines to keep barrier-to-entry low

## References

- Matt Pocock's ADR format: https://github.com/mattpocock/skills/blob/main/skills/engineering/grill-with-docs/ADR-FORMAT.md
- Matt Pocock's three-gate test (from `/grill-with-docs` SKILL.md)
- Michael Nygard, ADR template: https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions
- Related: OCT-0002 (CONTEXT.md), OCT-0003 (inline updates)
