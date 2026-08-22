# claude-mem Rebuild — File-Based Memory Design for `rinnegan`

**Status:** Phase-3 design of record. Produced by the `SPEC.md` §10 Phase-3 exit criterion
("file-based rebuild design written to `eval/claude-mem-rebuild.md`") and checked against
`ROADMAP.md` V3.5–V3.7.

**Source read:** `thedotmack/claude-mem` at the `upstream.json` pinned commit
`fae697a45d107aae567d605916391ab64d8ecae1`, verified by `git rev-parse HEAD` against the pin before
any file was read. Evidence paths: `docs/architecture-overview.md`, `plugin/hooks/hooks.json`,
`plugin/.mcp.json`, `plugin/.claude-plugin/plugin.json`, `plugin/skills/mem-search/SKILL.md`,
`plugin/skills/cloud-sync/SKILL.md`, `package.json`.

**Relationship to the matrix.** Two rows, which is `eval/rubric.md` §7 Example A met in the field:

| `id` | Verdict | Meaning |
|---|---|---|
| `claude-mem/memory-hooks` | `reject` (`HR-1,HR-2,HR-4,HR-5,HR-6`) | The shipped implementation. Triage entry T-063. |
| `claude-mem/session-memory` | `shortlist`, `component_type = concept`, `target_plugin = rinnegan` | This document. |

**This is a design, not an implementation.** Nothing here is built until Phase 6, and Phase 6 is
barred until the G5 reviewer approves and the owner acknowledges it (`SPEC.md` §10 Phase 5, D-25).

---

## 1. Concept Inventory

What is worth taking from claude-mem, stated as capabilities rather than as its architecture.

| # | Concept | Why it survives |
|---|---|---|
| C1 | **Session memory** — each working session leaves a durable, readable record | The recurring failure claude-mem exists to fix: re-explaining the project every session |
| C2 | **Typed observations** — each record carries a kind (`bugfix`, `feature`, `decision`, `discovery`, `change`) | Typing is what makes later filtering cheap; it costs one field at write time |
| C3 | **Session summary** — `request` / `learned` / `completed` per session | The compressed unit a later session actually reads |
| C4 | **Prompt history** — what the user asked, in order | Answers "what were we doing?" when the summary is too coarse |
| C5 | **Searchable history with a filter-first discipline** — search returns an index, not bodies | `mem-search` calls it a 10x token saving; the index/body split is the whole trick |
| C6 | **Timeline around an anchor** — N records before and after a hit | Turns a match into context without reading a whole session |
| C7 | **Content-hash deduplication** | Makes capture idempotent, which C-1 requires of any hook |
| C8 | **Never block the host session** — a memory failure degrades, it does not stop work | claude-mem's own `hook-command.ts` rule; `CLAUDE.md` §6.4 requires the same |

Two more concepts are re-donated from ECC skills rejected in the same phase, and are folded in below:

- **`ecc/unified-memory` (T-060)** — portable Markdown memory documents rather than
  harness-specific transcripts; an explicit `project` / `team` / `user` scope split; recall
  before writing so the store does not accumulate duplicates; a fail-closed guard on the
  project scope so memories are never committed by accident.
- **`ecc/ck` (T-039)** — a structured source of truth with a *generated* human view beside it;
  unsaved-session detection; git activity since the last session as a cheap delta.

---

## 2. Storage Layout

Plain files only. No database, no index process, no binary format.

```text
${CLAUDE_CONFIG_DIR:-$HOME/.claude}/rinnegan/          # rinnegan's own plugin data directory (D-18)
├── projects.json                                      # project key -> {name, root, first_seen, last_session}
└── projects/<project-key>/
    ├── index.jsonl                                    # append-only record index, one JSON object per line
    ├── sessions/<YYYY>/<MM>/<YYYY-MM-DD>--<session-id>.md
    └── decisions/<NNNN>-<slug>.md                     # durable decisions, one file each
```

