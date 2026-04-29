# Discussion: Session Knowledge Retention via Lean Memory Layer

**Date:** 2026-04-24

## Context
The discussion was prompted by repeated loss of useful knowledge between coding sessions. Although ticket/research/plan files exist, prior discoveries often do not reliably carry into new tickets. The user asked whether integrating an "LLM Wiki" style pattern (inspired by Karpathy's gist) would improve general reasoning and continuity.

## Key Points Discussed
- The core issue is not model intelligence; it is memory architecture and retrieval workflow discipline.
- Existing `thoughts/shared/{tickets,research,plans,reviews}` already provides strong historical artifacts, but they are ticket-centric and not optimized for cross-ticket recall.
- A pure LLM-generated wiki can improve compounding knowledge, but introduces drift and false-authority risks if generated summaries are treated as canonical truth.
- A deterministic retrieval layer plus small distilled memory artifacts is more reliable than relying on broad LLM recall.
- Knowledge graphs can still underperform if schema quality is weak or if no workflow enforces usage at ticket start.

## Decisions Made
- Adopt a **lean hybrid memory approach** rather than a full autonomous wiki system.
- Add a minimal memory layer:
  - `thoughts/shared/memory/index.md` as curated retrieval map
  - `thoughts/shared/memory/concepts/` for durable cross-ticket invariants
  - `thoughts/shared/memory/decisions/` for ADR-lite rationale history
- Define "done for memory update" as **PR merged to main** (single stable trigger).
- After merge, perform a short "memory delta" pass (target 5-10 minutes max) to capture reusable insights and update index links.

## Open Questions
- Should rejected/abandoned tickets with meaningful findings produce explicitly marked `experimental` memory entries?
- What initial taxonomy/tags should be standardized first (domain/module/component) to maximize retrieval quality?
- How often should memory linting happen (weekly vs. ad hoc)?

## Action Items
- [ ] Create `thoughts/shared/memory/index.md` with domain/module sections and links to existing high-value artifacts.
- [ ] Create `thoughts/shared/memory/concepts/` and add first concept page from recent quote/PDF/i18n work.
- [ ] Create `thoughts/shared/memory/decisions/` and add first ADR-lite decision with alternatives and consequences.
- [ ] Add a merge-time checklist item: "memory delta completed".
- [ ] Start a 2-3 week pilot and trim process if any update exceeds ~10 minutes.

## References
- Karpathy gist: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
- Existing artifacts in repo:
  - `thoughts/shared/tickets/`
  - `thoughts/shared/research/`
  - `thoughts/shared/plans/`
  - `thoughts/shared/reviews/`
