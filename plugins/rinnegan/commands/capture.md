---
description: Write this session's memory to rinnegan's file store — a session note (Request, Completed, Learned) plus typed records appended to a searchable index — so a later session can recall what happened. Run at the end of a session or before a long break; safe to re-run, a second run appends nothing new.
argument-hint: "[session-title]"
allowed-tools: [Read, Grep, Glob, Write, "Bash(git log:*)", "Bash(git status:*)"]
---

# Capture Session Memory

Interpret `$ARGUMENTS` as the session title. If it is empty, derive a title from the user's first request.

**Writes go to exactly two places and nowhere else:** the user-level store at `${CLAUDE_PLUGIN_DATA}` (this
plugin's own data directory), and — only when the user has opted the project in — `<project-root>/.rinnegan/`.
The only shell commands this procedure runs are `git log` and `git status`, read-only, for the activity delta.

## Store Layout

```text
${CLAUDE_PLUGIN_DATA}/
├── projects.json                          # {"<key>": {"name","root","first_seen","last_session"}}
└── projects/<key>/
    ├── index.jsonl                        # append-only; one record per line; the searchable surface
    ├── sessions/<YYYY>/<MM>/<YYYY-MM-DD>--<session-id>.md
    └── decisions/<NNNN>-<slug>.md         # durable decisions, one file each
```

`index.jsonl` and `projects.json` are the source of truth; the session note is the generated, human-readable view.
An index line: `{"id","kind","session","title","tags","ref","hash"}` — `id` is an RFC-3339 UTC timestamp plus a
four-digit per-day counter; `kind` is one of `bugfix`, `feature`, `decision`, `discovery`, `change`, `summary`,
`prompt`; `title` is one sentence of at most 120 characters; `tags` are 0–6 kebab-case words; `ref` is the
store-relative path plus the `#<anchor>` of the record's heading; `hash` is defined in step 4.

## Procedure

1. **Resolve the project key.** Read `projects.json` and look the project up by its absolute `root` — never by
   recomputing. If absent, create the entry with key `<basename-of-root>-<first-12-hex-of-sha256(root)>`,
   `first_seen` now, and no `last_session`. Create missing directories.
2. **Project scope, only if opted in** (the user asked, or `.rinnegan/` already exists): `.rinnegan/.gitignore` must
   contain exactly `*`. Create it if missing; if it exists with different content, do not write to the project
   scope at all — say so and continue with the user-level store.
3. **Draft the session note** from the conversation: `Request` (the user's ask, in their framing), `Completed`
   (one bullet per thing that landed), `Learned` (one bullet per transferable pattern), then `Records` — one H3
   per typed record, `### <anchor> [<kind>] - <title>` followed by its body. Decisions meant to outlive the session
   also get a `decisions/<NNNN>-<slug>.md` file (next free number) and their `ref` points there. Never record a
   value from an environment variable, a `.env` file, or command output that looks like a credential — drop the
   record rather than redact it.
4. **Hash each record**: `hash = sha256(session + "\n" + title + "\n" + body)` truncated to 16 hex characters.
   The session id is the one the note carries; if the harness exposes none, use `s-<YYYYMMDD>-<HHMM>` of the
   session start and keep it for every re-run of the same session.
5. **Skip what is already stored.** Grep `index.jsonl` for `"session":"<session-id>"` and read the last 200
   lines. A record whose `hash` — or whose exact `session` and `title` pair — is already present is dropped.
6. **Append the survivors** to `index.jsonl`, one JSON object per line, in chronological order, without
   rewriting any existing line. Write the index before the note, so an interrupted run still leaves the
   searchable surface intact.
7. **Write the session note once** to `sessions/<YYYY>/<MM>/<date>--<session-id>.md`, with frontmatter
   `session`, `project`, `started`, `ended`, and an H1 that is the session title. A re-run overwrites this
   one path with the same content; it never creates a second note for the same session.
8. **Record the activity delta**: run `git log --oneline --since=<previous last_session.ended>` and
   `git status --short`, and put the commit list under `Completed` and any uncommitted paths under a
   `Working tree` line. Skip this step outside a git repository.
9. **Update `projects.json.last_session`** to `{"id","ended","note"}` for this session.

## Response Format

Report the store path written, the number of records appended and the number skipped as duplicates, the
decision files created, and whether the project scope was used. If any write failed, say which and continue —
memory failure never blocks the session.
