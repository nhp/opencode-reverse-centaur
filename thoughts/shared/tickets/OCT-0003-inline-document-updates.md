# OCT-0003: Add Inline Document Updates to Workflow Commands

**Status:** Done
**Priority:** High
**Type:** Enhancement
**Depends on:** OCT-0002

## Problem Statement

Knowledge is currently captured in two ways: ticket/research/plan artifacts during work, and (after OCT-0002) a `CONTEXT.md` glossary. But domain terms and architectural decisions are only written to these files at the end of a session or when explicitly running `/memory capture`. The moment a term is clarified or a trade-off resolved, the insight should be captured — not batched for later when context has already faded.

## Solution

Enhance existing workflow commands to update `CONTEXT.md` and `thoughts/shared/memory/decisions/` inline as decisions crystallize during sessions. No new command — just sharper behavior in the commands we already have.

## Scope

### In Scope

- `/discuss`: update `CONTEXT.md` immediately when domain terms are clarified (not batched at summary time)
- `/create-ticket`: when acceptance criteria reveal domain constraints, suggest `CONTEXT.md` updates
- `/plan`: when trade-offs are resolved, suggest creating a decision record inline
- `/memory capture`: update `CONTEXT.md` if new terms emerged during the ticket lifecycle

### Out of Scope

- New `/grill-with-docs` command (different workflow model)
- Automated term extraction or NLP-based glossary generation
- Enforcing CONTEXT.md updates (suggestions only, user decides)

## Acceptance Criteria

- [ ] `/discuss` has explicit instruction to update `CONTEXT.md` inline when terms surface during the conversation — add term, definition, and "Avoid" synonyms as they are resolved
- [ ] `/discuss` summary still written at end, but inline updates happen throughout
- [ ] `/create-ticket` references `CONTEXT.md` and suggests updates when acceptance criteria reveal new domain constraints
- [ ] `/plan` suggests decision records when trade-offs are resolved during planning dialogue
- [ ] `/memory capture` checks for new domain terms that emerged and updates `CONTEXT.md` accordingly
- [ ] All inline updates include source citations (which discussion point, which question, which constraint triggered the update)
- [ ] Updates are suggested, not forced — user always has the option to skip

## Technical Notes

- Inline updates should be lightweight — add a term + definition, not rewrite the whole file
- When `CONTEXT.md` does not exist, commands should continue normally without error
- Suggestions should be brief: "Term 'fulfillment cascade' just clarified — updating CONTEXT.md" rather than asking for confirmation each time
- Decision records created inline should use the three-gate test from OCT-0005

## References

- Matt Pocock's `/grill-with-docs`: https://github.com/mattpocock/skills/blob/main/skills/engineering/grill-with-docs/SKILL.md
- Related: OCT-0002 (CONTEXT.md scaffold), OCT-0005 (decision record template)
