---
ticket: OCT-0002
title: "Research: CONTEXT.md Shared Domain Language Pattern"
date: 2026-05-04
status: complete
---

# Research: CONTEXT.md Shared Domain Language Pattern

## Context

OCT-0002 adds a `CONTEXT.md` shared domain language pattern to the opencode workflow template. This requires understanding: (1) which files need modification, (2) what integration patterns already exist in the codebase, (3) what Matt Pocock's format spec looks like, and (4) where exactly each insertion point is.

No prior memory entries exist — this is the first research document in the repository after cleanup.

## File Map

### Must Change (8 files + 1 new)

- `commands/research.md` — Research command; needs CONTEXT.md check in "Before You Start"
- `commands/plan.md` — Plan command; needs CONTEXT.md in "Gather Context" read list
- `commands/discuss.md` — Discuss command; needs new "Before You Start" section + inline update suggestion
- `commands/init-workflow.md` — Scaffold command; needs new "Step 4c" for CONTEXT.md creation
- `commands/create-ticket.md` — Ticket creation; needs CONTEXT.md vocabulary awareness
- `AGENTS-base.md` — Shared standards; needs new "Domain Language" section
- `README.md` — Public docs; needs CONTEXT.md section
- `PLANNING.md` — Planning doc; needs inventory updates
- **NEW:** `project-skeleton/CONTEXT.md.example` — Format template for new projects

### Likely Change (4 files)

- `AGENTS.md.example` — Starter template; needs CONTEXT.md in directory tree + new section
- `commands/memory.md` — Memory workflow; capture mode should check for new domain terms
- `project-skeleton/thoughts/shared/memory/index.md.example` — May reference CONTEXT.md terms
- `commands/implement.md` — Has "Before You Start"; should read CONTEXT.md for vocabulary

### May Need Awareness (3 files)

- `commands/commit.md` — Commit messages should use CONTEXT.md vocabulary (covered by AGENTS-base.md rule)
- `commands/review.md` — Reviews should use consistent vocabulary (covered by AGENTS-base.md rule)
- `skills/research-document/SKILL.md` — Research output should use domain vocabulary (covered by command-level instruction)

## Implementation Analysis

### Three Established Patterns for File References

The codebase uses three distinct patterns for referencing optional files. CONTEXT.md integration must use the correct pattern in each location.

**Pattern A: "Read if present, skip if not" (soft optional)**

Used by `commands/research.md:15` and `commands/memory.md:35`. Format:

```
Read `[file]` if present.
If [it] does not exist, continue normally.
```

Use this for: `research.md`, `plan.md`, `discuss.md`, `create-ticket.md`, `implement.md`, `memory.md`

**Pattern B: "Check if exists → skip or copy" (scaffolding)**

Used by `commands/init-workflow.md:105-108`, `init-workflow.md:129`, `init-workflow.md:153-156`. Format:

```
Check if [file] exists.
- **If it exists:** Skip.
- **If it doesn't exist:** Copy from template.
```

Use this for: `init-workflow.md` (new Step 4c)

**Pattern C: "If exists, follow its rules unconditionally" (mandatory convention)**

Used by `AGENTS-base.md:11` (`thoughts/.user-acronym`). Format:

```
If `[file]` exists, read it and follow [behavior].
```

Use this for: `AGENTS-base.md` (new "Domain Language" section)

### Exact Insertion Points

**`commands/research.md`** — Insert after line 21 (after Memory Recall, before ticket-ID check):
```markdown
### 0b. Domain Language (if available)

- Read `CONTEXT.md` if present at project root.
- Use its vocabulary consistently in all research findings.
- If `CONTEXT.md` does not exist, continue normally.
```

**`commands/plan.md`** — Insert at line 18 (within "Read ALL of the following" list):
```markdown
- **CONTEXT.md** (if present) — understand domain vocabulary and use it consistently in the plan
```

**`commands/discuss.md`** — Insert new section between line 13 ("Your Role") and line 15 ("How to Discuss"):
```markdown
## Before You Start

- Read `CONTEXT.md` if present at project root. Use its vocabulary during the discussion.
- If `CONTEXT.md` does not exist, continue normally.
```
Also add to "During the Discussion" section (~line 40):
```markdown
- When domain terms are clarified or new terms emerge, suggest updating CONTEXT.md
```

**`commands/create-ticket.md`** — Insert after line 16 (in "Before You Start"):
```markdown
- Read `CONTEXT.md` if present at project root. Use its vocabulary when defining the problem, acceptance criteria, and user stories.
- If `CONTEXT.md` does not exist, continue normally.
```

**`commands/init-workflow.md`** — Insert new "Step 4c" after line 156 (after AGENTS.md generation):
```markdown
## Step 4c: Generate CONTEXT.md (optional)

Check if a `CONTEXT.md` file exists in the project root.

- **If it exists:** Skip. Tell the user their existing CONTEXT.md is preserved.
- **If it doesn't exist:** Ask the user if they want to create a CONTEXT.md for domain vocabulary. If yes, copy `$OPENCODE_TEMPLATE_DIR/project-skeleton/CONTEXT.md.example` to `CONTEXT.md`. If no, skip.

Explain briefly:
> `CONTEXT.md` defines your project's domain language — precise terms, relationships, and resolved ambiguities. Agents use its vocabulary in code, commits, and documentation.
```

**`AGENTS-base.md`** — Insert new section between line 65 (end of "Development Conventions") and line 67 (start of "Security Awareness"):
```markdown
## Domain Language

If `CONTEXT.md` exists at the project root, read it before starting any task. Use its vocabulary consistently in:
- Code (variable names, function names, class names)
- Comments and documentation
- Commit messages
- Ticket descriptions, research documents, and plans
- Conversations with the user

If a term in `CONTEXT.md` has an "Avoid" list, never use those synonyms — use the canonical term.

If `CONTEXT.md` does not exist, continue normally. Do not prompt to create one.
```