`<project-key>` is `<basename-of-project-root>-<first-12-hex-of-sha256(absolute-project-root)>`, so
two checkouts of the same repository at different paths do not collide and no absolute path is
embedded in a filename.

### 2.1 `index.jsonl` — the searchable surface

One JSON object per line, append-only, never rewritten in place. This is the only file a search
reads, and it is deliberately small: titles and tags, never bodies.

```json
{"id":"2026-08-22T14:03:11Z-0007","kind":"decision","session":"s-01hzx9q4m7","title":"Chose JSONL over SQLite for the memory index","tags":["storage","rinnegan"],"ref":"sessions/2026/08/2026-08-22--s-01hzx9q4m7.md#d-0007","hash":"a1b2c3d4e5f60718"}
```

| Field | Rule |
|---|---|
| `id` | RFC-3339 UTC timestamp plus a 4-digit per-day counter. Sorts chronologically as a string |
| `kind` | `bugfix` \| `feature` \| `decision` \| `discovery` \| `change` \| `summary` \| `prompt` (C2, C3, C4) |
| `session` | The host session identifier, so every record ties back to one session note |
| `title` | One line, <= 120 characters. This is what a search result shows |
| `tags` | Lowercase kebab-case, 0–6 entries. Free-form; no controlled vocabulary to maintain |
| `ref` | Repo-data-relative path plus an anchor into the session note or decision file |
| `hash` | First 16 hex characters of `sha256(session + "\n" + title + "\n" + body)` (C7) |

JSONL is chosen over one file per record because a search must read *one* file, and over SQLite
because SQLite is a hard reject (HR-5). Appending is atomic enough for this use: one line, one
`>>`-equivalent write, no read-modify-write.

### 2.2 Session notes — the readable surface

One Markdown file per session, written once at session end and never rewritten. This is the
generated human view that `ecc/ck` gets right: structured data in `index.jsonl`, prose beside it.

```text
---
session: s-01hzx9q4m7
project: awakened
started: 2026-08-22T13:10:04Z
ended: 2026-08-22T15:47:52Z
---

(H1) Session 2026-08-22 - Phase 3 ECC triage

(H2) Request
What the user asked for, in their framing.

(H2) Completed
- One bullet per thing that actually landed.

(H2) Learned
- One bullet per transferable pattern.

(H2) Records
(H3) d-0007 [decision] - Chose JSONL over SQLite for the memory index
Body. Why, what was rejected, what it costs.
```

The `(H1)` / `(H2)` / `(H3)` markers stand for real ATX heading levels; they are written out here so
this document keeps a single H1 of its own. The note's H1 is the session title, and each record is
an H3 whose slug is the anchor its `index.jsonl` line points at.

Anchors (`#d-0007`) are stable because records are never renumbered.

### 2.3 Decisions

A record of `kind: decision` that is expected to outlive its session is additionally written to
`decisions/<NNNN>-<slug>.md`, and its `ref` points there instead of into the session note. This is
the same file the shortlisted `ecc/architecture-decision-records` skill authors — that skill is the
*author*, this design is the *store*, and `ecc/growth-log` is the second author for
`kind: discovery`. All three are `rinnegan` under B-3.

### 2.4 Scopes

| Scope | Location | Default |
|---|---|---|
| `user` | `…/rinnegan/projects/<key>/` as above | **On.** The only scope written without an explicit opt-in |
| `project` | `<project-root>/.rinnegan/` | **Off.** Opt-in per project; on first write, create `.rinnegan/.gitignore` containing `*` and refuse to write if that file exists with different content (the fail-closed guard from `ecc/unified-memory`) |

Both targets are inside the D-18 write scope: (a) the active project directory, (b) the owning
plugin's own data directory under the user's Claude configuration directory. No third location
exists, and no `team` scope is adopted — it would mean committing memories, which is a repository
policy question, not a memory-system question.

---

## 3. Capture Flow

