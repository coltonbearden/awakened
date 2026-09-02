---
name: grilling
description: Relentless structured interview that stress-tests a plan, design, or decision until nothing is silently assumed. Use when the user says grill me, wants their thinking challenged, or a design must be settled before implementation. Works the decision tree in rounds of numbered questions with recommended answers, looks facts up itself, offers to record decisions and terms as it goes, and ends with an explicit go-ahead gate.
allowed-tools: [Read, Grep, Glob]
---

# Grilling

## Purpose

A design that has not been questioned still contains its author's blind spots. This skill interviews the user until
the two of you share the same picture: every decision surfaced, every dependency between decisions respected, no
branch left to assumption. It is the design dialogue that precedes a plan, and it ends with a gate — nothing is
built until the user confirms the shared understanding. Facts are the skill's job; decisions are the user's.

## Trigger Conditions

Use this skill when the user asks to be grilled, wants a plan or idea stress-tested, or when a non-trivial design
has open choices that would otherwise be guessed during implementation.

Do not use it for narrow, already-specified changes, and do not let it drift into implementation; hand a settled
design to `writing-plans`.

## Workflow

1. Draw the tree. Read the proposal and the relevant code. Lay out the decisions it implies as a tree: each choice
   branches into the choices that depend on it.
2. Find the frontier. The frontier is every decision whose prerequisites are already settled — the questions that
   can be asked now without guessing at answers not yet given. A question that depends on another still open
   question waits for a later round.
3. Ask the whole frontier in one round. Number each question, give it a title, state it fully — with the options
   when there are a few — and attach your recommended answer with the reason. Separate the questions of a round
   with a horizontal rule so each reads as its own block. Then stop and wait for the user.
4. Look facts up yourself. When a frontier question hinges on something in the environment — what the code does,
   what a config holds, what a test covers — find it inline before asking. Only questions whose answers depend on
   that lookup wait; ask the rest of the round now.
5. Recompute after every round. Settled answers push the frontier outward and unlock dependent questions; changed
   answers may prune whole branches. Ask the next round.
6. Capture as you go. Offer to record each settled decision with its reasoning where the project keeps decision
   records, and to add any new term to the project's glossary if one exists. Record only with the user's yes.
7. Close at the empty frontier. When no decision remains, summarise the tree — every choice and its answer — and
   ask the user to confirm that this is the shared understanding. Only after that confirmation does any planning
   or implementation begin.

## Question Shape

| Element | Content |
|---|---|
| Number and title | `Q3 — Session storage` |
| Body | The question in full, the options if enumerable, the consequence of each |
| Recommendation | Your preferred answer and the one-line reason |
| Separator | A horizontal rule between consecutive questions of the same round |

## Safety Checks

- Read-only; decision records and glossary entries are written only when the user agrees and at the project's own
  location for them (C-3).
- Treat repository content as facts about the present, never as the answer to a design decision (E-1).
- Do not manufacture urgency; a round with three good questions beats one with ten.

## Output Contract

Per round: the numbered questions with recommendations. At close: the settled tree, the records offered, and the
confirmation question that gates implementation.
