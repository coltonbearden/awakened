---
name: test-driven-development
description: The red-green-refactor loop for any feature, bug fix, or behaviour change. Use before writing implementation code, when fixing a bug, or when changing code that has tests. Writes one failing test, confirms it fails for the right reason, writes the minimal code to pass, confirms green, then cleans up — and treats untested legacy code and existing tests as the first step, not an afterthought.
allowed-tools: [Read, Grep, Glob, Edit, Write]
---

# Test-Driven Development

## Purpose

If you never watched a test fail, you do not know that it tests anything. This skill enforces the order: failing
test first, minimal code second, cleanup third, one behaviour per cycle. It adds two rules for real codebases —
update the tests that already describe the behaviour before changing it, and put characterization tests around
legacy code before touching it. It does not choose which seams to test (`testing-at-seams` does) and it does not
diagnose failures (`systematic-debugging` does).

## Trigger Conditions

Use this skill for new features, bug fixes, refactors, and any change in observable behaviour.

Do not use it for throwaway prototypes, generated code, or pure configuration — but say so and get the user's
agreement rather than deciding alone. "Skipping TDD just this once" is the rationalization the skill exists to catch.

## Workflow

1. Find the existing tests first. Search for tests that already cover the code you are about to change. If the
   requested change alters behaviour those tests assert, update those tests first so they describe the new
   behaviour and fail; that is the difference between a fix and a tweak. If nothing covers the code and it is
   legacy, write characterization tests that pin the current behaviour, run them green, and only then begin.
2. Red. Write one minimal test for one behaviour, named for what the code should do, exercising real code rather
   than a mock of it. Run only that test. Confirm it fails — not errors — and fails because the feature is missing,
   with the message you expected. A test that passes immediately is testing behaviour that already exists; fix the
   test.
3. Green. Write the simplest code that makes the test pass. No extra parameters, no configurability, no "while I am
   here". Run the test and the surrounding suite; confirm the new test passes, nothing else broke, and the output
   is clean of warnings. If the test still fails, change the code, not the test.
4. Refactor. With everything green, remove duplication, improve names, extract helpers. No new behaviour. Rerun the
   suite after each refactor step.
5. Repeat for the next behaviour. Vertical slices: one test, one implementation, learn, next.
6. If code was written before its test: delete it and start from the test. Keeping it "as reference" turns into
   testing after, which proves nothing.

## What a Good Test Looks Like

| Quality | Good | Bad |
|---|---|---|
| Scope | One behaviour; an "and" in the name means two tests | One test for validation, formatting, and saving |
| Name | Reads as a specification of behaviour | A number or the function name |
| Subject | Real code through its public interface | Assertions about how a mock was called |
| Expected value | From an independent source: a known literal, the spec | Recomputed the way the code computes it |
| Failure | You can name the production change that would make it fail | It cannot fail |

## Rationalizations to Refuse

| Excuse | Reality |
|---|---|
| "Too simple to test" | Simple code breaks; the test costs a minute |
| "I will add tests after" | Tests written after pass at once and prove nothing |
| "I tested it by hand" | Unrecorded, unrepeatable, and forgotten under pressure |
| "The existing code has no tests" | Then characterization tests come first — that is the improvement |
| "Deleting the code I wrote wastes hours" | The hours are spent either way; keeping untrusted code is the waste |

## Safety Checks

- Bash runs the project's own test command and nothing else; no installation, no network.
- Writes are limited to the test files and the implementation files the change requires (C-3).
- Never put real credentials or production data into fixtures.

## Output Contract

For each cycle: the test written, the failing run and its message, the minimal change, the passing run, and any
refactor. At the end, the full-suite result.