**`AGENTS.md.example`** — Add `CONTEXT.md` to directory tree (line 43) and add new section between "Memory Continuity" and "Local Development" (between lines 66-68).

**`README.md`** — Add `CONTEXT.md` to project structure tree (line 303), add new section after "Cross-Ticket Memory Layer" (~line 109).

## Existing Patterns

### Pattern: `.example` File Naming Convention

The repository consistently uses `[original-filename].example` suffix:

| Example file | Target |
|---|---|
| `AGENTS.md.example` | → `AGENTS.md` |
| `project-skeleton/opencode.json.example` | → `opencode.json` |
| `project-skeleton/thoughts/shared/memory/index.md.example` | → `thoughts/shared/memory/index.md` |

CONTEXT.md should follow: `project-skeleton/CONTEXT.md.example` → `CONTEXT.md`

### Pattern: `.example` File Structure

Example files use square brackets for placeholders (`[Your Project Name]`), include `## How to Use` sections, and provide concrete examples. The `index.md.example` at 26 lines is a good reference for length.

### Pattern: init-workflow Summary Section

The summary at `init-workflow.md:171-203` lists all created files with optional items in brackets: `[AGENTS.md (if generated)]`. CONTEXT.md should be added as `[CONTEXT.md (if generated)]`.

## External Research

### Matt Pocock's CONTEXT.md Format

The format has four sections:

1. **`## Language`** — Bold term name + one-sentence definition + `_Avoid_:` synonyms list. Group terms under subheadings when clusters emerge.
2. **`## Relationships`** — Bold term links with cardinality (e.g., "An **Issue tracker** holds many **Issues**").
3. **`## Example dialogue`** — Dev ↔ domain expert conversation demonstrating terms in natural use (optional but powerful).
4. **`## Flagged ambiguities`** — Explicit call-outs of terms that were confusing, with clear resolution text.

### Format Rules (from CONTEXT-FORMAT.md)

- Be opinionated — pick the best term, list others as aliases to avoid.
- Flag conflicts explicitly with clear resolutions.
- Keep definitions tight — one sentence max. Define what it IS, not what it does.
- Show relationships with bold term names and cardinality.
- Only include terms specific to the project — no general programming concepts.
- Group terms under subheadings when natural clusters emerge.
- Write example dialogue (dev ↔ domain expert showing terms in use).

### Real-World Example (course-video-manager)

Matt's production CONTEXT.md has ~60 domain terms organized into 8 subheaded clusters, 15 relationship bullets, 2 example dialogues (~20 exchanges each), and 6 flagged ambiguities. This demonstrates the format scales well.

### Adaptation for Our Template

Our version should be **simpler** than Matt's production example but follow the same format. Key differences:

- Matt's format includes "Example dialogue" — we should include it in the format spec but mark as optional.
- Matt creates `CONTEXT.md` lazily during grilling sessions — we scaffold an example template but creation is opt-in during `/init-workflow`.
- Matt's skills update CONTEXT.md inline — we defer that to OCT-0003.

## Impact Analysis

### Direct Changes

| File | Change Type | Risk |
|---|---|---|
| `commands/research.md` | Add 4-line block | Low — additive, follows existing pattern |
| `commands/plan.md` | Add 1 bullet to read list | Low — additive |
| `commands/discuss.md` | Add new section + 1 bullet | Low — no existing pattern to break |
| `commands/create-ticket.md` | Add 2-line block | Low — additive |
| `commands/init-workflow.md` | Add new step + summary update | Medium — must maintain step numbering |
| `AGENTS-base.md` | Add new section | Low — additive, between existing sections |
| `AGENTS.md.example` | Add tree entry + new section | Low — example file |
| `README.md` | Add section + tree entry | Low — documentation only |
| `PLANNING.md` | Update counts/inventory | Low — metadata only |
| **NEW** `project-skeleton/CONTEXT.md.example` | Create from scratch | Low — new file |

### Side Effects

- **Existing projects using the template** will get the AGENTS-base.md rule via symlink automatically. If they don't have a CONTEXT.md, the rule says "continue normally" — no breakage.
- **init-workflow** changes only affect new project setups — existing projects are unaffected unless they re-run init.
- **Command changes** are purely additive "if present" blocks — zero impact when CONTEXT.md doesn't exist.

### Backward Compatibility

Full backward compatibility. All changes are conditional on CONTEXT.md existence and degrade gracefully.

## Security Assessment

This feature has **no security surface**. CONTEXT.md is a plain markdown file containing domain vocabulary definitions. It:
- Contains no credentials or secrets
- Is not executable
- Does not affect authentication, authorization, or data flow
- Does not handle user input
- Does not interact with databases or external APIs

No security categories from the OWASP/CWE checklist apply.

## Summary

- **8 files need modification + 1 new file** to create. All changes are additive with zero backward compatibility risk.
- **Three established patterns** (soft optional, scaffolding, mandatory convention) cover every insertion point. No new patterns need to be invented.
- **Matt Pocock's format** (Language, Relationships, Example dialogue, Flagged ambiguities) is well-proven in production. Our template version should follow the same structure but mark "Example dialogue" as optional.
- **Every insertion point is precisely identified** with line numbers and exact content blocks.
- **No security concerns** apply to this feature.
- **No prior memory entries** were used (memory layer is empty).
- **Recommendation:** This is ready for `/plan`. No additional research needed.
