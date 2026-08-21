# Evaluation Rubric

**Instrument for scoring every candidate component during build phases 2–4.**

**Normative source:** `SPEC.md` §6 (policy) and §9 (axes, thresholds, verdict enum, matrix header). This file is the human-readable guide to §9; it does not amend it. Where this file and `SPEC.md` §9 differ, §9 wins and this file is corrected.

**Machine-readable mirror:** `eval/rubric.json`. The two must never disagree — the axis `question` strings and the 1/3/5 anchor strings are copied from §9 into both, and `scripts/validate.*` check R1 compares them.

**Where output lands:** scores go to `eval/matrix.csv`; rejections and audit history go to `eval/triage-log.md`.

---

## 1. Scoring Procedure

1. Read the component **at the pinned SHA** recorded in `upstream.json` — never at branch HEAD. If `upstream.json` still carries `null` commits, stop: `scripts/pin-upstream.*` has not been run and no audit is reproducible (§8).
2. **Policy screen first.** Check every hard reject, HR-1…HR-8. Any hit sets `hard_reject` to the comma-joined list of triggering IDs and forces `verdict = reject`. §9 rule 1 makes this unappealable at audit time: a hard reject fires "regardless of scores".
3. **Score all five axes anyway**, 1–5, using the §2 anchors — including on a hard-rejected row. §9 says the verdict overrides the scores, not that the scores are skipped, and `ROADMAP.md` V2.3 and V5.3 require every row to carry all five axis scores. A hard-rejected component typically scores `risk = 1` on the anchor text, but that is an observation, not a rule.
4. If conditional triggers C-1…C-3 apply, audit each against its full checklist. Per the §9 Risk anchors, conditional behavior passing every check scores 3; conditional behavior failing at least one check scores 1.
5. Assign exactly one owning plugin from the nine Tier-1 names, per the B-1…B-8 boundaries. A component that fits none, or two equally well, is not shortlistable (§4).
6. Apply the verdict rules (§4 below) and write the matrix row.

**One effective row per component.** `eval/matrix.csv` records current state, not history: a re-audit **replaces** the component's row in place, keeping the same `id`. The superseded scoring, the reason for re-auditing, and the SHA it was re-read at are recorded in `eval/triage-log.md`, which is the append-only surface. `ROADMAP.md` V5.2 checks the matrix for duplicate IDs on that basis.

**Provenance.** Ratified — SPEC v2.2, D-20 (formerly open as A-GAP-002): the §9 header is byte-exact and has no column for the pinned SHA, the auditor, or the date, and §9 rule 4 now places provenance outside the matrix — the SHA in `upstream.json.pinned_at` and the `repos[].commit` values, and the auditor and date in the `eval/triage-log.md` entry. The header is immutable; never add columns to `matrix.csv` to solve it (ADR-020).

Versioning: `rubric.json`'s `version` tracks the §9 scoring payload only (axes, anchors, thresholds, verdict enum) and bumps only when that payload changes; it is deliberately decoupled from the SPEC version. Candidate §14 clarification row for a future spec revision.

---

## 2. Axes and Anchors

Every candidate is scored 1–5 on each axis. **Polarity is uniform: 5 is always best.** `3` is the shortlist floor on every axis (§9 rule 2).

The **1 / 3 / 5** anchors below are copied verbatim from `SPEC.md` §9 and are normative. The **2 / 4** rows are labelled interpolations supplied by this guide for scorer calibration only; they are not in §9 and carry no normative force. Where an interpolation seems to conflict with a §9 anchor, score to the §9 anchor.

### Value — *Does it solve a real, recurring problem for general users?*

| Score | Anchor | Source |
|---|---|---|
| 5 | Recurring problem for nearly all users and stacks | §9 |
| 4 | Between 3 and 5: recurring for a broad majority, not quite universal | interpolation |
| 3 | Useful in some common workflows | §9 |
| 2 | Between 1 and 3: narrow, occasional value for a minority | interpolation |
| 1 | Niche/one-off; useful in a single project type | §9 |

### Bloat — *Token/context overhead vs. payoff; instruction-file size discipline*

| Score | Anchor | Source |
|---|---|---|
| 5 | Minimal tokens; tight instructions; pay-for-use | §9 |
| 4 | Between 3 and 5: lean, modest size fully justified by payoff | interpolation |
| 3 | Moderate footprint, loaded on demand | §9 |
| 2 | Between 1 and 3: sprawling or padded, though not always loaded | interpolation |
| 1 | Large always-loaded instruction files; heavy context tax | §9 |

### Risk — *Policy check against §6*

| Score | Anchor | Source |
|---|---|---|
| 5 | Pure skills/commands; read-only; no shell side effects | §9 |
| 4 | Between 3 and 5: executes or writes within §6 bounds with no conditional trigger raised | interpolation |
| 3 | Conditional behaviors passing all C-1…C-3 checks | §9 |
| 2 | Between 1 and 3: conditional behavior whose audit is incomplete or not settleable from a static read | interpolation |
| 1 | Conditional-category behavior failing ≥1 check | §9 |

