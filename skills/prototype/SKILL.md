---
name: prototype
description: Throwaway prototyping workflow for UI variants, interaction feel, state machines, and business logic questions. Use when the user wants to prototype, see options, sanity-check behavior, or answer a high-fidelity design question.
---

# Prototype

A prototype is throwaway code that answers one question. The question decides the shape.

Do not treat prototype code as production implementation. Skip polish, skip broad abstractions, and keep the answer instead of the scaffolding.

## Step 1: State the Question

Before coding, write:

- The exact question being answered
- The branch: logic/state or UI
- The one command the user will run
- Where the answer will be captured afterward

If the question is unclear, ask one clarification before building.

## Branch A: Logic or State Prototype

Use this for state machines, reducers, business rules, data flow, validation, or hard-to-reason-through edge cases.

Build a tiny interactive terminal app or script that:

- Runs with one command
- Keeps state in memory by default
- Prints the full relevant state after each action
- Includes fixture scenarios that exercise the confusing cases
- Is named clearly as throwaway, for example `prototype-*`, `*.prototype.*`, or a local scratch route/script matching project conventions

## Branch B: UI Prototype

Use this for layout, interaction feel, visual hierarchy, flows, or competing designs.

Build several meaningfully different variants that:

- Live on one throwaway route or clearly marked local entry point
- Are switchable by query parameter, small control, or route segment
- Show enough realistic content to judge the decision
- Avoid production persistence unless the question explicitly requires it
- Follow existing framework/routing conventions instead of inventing a new structure

## Rules

- Mark files clearly as prototype/throwaway.
- Keep the prototype close to the relevant code so context is obvious.
- Provide one command to run it.
- Avoid persistence unless the persistence model is the thing being tested.
- Add only enough error handling to make it runnable.
- Do not add tests unless the prototype is being promoted to production.
- Delete or absorb the prototype when it has answered the question.

## Capture The Answer

When done, capture only the useful result:

- What question was answered
- What the answer was
- Which variant/model won and why
- What should change in the ticket, plan, `CONTEXT.md`, or decision record
- Whether the prototype should be deleted now or left briefly for user review

If the prototype came from a `/handoff`, write a return handoff summarizing the answer and artifact paths.
