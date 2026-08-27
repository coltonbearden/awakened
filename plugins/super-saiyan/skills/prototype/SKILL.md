---
name: prototype
description: Builds throwaway code that answers one design question. Use when the user wants to feel whether a state model or piece of logic holds up, or see what a screen could look like, before committing to real implementation. Picks the logic or UI shape, keeps the prototype runnable in one step and clearly marked, and captures the verdict when done.
allowed-tools: [Read, Grep, Glob, Edit, Write]
---

# Prototype

## Purpose

A prototype is code built to be discarded once it has answered a question. The question decides the shape: a state
model is best felt by driving it through awkward cases; a screen is best judged by seeing several very different
versions side by side. This skill builds the smallest artifact that lets the user answer, keeps it from being
mistaken for production code, and folds the verdict — not the code — back into the real work.

## Trigger Conditions

Use this skill when the user asks to sanity-check logic or a state machine, explore how something should look, or
"try something quickly" to make a design decision.

Do not use it to ship features, and do not let it stand in for tests; a validated decision is implemented afresh
through `test-driven-development`.

## Workflow

1. Name the question. From the request and the surrounding code, state in one sentence what the prototype must
   answer. If it is ambiguous and the user is available, ask; if not, infer from the code — a backend module points
   to a logic prototype, a page or component to a UI one — and write the assumption at the top of the artifact.
2. Pick the shape. Logic: a single self-contained page with free-play controls and a few guided walkthroughs that
   push the state through the cases hardest to reason about on paper, usable by a non-developer. UI: several
   deliberately different variants of one screen, switchable in place, on a route that follows the project's
   existing routing convention.
3. Place and mark it. Put the prototype next to the module or page it explores so the context is obvious, and name
   it so a casual reader sees at once that it is throwaway.
4. Make it trivial to run: one command from the project's task runner, or one file the user opens directly. No
   setup thought required.
5. Keep state in memory. Persistence is usually what the prototype is examining, not something it depends on. If a
   store is unavoidable, use a scratch one whose name says it can be wiped.
6. Skip the polish. No tests, no error handling beyond what keeps it running, no abstractions. After every action
   or variant switch, show the full relevant state so the user can see what changed.
7. Capture the answer. Once the user has decided, write the verdict and the question it settled where the project
   tracks the work — the issue, or the commit that implements the real thing. Offer to keep the prototype on a
   throwaway branch as a primary source; the main branch keeps only the validated decision.

## Safety Checks

- Writes are confined to the project directory, in clearly named prototype files (C-3).
- Bash runs only the project's own task runner and existing scripts; nothing is installed and no server is left
  running after the turn.
- Never wire a prototype to production data or credentials.

## Output Contract

The question, the shape chosen and why, the path and one-line run instruction, and — after the user's decision —
the recorded verdict and the location of any preserved prototype.
