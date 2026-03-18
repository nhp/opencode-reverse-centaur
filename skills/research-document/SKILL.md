---
name: research-document
description: "Template and format specification for codebase research documents. Load this when creating a research document to get the output structure, YAML frontmatter format, and quality checklist."
---

# Research Document Template

Use this template when writing research documents to `thoughts/shared/research/`.

## File Naming

```
thoughts/shared/research/PREFIX-XXXX-topic-name.md
```

Where `PREFIX-XXXX` is the ticket ID (if researching for a ticket) or a date-based name for general research.

## Document Structure

```markdown
---
ticket: PREFIX-XXXX
title: "Research: [Topic Name]"
date: YYYY-MM-DD
status: complete
---

# Research: [Topic Name]

## Context
Why this research was conducted. What question are we trying to answer?

## File Map
Files identified as relevant to this topic, organized by purpose.
(Output from codebase-locator agent)

### [Category 1]
- `path/to/file.ext` — Brief description

### [Category 2]
- `path/to/file.ext` — Brief description

## Implementation Analysis
How the relevant code currently works.
(Output from codebase-analyzer agent)

### Entry Points
Where execution starts for this feature.

### Data Flow
How data moves through the system.

### Key Logic
Important decisions, conditions, and business rules with `file:line` references.

## Existing Patterns
Similar implementations found in the codebase.
(Output from codebase-pattern-finder agent)

### Pattern: [Name]
**Location:** `file:line`
**Description:** What it does and how.

## Related Documentation
Relevant findings from existing thoughts documents.
(Output from thoughts-analyzer agent, if applicable)

## External Research
Relevant findings from web research.
(Output from web-search-researcher agent, if applicable)

## Impact Analysis
What existing code would be affected by changes in this area?
- Dependencies and consumers of the code
- Potential side effects
- Backward compatibility concerns

## Summary
Key takeaways from the research in 3-5 bullet points.
```

## Quality Checklist

Before finalizing a research document, verify:

- [ ] All file references use `file:line` format and point to real files
- [ ] Analysis is purely descriptive — no suggestions, recommendations, or opinions
- [ ] Impact analysis covers both direct and indirect effects
- [ ] Related documentation from `thoughts/` has been checked
- [ ] Summary accurately reflects the detailed findings
- [ ] Document answers the original research question
