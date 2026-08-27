---
description: Write failing tests for a described behaviour in the project's own conventions, run them, and confirm each fails for the intended reason before any production code exists. Use to start a TDD cycle.
argument-hint: "[feature-or-component-to-test]"
allowed-tools: [Read, Grep, Glob, Write, Edit]
---

# TDD Red

Interpret `$ARGUMENTS` as the behaviour to specify with tests. If it is empty, ask in one line what behaviour to
test and stop.

Work inline. Do not dispatch a subagent or enter plan mode; write the tests directly.

## Rules

1. Tests only. Do not create or edit production code in this phase, not even a stub, unless the test cannot
   import without it — and then say so.
2. Every new test must fail when run. A test that passes immediately is investigated and rewritten.
3. Failures must be for the right reason — an assertion about behaviour, not a syntax or import error. Halt and
   show the user if generation itself is broken.
4. Match the project: same framework, file location, naming, fixtures, and assertion style as neighbouring tests.
5. One behaviour per test, arrange-act-assert, names that read as a sentence about intent, realistic data rather
   than placeholder strings.

## Procedure

1. Read one or two existing tests closest to the target to learn the conventions. Identify the test command
   from the project manifest.
2. Enumerate the behaviours to specify: the main path, boundaries (empty, single element, limits), invalid input
   and error handling, state transitions, and concurrency where the design has it. Skip categories that do not
   apply and say which.
3. Write the tests. Keep setup small and independent; no test depends on another's side effects.
4. Run the new tests with the project's own runner. Confirm every one fails, and that each failure message would
   help a reader understand the missing behaviour.

## Response Format

| Section | Contents |
|---|---|
| Tests | Each test file with the behaviours it covers and the count |
| Run | The exact command used and the failure output summarised, one line per test |
| Next | The command to re-run in the green phase, and any stub the green phase must create first |
