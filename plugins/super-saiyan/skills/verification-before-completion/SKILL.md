---
name: verification-before-completion
description: Gate that runs before any claim that work is done, fixed, passing, or shipped. Identifies the command that would prove the claim, runs it fresh, reads the whole output, and only then reports — with the evidence attached and any gap stated. Use before committing, opening a pull request, marking a task complete, or telling the user something works.
allowed-tools: [Read, Grep, Glob]
---

# Verification Before Completion

## Purpose

A status report is a claim, and a claim without fresh evidence is a guess dressed as a fact. This skill sits between
finishing the work and describing it: it names the check that would prove each claim, runs that check now, reads
the full result, and reports what the result actually shows. It also carries a short self-assessment so that gaps
are surfaced by you rather than by the user. It does not fix what it finds — it reports, and the fix goes through
the ordinary workflow.

## Trigger Conditions

Use this skill before any sentence that implies success: "done", "fixed", "passing", "ready", "deployed", or their
paraphrases; before a commit, a pull request, or moving to the next task; and whenever you notice yourself writing
"should work" or "looks correct".

Do not use it as a substitute for test-driven development or debugging; those produce the evidence this skill
demands.

## Workflow

1. List the claims. Write down each thing you are about to assert: tests pass, build succeeds, lint is clean, the
   bug no longer reproduces, every requirement is met, the change is live.
2. Pair each claim with its proof. Use the table below. If no command can prove a claim, the claim is downgraded to
   an observation with its evidence gap stated.
3. Run the proof now. In this turn, the complete command, not a cached or partial run. Run the project's own build,
   type check, lint, and test commands in that order, then read the diff of every changed file for unintended
   edits, leftover debug output, and credentials.
4. Read everything. Exit code, failure count, warnings, and the last lines of output. A run that exited 0 with a
   warning you did not read is not verified.
5. Distinguish "exited 0" from "live". A deploy or restart command that returned success proves the command ran. It
   does not prove the new code is serving. If the claim is "shipped", check the running system — version string,
   health endpoint, a request that exercises the change — before saying so, and say which check was made.
6. Self-assess against the request. Re-read the original ask and judge the result on accuracy, completeness,
   clarity, and actionability. Any weakness is named with its specific evidence ("the timeout path has no test"),
   never as a vague "could be better". Judge against what was asked, not against what could additionally have
   been built.
7. Report with the evidence attached. If the proof failed, report the actual state; if it passed, report the claim
   together with the command and the relevant output.

## Claim to Proof

| Claim | Sufficient evidence | Not sufficient |
|---|---|---|
| Tests pass | Full suite run in this turn, zero failures shown | An earlier run, "should pass", a subset |
| Build succeeds | Build command exit 0 read from output | Lint passing, editor showing no errors |
| Lint and types clean | Linter and type checker output with zero errors | A partial directory, extrapolation |
| Bug fixed | Original reproduction passes; the test failed before the fix | Code changed, symptom assumed gone |
| Regression test works | Seen red without the fix, green with it | A test that passed the first time |
| Requirements met | Line-by-line checklist against the plan or spec | Tests passing |
| Shipped | Live system observed serving the new behaviour | Deploy command exited 0 |

## Rationalizations to Refuse

| Excuse | Reality |
|---|---|
| "I am confident" | Confidence is not evidence |
| "The linter passed" | The linter does not compile or test |
| "It passed earlier this session" | Only the tree you are about to hand over counts |
| "A partial check is enough" | A partial check proves the part, not the claim |
| "I am tired and it is surely fine" | Fatigue is when unverified claims slip through |

## Safety Checks

- Bash runs only the project's declared build, test, lint, and type-check commands and read-only git commands.
- No installation, no network, no process that outlives the turn.
- When scanning the diff for secrets, describe the location and kind of anything found; never reproduce the value.

## Output Contract

One line per claim in the form `claim — command — result`, followed by the self-assessment with at most one
concrete improvement per weakness, then the overall verdict: ready, or not ready with the list of what remains.
