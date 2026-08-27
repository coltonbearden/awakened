---
description: Review uncommitted local changes, or a GitHub pull request given by number or URL, across seven quality categories and return severity-ranked findings with a merge decision. Use before committing, before opening or merging a PR, or when asked to review a PR. Works fully offline; GitHub access is optional.
argument-hint: "[pr-number | pr-url | blank for the local working tree]"
allowed-tools: [Read, Grep, Glob, "Bash(git diff:*)", "Bash(git status:*)", "Bash(git log:*)", "Bash(gh pr view:*)", "Bash(gh pr diff:*)"]
---

# Code Review

Interpret `$ARGUMENTS` as the review target. Empty means **local mode**: the uncommitted working tree. A bare
integer, or a URL of exactly the form `https://github.com/<owner>/<repo>/pull/<N>`, means **PR mode**. Anything
else (extra words, a branch name, a non-PR URL, shell metacharacters) is rejected: stop, quote the input, and ask
for a PR number or a matching URL. Never interpolate an unvalidated argument into a command.

This command analyses; it never edits source, runs a test suite, installs anything, or posts to GitHub. The only
shell commands it runs are read-only `git diff`, `git status`, `git log`, and, in PR mode, `gh pr view` and
`gh pr diff`. If `gh` is absent, not authenticated, or the PR cannot be resolved, say so and continue in local
mode against the checked-out branch, marking the review as local-only.

## Procedure

1. Resolve the target. Local: `git diff --name-only HEAD` plus untracked files from `git status --short`; if empty,
   report "nothing to review" and stop. PR: `gh pr view <N>` for title, body, base, head, and draft state, then
   `gh pr diff <N>`. When the PR branch is checked out locally, prefer reading files from disk.
2. Build context: read `CLAUDE.md`, contributing guidelines, and any planning notes under `.claude/` or `docs/`
   that name the change. Extract the stated intent and test plan from the PR body when one exists.
3. Read every changed file in full, not only the hunks. Classify files as source, test, config, or docs; on a very
   large change (more than about fifty files) say so and review source first, then tests, then the rest.
4. Apply the checklist. Report a finding only when you would stake at least 80 percent confidence on it; anything
   weaker goes under Uncertainties, never into the decision.

| Category | Looks for |
|---|---|
| Correctness | logic errors, boundary and null handling, ordering and concurrency assumptions |
| Type safety | unsafe casts, escape hatches, mismatched contracts between caller and callee |
| Convention | departures from the project's own naming, structure, error, and import patterns |
| Security | injection, missing authorisation, credential exposure, request forgery, path traversal |
| Performance | repeated queries in loops, unbounded growth, missing limits on external input |
| Completeness | untested behaviour, missing error paths, half-finished migrations or docs |
| Maintainability | dead code, magic values, deep nesting, names that hide intent |

Severity: **Critical** (exploitable or data-losing), **High** (a bug likely to surface), **Medium** (quality or
missing practice), **Low** (style).

## Decision

| Condition | Decision |
|---|---|
| No Critical or High findings | Approve, with any Medium and Low items as comments |
| Any High finding | Request changes |
| Any Critical finding | Block; a security finding is never approved away |
| Draft PR, or the review could not run in full | Comment only |

Fail closed: when the diff could not be read completely, `gh` failed part-way, or a category was skipped, the
decision is Comment and the report names what did not run. Never present a clean approval for a partial review.

## Response Format

Return, in order: **Scope** (mode, target, files reviewed, what was skipped and why), **Findings** grouped by
severity with file, line, evidence, impact, and a corrective direction, **Uncertainties** (sub-threshold items
and questions for the author), **Validation not run** (the project's own type-check, lint, and test commands the
user should run), and **Decision** with the tally per severity. If the user asks for a saved artifact, write it to
`.claude/reviews/<local-or-pr-N>-review.md` in the project directory and nowhere else.
