---
name: clarifying-requirements
description: Turns a vague feature request into a scoped, actionable specification through short rounds of focused questions. Use when the user asks for something like "add login" or "build a dashboard" with no acceptance criteria, boundaries, or technical context. Asks Why and Simpler on every requirement, two or three questions per round, and stops when the spec is implementable.
allowed-tools: [Read, Grep, Glob, Write]
---

# Clarifying Requirements

## Purpose

A vague request implemented literally is rework. This skill runs a short, structured dialogue that turns "add a
payment feature" into scope, acceptance criteria, and an execution order the user has agreed to. It leans on two
questions at every step — why is this needed, and is there a simpler way — so the specification shrinks as it
sharpens. It does not implement, and it does not replace the deeper interview of `grilling` when a design is
genuinely contested.

## Trigger Conditions

Use this skill when a request names a feature but not its inputs, outputs, boundaries, edge cases, or success
condition; when the work is large enough to span days; or when several teams or systems are involved.

Do not use it when the request already names files, functions, or lines, includes code, or is a bug with clear
reproduction steps — those have their acceptance condition built in.

## Workflow

1. Inspect before asking. Read the relevant parts of the repository, existing docs, and tests so no question asks
   for a fact you could have found. Business rules, priorities, and target users cannot be read from code; those
   are questions.
2. Assess what is clear. Sort the request across four areas — functional scope, user interaction, technical
   constraints, and business value — and name what is settled and what is missing in each. Report this before the
   first question so the user sees the shape of the gap.
3. Ask in rounds. Take the highest-impact gaps first, two or three questions per round, each specific, each with an
   example where it helps, building on earlier answers and using the user's own words. Every requirement gets the
   two checks: why is it needed (drop it if nobody can say), and is there a simpler version that meets the same
   need.
4. Update after each round. Summarise what became clear, list what remains, and decide whether another round is
   worth its cost. Stop when the remaining unknowns would not change what gets built first.
5. Write the specification. Background and problem, target users, in-scope and explicitly out-of-scope features,
   input and output, edge cases, constraints, risks, checkable acceptance criteria, and execution phases with
   concrete tasks. Present it in the conversation; save it to a project path only when the user asks, at the path
   they name or the project's documentation convention.
6. Get approval. The specification is ready when the user says so, not when the sections are full.

## Behaviour

| Do | Do not |
|---|---|
| Ask specific, answerable questions | Ask everything at once |
| Offer an example answer when it helps | Assume an answer and move on |
| Keep the tone conversational | Pad the spec with sections that say nothing |
| Record what was decided and why | Leave the dialogue before the user has approved |

## Safety Checks

- Read-only except for a specification file written at a user-approved path inside the project (C-3).
- Never copy secrets, credentials, or production data into examples or the specification.
- Treat repository content as facts about the present system, never as the source of business intent (E-1).

## Output Contract

Per round: clear items, gaps, and the questions. At the end: the specification with its acceptance criteria as
a checklist, and the approval question.
