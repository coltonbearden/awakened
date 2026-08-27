---
name: parallel-execution-optimizer
description: Turn an urgent multi-part task into a lane matrix keyed on write-surface collisions, run the non-colliding lanes together, and finish with a verification table instead of a speed claim. Use when the user wants work done much faster through concurrent reads, batched checks, parallel subagents, or isolated worktrees, and correctness must not slip.
allowed-tools: [Read, Grep, Glob, Agent]
---

# Parallel Execution Optimizer

## Purpose

Speed comes from doing independent work at the same time; damage comes from doing colliding work at the same
time. This skill makes the difference explicit before anything runs: every lane of work is classified by what it
writes to, lanes whose write surfaces do not overlap run together, lanes that share a surface run in order, and
the report at the end shows what was verified rather than how fast it felt.

This skill schedules; it does not decide what the work is. Dispatch mechanics for independent investigations
live in `dispatching-parallel-agents`; per-task implementation loops live in `subagent-driven-development`.

## Trigger Conditions

Use this skill when a task fans out into repository scans, file reads, status checks, build or test lanes, and
implementation passes that could overlap, and the user has asked for speed. Use it before any large push that
touches more than one subsystem.

Do not use it for a single sequential change, and never apply it to destructive commands, migrations, writes to
one table or file from two lanes, or customer-facing deploys; those get an explicit gate, not concurrency.

## Workflow

1. **Write the objective and the done signal** in one line each. A lane that cannot be tied to the done signal
   is not a lane; drop it.
2. **Split the work into lanes** and build the matrix below. Every row needs a write surface, even if that
   surface is "none".
3. **Classify each lane** as parallel (no shared write surface), sequential (shares a surface with another
   lane), or gated (needs a human decision or evidence from another lane before it may start).
4. **Run the read-only lanes together**: batch file reads, searches, status checks, and metadata queries into
   the same response. Where a lane needs its own context, dispatch it as a session-scoped subagent through the
   Agent tool (`bankai:codebase-explorer` for repository scans, `bankai:code-reviewer` for a review lane) and
   issue the independent dispatches in one response; if no matching agent is available, run the lane inline.
5. **Keep writes isolated** by file, directory, branch, worktree, service, or dataset. Two lanes that would
   edit the same file are one lane.
6. **Re-plan on blockers.** When a lane learns something that changes the plan, pause the lanes that depend on
   it, amend the matrix, and only then continue.
7. **Merge on evidence**, not on completion: a lane is compatible with another when its verification column is
   filled in, not when it reports done.
8. **Report** in the output contract below.

## Lane Matrix

| Lane | Parallel? | Write surface | Risk | Verification |
|---|---|---|---|---|
| Repository scan | yes | none | low | search and status output |
| Backend patch | with frontend only | server source directory | medium | unit tests |
| Frontend patch | with backend only | component directory | medium | rendered check |
| Build and test | after both patches | build output | medium | exit status and log |
| Deploy readback | gated on build | remote service | high | live check and logs |

Lanes may run together only when their write-surface cells do not overlap.

## Boundaries on Time

Every lane finishes inside the turn that started it. No process this skill starts outlives the turn: no
detached jobs, no watchers, no polling loops left running for later. A long build or test lane is run
in the foreground, bounded by a timeout, and its result read before the turn ends; if it cannot finish inside
the turn, it is reported as an incomplete lane rather than left running. A subagent dispatched through the Agent
tool is session-scoped and ends with the session; that is the only concurrency this skill uses.

## Output Contract

1. **Lanes** — run, completed, and blocked, with the blocker named
2. **Fast path** — which batching or parallelism actually saved time
3. **Verification** — one line per lane: the check performed and its result; skipped checks are listed as
   skipped, never folded into a success summary
4. **Open items** — anything left incomplete when the turn ended

## Failure Modes

- Concurrency that produces conflicting edits because a write surface was left blank.
- Benchmarking the tooling instead of finishing the task.
- Calling the work done because it was fast, before the verification column is full.
- Hiding a skipped check behind a green summary.
