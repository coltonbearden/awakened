---
name: architecture-decision-records
description: Record a significant technical or accessibility decision as a short decision record — context, the choice, the alternatives rejected and why, consequences — and file it in rinnegan's decision store or the project's ADR directory. Use when the user picks between frameworks, storage, API styles, auth strategies or patterns, says "we decided" or "record this decision", or asks why an earlier choice was made.
allowed-tools: [Read, Grep, Glob, Write]
---

# Architecture Decision Records

## Purpose

Turn a decision that was made in conversation into a durable record that explains itself a year later. The skill
writes one file per decision, after the user has seen the draft; it does not make decisions, and it does not
record trivia.

## Trigger Conditions

Use it when a choice with lasting consequences is settled: a technology, a data model, an API shape, a
deployment or security approach, a testing strategy, a process rule — or an accessibility commitment such as a
colour-contrast floor, a keyboard-navigation rule or a screen-reader labelling convention. Use it read-only when
the user asks "why did we choose X": search existing records first (`recalling-context` owns broad recall).
Do not record naming, formatting or one-off implementation choices.

## Where Records Live

| Store | Path | When |
|---|---|---|
| rinnegan (default) | `${CLAUDE_PLUGIN_DATA}/projects/<key>/decisions/<NNNN>-<slug>.md` | Always available |
| Project | `<project-root>/docs/adr/<NNNN>-<slug>.md` plus a row in `docs/adr/README.md` | Exists, or user asks |

`<key>` is read from `${CLAUDE_PLUGIN_DATA}/projects.json` by the project's absolute root. Confirm before creating
`docs/adr/`.

Numbers are four digits, scanned from the chosen store and incremented; never reuse one. Writes go nowhere else.

## Record Format

```markdown
# 0007: <Decision as a sentence>

Date: YYYY-MM-DD | Status: proposed | accepted | deprecated | superseded by 0012 | Kind: architecture | accessibility

## Context
The forces at work — the problem, the constraints, who is affected. Two to five sentences.

## Decision
What is done, in the present tense, in one to three sentences.

## Alternatives
For each option that lost: what it offered, what it cost, and the specific reason it was not taken.

## Consequences
What becomes easier, what becomes harder, and the risk carried with its mitigation.
```

For an accessibility decision (`Kind: accessibility`) the Context names the users and assistive technologies
affected and the criterion or standard being met or knowingly missed, the Decision states the rule the codebase
now follows, and the Consequences name what must be checked in review so the commitment survives. The structure
is otherwise identical: accessibility choices are architecture, and they are recorded the same way.

## Workflow

1. Notice the decision moment — an explicit "let's go with", a comparison that reached a verdict, or a request.
   When the signal is implicit, propose recording rather than assuming.
2. Grep the existing decision titles for the same subject. If one exists, offer to supersede it instead of adding
   a duplicate; a superseded record gets its status updated to point at the new number.
3. Extract the choice, the context, at least one rejected alternative with its reason, and honest consequences.
   "We just picked it" is not a rationale; ask for the reason before writing.
4. Assign the next number and slug, draft the record, and show it to the user.
5. Write the file only after the user approves; if they decline, discard the draft. Then say the path, and note
   that `/rinnegan:capture` will index it as a `decision` record.
6. For "why did we choose X": grep the store for X, present Context and Decision of the matches, and if nothing
   matches say so and offer to record it now.

## Safety Checks

- Never write before the user has seen the draft and agreed; never create `docs/adr/` unasked.
- A record holds reasons, not secrets: refer to credentials or endpoints by location and type only.
- Backfilled decisions carry their original date and say they were recorded later.

## Output Contract

1. **Decision** — number, title, status, kind, and the path written (or "not written" and why)
2. **Superseded** — any earlier record whose status changed
3. **Open** — anything the user still has to settle before the status can move to accepted
