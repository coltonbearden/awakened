---
description: Write a reviewed handoff file — goal, what worked with evidence, what failed and why, file states, next step — into the plugin's data directory. Use before closing a session, before a context reset, or after solving something worth keeping.
argument-hint: "[slug] [as <alias>]"
allowed-tools: [Read, Write, Grep, Glob, Bash(git status:*), Bash(git log:*), Bash(git diff:*), Bash(git rev-parse:*)]
---

# Save Session

Interpret `$ARGUMENTS` as an optional slug for the file name and, after the word `as`, an optional alias such as
`auth` or `wip`. If `$ARGUMENTS` is empty, derive a two-to-four-word slug from the session topic and use no alias.

Files live in the plugin's data directory, `${CLAUDE_PLUGIN_DATA}/sessions/`. The naming rule is
`<YYYY-MM-DD>--<slug>.md` — today's date, two hyphens, a lowercase kebab-case slug. If that name already exists,
append `-2`, `-3`, and so on; a session file is never appended to or overwritten. `index.md` in the same directory
is the session index: one table row per file with date, slug, alias, project, branch, worktree, and path.

## Procedure

1. Gather: the files touched (`git status --short`, `git diff --stat`, and the conversation), the branch
   (`git rev-parse --abbrev-ref HEAD`), the worktree root (`git rev-parse --show-toplevel`), and every attempt,
   error, and decision the session produced.
2. Draft the file in the format below, in the reply — not yet on disk. Every section is filled; a section with
   nothing to say gets one honest line such as "nothing confirmed yet" rather than being dropped. Where a plan,
   design note, checkpoint log, or decision record already exists on disk, cite its path instead of restating it.
3. Redact: read the draft for anything credential-shaped — tokens, keys, passwords, connection strings with
   passwords, private URLs — and replace each with its location and kind (`<token in .env, line 4>`). A handoff is
   a file the user reviews and keeps; it is never handed to a background process or any other runtime.
4. Ask "Save this as `<name>`? Anything to correct first?" and wait. Apply corrections. Only after a yes, write
   the file and add or update the index row. Report the final path.
5. Optionally name `/rinnegan:capture` for durable, searchable memory if that plugin is installed. Nothing here
   depends on it.

## Session File Format

```markdown
# Session <YYYY-MM-DD> — <topic>
Project: <name>  Branch: <branch>  Worktree: <root>  Alias: <alias or none>
## Goal
## Worked — with evidence (each item: what, and the observation proving it)
## Failed — and why (each item: what was tried, the exact error or reason)
## Not yet tried
## File states (table: path | complete / in progress / broken / untouched | note)
## Decisions (each: choice — reason)
## Blockers and open questions
## Exact next step (one action, precise enough to start on cold)
## Related artifacts (paths only) and suggested skills for the next session
## Environment notes (only when non-standard)
```
