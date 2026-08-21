# Gate Review Protocol

**Version:** 1.0.1 — 2026-08-21 (loader pin only, §0; the SPEC v2.5 amendments — clean-room
invocation, §3 Step 0, owner-acknowledgement recording, second-model pass — are pending). v1.0 is
the 2026-08-18 text (SPEC v2.4).

**Purpose.** The standard an independent reviewer applies at **Gate G5**, the hard approval
gate before any building begins (`SPEC.md` §10 Phase 5, `ROADMAP.md` §7). This file is the
review standard of record: it is versioned, and an auditor answering "what standard was
applied at G5" reads this file at the commit the gate was decided.

**Authority.** G5's verdict is the reviewer's, not the executor's. `ROADMAP.md` §10 rule 2
makes G5 a hard gate — Phase 6 work of any kind before a recorded G5 approval is a process
violation, and that is unchanged by who reviews.

---

## 0. Reviewer loader pin

The reviewer is loaded from an agent definition that lives **outside this repository**:
`.claude/agents/gate-reviewer.md` at the project root, one level above the repository root
(`SPEC.md` §3 admits no `.claude/` entry — ADR-025, Consequences). This section makes that
file tamper-evident: the standard is versioned here, and the loader that points at it is
pinned here.

| Item | Value |
|---|---|
| Loader | `.claude/agents/gate-reviewer.md` at the project root (one level above this repository); an invocation supplies its **absolute** path — never a `../` path, which resolves against the caller's own directory |
| sha256 | `466587e533de6f73ac85fab0a53620f894988585f9c3e295d7c59092d5e586ec` |
| Size | 2,376 bytes |
| Pinned | 2026-08-21 |

1. The loader is **READ-ONLY**. A change to the loader is a change to this table, landed by
   pull request so the diff is reviewed where the standard lives; nobody edits the loader in
   place and then invokes it.
2. Before every invocation the executor recomputes the digest (`sha256sum <loader>`) and
   compares it with this table. A mismatch stops the invocation: the gate is not run until the
   owner has reviewed the loader diff. (The reviewer-side check — §3 Step 0, an automatic
   `REJECTED` on mismatch — lands with SPEC v2.5.)
3. **Registration.** Claude Code discovers project subagents only between the working
   directory and the repository root, so a session started inside `04-master` never sees the
   project-root loader. Sessions that will invoke the reviewer are launched with
   `claude --add-dir <project-root>`; on 2026-08-21 an in-session `/add-dir` did not register
   the agent in the running session — launch-time `--add-dir` is the supported route.
4. **Residual.** A `--agents` CLI override outranks project agents and is not detectable by a
   file digest; the owner's launch command is the control for that.

---

## 1. Independence

The reviewer's whole value is that it did not do the work. Three rules protect that, and
violating any one of them makes the review worthless rather than merely weak:

1. **Artifacts only.** The reviewer reads `eval/matrix.csv`, `eval/triage-log.md`,
   `eval/rubric.md`, `SPEC.md`, `ROADMAP.md`, and upstream sources at their pinned SHAs.
   It does **not** receive the executing agent's reasoning, session transcript, commit
   messages, or pull-request narrative.
2. **No conclusions in the prompt.** The invocation states the gate and the artifact paths.
   It **MUST NOT** state that the criteria are met, summarize what the executor found, or
   otherwise supply the answer the reviewer exists to derive. A prompt that says "verify
   these all pass" has already failed this rule.
3. **Re-derive, never confirm.** Every verification criterion is computed from the
   artifacts by the reviewer. The executor's claim that a check passed is not evidence that
   it passed; it is the claim under review.

> **Why this is written down.** The Phase-2 audit (2026-08-18) scored 55 skill files and
> shortlisted 29. Two of those shortlists — `vercel/find-skills` and
> `superpowers/using-git-worktrees` — were hard-reject violations (HR-6, HR-7) that
> survived because the executor profiled the files rather than reading them, then reported
> the coverage claim with confidence. They were caught only when a second reader went back
> to the sources. A reviewer that inherits the executor's framing reproduces exactly that
> failure. One that reads the artifacts cold does not.

---

## 2. Inputs

| Input | Path |
|---|---|
| Final scored matrix | `eval/matrix.csv` |
| Rejection history | `eval/triage-log.md` |
| Scoring rubric | `eval/rubric.md` |
| Governing spec | `SPEC.md` (§4 boundaries, §6 policy, §9 rubric, §10 phases) |
| Phase criteria | `ROADMAP.md` §7 (V5.1–V5.7) and §10 |
| Pin state | `upstream.json` |
| Upstream sources | Cloned at the `upstream.json` pinned SHA, read-only |

