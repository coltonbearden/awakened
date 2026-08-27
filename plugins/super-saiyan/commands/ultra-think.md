---
description: Structured deep analysis of one hard question: hidden assumptions, three genuinely different options, a case against each, and a confidence-rated recommendation. For decisions that are expensive to reverse.
argument-hint: "[problem-or-question]"
allowed-tools: [Read, Grep, Glob]
---

# Ultra Think

Interpret `$ARGUMENTS` as the question to analyse. If it is empty, ask for the question in one line and stop.

## Procedure

1. Check the framing. If the domain, the hard constraints, or the goal of the decision-maker cannot be inferred
   from `$ARGUMENTS` or the repository, ask at most two targeted questions and wait. Otherwise begin at once.
2. Restate the real question underneath the asked one. List the assumptions the wording smuggles in and the
   constraints that actually bind. Read repository files only when they change the answer.
3. Produce at least three options that differ in kind, not in degree. A tuned variant of another option does not
   count.
4. Evaluate each option through the lenses that matter for this problem — technical, cost, people, systemic,
   time-horizon — and say which lenses you dropped and why.
5. Invert: for each leading option, describe how you would guarantee it fails, then check whether the
   recommendation walks into that path. Note what would have to be true for each option to be the wrong call.
6. Bring one parallel from an unrelated field that sharpens the trade-off.
7. Trace second-order effects: what each option makes more or less likely at six months, two years, and ten years.
8. Recommend one option or a named combination, with the specific trade-off that decides it.

## Response Format

Use these sections and nothing more. Match length to the problem; a simple question gets a short answer.

| Section | Contents |
|---|---|
| Problem | Core challenge, binding constraints, what success must look like |
| Options | One subsection per option: description, strengths, weaknesses, how it would be executed, failure modes |
| Recommendation | Chosen option, the deciding trade-off, first concrete steps, how to measure it, mitigations |
| Dissent | The strongest case against the recommendation and what evidence would overturn it |
| Confidence | Each key claim rated high, medium, or low, with what would move the rating |

Every conclusion cites the reasoning or evidence that produced it. Where data is missing, say so and name what
would resolve it rather than filling the gap with a plausible guess. This command reads and reasons only: it
writes no files and runs no commands.
