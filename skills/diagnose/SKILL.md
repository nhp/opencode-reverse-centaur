---
name: diagnose
description: Disciplined debugging loop for bugs, failing tests, and performance regressions. Use when the user says diagnose/debug, pastes an error, reports broken behavior, or asks for root-cause analysis.
---

# Diagnose

Use this skill for hard bugs. Do not jump straight to speculative fixes. Skip a phase only when explicitly justified.

If `CONTEXT.md` exists, read it first and use its vocabulary. Check relevant memory decisions before changing behavior.

## Phase 1: Build a Feedback Loop

This is the core discipline. A fast deterministic pass/fail signal makes the bug tractable.

Try feedback loops in this order:

1. Failing test at the seam that reaches the bug
2. Curl or HTTP script against a dev server
3. CLI invocation with fixture input and expected output
4. Headless browser script that asserts DOM, console, or network state
5. Replay captured trace, payload, event log, or request
6. Throwaway harness around the smallest executable subsystem
7. Property or fuzz loop for intermittent wrong output
8. Bisection harness for commit, data, or version regressions
9. Differential loop comparing old/new versions or configs
10. HITL bash script when a human must perform the trigger

Improve the loop before moving on:
- Faster: cache setup and narrow scope
- Sharper: assert the exact user-reported symptom
- More deterministic: pin time, seed randomness, isolate filesystem/network

For non-deterministic bugs, raise the reproduction rate. Loop 100 times, parallelize, stress, add sleeps, or narrow timing windows.

If no loop can be built, stop. List what was tried and ask the user for access, logs, HAR files, core dumps, screen recordings with timestamps, or permission for temporary instrumentation.

## Phase 2: Reproduce

Run the loop and confirm:

- It catches the same failure mode the user described
- It reproduces across multiple runs, or often enough for flaky bugs
- The exact symptom is captured for later verification

Do not continue until the bug is reproduced.

## Phase 3: Hypothesize

Generate 3-5 ranked, falsifiable hypotheses before testing any one idea.

Use this format:

> If X is the cause, then changing Y will make the bug disappear or changing Z will make it worse.

Discard hypotheses that cannot make a prediction. Show the ranked list to the user when practical; proceed if they are AFK.

## Phase 4: Instrument

Each probe must map to a prediction from Phase 3. Change one variable at a time.

Tool preference:

1. Debugger or REPL inspection
2. Targeted logs at boundaries that distinguish hypotheses
3. Never "log everything and grep"

Tag every temporary log with a unique prefix like `[DEBUG-a4f2]` so cleanup is a single search.

For performance regressions, establish a baseline first with a timing harness, profiler, query plan, or browser performance trace. Measure before fixing.

## Phase 5: Fix and Regression Test

Write the regression test before the fix when a correct seam exists.

A correct seam exercises the real bug pattern as it occurs at the call site. If the only available seam is too shallow, that is itself a finding: the architecture prevents a reliable regression test.

If a correct seam exists:

1. Turn the minimized repro into a failing test
2. Watch it fail
3. Apply the smallest correct fix
4. Watch it pass
5. Re-run the original feedback loop

## Phase 6: Cleanup and Post-Mortem

Before declaring done:

- Original repro no longer reproduces
- Regression test passes, or missing seam is documented
- All `[DEBUG-...]` instrumentation is removed
- Throwaway harnesses are deleted or clearly marked
- The true root cause is stated in the final summary or commit message

Ask what would have prevented the bug. If the answer is missing locality, weak seams, or tangled callers, suggest `/improve-codebase-architecture`. If the finding will matter later, suggest `/memory capture TICKET-ID` after merge.
