# OCT-0002: Add CONTEXT.md Shared Domain Language Pattern

**Status:** Done
**Priority:** High
**Type:** Feature

## Problem Statement

Agents working on a project lack a structured domain vocabulary. They use verbose descriptions where a precise term would suffice, name variables/functions inconsistently, and rediscover domain concepts each session. This directly contributes to knowledge loss between sessions and inflated token usage.

Inspired by Matt Pocock's `CONTEXT.md` pattern (from [mattpocock/skills](https://github.com/mattpocock/skills)), which demonstrates that a shared domain language document dramatically improves agent consistency, reduces verbosity, and makes codebases more navigable.

## Solution

Add `CONTEXT.md` as a first-class convention in the template. A living glossary that defines domain terms precisely, documents relationships between concepts, and flags ambiguities. Agents read it before starting work and use its vocabulary consistently.

Convention + scaffold only — no new command. Existing commands (`/research`, `/plan`, `/discuss`) will be updated to check for and reference `CONTEXT.md` when present.

## Scope

### In Scope

- `CONTEXT.md.example` template in `project-skeleton/` with format spec
- `/init-workflow` update to offer `CONTEXT.md` creation (opt-in, lazy)
- `AGENTS-base.md` update with rule to respect `CONTEXT.md` when present
- `/research` update: check for `CONTEXT.md` before codebase search
- `/plan` update: use `CONTEXT.md` vocabulary in plan writing
- `/discuss` update: reference `CONTEXT.md` during discussions, suggest updates when terms clarified
- `AGENTS.md.example` directory structure update
- `README.md` and `PLANNING.md` alignment

### Out of Scope

- New `/grill-with-docs` command (may be added later)
- `CONTEXT-MAP.md` for monorepo multi-context support (future ticket)
- Automated CONTEXT.md linting or drift detection

## Acceptance Criteria

- [ ] `project-skeleton/CONTEXT.md.example` exists with format spec:
  - `## Language` section with terms (term, definition, "Avoid" synonyms)
  - `## Relationships` section (entity relationships in plain English)
  - `## Flagged Ambiguities` section (resolved ambiguities with decisions)
- [ ] `/init-workflow` offers to create `CONTEXT.md` from the example template
- [ ] `AGENTS-base.md` has a rule: "When `CONTEXT.md` exists, use its vocabulary consistently in code, comments, commit messages, and documentation"
- [ ] `/research` checks for `CONTEXT.md` before starting and uses its terms in findings
- [ ] `/plan` references `CONTEXT.md` vocabulary when writing phase descriptions
- [ ] `/discuss` references `CONTEXT.md` during discussions and suggests inline updates when domain terms are clarified or new terms emerge
- [ ] `README.md` documents the `CONTEXT.md` convention
- [ ] `PLANNING.md` component inventory updated

## Technical Notes

- `CONTEXT.md` lives at project root (same level as `AGENTS.md`)
- Format should be lean — no YAML frontmatter, just markdown sections
- Terms should NOT be coupled to implementation details (no file paths, class names)
- Only include terms meaningful to domain experts, not internal code jargon

## References

- Matt Pocock's CONTEXT.md: https://github.com/mattpocock/skills/blob/main/CONTEXT.md
- Matt Pocock's grill-with-docs skill: https://github.com/mattpocock/skills/blob/main/skills/engineering/grill-with-docs/SKILL.md
- Eric Evans, Domain-Driven Design — Ubiquitous Language concept