`rinnegan` gets exactly one hook. D-15 budgets one load-bearing hook per plugin, and `SPEC.md` §6
allocates rinnegan's to memory capture; capture is the load-bearing half, because without it there
is nothing to recall.

### 3.1 The hook

| Property | Value |
|---|---|
| Event | **`SessionEnd`** — "When a session terminates" |
| Handler type | **`prompt`** — shell-free, per the §6 Hook Dispatch rule (D-24). No `command` handler exists in this design, so no interpreter is required on either platform |
| Declared timeout | **10 seconds** — the repo standard ceiling (C-1, ADR-022; every hook declares a timeout regardless of handler type). See the budget note below: on `SessionEnd` the declared value is also what raises the shared budget |
| Failure mode | Warn and continue. A memory failure never blocks the user's session (C8, `CLAUDE.md` §6.4) |
| Writes | Only under §2's two scope roots |

**The event is `SessionEnd`, not `Stop`, and the distinction is load-bearing.** Verified against the
official hooks reference at `https://code.claude.com/docs/en/hooks` on 2026-08-22 (§0 standard of
record): `Stop` fires **"When Claude finishes responding"** — once per turn — while `SessionEnd`
fires **"When a session terminates"**. An earlier draft of this design named `Stop` and described it
as session end. Every "written once" and "one pass" premise below depends on the correct event: on
`Stop` the hook would fire on every turn, the session note would be rewritten mid-session with
different content each time, and §3.3's idempotence argument would not hold. claude-mem's own
`plugin/hooks/hooks.json` registers `Stop` for summarization while its
`docs/architecture-overview.md` table lists `SessionEnd` separately — the two disagree, which is
part of why this was worth checking rather than inheriting.

**`SessionEnd` timeout budget.** The same reference records that `SessionEnd` hooks **share a
1.5-second budget**, and that a longer per-hook `timeout` raises that budget to match, up to 60
seconds. The declared 10 seconds is therefore doing two jobs: it is the C-1 ceiling *and* the value
that lifts the shared budget from 1.5 s to 10 s. A design that declared nothing would be cut off at
1.5 seconds shared with every other `SessionEnd` hook on the machine. Whether 10 seconds is
sufficient in practice is a Phase-6 execution check (§7 item 1), not something a static read can
close; if it is not, the fallback is to write the `index.jsonl` lines first and the prose note
second, so a truncated run still leaves the searchable surface intact.

The handler injects a short instruction; the session's own model then writes the session note and
appends the `index.jsonl` lines with the tools it already has. Nothing is spawned, nothing is
queued, and no second model is invoked — which is where claude-mem needs the Agent SDK, the worker
and the pending queue.

### 3.2 Sequence

```text
SessionEnd
 └─ prompt hook fires (<= 10s declared; raises the 1.5s shared SessionEnd budget to match)
     1. Resolve <project-key> from the project root; create it in projects.json if new.
     2. Draft the session note: Request / Completed / Learned, then the typed records.
     3. For each record compute hash = sha256(session + title + body)[:16].
     4. Read the tail of index.jsonl; skip any record whose hash is already present.
     5. Append the surviving records to index.jsonl, one line each.
     6. Write sessions/<YYYY>/<MM>/<date>--<session-id>.md once.
     7. Update projects.json.last_session.
```

### 3.3 Idempotence

Step 3–4 make the hook idempotent by construction: firing twice for the same session produces
identical hashes and appends nothing the second time. The session note is written to a
session-keyed path, so a re-run overwrites it with the same content rather than creating a
duplicate. This is C-1's idempotence requirement satisfied in the design rather than asserted —
though whether the implementation honours it is a Phase-6 execution check, not something a static
read can close (`eval/rubric.md` §7 Example C).

