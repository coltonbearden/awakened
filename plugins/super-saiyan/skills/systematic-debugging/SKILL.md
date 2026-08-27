---
name: systematic-debugging
description: Root-cause-first discipline for any bug, failing test, build failure, or unexpected behaviour. Use before proposing any fix, especially under time pressure or after a previous fix did not hold. Reproduces, traces the bad value to its origin, compares against working code, tests one hypothesis at a time, and stops to question the design after three failed fixes.
allowed-tools: [Read, Grep, Glob, Edit]
---

# Systematic Debugging

## Purpose

A fix applied before the cause is understood is a guess, and guesses compound. This skill orders the work so that
the fix comes last: understand, compare, hypothesize, then change one thing. It contains the tracing and bisection
procedures inline so nothing needs a script. It does not build the reproduction harness — `diagnosing-bugs` covers
that when a bug resists a simple repro — and it hands the fix itself to `test-driven-development`.

## Trigger Conditions

Use this skill for test failures, production bugs, build breaks, integration failures, performance problems, and
any behaviour that does not match expectation. Use it most deliberately when the fix "seems obvious", when time is
short, and when earlier fixes did not work.

Do not skip it because the bug looks simple; simple bugs have root causes and the process is fast for them.

## Workflow

1. Investigate before touching anything. Read the full error and stack trace; note file, line, and code. Reproduce
   the failure on demand with exact steps — if it cannot be reproduced, gather more evidence rather than guessing.
   Check what changed recently: diff, commits, dependency and configuration changes, environment differences.
2. Trace the bad value to its origin. Start at the failure and walk backwards: what produced this value, what
   called that, what supplied its input. Continue until the first place the data is wrong. The fix belongs there,
   not where the symptom surfaced. In a multi-component path, log what enters and leaves each boundary once, run
   once, and read where the data first goes wrong before reasoning further.
3. Compare against something that works. Find similar code in the same codebase that behaves correctly, or read the
   reference implementation completely. List every difference, including the ones that "cannot matter". Note the
   dependencies, configuration, and assumptions the broken path relies on.
4. Form one hypothesis and state it: "the cause is X because Y". Test it with the smallest possible change, one
   variable at a time. If it does not hold, form a new hypothesis; do not stack a second change on the first.
5. Fix through a failing test. Write the smallest reproduction as a test, watch it fail, apply one change at the
   root cause, watch it pass, and run the surrounding suite. No bundled refactoring, no unrelated improvements.
6. Count the attempts. After a second failed fix, return to step 1 with what was learned. After a third, stop:
   when each fix reveals coupling in a new place, the design is the problem. Say so and discuss it with the user
   before trying a fourth.
7. Report the cause. State what the root cause was, how it was confirmed, and what the fix changed, so the next
   reader learns from it.

## Isolating a Polluting Test

When a suite fails or leaves state behind only in combination, bisect the test set instead of reading every test.
Confirm the polluted state is absent, run the first half of the test files, and check whether it appeared. Keep
the half that produced it and split again until one file remains; then apply the same halving inside that file's
tests. Each round takes one run, so even a large suite yields the culprit in a handful of runs. Record the pair
(polluter, victim) in the fix commit.

## Red Flags

Stop and return to step 1 when you notice any of: "quick fix now, investigate later"; "just try changing X"; several
changes made before one test run; a fix proposed before the data flow was traced; a sentence beginning "it is
probably"; and the user asking "is that not happening?" or "stop guessing".

## When No Root Cause Emerges

If the investigation genuinely ends at something environmental, timing-dependent, or external, document what was
examined, handle the condition explicitly (a bounded retry, a timeout, a clear error), and add the logging that
would answer the question next time. Most "no root cause" verdicts are an investigation that stopped early.

## Safety Checks

- Bash runs the project's own tests and read-only git commands; no installation, no network.
- Temporary diagnostic output carries a unique tag so a single search removes it before the work is reported.
- Redact secrets from any output shown; name their location and kind instead.

## Output Contract

Reproduction steps, the traced origin of the fault, the hypothesis and how it was tested, the failing-then-passing
test, the single change made, and the suite result.
