---
description: Turn a request or PRD into a grounded plan: mandatory reading, what is NOT built, six to ten atomic tasks, validation, risks, blast-radius size; then wait for approval. Use before any multi-file change.
argument-hint: "[feature-description | path/to/name.prd.md]"
allowed-tools: [Read, Grep, Glob, Write, Edit]
---

# Plan

Run entirely inline. Do not dispatch a subagent; this command must work with nothing but the repository in front
of it. It writes no code — it produces a plan and stops.

## Input Modes

| `$ARGUMENTS` | Behaviour |
|---|---|
| Path ending in `.prd.md` | Read it, pick the first `pending` milestone, write `.claude/plans/<name>.plan.md` |
| Any other file path | Read it as context and present the plan inline |
| Free text | Present the plan inline |
| Empty | Ask in one line what should be planned, then stop |

## Procedure

1. Restate the requirement in your own words: what must be true when the work is done, and for whom.
2. Ask at most one or two questions, and only if the answer would change the plan. Otherwise proceed and record
   your assumptions in the plan.
3. Understand the existing code before designing. Search for the conventions the change must mirror — naming,
   error handling, logging, data access, test layout — and cite one concrete example per category as
   `path:line`. If no precedent exists, say so; never invent one.
4. Classify the blast radius and state it:

   | Size | Meaning |
   |---|---|
   | Small | One or two files, no interface or schema change, existing tests cover the area |
   | Medium | Several files or one shared interface; new tests needed |
   | Large | Cross-cutting, a schema or public contract, a migration, or anything hard to reverse |

   Medium and Large plans must name a rollback path. Large plans should propose splitting.
5. Write the plan with the sections below. Tasks are atomic, ordered, verb-first, and number six to ten; each
   names the pattern it mirrors and the command that proves it done.
6. Present the plan (or its path) and stop. This is the first human gate: wait for an explicit approval in the
   conversation before any file other than the plan is touched. The second gate sits before the commit; state
   that it will be applied by `/super-saiyan:commit`.
7. In PRD mode, after approval only, set the chosen milestone's status to `in-progress` and its plan cell to the
   plan path. Change nothing else in the PRD.

## Plan Sections

| Section | Contents |
|---|---|
| Summary | Two or three sentences plus the blast-radius size |
| Mandatory Reading | Files anyone executing this plan must read first, each with one line on why |
| NOT Building | Adjacent work explicitly excluded, so scope cannot drift silently |
| Patterns to Mirror | Category, `path:line`, short description |
| Files to Change | Path, create/update/delete, reason |
| Tasks | Six to ten numbered, verb-first steps: action, pattern to mirror, validation command |
| Validation | The project's own commands that prove the whole change, run in order |
| Risks | Risk, likelihood, mitigation — and the rollback path for Medium or Large |
| Acceptance | Checklist: all tasks done, validation green, patterns mirrored, nothing from NOT Building crept in |

## Worked Example

`/super-saiyan:plan add a --dry-run flag to the export command` yields a Small plan: Mandatory Reading lists the
command's entry file and its existing test; NOT Building states that no other command gains the flag; the tasks
add the flag, thread it to the writer, skip the write when set, extend the existing test, and run the project's
test command. The reply ends by asking for approval and waits.
