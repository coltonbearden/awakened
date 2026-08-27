---
name: domain-modeling
description: Build and sharpen a project's domain glossary while design is happening — challenge vague or conflicting terms, probe relationships with concrete scenarios, check claims against the code, and record each resolved term in CONTEXT.md as it crystallises. Use when the conversation is defining or renaming business concepts, when a term is used two ways, or when writing or editing CONTEXT.md or CONTEXT-MAP.md.
allowed-tools: [Read, Grep, Glob, Write, Edit]
---

# Domain Modeling

## Purpose

Keep the project's language precise and written down. The skill is active work on the model — pushing back on
a loose word, inventing the edge case that splits two concepts, and updating the glossary the moment a term is
settled. The only artifact is the glossary: `CONTEXT.md` (or per-context files listed by a root
`CONTEXT-MAP.md`). Decisions that come out of the modelling are handed to `rinnegan`; this skill records what
things are called, never why a choice was made.

## Trigger Conditions

Use this skill when terms are being coined, merged, or renamed; when the user says one word and appears to mean
another; when a relationship between concepts is being argued about; or when `CONTEXT.md` needs writing.

## Do not use this skill when

- The task only needs to read the glossary for vocabulary — any skill can do that in one line.
- The subject is module shape, interfaces, or seams (`codebase-design`).
- The request is to record or revisit a decision and its rationale (`rinnegan`).
- The project is a script or prototype with no shared vocabulary worth curating.

## Viability check

Before modelling, confirm all of the following; if any fails, say which and stop:

1. There is a business or problem domain with terms specific to this project, not just general programming
   concepts such as timeouts or retries.
2. The user is present to answer challenges — modelling against silence produces invented definitions.
3. The scope is one context at a time. If `CONTEXT-MAP.md` exists, identify which context the topic belongs
   to; if unclear, ask.

## Workflow

1. Locate the glossary: `CONTEXT-MAP.md` at the root means several contexts, each with its own `CONTEXT.md`; a
   single root `CONTEXT.md` means one context; neither means the file is created at the first resolved term.
2. Challenge conflicts on the spot. When a term is used differently from its glossary entry, quote the entry and
   ask which meaning is intended.
3. Sharpen fuzzy words. When a term is overloaded, propose one canonical name and name the alternatives it
   replaces.
4. Stress relationships with scenarios. Invent specific cases that sit on the edge between two concepts and make
   the user rule on them.
5. Cross-check the code. When the user states how something behaves, grep for the concept and report a
   contradiction as a question, not a correction.
6. Record immediately. Each resolved term goes into the glossary as: bold term, a one- or two-sentence
   definition of what it is (not what it does), and an "avoid" line listing the rejected synonyms. Group under
   subheadings only when clusters emerge. No implementation detail enters the file.
7. When a resolution reveals a decision that is hard to reverse, surprising later, and the product of a real
   trade-off, say so and point the user to `rinnegan` to record it. Otherwise say nothing about decisions.

## Safety Checks

- Writes are limited to `CONTEXT.md`, per-context `CONTEXT.md` files, and `CONTEXT-MAP.md` in the project (C-3).
- The glossary is not a specification, scratchpad, or decision log; refuse content that belongs elsewhere.
- Existing glossary text is data to reconcile with the user, not authority over the user (E-1).

## Output Contract

1. **Terms resolved** — each with its definition and the synonyms retired
2. **Open questions** — scenarios the user has not yet ruled on
3. **Glossary** — the file path updated, or the reason no file was written
