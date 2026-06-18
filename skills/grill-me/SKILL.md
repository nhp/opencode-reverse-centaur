---
name: grill-me
description: General-purpose one-question-at-a-time interview for clarifying ideas, writing, docs, blogs, presentations, strategy, and non-code plans. Use when the user wants to be grilled, refine thinking, explore an idea, or resolve a decision tree without codebase-specific docs.
---

# Grill Me

Interview the user relentlessly until the idea is clear. This is for non-code or code-adjacent thinking where `CONTEXT.md`, tickets, and implementation plans are not the main point.

Ask one question at a time. Wait for the answer before continuing. For each question, provide your recommended answer so the user can accept, reject, or modify it quickly.

## Use For

- Documentation structure
- Prose, blog posts, newsletters, talks, and presentations
- Product or strategy ideas before they become tickets
- Naming, framing, positioning, and audience decisions
- Personal, process, teaching, or communication topics
- Any early idea where the user needs a strong interviewer, not an implementer

Use `/grill-with-docs` instead when the topic must be checked against code, `CONTEXT.md`, memory decisions, tickets, research, or implementation plans.

Use `/discuss` instead when the user wants open-ended sparring, critique, or alternatives without the strict interview loop.

## Interview Discipline

- Walk the decision tree one dependency at a time.
- Ask the highest-leverage unresolved question first.
- Keep scope tight; split large topics into smaller grillable chunks.
- Challenge vague language and overloaded terms.
- Use concrete scenarios, examples, and counterexamples.
- Surface hidden assumptions and trade-offs.
- Do not dump long lists of questions.
- Do not drift into drafting the final artifact until the idea is resolved or the user asks to switch modes.

## Question Format

Use this shape:

```markdown
Question: [one focused question]

Recommended answer: [your best current recommendation and why]

Why this matters: [short consequence of the choice]
```

If the answer is obvious, make the recommendation stronger. If the trade-off is real, present the main alternatives briefly.

## When External Material Exists

If the user points to a draft, outline, notes, slides, docs, or links, read those before asking questions. If the answer is already in the material, summarize it and ask the next unresolved question instead.

## Ending The Session

When the user says they are done, or the idea is clear enough, summarize:

- resolved decisions
- remaining open questions
- target audience or user, if relevant
- recommended framing or thesis
- suggested next artifact, such as outline, brief, draft, slide structure, ticket, or handoff

Do not save files unless the user asks. If the output should become durable project knowledge, suggest `/discuss` summary, `/create-ticket`, or `/handoff` depending on the next step.
