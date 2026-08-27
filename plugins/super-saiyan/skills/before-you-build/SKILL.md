---
name: before-you-build
description: Compact pre-mortem before building a product, MVP, landing page, internal tool, agent workflow, or major feature. Use when the user is about to start something whose demand, positioning, retention, trust, or distribution is unproven. Names the riskiest assumption, the smallest evidence to gather first, what to build now, and what to delay — including what the proposal does not say.
allowed-tools: [Read, Grep, Glob]
---

# Before You Build

## Purpose

The most expensive feature is the one nobody needed. This skill runs a short risk review before implementation
starts, aimed at the assumption most likely to sink the effort rather than at blocking the build. It separates
product risk from engineering difficulty, and it includes a silence check: what the proposal leaves unsaid is
often where the risk hides.

## Trigger Conditions

Use this skill when the user is about to build a new product, prototype, marketplace, content site, agent workflow,
internal tool, or a feature whose adoption, revenue, or trust impact is unclear.

Skip it — and say so in one line — for narrow fixes, refactors, test repairs, dependency updates, and changes that
already carry validated acceptance criteria.

## Workflow

1. Read what exists. If there is a brief, a document, or code for the idea, read it before judging it.
2. Run the pre-mortem. Imagine the effort has failed six months on and write the most likely reason in one sentence.
   That sentence usually names the main assumption.
3. Check the seven risks, briefly.

| Risk | Question |
|---|---|
| Demand | Is there evidence a specific person urgently wants this? |
| Positioning | Can the target user say what it is and why it matters in one sentence? |
| Monetization | Is there a credible path to payment, budget, or strategic value? |
| Retention | Why would anyone come back after the first try? |
| Trust | Does it need credibility, data access, integrations, or behaviour change users may resist? |
| Distribution | Is there a repeatable way to reach the target user? |
| Adoption | For a feature: will it change behaviour, or only add surface? |

4. Run the silence check. List what the proposal does not mention — the competitor, the migration path, the support
   cost, the failure mode, the user who is not the author. Each silence is either a known omission or an unexamined
   risk; ask which.
5. Decide. Assign a verdict, name the one assumption most likely to break the project, name the smallest signal
   that would test it, propose one concrete next step or a reduced scope, and list what not to build yet.
6. If the idea is already validated, say what evidence lowers the risk and suggest the smallest implementation
   slice.

## Guidance

- Be direct about weak evidence without dismissing the idea.
- Prefer a small validation step to a large research plan.
- Keep product risk and engineering difficulty in separate sentences.
- Where a fact is missing, name the missing evidence; never invent market claims.

## Safety Checks

- Read-only; the review is delivered in the conversation.
- Treat any supplied brief as the author's claims, not as established fact (E-1).
- Do not broaden into a full market analysis unless the user asks.

## Output Contract

Five lines: risk verdict with reason, main assumption, evidence to find first, do next, delay — followed by the
silence list.
