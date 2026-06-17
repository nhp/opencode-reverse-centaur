---
name: improve-codebase-architecture
description: Finds architectural deepening opportunities in codebases: shallow modules, weak seams, low locality, and hard-to-test areas. Use after reviews, failed implementations, debugging findings, or when the user asks to improve architecture/refactorability.
---

# Improve Codebase Architecture

Find refactors that make the codebase easier to test, change, and navigate. Do not start by proposing a rewrite. Surface candidates first.

## Architecture Language

Use these terms consistently:

- **Module:** anything with an interface and implementation
- **Interface:** everything callers must know to use the module, including types, invariants, ordering, config, and errors
- **Implementation:** the code inside the module
- **Depth:** how much useful behavior sits behind a small interface
- **Seam:** where behavior can change without editing callers in place
- **Adapter:** a concrete implementation satisfying an interface at a seam
- **Leverage:** what callers gain from a deeper module
- **Locality:** how well related change, bugs, and knowledge stay together

Apply the deletion test: if deleting a module only removes indirection, it was shallow; if deleting it spreads complexity across callers, it was earning its keep.

## Explore First

Read if present:

- `CONTEXT.md` for domain terms
- `thoughts/shared/memory/index.md`
- relevant decision records under `thoughts/shared/memory/decisions/`
- relevant tickets, research, plans, reviews, or debugging notes

Use codebase exploration to find friction:

- Understanding one concept requires bouncing through many files
- Tests reach into implementation details because seams are weak
- Helpers were extracted but did not improve locality
- Modules are pass-through wrappers with nearly as much interface as implementation
- The agent or developer repeatedly chooses the wrong edit location
- A bug could not be regression-tested at a correct seam

## Report Candidates

Write a markdown report to the OS temp directory, not the repository:

- Use `$TMPDIR` when set, otherwise `/tmp`
- Name it `opencode-architecture-review-YYYYMMDD-HHMMSS.md`

For each candidate include:

- **Files/modules:** relevant paths
- **Problem:** why current architecture causes friction
- **Deletion test:** what happens if the module disappears
- **Deepening opportunity:** what concept or seam could become deeper
- **Benefits:** locality, leverage, and testing improvement
- **Risks:** behavior, migration, or decision conflicts
- **Recommendation strength:** Strong, Worth exploring, or Speculative

End with a top recommendation and why it should be tackled first.

Do not propose detailed interfaces yet. After writing the report, ask which candidate the user wants to explore.

## Explore A Selected Candidate

When the user picks a candidate:

- Use `/grill-with-docs` discipline to resolve naming, boundaries, and constraints
- Update `CONTEXT.md` if a new domain term or relationship is clarified
- Create a decision record only when the three-gate test passes
- Suggest `/create-ticket` or `/plan` for the chosen refactor slice

If an existing decision record forbids a candidate, surface the conflict only when the friction is real enough to justify revisiting it.
