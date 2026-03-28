---
description: "Step 2/4: Research the codebase for a ticket or topic. Spawns subagents to locate files, analyze code, find patterns, and check existing documentation."
---

# Research Codebase

Research the codebase for: **$ARGUMENTS**

## Before You Start

If `$ARGUMENTS` looks like a ticket ID (e.g., PROJ-0001), gather all existing context:
```
!`./scripts/ticket.sh $1`
```

Read the ticket file to understand what needs to be researched. Focus on:
- The technical questions in the "Open Questions" section
- The acceptance criteria (to understand what the code needs to do)
- The problem statement (to understand the domain)

## Research Process

Use the following subagents to research the codebase. Run them in parallel where possible.

### 1. Locate Relevant Files
Use **@codebase-locator** to find all files related to the topic. Provide it with:
- The feature/topic description
- Key terms, class names, or module names from the ticket

### 2. Analyze Implementation
Use **@codebase-analyzer** to understand how the relevant code works. Give it:
- The file list from step 1
- Specific questions about data flow, logic, or behavior

### 3. Find Existing Patterns
Use **@codebase-pattern-finder** to find similar implementations. Ask it for:
- Code that does something similar to what the ticket requires
- Testing patterns used for similar features

### 4. Check Existing Documentation
Use **@thoughts-locator** to find related documents in `thoughts/`. Then use **@thoughts-analyzer** on any relevant documents found.

### 5. Web Research (if needed)
If the ticket involves external libraries, APIs, or unfamiliar technology, use **@web-search-researcher** to gather relevant documentation.

## Critical Rules

1. **Subagents are documentarians.** They describe what exists. They NEVER suggest improvements. If a subagent starts suggesting changes, remind it to only document.

2. **Impact analysis is mandatory** when the ticket involves modifying or extending existing code. Document:
   - All consumers/users of the code being changed
   - Potential side effects
   - Backward compatibility concerns

3. **Don't skip steps.** Even if the topic seems simple, run the locator first. You might discover code you didn't expect.

## Security Assessment

Before writing the research document, evaluate the security surface of the feature being researched. Load the **security-checklist** skill and use the **Quick Decision Matrix** to identify which security categories apply.

Document in the research output:
- Which security categories are relevant to this feature
- Existing security patterns in the codebase (how does the project currently handle input validation, authentication, query parameterization, etc.)
- Any existing security vulnerabilities or weak patterns in the code being analyzed
- Security constraints that must be respected during implementation

If the feature involves user input, authentication, file handling, API endpoints, or database queries, this section is **mandatory** — do not skip it.

## Output

Load the **research-document** skill for the output template.

Write the research document to: `thoughts/shared/research/[TICKET-ID]-research.md`

If there's no ticket ID, use: `thoughts/shared/research/YYYY-MM-DD-[topic-slug].md`

After writing, present a brief summary to the user highlighting:
- Key findings
- Any surprising discoveries
- Open questions that still need answers
- Recommendation: is this ready for `/plan` or does it need more research?
