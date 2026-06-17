---
name: tdd
description: Test-driven development workflow using red-green-refactor. Use when implementing features or fixes where tests should drive behavior through public interfaces.
---

# Test-Driven Development

Use this skill to implement one behavior at a time. Tests verify observable behavior through public interfaces, not implementation details.

## Core Rules

- Test behavior, not private functions or internal structure.
- Prefer integration-style tests through stable seams.
- Write one failing test, implement the smallest fix, then repeat.
- Never write all tests first and all code afterward.
- Never refactor while red. Refactor only after all current tests pass.

## Planning Checklist

Before implementation, identify:

- The public interface or highest reliable seam to test
- The behaviors that matter most to acceptance criteria
- Existing test patterns to follow
- Any missing seam that makes correct testing difficult

Ask the user when the interface or priority of behaviors is unclear.

## Red-Green-Refactor Loop

For each behavior:

1. **Red:** write one focused failing test for observable behavior
2. **Green:** add the smallest production change that passes the test
3. **Repeat:** move to the next behavior only after the current test passes
4. **Refactor:** clean duplication and deepen modules after all relevant behavior is green

Good test names read like specifications, for example `user can checkout with a valid cart`.

## Bad Test Smells

- Mocking internal collaborators instead of using the public seam
- Testing private methods
- Asserting exact implementation steps instead of outcomes
- Querying storage directly when a public read interface exists
- Failing after a harmless internal refactor

If the only available test seam is too shallow or too coupled, state that explicitly. It may be an architecture finding rather than a testing problem.

## Per-Cycle Checklist

- The test describes one observable behavior
- The test fails for the expected reason before implementation
- The implementation is minimal and non-speculative
- The test passes after the implementation
- Existing tests still pass
- Refactors happen only after green