### Dependencies — *Zero-dependency preferred; allowed exceptions only*

| Score | Anchor | Source |
|---|---|---|
| 5 | Zero dependencies beyond Claude Code | §9 |
| 4 | Between 3 and 5: only ambient tooling already required to use the repo (git, POSIX or PowerShell built-ins) | interpolation |
| 3 | Uses an allowed exception (Obsidian/Context7) | §9 |
| 2 | Between 1 and 3: a third-party CLI that is widely present but outside P-5 | interpolation |
| 1 | Requires anything outside P-5 exceptions | §9 |

### User-scope fit — *Useful across any project, language, and stack?*

| Score | Anchor | Source |
|---|---|---|
| 5 | Universal | §9 |
| 4 | Between 3 and 5: any project type, with trivial assumptions such as "a git repository exists" | interpolation |
| 3 | Broad but with stack assumptions | §9 |
| 2 | Between 1 and 3: leans on one ecosystem, partial value elsewhere | interpolation |
| 1 | Project- or language-specific | §9 |

---

## 3. Policy Triggers

The policy itself is `SPEC.md` §6. The tables below are the audit-time index into it, by ID.

### Hard reject — any single hit fails the component (§9 rule 1)

| ID | Trigger |
|---|---|
| HR-1 | Third-party API keys, external services, or accounts |
| HR-2 | MCP servers beyond Obsidian, Context7, and Claude Code |
| HR-3 | LSP servers or language-specific tooling at user scope |
| HR-4 | Background daemons, workers, watchers, or services |
| HR-5 | sqlite/native binary dependencies |
| HR-6 | Telemetry, analytics, or network calls of any kind. Sole exception: `scripts/pin-upstream.*` and `.github/workflows/upstream-watch.yml`, which are repo-maintenance tooling, not shipped plugin components |
| HR-7 | Auto-installing packages or runtime dependency fetching |
| HR-8 | Hooks that write outside (a) the project directory or (b) the owning plugin's own data directory under the user's Claude config dir (**D-18**). Any other write target is rejected |

The HR-8 carve-out is not optional shorthand: omitting it re-creates the contradiction D-18 resolved and would reject `rinnegan`'s budgeted memory hook (ADR-018).

### Conditional — audited, kept only if all pass

| ID | Trigger | Pass requires |
|---|---|---|
| C-1 | Hooks executing shell commands | Idempotent; read-only by default; timeout-bounded (repo standard ≤ 10 s); cross-platform on Windows 11 PowerShell 7 and WSL2 bash; within the D-15 budget |
| C-2 | Subagents | Restricted tool allowlists only; no bare `Bash(*)` or unrestricted `Write(*)`. Enforced mechanically by `schemas/agent.schema.json` |
| C-3 | File writes | Inside the project directory, the owning plugin's data directory (HR-8/D-18), or explicit user-approved locations only |

### Every component — regardless of scores

| ID | Check |
|---|---|
| E-1 | Static review for prompt-injection patterns ("always run X without asking"), secrets handling, and obfuscation |
| E-2 | Passes `scripts/validate.*` (structure, frontmatter, naming, policy lint) before merge |

---

## 4. Verdict Rules

The enum is frozen by `SPEC.md` §9 rule 3 (D-21): `shortlist` | `reject` | `merge` | `defer`. No other value may appear in the `verdict` column.

| Verdict | Rule | Mandatory companion |
|---|---|---|
| `shortlist` | No hard-reject hit **and** every axis ≥ 3 **and** exactly one owning plugin (§9 rule 2) | — |
| `reject` | Any HR-1…HR-8 hit, or deficiencies synthesis cannot fix | An `eval/triage-log.md` entry citing the rule IDs (§10 Phase 2) |
| `merge` | The candidate's value is fully absorbed by another candidate | **Name the absorbing candidate** in `rationale`, by its matrix `id` |
| `defer` | Audited, but the decision waits on a named blocking check | **Name the blocking check ID and the phase** in `rationale` (§9 rule 3); the Phase 5 sign-off ADR enumerates every open `defer` |

Shortlisted components are **candidates for synthesis**, not accepted content — final inclusion happens only at the §10 Phase 5 independent-reviewer approval gate (`ROADMAP.md` G5, D-25), whose sign-off is recorded as an ADR and stays provisional until the project owner acknowledges it.

A rejected component's *concept* may still be re-donated through a rebuild (the claude-mem pattern). The rebuild enters the matrix as a new row with `component_type = concept`, owned by the receiving plugin.

**Ratified — SPEC v2.2, D-21 (formerly open as A-GAP-003).** Some C-1…C-3 checks — idempotence, timeout behavior, real cross-platform execution — cannot be settled from a static read. §9 rule 3 now rules on it directly: use `defer`, naming the blocking check ID and the phase in which the check will be performed. A named `defer` satisfies §10 Phase 5's "zero empty `verdict` cells" and no non-rejection is written into the triage log as a rejection, but the Phase 5 sign-off ADR must enumerate every open `defer`. Set A's `hold` value is not adopted; adding one would still require a D-16 spec PR (ADR-021).

