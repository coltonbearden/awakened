---
description: Create, compare, or list named checkpoints — a git SHA plus a log line in the project — so later work can be measured against a known-good point. Use at the start of a feature, after a slice is proven, and before a refactor.
argument-hint: "[create <name> | compare <name> | list]"
allowed-tools:
  - Read
  - Write
  - Grep
  - Glob
  - Bash(git status:*)
  - Bash(git log:*)
  - Bash(git diff:*)
  - Bash(git rev-parse:*)
  - Bash(git stash:*)
---

# Checkpoint

Interpret `$ARGUMENTS` as a subcommand and an optional name. If `$ARGUMENTS` is empty, behave as `list`.
The log is `.claude/checkpoints.log` at the project root, one line per checkpoint:
`<YYYY-MM-DD HH:MM> | <name> | <short SHA> | <clean|dirty> | <verification note>`.

## Procedure

### create

1. Read the working tree with `git status --short` and `git rev-parse --short HEAD`. Nothing else runs; this
   command never executes tests. The verification note is whatever evidence the conversation already holds — a test
   run the user performed, a build that passed — or `unverified` when there is none. Say which it is; never invent
   a check that was not observed.
2. If the tree is dirty, present the choice: record the checkpoint against the current commit with the dirty files
   listed, or stash so the SHA alone describes the state. Run `git stash` only after the user answers yes to that
   exact question, and only for that one stash. Committing is the user's own step: if they want the checkpoint to
   sit on a fresh commit, they commit first and run `create` again.
3. Append the log line and report it back. Create the log file on first use.
4. When this is the first checkpoint on the branch and the goal is a multi-part feature, offer a decomposition into
   two to five thin end-to-end slices — each one touches every layer the feature needs, each one is demonstrable on
   its own, and each one becomes the name of a future checkpoint. Record accepted slice names as `planned` lines in
   the log. This is a checkpoint plan, not a project plan and not a ticket in any tracker.

### compare

1. Find the named line in the log; report clearly if it is absent and stop.
2. Run `git diff --stat <sha>..HEAD` and `git status --short` to list files added, modified, and removed since
   the checkpoint, plus whatever is uncommitted now.
3. Set the recorded verification note beside the current one — again only from evidence already present.

### list

Show every line with a status column: `current` when the SHA equals `HEAD`, `behind` when `HEAD` descends from it,
`planned` for slices not yet reached, `unknown` otherwise (use `git log --oneline <sha>..HEAD` to decide).

## Response Format

```text
CHECKPOINT <create|compare|list>: <name or "all">
Commit:        <short SHA>  (<clean|dirty: N files>)
Since then:    <added/modified/removed counts, or "n/a">
Verification:  then=<note>  now=<note>
Next slice:    <planned name, or "none recorded">
```
