---
description: Answer a side question mid-task and return to the exact point of work with nothing changed on disk. Use for a quick explanation of the code in hand, a concept, an error, or an unrelated curiosity that must not derail the task.
argument-hint: "[question]"
allowed-tools: [Read, Grep, Glob]
---

# Aside

Interpret `$ARGUMENTS` as the side question. If `$ARGUMENTS` is empty, reply with the standard shape below, put
"no question given — ask it and the task stays parked" in the answer slot, and resume.

## Procedure

1. Park the task first. Record to yourself, in one line each: the active goal, the step underway when the aside
   arrived, and the very next action that was about to happen. This line becomes the closing "Back to" line.
2. Answer the question, shortest complete form first. Lead with the answer; reasoning follows only if it changes
   what the user should do. When the question concerns code in the working set, cite `path:line`. Read whatever is
   needed to answer accurately, but only read — nothing is created, edited, or deleted during an aside.
3. Check the answer against the parked task before resuming. Three cases interrupt the automatic return:
   - the answer undermines the current approach — say so plainly and ask whether to adjust or continue as planned;
   - the "question" is really a change of direction (for example, "let's switch to a queue instead") — name it as
     such and ask whether it is information only or a redirect, then wait;
   - the answer implies a code change — describe the change and defer it to after the task, unless the user asks
     to do it now. Never make the change inside the aside.
4. Resume from the recorded step. No permission is needed to resume unless step 3 fired. A long answer gets its
   essential form now and an offer to go deeper once the task is done. Several asides in a row are answered in
   order, and the parked state survives all of them.

## Response Format

```text
ASIDE: <the question, restated in a few words>

<answer>

Back to: <the parked step, one line — or "no task in progress">
```

An ambiguous question earns exactly one clarifying question, the shortest one that unblocks an answer.
