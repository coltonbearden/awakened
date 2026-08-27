---
name: finishing-a-development-branch
description: Closes out a feature branch once implementation is complete. Use when all tasks are done and the work must be integrated. Verifies the suite on the exact tree being handed over, confirms the base branch, offers merge, pull request, or keep as the only options, and cleans up only worktrees it created. Also sets up isolation and a baseline test run before a branch starts.
allowed-tools: [Read, Grep, Glob]
---

# Finishing a Development Branch

## Purpose

Integration is the user's decision; this skill makes that decision cheap and safe. It runs the tests on the tree
about to be integrated, establishes where the branch came from, presents a short menu, carries out the choice, and
cleans up after itself without touching anything it did not create. It also covers the mirror step at the start of
a branch — isolate the work and record a baseline — because a branch that began on a red suite cannot be finished
honestly. It does not review code and it does not resolve conflicts (`resolving-merge-conflicts` does).

## Trigger Conditions

Use this skill when the user asks to start a branch or a worktree for a piece of work, and again when implementation
is complete and the user asks to merge, open a pull request, or wrap up.

Do not use it to discard work on your own initiative, and never on the default branch without explicit consent.

## Before the Branch Starts

1. Confirm the current branch. If it is the default branch, propose a feature branch (or a worktree under the
   project's worktree directory if the project uses them) and create it only after the user agrees.
2. Run the full test suite once on the untouched tree and record the result. A pre-existing failure is reported now,
   so it is never mistaken later for something the branch introduced.

## Workflow at Completion

1. Verify on this tree. Run the project's full test suite now. If anything fails, show the failures and stop — the
   menu comes after green.
2. Detect the environment. Determine whether this checkout is an ordinary repository or a linked worktree, and
   whether HEAD is on a named branch or detached. Capture the worktree path before any directory change.
3. Confirm the base branch. It is whatever this work forked from — named in the plan, the conversation, or the
   branch's upstream. If unknown, ask: "this branch split from <best guess>, correct?" Merging into the wrong base
   is expensive to undo.
4. Present the menu and wait. On a named branch: merge locally into the base, push and open a pull request, or keep
   the branch as is. On a detached HEAD: push as a new branch and open a pull request, or keep as is. Nothing
   else is offered; discarding work happens only when the user asks for it in those words.
5. Carry out the choice. For a local merge: move to the main checkout, update the base, merge, rerun the suite on
   the merged result, and only if green delete the feature branch. A red merged result stops everything with the
   branch and worktree intact. For a pull request: push with upstream set, open the request against the base with
   the forge's CLI if present or the URL the push printed, follow the repository's template, and report the URL —
   the worktree stays for review feedback. For keep: report the branch name and path.
6. Clean up only what you own. Remove a worktree only if it sits under the project's worktree directory and the
   choice was a completed local merge or an explicit discard. If removal is refused because of uncommitted files,
   list them and ask whether to commit, move, or delete them; never force removal. Worktrees elsewhere belong to
   the host and stay.

## Rationalizations to Refuse

| Excuse | Reality |
|---|---|
| "Tests passed earlier in the session" | Only a run on the tree being integrated counts |
| "They obviously want it merged" | The user picks from the menu |
| "The push was rejected, force-push will fix it" | The remote moved; investigate, and force only on explicit request |
| "This stale worktree can go too" | Only worktrees this skill created are cleaned up |
| "The merged-result failure is probably flaky" | A red merged result stops the integration |

## Safety Checks

- Bash runs the project's test command and ordinary git commands. No history rewriting, no force operations, and
  no branch deletion except as the completed-merge step or an explicit, confirmed discard.
- Pushing and opening a pull request use the user's existing credentials and forge tooling; nothing is installed.

## Output Contract

The baseline or final suite result with its command, the detected environment and confirmed base, the menu, and
after the choice a report naming exactly what was merged, pushed, kept, or removed.
