---
description: "Cross-ticket memory workflow. Use lookup before research/planning and capture after merge to preserve durable knowledge."
---

# Memory Workflow

Run memory workflow for: **$ARGUMENTS**

## Purpose

Prevent knowledge loss across sessions by maintaining a small reusable memory layer:

- `thoughts/shared/memory/index.md` (curated retrieval map)
- `thoughts/shared/memory/concepts/` (durable invariants, pitfalls, constraints)
- `thoughts/shared/memory/decisions/` (ADR-lite decision history and supersession)

## Modes

Interpret `$ARGUMENTS` as one of these intents:

1. **Lookup mode** (default)
   - Use for new tickets, research, or planning
   - Find and summarize relevant memory entries before new analysis begins

2. **Capture mode** (`capture <TICKET-ID>`)
   - Use after PR merge to main
   - Extract durable insights from ticket/research/plan/review and update memory files

If the mode is ambiguous, infer the safest default:
- New ticket/topic context -> lookup mode
- Explicit "after merge", "capture", or "update memory" -> capture mode

## Lookup Mode Process

1. Read `thoughts/shared/memory/index.md` (if present)
2. Use **@thoughts-locator** to find relevant files in:
   - `thoughts/shared/memory/concepts/`
   - `thoughts/shared/memory/decisions/`
3. Use **@thoughts-analyzer** to extract:
   - Applicable constraints/invariants
   - Known pitfalls
   - Prior decisions that should be respected
4. Present a concise "memory context" summary with citations

## Capture Mode Process

Expected trigger: **ticket merged to main**.

1. Gather source artifacts for the ticket via `./scripts/ticket.sh <TICKET-ID>`
2. Read ticket/research/plan/review docs and identify only durable knowledge:
   - Likely to matter in 3+ months
   - Useful beyond this single ticket
3. Update or create:
    - One concept page if a reusable invariant/pitfall emerged
    - One decision page if a meaningful trade-off was resolved and passes the three-gate test
4. Update `thoughts/shared/memory/index.md` links
5. If `CONTEXT.md` exists, check whether new domain terms emerged during the ticket lifecycle. If so, suggest additions to `CONTEXT.md`.
6. Keep the update lean (target 5-10 minutes)

### Decision Record Gate

Before creating a decision record, verify all three are true:

1. **Hard to reverse** — changing later has meaningful cost
2. **Surprising without context** — future readers will ask why
3. **Real trade-off** — credible alternatives existed and one was chosen for a reason

If any gate fails, skip the decision record and keep the rationale in the source artifact instead.

Decision records live at `thoughts/shared/memory/decisions/dec-YYYY-MM-DD-short-title.md` and include:
- Context
- Decision
- Consequences
- Alternatives considered
- Supersedes / Superseded by links
- Sources pointing back to ticket/research/plan/review/discussion files

## Quality Rules

- Do not copy ticket prose verbatim into memory pages.
- Keep raw source artifacts canonical; memory pages are derived.
- Every memory claim should link back to ticket/research/plan/review sources.
- Mark uncertain/rejected hypotheses as `experimental` instead of asserting them as fact.
- Do not delete superseded decisions. Mark `**Status:** superseded` and link to the replacing decision.
- Keep decision records short; the template in `thoughts/shared/memory/decisions/decision-template.md.example` is the upper bound, not a prompt to write essays.

## If Memory Layer Is Missing

If `thoughts/shared/memory/` does not exist, create:

- `thoughts/shared/memory/index.md`
- `thoughts/shared/memory/concepts/.gitkeep`
- `thoughts/shared/memory/decisions/.gitkeep`

Initialize `index.md` with short sections by domain/module and placeholder links.
