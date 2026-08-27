---
description: Commit a described subset of the working tree: show the staging plan and message, get a yes, commit locally. Never force, never push. Use when you can say in words what belongs in the next commit.
argument-hint: "[what-to-commit]"
allowed-tools: [Bash(git:*), Read]
---

# Commit

Interpret `$ARGUMENTS` as a description of which changes belong in this commit. If it is empty, propose all
changes and say so explicitly in the staging plan.

## Procedure

1. Run `git status --short`. If nothing is changed, say "Nothing to commit." and stop.
2. Resolve the description into a file list:

   | Description | Resolution |
   |---|---|
   | empty | every changed and untracked file |
   | `staged` | whatever is already staged; no further `git add` |
   | a glob such as `*.py` | matching changed files |
   | `except <thing>` | everything, minus files matching the thing |
   | `only new files` | untracked files only |
   | natural language | files whose path or diff relates to the words, judged from `git status` and `git diff` |
   | explicit paths | those paths |

3. Classify the blast radius of the candidate set: Small (one or two files, no interface change), Medium (several
   files or a shared interface), Large (schema, public contract, migration, generated files, or lockfiles).
4. Draft one commit line, imperative mood, under 72 characters, in the form `type: what changed` using `feat`,
   `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, or `ci`. Describe what, not how.
5. Show the staging plan before touching the index: each file with its status, why it matched, the files left out,
   the blast-radius size, and the proposed message. For Large sets also list what a reviewer should look at
   first. Then ask for confirmation and wait. This is the commit gate: nothing is staged or committed without a
   yes in the conversation.
6. On yes: `git add` the listed files, verify with `git diff --cached --stat`, and if the staged set is empty stop
   with "No files matched your description." Otherwise `git commit -m "<message>"`.
7. Report the short hash, the message, and the file count. Suggest a review or a push as the user's next move —
   this command never pushes.

## Guardrails

- No `--force`, `--no-verify`, `--amend`, or history rewriting of any kind.
- If a candidate file looks like a credential, a key, or a local environment file, exclude it, say why, and let
  the user decide.
- If hooks configured by the project reject the commit, show their output and stop; do not bypass them.
