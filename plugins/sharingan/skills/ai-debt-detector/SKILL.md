---
name: ai-debt-detector
description: Audit recently generated or AI-assisted code for the debt patterns machine generation produces specifically, such as swallowed errors, resources opened without a cleanup path, unhandled edge inputs, imports and API methods that do not exist, and silent drift from the project's own conventions, and file each finding under a technical-debt category. Use after a generation session, before merging AI-written changes, when code works but feels brittle, or when an agent claims done without showing verification.
allowed-tools: [Read, Grep, Glob, "Bash(git diff:*)", "Bash(git log:*)"]
---

# AI Debt Detector

## Purpose

Generated code is optimised to look correct and pass the happy path. It leaves a characteristic residue: thin
failure handling, orphaned resources, invented dependencies, and conventions quietly ignored. This skill audits a
change for exactly that residue and classifies what it finds so the debt can be scheduled rather than forgotten.
It reports; the implementing workflow fixes. The only shell commands it runs are read-only `git diff` and
`git log` to locate the change.

## Trigger Conditions

Use after any generation session of more than a screen of code, before merging an AI-written PR, after a fast
iteration sprint, when something works but feels off, or when "done" arrived without evidence. Do not use it as a
general style review; that is the code-review surface.

## Workflow

1. **Locate the change** with `git diff` or the paths the user names, and read each changed file in full.
2. **Ask the five questions** below of every function, handler, and resource in the change. Check what is
   absent, not only what is present: the missing error path is the finding.
3. **Verify dependencies against the manifest.** Every import must exist in the lockfile or manifest and every
   called method must exist in the version pinned there; a plausible-sounding method is not evidence.
4. **Compare with the neighbours.** Read one or two existing modules doing similar work and note where the new
   code diverges in error style, utilities used, or file placement.
5. **File each finding** under a debt category and severity, with file, line, and the failure it would cause.

## The Five Questions

| Question | Look for |
|---|---|
| What happens when this fails? | timeouts, full disks, denied permissions, null input; catches that swallow |
| What is created and never released? | temp files, listeners, timers, subscriptions, connections with no close |
| What input breaks this? | empty, null, oversized, non-ASCII, concurrent calls; happy-path-only assumptions |
| Does every dependency exist? | packages missing from the manifest, methods missing from the pinned version |
| Does this match the project? | different error idiom, reinvented utility, file placed against convention |

## Red Flags

Any of these is a finding on sight: an empty catch or a catch that only logs; a resource opened with no
`finally` or equivalent; a comment deferring error handling to later; an import path that does not exist in the
tree; a timeout with no abort or cleanup when it fires; a connection taken from a pool and never returned.

## Debt Taxonomy

| Category | Typical finding here | Interest it charges |
|---|---|---|
| Code quality | swallowed errors, duplicated logic, deep nesting | every later change pays to understand it |
| Design | drift from the project's structure, reinvented abstractions | inconsistency spreads with each imitation |
| Test | happy-path-only tests, tests asserting mocks rather than behaviour | regressions arrive unannounced |
| Documentation | contracts and failure modes undocumented | the next author repeats the mistake |
| Dependency | hallucinated packages, deprecated or unpinned versions | build breaks and vulnerability exposure |
| Infrastructure | orphaned resources, missing cleanup in jobs and workers | leaks that surface only under load |
| Performance | unbounded input, repeated work in loops | cost that grows with usage |
| Security | unvalidated input on a boundary, credentials in generated config | exploitable on day one |

For each item record whether the debt was deliberate (a known shortcut) or inadvertent (the generator did not
know better); the fix differs, and so does what the team should learn.

## Safety Checks

- Compilation proves syntax, not logic; a green build is not evidence against any of the five questions.
- Garbage collection does not release connections, listeners, or timers; never skip the orphan check on that
  basis.
- Read-only: no edits, no installs, no network; credentials found are cited by location only.

## Output Contract

1. **Scope** — files audited and the range they came from
2. **Findings** — each with category, severity, deliberate or inadvertent, file and line, failure mode, direction
3. **Not verifiable here** — dependency versions or runtime behaviour that need a build or a run to confirm
