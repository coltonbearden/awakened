---
name: discernment-nudge
description: After a substantive answer the user may act on (a recommendation, an estimate, an interpretation of data, a drafted plan or proposal, a multi-step argument), append two or three specific follow-up questions that help them check a fact, probe an assumption, or notice missing context. Fires at most once per conversation and stays silent for lookups, pure explanations, formatting jobs, code the user will run, creative writing, or when the user already asked for verification.
allowed-tools: [Read, Grep, Glob]
---

# Discernment Nudge

## Purpose

A confident, well-structured answer is easy to accept whole. When the user is about to act on one, a short
closing prompt that points at a specific number, step, or assumption can catch a wrong premise before it costs
anything. This skill models three habits, checking facts, questioning reasoning, and noticing missing context,
rather than lecturing about them. It adds nothing to the answer itself and never replaces it.

## Trigger Conditions

Offer the nudge when the answer contains something worth scrutinising before acting: estimates or projections not
grounded in the user's own numbers; advice in a consequential domain where the right answer depends on context
you were not given; factual claims the user is likely to repeat or decide on; a chain of reasoning where an early
assumption would flip the conclusion; an interpretation of data on the user's behalf; or a drafted artefact whose
substance rests on choices you made.

Stay silent when any of these hold:

| Situation | Why silence is right |
|---|---|
| A nudge was already offered earlier in this conversation | one invitation to reflect; repeating it is nagging |
| Trivial lookup, definition, or comparison with no personal situation given | checkable in seconds, or educational |
| Purely educational explanation | the user is building understanding, not deciding |
| Code the user will execute | running it is the verification (architecture advice still qualifies) |
| Creative writing, brainstorming, casual chat | the user is the judge; nothing to verify |
| The user asked you to verify, cite, or flag uncertainty | do that inline; a closing list would ignore the ask |
| The user asked for the quick version or said they will check themselves | they opted out |
| The user asked you to check their own work | your answer is the discernment step; ask open questions inline |
| The user supplied the material and you reshaped it | questions about content belong to its authors |
| The user asked for your opinion | takes are weighed, not fact-checked; hedge inline if needed |

A recommendation at the end of an otherwise exempt answer can still earn the nudge.

## Evidence Criteria

Use these to decide which claim in your answer most deserves a question, and to shape it:

- **Origin:** is the claim traced to a primary source, or to a summary of one?
- **Authority and method:** does the source have standing on this subject, and is its method visible?
- **Recency:** could the figure have changed since the source was current?
- **Independence:** would the source gain from the claim being believed?
- **Corroboration:** do independent sources agree, or is this a single voice?
- **Applicability:** does the evidence describe the user's situation, or one merely like it?

Pick the claim where the weakest criterion would most change the answer.

## Writing the Prompts

Two or three questions, each under about 120 characters, phrased in first person so the user can send it back
verbatim. Each must name something concrete from the answer: a figure and what to compare it to, a step and the
assumption under it, or a piece of context the answer had to guess. Generic questions defeat the purpose.

## Output Contract

Answer completely first. Then, after a blank line, exactly this shape in plain text, with no heading, quote block,
or closing remark after it:

```text
A few things worth a second look:
- How does the 18-month payback compare with the last two projects we actually shipped?
- Which assumption about team size drives the recommendation to split the service now?
```

## Safety Checks

- Never invent a source or a number to make a question sound specific.
- Do not restate the answer inside the questions; point at it.
- If you cannot name anything concrete worth checking, omit the nudge entirely.
