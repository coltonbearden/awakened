---
name: diagnosing-bugs
description: Feedback-loop-first diagnosis for hard bugs, flaky failures, and performance regressions. Use when the user says diagnose or debug, or reports something broken, throwing, failing, or slow and no reliable reproduction exists yet. Builds one fast command that goes red on this exact bug, shrinks the repro, ranks hypotheses, instruments narrowly, fixes with a regression test, and cleans up.
allowed-tools: [Read, Grep, Glob, Edit, Write]
---

# Diagnosing Bugs

## Purpose

Hard bugs are hard because there is no tight signal. This skill spends its effort on building that signal — a single
command that turns red on the user's exact symptom and green when it is fixed — and treats everything after as
mechanical. It complements `systematic-debugging`, which orders the reasoning; this skill supplies the loop the
reasoning runs against.

## Trigger Conditions

Use this skill when a bug resists a straightforward reproduction: intermittent, environment-dependent, deep in a
call chain, or a performance regression with no obvious cause.

Do not use it for failures a single existing test already isolates; go straight to `systematic-debugging`.

## Workflow

1. Redact first. Every command, output, or captured artifact you show has secrets replaced by a placeholder. Build
   loops that read credentials from the environment so the value never appears in what you display. If the
   redacted output is too thin to diagnose from, say so and ask.
2. Build the feedback loop. Try, in roughly this order: a failing test at whatever seam reaches the bug; an HTTP
   call against a running dev server; a CLI run on a fixture, diffed against a known-good output; a headless browser
   script; replaying a captured payload or event log through the code path; a throwaway harness that calls the
   code path directly; a fuzz loop over random inputs; a bisection loop over commits or versions; a differential run
   of old versus new. The loop is done when you can name one command you have already run whose output you can
   show, that asserts the user's exact symptom, gives the same verdict every run, and finishes in seconds.
3. Tighten it. Cache setup, skip unrelated initialisation, assert the specific symptom rather than "did not crash",
   pin time and random seeds, isolate the filesystem. For intermittent bugs, raise the reproduction rate — loop the
   trigger, add concurrency, narrow timing windows — until it is high enough to work against.
4. If a human must be in the loop, structure it anyway. Write down the exact manual step, what to observe, and what
   to paste back; ask for one round at a time; and treat the pasted, redacted output as the loop's result. If no
   loop can be built at all, stop, list what was tried, and ask the user for a reproducing environment, a redacted
   capture, or permission to add temporary instrumentation. Do not hypothesize without a loop.
5. Reproduce and minimise. Watch the loop go red and confirm it is the user's failure, not a neighbour. Then remove
   inputs, callers, configuration, and steps one at a time, re-running after each cut, until every remaining
   element is load-bearing.
6. Hypothesize. Write three to five ranked, falsifiable hypotheses, each with the prediction it makes. Show the list
   to the user — they often re-rank it instantly — but proceed with your ranking if they are not around.
7. Instrument narrowly. Each probe tests one prediction and changes one variable. Prefer a debugger or REPL to
   logs; prefer targeted logs at the boundaries that separate hypotheses to logging everything. Tag every temporary
   log with a unique marker. For performance work, measure a baseline first and bisect — logs are usually the wrong
   tool.
8. Fix with a regression test. If a seam exists where the test exercises the real bug pattern, write the test,
   watch it fail, fix, watch it pass, then rerun the original un-minimised loop. If no honest seam exists, that is
   itself a finding: record it rather than writing a test that gives false confidence.
9. Clean up. Original loop green; regression test in place or its absence documented; every tagged log removed
   (search the tag); throwaway harnesses deleted or clearly marked; the confirmed cause stated in the commit
   message.

## Safety Checks

- Bash runs the project's own tests, dev server, and scripts; no installation, no network beyond the project's own
  local services, no process left running after the turn.
- Writes are confined to the project directory, and throwaway harnesses are named so nobody mistakes them for
  production code (C-3).
- Never show a secret; never add instrumentation to production without the user's explicit authorization.

## Output Contract

The loop command and its output, the minimised reproduction, the ranked hypotheses, the confirmed cause, the
regression test's red and green runs, and the cleanup checklist with each item ticked or explained.