---

## 5. Matrix Column Dictionary (`eval/matrix.csv`)

The header is byte-exact per `SPEC.md` §9 — thirteen columns, in this order, no additions, no renames:

```csv
id,source_repo,component_path,component_type,target_plugin,value,bloat,risk,dependencies,user_scope_fit,hard_reject,verdict,rationale
```

| Column | Type | Rule |
|---|---|---|
| `id` | string | Stable, unique per component: `<source-slug>/<component-name>`, kebab-case per N-3. One effective row per `id` |
| `source_repo` | string | The `name` of a repo object in `upstream.json` |
| `component_path` | string | Path within the source repo, at the pinned SHA |
| `component_type` | enum | `skill` \| `command` \| `agent` \| `hook` \| `template` \| `concept` (§9) |
| `target_plugin` | enum | Exactly one of the nine Tier-1 plugin names, or empty when no single owner exists — which forbids `shortlist` (§9 rule 2) |
| `value` | int 1–5 | Per §2 anchors |
| `bloat` | int 1–5 | Per §2 anchors |
| `risk` | int 1–5 | Per §2 anchors |
| `dependencies` | int 1–5 | Per §2 anchors |
| `user_scope_fit` | int 1–5 | Per §2 anchors |
| `hard_reject` | string | Empty, or a comma-joined list of HR IDs (§9) |
| `verdict` | enum | `shortlist` \| `reject` \| `merge` \| `defer` (§9 rule 3) |
| `rationale` | string | One or two sentences citing rule IDs and the deciding axis. Quote the field if it contains a comma |

Mechanical consistency, enforced by `scripts/validate.*` check M-group against `rubric.json`:

- non-empty `hard_reject` ⇒ `verdict = reject`
- `verdict = shortlist` ⇒ empty `hard_reject`, every axis ≥ 3, and a non-empty `target_plugin`
- `verdict = merge` or `defer` ⇒ `rationale` is non-empty
- every axis value is an integer in 1–5; every `component_type` and `verdict` is in its enum

---

## 6. Hard-Reject Procedure

1. Identify the triggering rule IDs. Record them comma-joined in `hard_reject`.
2. Set `verdict = reject`.
3. Score all five axes anyway (§1 step 3).
4. Write an `eval/triage-log.md` entry using the `### T-NNN` template, whose **HR/axis trigger IDs** field carries the same IDs. §10 Phase 2's exit criterion — "every `reject` has a triage-log entry citing rule IDs" — is satisfied by that field, not by prose.
5. Where the rejection is a *bulk class* (for example ECC's language packs), log the class once in aggregate with its rule ID and the count, per §10 Phase 3.

---

## 7. Calibration Examples

Worked examples for scorer calibration, grounded only in facts already established by `SPEC.md` §8. They are **not** audit records — formal rows are produced only in build phases 2–4, and none of these appears in `eval/matrix.csv` or `eval/triage-log.md`.

**Example A — `reject`.** claude-mem's persistence layer: a sqlite database plus a background worker on the bun runtime (§8 names all three as reject-on-sight). Policy screen hits HR-4 (workers) and HR-5 (sqlite, native binary). Row: `hard_reject = HR-4,HR-5`, `verdict = reject`, axes still scored (`risk = 1` on the §9 anchor, `dependencies = 1`), rationale "Automatic fail on daemon and native-binary triggers (HR-4, HR-5); the memory concept is re-donated to the rinnegan file-based rebuild." The concept survives; the implementation does not. The rebuild enters later as a separate row with `component_type = concept`, `target_plugin = rinnegan`.

**Example B — `shortlist`.** A skill-authoring meta-skill from the `superpowers` writing-skills lineage, which §4 assigns to `instinct`. Illustrative scoring: value 5 (improves every skill authored after it), bloat 4 (lean, single file), risk 5 (pure prompt, no shell side effects), dependencies 5 (none), user_scope_fit 5 (project-agnostic). No HR hit, no conditional trigger, exactly one owner → `verdict = shortlist`.

**Example C — `defer`.** A candidate hook whose C-1 audit cannot be completed from a static read: idempotence and timeout behavior are asserted but unverifiable without executing it on both platforms. No HR hit. Axes scored, `risk = 2` (interpolated: conditional audit incomplete). Row: `verdict = defer`, rationale "C-1 idempotence and timeout unverifiable from a static read; settle in Phase 5 by executing on Windows 11 and WSL2 before the G5 gate." The named phase is mandatory (§4).

**Example D — `merge`.** Two ECC commands covering the same planning step, one a strict superset of the other. The narrower row takes `verdict = merge`, rationale "Fully absorbed by `ecc/plan-prp`; no unique capability remains." Naming the absorbing row's `id` is mandatory (§4), so the shortlist stays traceable to every candidate it consumed.
