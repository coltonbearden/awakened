---
description: Write a lean problem-first PRD at .claude/prds/<name>.prd.md through four question gates, stopping before any implementation detail. Use when an idea needs its problem, users, and metrics pinned down.
argument-hint: "[product-or-feature-idea]"
allowed-tools: [Read, Glob, Write]
---

# Plan PRD

Interpret `$ARGUMENTS` as the idea to document. If it is empty, ask in one or two sentences what the user wants to
build, and wait.

A PRD records what must be true and why. It never records how. If a file path, library, or task list appears in
your draft, delete it — that material belongs to `/super-saiyan:plan`.

## Procedure

Each phase is one exchange: ask the set, wait for the reply (or an explicit "skip"), then continue.

1. **Frame.** Restate the idea in one sentence and ask whether it is right. Then ask together: who has the
   problem, what the observable pain is, why existing options fail them, and what changed to make this worth
   doing now.
2. **Ground.** Ask for evidence that the problem is real: quotes, tickets, metrics, failed workarounds. If there
   is none, the Evidence section reads `Assumption — needs validation via <method>`. Never invent evidence.
3. **Decide.** Ask together: the hypothesis in the form "we believe X will do Y for Z; we will know when M", the
   smallest thing that tests it, what is explicitly out of scope, and the open questions that could change the
   approach.
4. **Generate.** Create `.claude/prds/` if missing and write `.claude/prds/<kebab-name>.prd.md` with the
   sections below. Where a fact is unknown, write `TBD — needs validation via <method>` rather than a guess.
5. Report the path, one line each for problem, hypothesis, and MVP, a validation status per section (evidenced or
   assumption), the count of open questions, and the next step: `/super-saiyan:plan <path>`.

## PRD Sections

| Section | Contents |
|---|---|
| Problem | Who, what, and the cost of leaving it unsolved |
| Evidence | Concrete observations, or the labelled assumption |
| Users | Primary user as a specific role; who this is explicitly not for |
| Hypothesis | The single testable sentence from step 3 |
| Success Metrics | Table: metric, target, how measured |
| Scope | MVP paragraph, then an out-of-scope list with a reason per item |
| Delivery Milestones | Table: number, milestone, user-visible outcome, status (`pending`), plan (empty) |
| Open Questions | Checklist of questions that could change scope |
| Risks | Table: risk, likelihood, impact, mitigation |

Close the file with a status line stating that it is requirements only and that planning is pending.

## Done When

The problem is specific and evidenced or flagged; the primary user is a role, not "users"; the hypothesis has a
measurable outcome; MVP and out-of-scope are both explicit; and no implementation detail survived.