The argument depends on the event firing **once per session**. On a per-turn event the content
would differ between firings, the hashes would differ with it, and the second firing would append
rather than no-op — so `SessionEnd` is not a cosmetic correction to §3.1, it is what makes this
paragraph true. A resumed session (`SessionStart` fires "when a session begins **or resumes**")
produces a second `SessionEnd` with a superset of the first run's records; the hash check makes the
overlap a no-op and only the new records append.

### 3.4 What is deliberately not captured

Tool-call-level observations. claude-mem captures on `PostToolUse` with a 120-second async hook,
which is the single largest source of its volume and the reason it needs a queue and a worker. One
end-of-session pass writes fewer, better records and needs neither. The cost is that a session that
crashes without a clean `SessionEnd` leaves no record; the mitigation is the unsaved-session
detection in §4.4.

---

## 4. Recall and Search Flow

No index process, no embeddings, no MCP server. Search is `grep` over one JSONL file and `Read`
over the files it points at.

### 4.1 Three layers, in order (C5)

```text
1. SEARCH  grep index.jsonl for the query terms, kinds, tags or date prefix
           -> a compact table: id | date | kind | title            (~40 tokens per hit)
2. FILTER  the model or the user picks the ids that matter
3. FETCH   Read only the refs those ids name, with offset/limit
```

Fetching bodies before filtering is the failure this ordering exists to prevent, and it is the
rule `plugin/skills/mem-search/SKILL.md` states in capitals. The filters carried over from its
`search` tool, all of which are line-level greps here:

| Filter | Implementation |
|---|---|
| free text | `grep -i` over the line (title and tags are on it) |
| `kind` | `grep '"kind":"decision"'` |
| tag | `grep '"tags":\[[^]]*"auth"'` |
| date range | `id` is an RFC-3339 prefix, so a range is a prefix match or a sorted-range scan |
| ordering | the file is chronological by construction; reverse with `tac` or read from the end |
| limit / offset | line slicing |

### 4.2 Timeline around an anchor (C6)

`index.jsonl` is append-only and chronological, so "three records before and after id X" is line
arithmetic on one file — no anchor table, no query planner.

### 4.3 Recall gets no hook

The hook budget is spent on capture (§3). Recall is reached two other ways, both free:

- A `rinnegan` skill whose frontmatter `description` names the triggers — "what did we decide",
  "how did we do X last time", "what was I working on" — so it auto-invokes (N-2).
- An explicit command, `/rinnegan:recall <query>`, for when the user wants it deliberately.

This is a real trade-off against claude-mem, which injects context automatically on
`SessionStart`. It is the cost of D-15, and it is recorded here rather than worked around.

### 4.4 Unsaved-session detection (from `ecc/ck`)

`projects.json.last_session` plus the newest `sessions/` entry are enough to notice that the
previous session ended without a note. The recall skill reports it as a line — "the previous
session was not captured" — and offers to reconstruct from what the user remembers. No hook, no
watcher.

---

## 5. Dropped-Features Map

Every capability in the shipped implementation, mapped to a file-based replacement or to an
explicit, reasoned omission. `ROADMAP.md` V3.6 requires this table to be complete for the named
five; the rest are listed because a partial map invites the question of what was skipped.

