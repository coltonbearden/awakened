---
name: growth-log
description: Distil a hard task, a failure or a surprise into a transferable learning entry — root cause, the pattern, the signal that will flag it next time — checked against earlier entries so the same lesson is never logged twice. Use after debugging that took longer than expected, a rollback or rework, a non-obvious decision, or when the user asks what was learned; the entry lands in rinnegan's session memory at capture.
allowed-tools: [Read, Grep, Glob, Write]
---

# Growth Log

## Purpose

Produce learning entries that name a pattern rather than narrate an event, so the next session recognises the
situation before repeating the cost. The entry becomes the `Learned` bullet and a `discovery` record when
`/rinnegan:capture` runs; this skill drafts and de-duplicates, and writes a file only on request.

## Trigger Conditions

Use it after a task that involved debugging, redoing, rollback or a non-obvious choice, after anything that was
"harder than it should have been", or when the user asks to review what was learned. Skip it for typo fixes,
one-line tweaks and configuration edits that needed no investigation — the test is whether something had to be
figured out. Decisions go to `architecture-decision-records`; broad recall goes to `recalling-context`.

## Three Rules

| Rule | Meaning |
|---|---|
| Failures outrank successes | One two-hour bug teaches more than three features that worked first time |
| Search before writing | Grep the index and recent `Learned` sections; a match gains an example, not a twin |
| Every entry transfers | If "next time I see X, I will Y" cannot be written, the pattern is not found yet |

## Entry Shape

```markdown
### <Pattern title — the mechanism, never the incident>

Context: what was attempted, what went wrong or worked unexpectedly well.
Root cause: the mechanism beneath the symptom, reached by asking "why" until the answer generalises.
Pattern: next time <situation>, do <specific action>.
Signal: the observable that says this pattern is active.
Related: ids of earlier entries this extends or contrasts with.
```

Four to eight sentences. Shorter has not gone deep enough; longer is telling the story instead of the lesson.

Entry types share the shape and shift the weight: a **failure** leans on root cause; a **method** that emerged
leans on context and pattern; a **discovery** about a tool or system leans on pattern; a **capability change**
leans on before-versus-after context.

## Workflow

1. State what happened in one sentence, then ask why repeatedly until the answer is a class of problem, not this
   instance (a default that changed underneath existing behaviour, not a version number).
2. Grep `${CLAUDE_PLUGIN_DATA}/projects/<key>/index.jsonl` for `"kind":"discovery"` lines and the session notes'
   `Learned` sections using the root-cause keywords. Merge into a match by proposing an added example; otherwise
   continue.
3. Draft the entry in the shape above and check it: title names the pattern; a "next time" sentence exists; the
   signal is specific; root cause is distinct from symptom; related entries are cross-referenced.
4. Hand the entry back for the session note. Tag it with two to four kebab-case tags so the index search finds it.
5. Only if the user keeps a learning file in the repository (for example `growth-log/<YYYY-MM-DD>.md`) and asks
   for it, append the entry there — the project directory is the only other place this skill writes.

## Safety Checks

- Copying a commit message is not an entry; commits say what changed, entries say why it matters.
- One entry per root cause, not per commit; silence is better than a diary line.
- No credentials or private data in an entry, even as an example of what went wrong.

## Output Contract

1. **Entry** — the drafted block, with its type and tags
2. **Duplicate check** — the ids searched and whether the entry merged into an existing one
3. **Next time** — the single transferable sentence, restated on its own