---

## 3. Required checks

### 3.1 The verification table, re-derived

`ROADMAP.md` §7 defines V5.1–V5.7. Compute each from the artifacts. Report the value found,
not a pass/fail assertion — "zero empty verdict cells across 55 rows" is a finding; "V5.1
passes" is not.

| # | Check |
|---|---|
| V5.1 | Zero empty `verdict` cells; every value in the §9 enum |
| V5.2 | Zero duplicate `id` values |
| V5.3 | Every row fully scored, each axis an integer 1–5 |
| V5.4 | Every shortlist row: empty `hard_reject`, no axis < 3, exactly one owning plugin |
| V5.5 | All 10 repos represented or explicitly dispositioned |
| V5.6 | Shortlist implies ≤ 1 hook per plugin, hooks only in `super-saiyan` and `rinnegan` (D-15) |
| V5.7 | Every core plugin has ≥ 1 shortlisted component or a recorded plan for original work |

### 3.2 Adversarial source spot-check — mandatory

A matrix can be internally consistent and still wrong about what it describes; §1's worked
example is exactly that failure. Independently verify **at least eight** shortlisted rows,
chosen by the reviewer, against the upstream file at its pinned SHA. Selection **MUST**
favour rows where a wrong score is most costly:

- rows whose rationale claims "pure prompt", "zero dependencies", or "no shell side effects"
- rows whose skill directory contains siblings — `scripts/`, `*.js`, `*.sh`, `*.json`
- rows scoring 5 on `risk` or `dependencies`
- rows a hard reject would plausibly have caught: anything invoking a package manager, a
  network host, a background process, or a write outside the project directory

For each, state the file read, the SHA, and whether the row's scores and `hard_reject` hold.

### 3.3 Policy conformance

- Every `verdict = reject` row has exactly one `eval/triage-log.md` entry whose trigger-ID
  field carries at least one rule ID (`SPEC.md` §10 Phase 2 exit criterion).
- No shortlisted component triggers HR-1…HR-8 on the reviewer's own reading of §6.
- Every shortlisted row's `target_plugin` is one owner, consistent with §4's B-1…B-8.
- `merge` and `defer` rows name their target or blocking check per §9 rule 3 and D-21.

### 3.4 Scope discipline

Shortlisted is not accepted. Confirm the shortlist the gate approves is the shortlist the
build plan proposes to synthesize — no component appears in the build plan that the matrix
did not shortlist.

---

## 4. Verdict

Exactly one of:

- **`APPROVED`** — every check in §3 holds on the reviewer's own derivation. Opens Phase 6.
- **`REJECTED`** — one or more checks fail, or the source spot-check contradicts a row.
  Names every failing check with its rule ID and the artifact location, so remediation is
  mechanical rather than interpretive.

`REJECTED` is not a soft signal. Per `ROADMAP.md` §10 rule 3 it loops the phase with noted
remediations, and no Phase 6 work may begin.

A finding the reviewer cannot resolve from the artifacts is reported as a finding, not
waived and not assumed benign. Uncertainty argues for `REJECTED`, because the cost of a
wrongly approved shortlist is a marketplace built on it.

---

## 5. Escalation

The reviewer decides G5. It does not decide indefinitely.

1. First `REJECTED` — the executor remediates and resubmits.
2. Second `REJECTED` **on the same gate** — the gate escalates to the project owner, with
   both review records and the executor's remediation attached. A reviewer and an executor
   that cannot converge in two rounds have a disagreement a human should settle.

The executor **MUST NOT** re-invoke the reviewer a third time on the same gate in place of
escalating, and **MUST NOT** narrow the resubmission to only the parts the reviewer
questioned — the whole gate is re-reviewed each round.

---

## 6. Recording

- The verdict gets a `ROADMAP.md` §11 Gate Log row: gate, date, verdict, record pointer.
- **G5's approval is recorded as an ADR in `DECISIONS.md`** (`SPEC.md` §10, `ROADMAP.md`
  §10 rule 3). That ADR is the authorization; the gate-log row is an index to it. The ADR
  states that the reviewer approved under this protocol, at this file's committed version.
- A `REJECTED` verdict is recorded too — a gate-log row and the findings — so a later
  auditor sees the loop, not just the eventual approval.