| claude-mem feature | Disposition | Replacement or reason |
|---|---|---|
| **SQLite** (`claude-mem.db`, six tables) | **Replaced** | `index.jsonl` for the searchable fields, Markdown for bodies. HR-5 bars the native binary outright |
| **Bun** runtime + `bun-runner.js` (`engines.bun >= 1.0.0`) | **Replaced** | No runtime. The hook is a `prompt` handler; the model writes the files with its own tools. HR-5, P-5 |
| **Workers** — Express daemon on `37700+(uid%100)`, `SessionManager`, `ProcessRegistry`, 5-minute orphan reaper, 7-step graceful shutdown | **Replaced** | The work happens in-turn inside the session that generated it. HR-4 |
| **Docker** (`Dockerfile.test-installer`, `docker-compose.yml`, `docker-compose.e2e.yml`) | **Omitted** | Nothing to containerize once the daemon is gone. HR-5 |
| **Cloud sync** (cmem.ai Pro, `SyncHub`, account token in `~/.claude-mem/settings.json`) | **Omitted, deliberately** | Requires a third-party account and network egress. HR-1, HR-6. Durability is the user's own backup or git; the store is plain files, so both work |
| ChromaDB vector embeddings, `obs_{id}_narrative` / `_fact_N` documents, semantic search | **Omitted, deliberately** | Needs either a native vector store (HR-5) or a hosted embedding API (HR-1, HR-6). Replaced by lexical search over titles and tags. **Stated cost:** a query that shares no words with the record will not find it. The mitigation is discipline at write time — titles are written as sentences and tags are mandatory-ish — not a second index |
| `mcp-search` MCP server (`plugin/.mcp.json`) | **Omitted** | HR-2 permits only Obsidian, Context7 and Claude Code. `Grep` and `Read` already search files |
| BullMQ + `ioredis` pending queue, `PendingMessageStore` | **Replaced** | Append-only JSONL: the write *is* the queue, and there is no consumer to fall behind. HR-4, HR-5 |
| Claude Agent SDK subprocess for summarizing | **Replaced** | The session's own model writes its own summary inside the hook's prompt. HR-4, HR-7 |
| `posthog-node` telemetry | **Omitted** | HR-6, and `CLAUDE.md` PD-7 |
| `better-auth` / `@better-auth/api-key` | **Omitted** | Nothing to authenticate once cloud sync is gone. HR-1 |
| `pg` (PostgreSQL server mode) | **Omitted** | HR-5, HR-4 |
| tree-sitter grammars (11) + `esbuild` in `trustedDependencies` | **Omitted** | Native binaries. HR-5 |
| SSE broadcast + `plugin/ui` dashboard | **Omitted** | The Markdown files are the interface |
| `npx claude-mem install` / `repair`, `bun install` in the plugin cache, `.install-version` marker, `Setup` version-check hook | **Omitted** | Runtime dependency fetching. HR-7. A design with no runtime needs no installer |
| 30+ translated `plugin/modes/*.json` | **Out of scope** | Not a memory capability |
| Two session-id kinds (`contentSessionId` / `memorySessionId`) | **Dropped** | The split exists because the SDK agent restarts and invalidates its id. With no agent there is one id |
| Content-hash dedup, `sha256(...)[:16]` | **Kept** | §2.1 `hash`, §3.3. The 30-second window becomes a tail scan |
| Typed observations, session summaries, prompt history | **Kept** | §2.1 `kind`, §2.2 |
| `search` -> `timeline` -> fetch, filter-before-body | **Kept** | §4.1, §4.2 |
| Never block the host session on memory failure | **Kept** | §3.1 |

---

## 6. Policy Proof

`ROADMAP.md` V3.7 requires this design to be checked line by line against HR-1…HR-8, to state its
hook's write targets under D-18, and to demonstrate zero daemons, databases or network calls.

### 6.1 Hard rejects

| ID | Trigger | This design |
|---|---|---|
| HR-1 | Third-party API keys, external services, or accounts | **None.** No account, no key, no endpoint. Cloud sync is dropped in §5 |
| HR-2 | MCP servers beyond Obsidian, Context7 and Claude Code | **None.** `mcp-search` is dropped; search is `Grep` over a local file |
| HR-3 | LSP servers or language-specific tooling at user scope | **None.** The store is language-agnostic Markdown and JSONL |
| HR-4 | Background daemons, workers, watchers, or services | **None.** One `SessionEnd` prompt hook that returns within its 10-second budget. Nothing is spawned, detached, scheduled or left running; there is no PID file, no port, and no process to reap |
| HR-5 | sqlite/native binary dependencies | **None.** JSONL and Markdown, read and written with the tools Claude Code already ships. No SQLite, no ChromaDB, no bun, no tree-sitter, no esbuild |
| HR-6 | Telemetry, analytics, or network calls of any kind | **None.** Every operation is a local file read or append. No fetch, no host name, no counter |
| HR-7 | Auto-installing packages or runtime dependency fetching | **None.** Nothing to install: no `package.json`, no runtime, no installer, no version-check hook |
| HR-8 | Hooks that write outside (a) the project directory or (b) the owning plugin's own data directory under the user's Claude config dir (**D-18**) | **Satisfied, and this is the design's tightest constraint.** The hook's only write targets are `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/rinnegan/**` — case (b), rinnegan's own data directory — and, when the project scope is opted into, `<project-root>/.rinnegan/**` — case (a). It writes nowhere else: not `~/.claude/settings.json`, not `~/.claude/scripts/`, not another plugin's directory, not a temp directory outside the project |

