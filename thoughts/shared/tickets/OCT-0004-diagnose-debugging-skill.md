# OCT-0004: Add /diagnose Debugging Skill

**Status:** Done
**Priority:** Medium
**Type:** Feature

## Problem Statement

There is no structured debugging workflow in the template. When agents encounter bugs, they default to ad-hoc code reading and speculative fixes. This wastes tokens, produces shallow fixes, and misses root causes.

## Solution

Add a standalone skill (`skills/diagnose/SKILL.md`) that provides a disciplined 6-phase debugging loop. Adapted from Matt Pocock's `/diagnose` skill to use our conventions (`CONTEXT.md`, `thoughts/shared/memory/`).

Loaded on demand — not a full command pipeline step, but available when debugging is needed.

## Scope

### In Scope

- `skills/diagnose/SKILL.md` with 6-phase debugging loop
- Phase 1: Build a feedback loop (the core discipline — 10 strategies ranked by preference)
- Phase 2: Reproduce (confirm the loop catches the right failure)
- Phase 3: Hypothesize (3-5 ranked, falsifiable hypotheses with predictions)
- Phase 4: Instrument (one variable at a time, tagged debug logs)
- Phase 5: Fix + regression test (write test before fix when a correct seam exists)
- Phase 6: Cleanup + post-mortem (remove instrumentation, state finding, suggest memory capture)
- Update `README.md` and `PLANNING.md` inventories

### Out of Scope

- Full command with ticket integration (could be added later if skill proves valuable)
- Automated test harness generation
- Performance profiling tools or specific instrumentation libraries

## Acceptance Criteria

- [ ] `skills/diagnose/SKILL.md` exists with all 6 phases documented
- [ ] Phase 1 lists feedback loop strategies in preference order (failing test, curl/HTTP script, CLI invocation, headless browser, replay trace, throwaway harness, property/fuzz loop, bisection harness, differential loop, HITL bash script)
- [ ] Phase 1 emphasizes: "spend disproportionate effort building the loop — if you have a fast deterministic signal, you will find the cause"
- [ ] Phase 3 requires hypotheses to be falsifiable with predictions in format: "If X is the cause, then changing Y will make the bug disappear"
- [ ] Phase 4 requires tagged debug logs with unique prefixes (e.g., `[DEBUG-a4f2]`) for easy cleanup
- [ ] Phase 5 notes: if no correct test seam exists, that itself is the finding — flag for architecture improvement
- [ ] Phase 6 suggests `/memory capture` for durable debugging insights and `/improve-codebase-architecture` if architecture prevented a good test seam
- [ ] Skill references `CONTEXT.md` for domain vocabulary when present
- [ ] Skill listed in `README.md` and `PLANNING.md` skill inventories

## Technical Notes

- Skill should be model-agnostic and provider-agnostic
- No external tool dependencies beyond what agents already have
- Non-deterministic bugs: skill should advise raising reproduction rate (loop 100x, parallelize, stress, narrow timing windows) rather than requiring clean repro
- When no feedback loop can be built, skill should stop and explicitly list what was tried and ask user for captured artifacts

## References

- Matt Pocock's `/diagnose`: https://github.com/mattpocock/skills/blob/main/skills/engineering/diagnose/SKILL.md
- David Thomas & Andrew Hunt, The Pragmatic Programmer — feedback loops
