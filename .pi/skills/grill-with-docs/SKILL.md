---
name: grill-with-docs
description: Stress-test a plan against the codebase, domain glossary, and prior decisions. Use when the user wants to refine vague ideas, be grilled, clarify requirements before ticketing, or resolve design trade-offs.
---

# Grill With Docs

Interview the user relentlessly until the plan is clear enough to become a ticket, plan, prototype brief, or implementation input.

Ask one question at a time. For each question, provide your recommended answer. Wait for the user's answer before continuing.

If a question can be answered by exploring the codebase or existing docs, explore instead of asking.

This is an upstream clarification workflow. Do not implement production code. The durable output is clarified decisions, updated domain language, decision records, or a clearer ticket/plan.

## Before Asking

Read if present:

- `CONTEXT.md` for canonical domain language
- `thoughts/shared/memory/index.md`
- relevant files under `thoughts/shared/memory/concepts/`
- relevant files under `thoughts/shared/memory/decisions/`
- any ticket, research, plan, or discussion documents named by the user

If `CONTEXT.md` does not exist, continue normally. Create or suggest it only after a real term is resolved.

## Grilling Discipline

- Walk the design tree one dependency at a time.
- Challenge vague words and overloaded terms.
- When user language conflicts with `CONTEXT.md`, call it out immediately.
- Use concrete scenarios and edge cases to force precise boundaries.
- Cross-check claims against code when the code should already know the answer.
- Keep scope tight. If the topic is too large, split it into smaller grillable chunks.
- Stop planning when the remaining questions are implementation details that can be handled by `/research`, `/plan`, or `/implement`.

## Documentation Updates

When a domain term, relationship, or ambiguity is resolved, suggest updating `CONTEXT.md` immediately. Keep `CONTEXT.md` as a glossary only:

- term name
- one-sentence definition
- `_Avoid_:` synonyms or misleading alternatives
- relationship entries when cardinality or ownership is clarified
- flagged ambiguity when a naming conflict is resolved

When a trade-off is resolved, apply the decision-record three-gate test:

1. Hard to reverse
2. Surprising without context
3. Result of a real trade-off

Only create a decision record when all three are true. Write it under `thoughts/shared/memory/decisions/dec-YYYY-MM-DD-short-title.md` and cite the discussion/ticket/plan source.

## High-Fidelity Questions

Some questions cannot be answered by talking:

- UI layout, motion, or interaction feel
- state models that need to be exercised
- product flows that need to be played with
- competing designs where the user needs to see options

When that happens, do not over-grill. Use `/handoff` to create a focused prototype brief, then resume grilling after the prototype answer is captured.

## Ending The Session

End with one of these outcomes:

- Ready for `/create-ticket`
- Ready for `/research`
- Ready for `/plan`
- Needs `/prototype` first
- Split into smaller grillable scopes

Summarize:

- decisions resolved
- documentation updates made or suggested
- open questions
- recommended next command