### 6.2 Conditionals

| ID | Trigger | This design |
|---|---|---|
| C-1 | Hooks executing shell commands | The hook is a `prompt` handler and executes no shell command, so the cross-platform clause does not bind (ADR-022). The rest of C-1 does and is met: idempotent by content hash (§3.3), read-only until it has something new to append, timeout declared at **10 seconds**, and within the D-15 budget as rinnegan's single hook. Real idempotence and timeout behaviour are Phase-6 execution checks |
| C-2 | Subagents | None. This design ships no agent |
| C-3 | File writes | Inside the owning plugin's data directory, or the project directory when opted in — the same two targets as HR-8. The project scope additionally refuses to write unless its fail-closed `.gitignore` is present and unmodified |

### 6.3 Every component

| ID | Check | This design |
|---|---|---|
| E-1 | Static review for prompt-injection patterns, secrets handling, obfuscation | Memory content is **untrusted data on read**: a recalled record is context, never an instruction, and the recall skill must say so in the same words `ecc/living-docs-governance` and `ecc/tdd-workflow` use. This matters more here than almost anywhere else, because a memory store is a place an attacker would like to write to and know the agent will read later. Capture never records values from environment variables, `.env` files, or command output that a secret scan flags; if a record would carry one, the record is dropped, not redacted-in-place |
| E-2 | Passes `scripts/validate.*` before merge | The store is user data, not a shipped component; what ships is the hook manifest, the skill and the command, all of which are validated like any other component |

### 6.4 The three claims V3.7 names, stated plainly

- **Zero daemons.** The only executing thing is one hook, on one event, bounded at 10 seconds,
  which returns before the session continues.
- **Zero databases.** Two file formats, both plain text, both readable with `cat`.
- **Zero network calls.** No operation in §2, §3 or §4 has a remote counterpart.

---

## 7. Open Items for Phase 6

Recorded here rather than resolved, because Phase 6 is barred until G5 approval and the owner's
acknowledgement.

| # | Item |
|---|---|
| 1 | C-1 idempotence and the 10-second timeout must be *executed* on Windows 11 PowerShell 7 and WSL2 before the hook ships; a static design cannot close them (`eval/rubric.md` §7 Example C) |
| 2 | *(Partly discharged 2026-08-22.)* The official hooks reference was read at `https://code.claude.com/docs/en/hooks` and confirms `prompt` as one of five handler types, `SessionEnd` as a distinct event, and the 1.5-second shared `SessionEnd` budget — all folded into §3.1. `SPEC.md` §6 and ADR-024 record that `agent`-type hooks are experimental upstream; this design uses `prompt`, so it does not depend on that. §0 still requires re-verification at the Phase-6 gate |
| 3 | Retention. `index.jsonl` grows without bound. A rotation rule — by age, by line count, or none — is a Phase-6 decision; nothing here depends on which is chosen |
| 4 | Whether the recall skill or the capture hook owns unsaved-session detection (§4.4) |
| 5 | The lexical-search cost in §5 is the one accepted quality regression against claude-mem. If it proves too costly in practice, the answer is better titles and tags, not a vector store — that path is closed by HR-5 and HR-6 |
