---
description: Make the failing tests pass with the least production code that could work, running the suite after every change and stopping on any regression. Use right after a red phase.
argument-hint: "[failing-tests-or-test-file-paths]"
allowed-tools: [Read, Grep, Glob, Edit, Write]
---

# TDD Green

Interpret `$ARGUMENTS` as the failing tests to satisfy — paths, names, or a description. If it is empty, run the
project's test command, treat every failing test as the target, and say so.

Work inline. Do not dispatch a subagent or enter plan mode; do the implementation directly.

## Rules

1. Write only what the failing tests demand. No extra features, options, optimisations, or error handling that
   no test asks for.
2. Run the tests after every change. Never batch several edits and hope.
3. Stop on failure. If the targeted tests stay red after an honest attempt, or any previously passing test
   breaks, halt and show the user the error rather than pushing on.
4. Do not touch the tests to make them pass. If a test looks wrong, say why and ask.
5. Keep the code readable but do not refactor yet; that is the next phase.

## Procedure

1. Read each failing test and its error output. Identify the smallest change that would satisfy it.
2. Take the tests one at a time, simplest first. Prefer, in order: a hard-coded return when one test alone
   drives it, the obvious implementation when it is trivial, and generalisation only when a second test forces
   it.
3. After each test turns green, run the whole suite using the project's own test command.
4. Note every shortcut, duplication, or assumption you took so the refactor phase can address it.

## Response Format

| Section | Contents |
|---|---|
| Result | Test command run and the final pass/fail counts |
| Changes | Each file edited and the behaviour it now satisfies |
| Debt | Shortcuts and duplication left for the refactor phase |
| Halted | Present only if a rule triggered a stop: the error and what the user must decide |
