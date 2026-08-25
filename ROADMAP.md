# ROADMAP.md — Awakened Build Phases

**Derived from:** `SPEC.md` §10 (Build Phases & Exit Criteria), §9 (Evaluation Rubric), §11 (Ongoing Maintenance).
**Rule:** phases execute in order; each phase ends at a gate (G1–G6). A gate closes only when every verification criterion passes and the gate decision is recorded per §11 below. **G5 is a hard approval gate — adjudicated by an independent reviewer (D-25), the sign-off recorded as an ADR in `DECISIONS.md`; Phase 6 stays barred until the owner acknowledges the reviewer's `APPROVED` on the sign-off PR (§10 Phase 5).**

Each phase below reproduces `SPEC.md` §10's exit criteria **verbatim** in a quoted block, then expands them into checkable verification rows. Where a verification row and the quoted criterion disagree, the quoted criterion wins.

## 1. Status Board

| Phase | Name | Status | Gate |
|---|---|---|---|
| 1 | Structural inventory | **Complete** (2026-08-15) | G1 — passed |
| 2 | Tier-1 deep audit | **Complete** (2026-08-18) — 55 rows, 27 shortlist / 25 reject / 3 merge | G2 — passed |
| 3 | ECC triage + claude-mem extraction | **Complete** (2026-08-22) — 285 ECC skills dispositioned, 40 deep-read (15 shortlist / 2 merge / 23 reject), `eval/claude-mem-rebuild.md` written | G3 — passed |
| 4 | Remaining sources | **Complete** (2026-08-22) — three passes: ECC `commands/`+`agents/`, wshobson, anthropics, the gap scan, and davila7. 225 rows, T-070…T-273; matrix 322 rows, 100 shortlist / 207 reject / 15 merge | G4 — passed |
| 5 | Evaluation matrix consolidation | **In progress** (2026-08-25) — matrix consolidated at 322 rows, **96 shortlist / 210 reject / 15 merge / 1 defer** after G5 round 1; `eval/shortlist.md` written (SPEC v2.8); T-274…T-281 | **G5 — independent-reviewer gate + owner ack** — round 1 `REJECTED`, remediated, resubmitted |
| 6 | Scaffold & synthesize | Not started | G6 |

## 2. Foundation Suite — Entry Criteria for Phase 2

Before Phase 2 begins, the governance, evaluation, schema, template, and legal foundation must be committed. The foundation is the 28 authored files plus `SPEC.md` shipped verbatim (D-16) — the count is historical, taken at Phase-2 entry; the tree has since gained `eval/gate-review-protocol.md` (SPEC v2.4), `.github/workflows/validate.yml` (SPEC v2.5) and `eval/claude-mem-rebuild.md` (SPEC v2.6):

| Group | Contents |
|---|---|
| Governance | `CLAUDE.md`, `CONTEXT.md`, `DECISIONS.md`, `ROADMAP.md`, `SPEC.md` (verbatim) |
| Evaluation harness | `upstream.json`, `eval/rubric.md`, `eval/rubric.json`, `eval/matrix.csv`, `eval/triage-log.md` |
| Schemas, scripts, attributes | `schemas/marketplace.schema.json`, `schemas/plugin.schema.json`, `schemas/skill.schema.json`, `schemas/agent.schema.json`, `scripts/validate.sh`, `scripts/validate.ps1`, `scripts/pin-upstream.sh`, `scripts/pin-upstream.ps1`, `.gitattributes` |
| Templates | `templates/plugin/plugin.json`, `templates/skill.md`, `templates/command.md`, `templates/agent.md`, `templates/hook.json` |
| Legal & contribution | `LICENSE`, `NOTICE`, `SOURCES.md`, `CONTRIBUTING.md`, `README.md` |

**Phase 2 entry check (all three, in order):**

1. All foundation files committed to `coltonbearden/awakened`.
2. `bash scripts/validate.sh` and `pwsh -File scripts/validate.ps1` both exit 0 on the committed tree, each on its own platform. This has not yet been executed on Windows 11; the Windows leg is an open entry-check item, not a completed one.
3. `bash scripts/pin-upstream.sh` has been run and `upstream.json` reports ten non-null `commit` values with a non-null `pinned_at` — the §10 Phase-2 exit criterion depends on it, and no SHA may be written by any other means (§8).

---

## 3. Phase 1 — Structural Inventory ✔ Complete

**Objective.** Crawl all 10 source repositories; map structure, component counts, and licenses.

> **Exit criteria (`SPEC.md` §10, verbatim):** All 10 repos crawled; structure, counts, licenses mapped.

**Delivered (evidence: `SPEC.md` §8).**

- All 10 repos inventoried with role, license, and mining or reject notes.
- Component-scale figures recorded in §8 for superpowers, mattpocock, ECC, wshobson, and kepano.
- Reject classes identified up front: ECC's 22 language packs and 41KB hooks.json; claude-mem's sqlite/bun/workers/docker/cloud-sync; davila7's npm CLI and analytics.

**Verification (passed).**

| # | Check | Expected | Result |
|---|---|---|---|
| V1.1 | §8 table coverage | 10 rows, each with role, license, and notes | 10/10 |
| V1.2 | Reject classes documented | ECC, claude-mem, davila7 caveats recorded | Recorded in §8 |

**Gate G1:** passed 2026-08-15 by ratification of `SPEC.md`.

---

## 4. Phase 2 — Tier-1 Deep Audit

**Objective.** Read **every skill file** in the four Tier-1 quality sources at their pinned SHAs and score each against the §9 rubric.

> **Exit criteria (`SPEC.md` §10, verbatim):** `upstream.json` SHAs pinned (no nulls); one `matrix.csv` row per skill file in all four repos; every `reject` has a triage-log entry citing rule IDs; §0 official-docs verification complete — the five `UNVERIFIED-EXTERNAL` assumptions (synthesis HD-9) adjudicated, the hook dispatch mechanism decided (HD-5) via a §14 changelog row, and all ten §8 licenses re-verified against the pinned commits (HD-10).

**Scope.** `obra/superpowers`, `mattpocock/skills`, `kepano/obsidian-skills`, `vercel-labs/skills` — the four repos §10 Phase 2 names. Per-repo file counts are not asserted here: they are determined by reading the repositories at their pinned SHAs, and §8's figures are approximate role notes, not audit targets.

**Deliverables.**

- One `eval/matrix.csv` row per skill file in the four repos, scored 1–5 on all five §9 axes, with `hard_reject`, `verdict`, `target_plugin`, and `rationale` populated.
- `eval/triage-log.md` entries for every `reject`, each citing the rule IDs that disqualified it.
- `poneglyph` confirmation pass: kepano's skills verified against §6 before EXC-1 is exercised.

**Verification criteria.**

| # | Check | Expected |
|---|---|---|
| V2.1 | Pin state | `upstream.json`: 10 repos, zero null `commit` values, non-null `pinned_at`; written by `scripts/pin-upstream.*` only |
| V2.2 | Coverage | Exactly one matrix row per skill file across the four repos; zero skill files unrepresented |
| V2.3 | Score completeness | 100% of rows carry all 5 axis scores, each an integer 1–5 |
| V2.4 | Reject traceability | Every row with `verdict=reject` has a triage-log entry citing at least one rule ID |
| V2.5 | Shortlist integrity | Zero shortlisted rows with any axis < 3 or any non-empty `hard_reject` |
| V2.6 | Ownership | Every shortlisted row names exactly one owning plugin from the nine Tier-1 names (B-1…B-8) |
| V2.7 | Pin stability | `upstream.json` SHAs unchanged during the audit; any re-pin logged in `eval/triage-log.md` |
| V2.8 | §0 assumptions | The five `UNVERIFIED-EXTERNAL` assumptions (synthesis HD-9) adjudicated against the live official docs; each outcome recorded, and any conflict with §3's structural assumptions raised as a `SPEC-GAP` |
| V2.9 | Hook dispatch | The cross-platform hook dispatch mechanism (HD-5, `B-GAP-002`) decided and landed as a `SPEC.md` §14 changelog row through the D-16 PR flow |
| V2.10 | License re-verification | All ten §8 licenses re-verified against the pinned commits (HD-10); any discrepancy corrected by a spec PR, never an ADR |

**Gate G2 (human review):** owner reviews matrix and triage log; approves Phase 3.

---

## 5. Phase 3 — ECC Triage + claude-mem Extraction ✔ Complete

**Objective.** Two-pass ECC reduction — breadth triage of the full skill set, then deep reading of the shortlist only — and extraction of claude-mem's memory concepts into a documented file-based rebuild design for `rinnegan`.

> **Exit criteria (`SPEC.md` §10, verbatim):** ECC shortlist ≤ 40 rows deep-read (bulk rejects logged in aggregate); file-based rebuild design written to `eval/claude-mem-rebuild.md`.

**Deliverables.**

- **ECC triage pass 1 (breadth):** every ECC skill dispositioned `shortlist` or `reject` with a reason class. §8's pre-identified mining targets are prioritized (sessions, plan/prp family, build-fix, code-review, hookify, security-scan, project-init); §8's pre-identified reject classes are disposed without deep reads (22 language packs, 41KB hooks.json, dashboards, domain-niche skills), logged in aggregate.
- **ECC deep read (depth):** full rubric scoring appended to `eval/matrix.csv` for shortlist rows only — **at most 40 rows**.
- **claude-mem extraction:** concept inventory (session memory, searchable history, recall) and the file-based rebuild design written to `eval/claude-mem-rebuild.md`.

**Verification criteria.**

| # | Check | Expected |
|---|---|---|
| V3.1 | Triage coverage | 100% of ECC skills dispositioned; bulk rejects logged in aggregate with a reason class |
| V3.2 | Shortlist cap | Deep-read shortlist ≤ 40 rows |
| V3.3 | Deep-read discipline | Fully scored ECC rows exist only for shortlisted components |
| V3.4 | Reject rationale | Every reject class carries a rule-ID rationale in `eval/triage-log.md` |
| V3.5 | Artifact path | The rebuild design exists at exactly `eval/claude-mem-rebuild.md` |
| V3.6 | Rebuild completeness | The design specifies storage layout (plain files), capture flow, recall/search flow, and an explicit dropped-features map (sqlite, bun, workers, docker, cloud sync → each mapped to a file-based replacement or an intentional omission) |
| V3.7 | Policy proof | The design demonstrates zero daemons, databases, or network calls, checked line by line against HR-1…HR-8, and states its hook's write targets under D-18 |

**Delivered (evidence: PR #10, merged `5cf3087`).** 285 canonical ECC skills dispositioned exactly once — 40 deep-read, 245 in seven aggregate classes (T-030…T-036); two further classes cover what sits outside the denominator — T-029 the 612 translation and harness duplicates, T-037 the 41KB `hooks.json`; `eval/matrix.csv` 55 → 97 rows; `eval/triage-log.md` T-028 → T-063; `eval/claude-mem-rebuild.md` written. ECC carries 897 `SKILL.md` files at the pin, of which 285 are canonical and 612 are translation and cross-harness duplicates; the arithmetic is recorded in the triage-log Phase-3 preamble.

**Verification (passed).** V3.1 285/285 dispositioned across seven in-denominator classes plus 40 deep reads. V3.2 exactly 40 rows — the cap bound, and the margin was named rather than silently dropped. V3.3 scored ECC rows exist only for deep-read components. V3.4 8/9 class entries carry rule-ID triggers; the ninth, T-029, carries a stated `n/a` because it rejects nothing — it records the 612 duplicates that are the same components at other paths. V3.5 the file exists at exactly that path. V3.6 all four parts present, the dropped-features map covering the five named features and twelve more. V3.7 §6 checks HR-1…HR-8 one row each, states the hook's D-18 write targets, and declares the 10-second timeout.

**Gate G3:** **APPROVED** 2026-08-22 under standing delegation D11 (D-25 moved only G5). Review record: PR #10; scope change arising at the gate recorded as D-26 / ADR-026 per §10 rule 4.

---

## 6. Phase 4 — Remaining Sources ✔ Complete

**Objective.** Complete candidate coverage across the remaining sources.

> **Exit criteria (`SPEC.md` §10, verbatim):** Matrix rows appended for each; gap-scan findings appended to `eval/triage-log.md`.

**Scope note (SPEC v2.6, D-26).** §10 Phase 4's scope column gained ECC `commands/` and `agents/`. Phase 3 established that four of the seven §8 mining targets — the `sessions` family, `build-fix`, `code-review` and `project-init` — exist only under `commands/`, and that §4 names ECC's `agents/` as `bankai`'s lineage; without this widening no phase would audit them.

**Deliverables.**

- **wshobson/agents:** the shortlisted general-purpose categories audited and scored; agent candidates annotated with proposed restricted tool allowlists (C-2).
- **anthropics/skills:** reference patterns reviewed; skill-creator lineage findings recorded for `instinct`; NOTICE-relevant close adaptations flagged.
- **davila7/claude-code-templates:** components directory only; the npm CLI and analytics surfaces are out of scope per §8 and HR-6/HR-7.
- **hesreallyhim/awesome-claude-code:** gap scan — discovery only, not merge material. Output is a capability-gap list, each gap mapped to an owning plugin or marked out of scope, appended to `eval/triage-log.md`.
- **affaan-m/ECC `commands/` (94 files):** audited and scored at the pinned SHA. §8's mining targets that exist only here are prioritized — `sessions.md`, `save-session.md`, `resume-session.md`, `build-fix.md`, `code-review.md`, `project-init.md`, the `plan*`/`prp-*` family, `hookify*.md`, `security-scan.md`.
- **affaan-m/ECC `agents/` (68 files):** the general-purpose candidates audited and scored, annotated with proposed restricted tool allowlists (C-2) alongside wshobson's.

**Pass structure (owner decision, 2026-08-22).** Phase 4 runs as **three passes**, because the
remaining surface measures far larger than §8's role notes suggest — `davila7/claude-code-templates`
alone carries 3,220 skill, 421 agent and 346 command files under `cli-tool/components/`, more than
all of ECC. Pass 1: ECC `commands/` + `agents/`. Pass 2: `wshobson/agents`, `anthropics/skills` and
the `hesreallyhim/awesome-claude-code` gap scan. Pass 3: `davila7/claude-code-templates`.
**G4 closes only after all three**, so the gate log carries no Phase-4 row until then.

**V4.7 convention, settled 2026-08-22 (pass 1).** ECC rows use `ecc/cmd-<name>` for all 94 commands
and `ecc/agent-<name>` for all 68 agents, applied uniformly rather than only to the colliding names.
The source slug stays `ecc` because `eval/rubric.md` §5 fixes the `id` shape as
`<source-slug>/<component-name>` and the slug denotes the `upstream.json` repo that check U1 pins to
exactly ten; a slug like `ecc-cmd/` would name a repository that does not exist. Recorded in full,
with the measured collision set, in the `eval/triage-log.md` Phase-4 preamble.

**Pass 1 delivered (2026-08-22).** ECC read at the pin `06c5e118c4d3`, verified by `git rev-parse`
before any component was opened. 162 canonical components — 94 `commands/*.md` and 68
`agents/*.md` — dispositioned exactly once: 102 scored matrix rows (26 shortlist / 69 reject /
7 merge, zero `defer`) plus 60 in the three `SPEC.md` §8-ratified reject classes (T-070 the 22
language-pack commands, T-071 the 28 language-pack agents, T-072 the 10 domain-niche agents).
`eval/matrix.csv` 97 → 199 rows; `eval/triage-log.md` T-069 → T-148. `kaioken`'s roster goes from
one shortlisted row to five, which is the §4 lineage D-26 was written to reach.

**Pass 2 delivered (2026-08-22).** `wshobson/agents`, `anthropics/skills` and the
`hesreallyhim/awesome-claude-code` gap scan, all read at their pins after a `git rev-parse` check
(3/3 MATCH). wshobson was triaged at **category** level first, as §10's "shortlisted plugins"
wording requires: 91 plugin descriptions read, **17** categories selected, 31 rejected by name and
43 as language/framework/cloud/business packs. Those 17 hold 77 component files but only **68
distinct bodies** — six components are published in several plugins byte-identically,
`code-reviewer` in five. Id convention `wshobson/<plugin>-<component>`, which collides zero ways
where a bare component name collides six. anthropics measured **19** skills: 14 Apache-2.0, 4
proprietary (excluded by D-24), and one — `doc-coauthoring` — with **no LICENSE file at all**, which
is rejected and flagged for the owner. 83 rows appended (17 shortlist / 66 reject); matrix 199 →
**282** rows; triage T-148 → **T-238**. The `Gap-scan entries` statistic moves off zero for the
first time: 18 entries dispositioning all 157 catalog rows, 9 mapped to an owning plugin and 9 out
of scope, **zero merge candidates sourced from the catalog** (V4.4).

**Two findings from pass 2 worth carrying forward.** First, re-verifying against the live reference
under §0 disposed of the single largest family in the source: the 17 `agent-teams` components depend
on a feature that is **experimental and disabled by default**, and `team-lead` declares two tools the
reference says no longer exist. Second, pass 2 corrected pass 1: eight shortlisted ECC agent rows had
been assigned on the purpose each agent serves rather than on **B-6**, which gives `bankai` *all*
subagents. All eight were replaced in place (T-149); every `agent`-type row now targets `bankai`,
which holds **27** shortlisted rows.

**Still open for pass 3.** V4.1 and V4.2 cannot discharge until `davila7/claude-code-templates` is
audited — V4.1 names davila7 component candidates explicitly and V4.2 is entirely about its
components-directory boundary. **G4 closes after pass 3.**

**Pass 3 delivered (2026-08-22).** `davila7/claude-code-templates`, read at its pin after a
`git rev-parse` check (1/1 MATCH). The largest source in §8: **1,664** canonical components across
**82** category directories. §10 gives this source no shortlisted-category wording and no deep-read
cap, so the grounds used are the ones that bind in every phase — **B-1…B-8** and the §9
`user_scope_fit` anchor. 82 categories → 12 candidate (444 components), 70 class-rejected; a breadth
screen removed 181 (61 already dispositioned at their actual source, 79 vendor-bound, 41
language-bound); **40** of the surviving 263 were deep-read and the other **223 are named** in T-243.
The 40-cap is a stated method choice adopted by analogy to §10 Phase 3's ECC cap, not a §10 grant,
and is recorded as such. 40 rows appended — 14 shortlist / 24 reject / 2 merge. Two licensing
findings: the source re-hosts Anthropic's four source-available skills under an MIT root license
(T-244), and GPL-3.0 enters through FFmpeg in its media skills (T-245, the second V4.5 flag).

**Delivered (evidence: PR #13 `c5a9b46`, PR #16 `ebed336`, and this PR).** Phase 4 ran as three
passes. Pass 1 dispositioned ECC's 94 `commands/` and 68 `agents/` — 102 rows plus three §8-ratified
classes. Pass 2 took `wshobson/agents` (91 categories → 17, 68 distinct bodies from 77 files),
`anthropics/skills` (19 skills: 14 Apache-2.0, 4 proprietary excluded by D-24, one unlicensed) and
the `hesreallyhim/awesome-claude-code` gap scan — 83 rows and 18 gap entries. Pass 3 took davila7 —
40 rows. `eval/matrix.csv` 97 → **322** rows (100 shortlist / 207 reject / 15 merge); `eval/triage-log.md`
T-069 → **T-273**, the last entry being a sweep that corrected eleven unresolvable citations and four
trigger/row contradictions across the whole phase. **All ten §8
repositories are represented or dispositioned**: nine carry rows, and awesome-claude-code carries
none by design with its 157 catalog rows dispositioned as gap-scan entries. Zero `defer` rows exist.

**Verification (passed).** V4.1 all three pass-2/3 sources carry rows — wshobson 68, anthropics 15,
davila7 40 — and the only §8 repo at zero is awesome-claude-code, which V4.4 requires to be at zero.
V4.2 all 40 davila7 rows sit under `cli-tool/components/` and zero touch the CLI, `analytics-ui/`,
`dashboard/`, `cli-rust/` or `cloudflare-workers/`. V4.3 **29/29** shortlisted agent rows carry a
proposed restricted allowlist, each replayed against `schemas/agent.schema.json`'s C-2 regex — zero
bare grants and zero `Write` grants anywhere; all 29 target `bankai`, which B-6 requires and which
pass 2 corrected pass 1 to honour (T-149). V4.4 18 gap entries disposition all 157 catalog rows, 9
mapped to an owning plugin and 9 out of scope, with **zero** merge candidates sourced from the
catalog. V4.5 two NOTICE flags raised — `anthropics/brand-guidelines` and davila7's GPL-3.0 FFmpeg
dependency. V4.6 all 19 §8 ECC command-only targets carry a matrix row, zero unaccounted. V4.7 zero
duplicate ids across 322 rows, under three source-specific conventions settled before any row was
written — `ecc/cmd-*` and `ecc/agent-*`, `wshobson/<plugin>-<component>`, `davila7/<category>-<name>`.

**Gate G4:** **APPROVED** 2026-08-22 under standing delegation D11 (§10 rule 2; D-25 moved only G5).
Review record: PR #13, PR #16 and PR #17. One finding is carried into Phase 5 rather than closed
here: the three capability gaps the V4.4 scan surfaced (T-223, T-232, T-235).

**Correction (2026-08-22, same day).** PR #17 as merged also claimed a gap in this repository's own
`schemas/agent.schema.json` — that its `$comment` prohibits `hooks` and `mcpServers` for agents while
only `permissionMode` was actually declared. **That claim is false and is retracted.** All three
fields *are* declared and *are* enforced: `hooks` and `mcpServers` use the JSON Schema boolean form
`false`, which is semantically identical to `permissionMode`'s `{"not": {}}` and validates no
instance. Verified empirically with `jsonschema` 4.19.2: an agent carrying `hooks`, `mcpServers` or
`permissionMode` is rejected, and a clean agent validates. The error was in the probe, which treated
the falsy value `false` as an absent declaration. No schema change is needed and none was made.

**Verification criteria.**

| # | Check | Expected |
|---|---|---|
| V4.1 | Coverage | Matrix rows appended for all wshobson shortlisted categories, anthropics/skills patterns, and davila7 component candidates |
| V4.2 | davila7 boundary | Every davila7 row's `component_path` is inside the components directory; zero CLI or analytics rows |
| V4.3 | Agent safety annotations | 100% of agent candidates carry a proposed restricted allowlist with no bare `Bash(*)` or unrestricted `Write(*)` |
| V4.4 | Gap scan output | Gap findings appended to `eval/triage-log.md`; every entry mapped to one owning plugin or explicitly out of scope; zero merge candidates sourced from awesome-claude-code |
| V4.5 | NOTICE flags | Apache-2.0 close-adaptation candidates flagged for `NOTICE` |
| V4.6 | ECC command coverage | Every §8 mining target that exists only under ECC `commands/` carries a matrix row or a triage-log entry; zero named targets unaccounted for |
| V4.7 | ECC id disambiguation | ECC rows use an `id` convention that separates a command from a same-named skill (`security-scan`, `plan-canvas`, the `orch-*` family collide), so `eval/rubric.md` §5's one-effective-row-per-`id` rule holds |

**Gate G4 (human review):** owner approves the full candidate pool; approves Phase 5.

---

## 7. Phase 5 — Evaluation Matrix Consolidation → Independent-Reviewer Approval Gate

**Objective.** Consolidate Phases 2–4 into the final scored matrix and shortlist; stop for an explicit, independently adjudicated approval before any building.

> **Exit criteria (`SPEC.md` §10, verbatim):** Zero empty `verdict` cells; **independent-reviewer approval gate** — G5 adjudicated by a reviewer that receives the artifacts only, never the executing agent's reasoning, against `eval/gate-review-protocol.md`; a second `REJECTED` on the gate escalates to the project owner. Sign-off recorded as an ADR in `DECISIONS.md` before any building (D-25). A reviewer `APPROVED` is provisional: the `ROADMAP.md` gate log records it as `APPROVED (reviewer) — pending owner ack`, and Phase 6 work of any kind is barred until the owner posts an acknowledgement comment on the sign-off PR (D-25, amended v2.5).

**Deliverables.**

- Final `eval/matrix.csv`: complete, integrity-checked, one effective row per component ID.
- Shortlist report: per-plugin component roster proposed for synthesis, with lineage.
- Complete `eval/triage-log.md`: every rejection across all phases with rule-ID rationale.
- **The sign-off ADR** in `DECISIONS.md` (next available ID), recording the approved shortlist and build plan.

**Verification criteria.**

| # | Check | Expected |
|---|---|---|
| V5.1 | Verdict completeness | Zero empty `verdict` cells; every value in the §9 enum `shortlist \| reject \| merge \| defer` |
| V5.2 | Row uniqueness | Zero duplicate `id` values. A re-audit **replaces** the component's row in place; the superseded scoring and the reason for re-audit are recorded in `eval/triage-log.md`, which is the append-only surface. The matrix holds effective state, the triage log holds history |
| V5.3 | Score completeness | Every row fully scored, each axis an integer 1–5 |
| V5.4 | Threshold enforcement | Every shortlist row: empty `hard_reject`, no axis < 3, exactly one owning plugin |
| V5.5 | Source coverage | All 10 repos represented in the matrix or explicitly dispositioned (awesome-claude-code is discovery-only, with no merge rows, by design) |
| V5.6 | Hook budget preview | Shortlist implies ≤ 1 hook per plugin, hooks only in `super-saiyan` and `rinnegan` (D-15) |
| V5.7 | Roster balance | Every core plugin has ≥ 1 shortlisted component or a recorded plan for original work (for example `aura`) |

**Gate G5 — MANDATORY INDEPENDENT APPROVAL (D-25).** No scaffolding, no synthesis, no component authoring until an **independent reviewer** — running on a different model from the executing agent, reading the matrix, shortlist report, triage log and the pinned sources, and receiving none of the executing agent's reasoning — returns `APPROVED` under `eval/gate-review-protocol.md`, and the approval is **recorded as an ADR in `DECISIONS.md`**. That `APPROVED` is provisional: the §11 gate log records it as `APPROVED (reviewer) — pending owner ack`, and Phase 6 work of any kind stays barred until the project owner posts an acknowledgement comment on the sign-off PR and an `OWNER ACK` row joins it. That ADR, together with the owner's acknowledgement, is the authorization; the §11 gate-log rows below index it, they are not the record. A first `REJECTED` loops the phase; a **second `REJECTED` on this gate escalates to the project owner**, who decides it. Scope changes demanded at this gate become superseding ADRs before Phase 6 starts.

**Delivered (evidence: PR #20 `782eabd`, PR #21 `046f066`, and this PR).** `eval/shortlist.md` entered the §3 tree
at SPEC v2.8 and carries the per-plugin rosters with lineage and synthesis constraints, the fifteen merge
absorptions, the one deferred row, the V5.6 hook-budget preview, the V5.7 recorded plans for original work, the two
knowingly-contested rows, the re-donated concepts listed unscored, and the proposed Phase-6 build plan.
`eval/triage-log.md` gained T-274 and T-275 (both contested rows re-read at their pinned commits, both holding),
T-276 (the consolidation record), and T-277…T-281 (the G5 round-1 remediation, below). The three capability gaps
carried out of G4 (T-223, T-232, T-235) are dispositioned as recorded original-work plans; `aura`'s stays closed by
authoring, never by sourcing. The matrix holds 322 rows — **96 shortlist / 210 reject / 15 merge / 1 defer** — and the
one `defer` (`claude-mem/session-memory`, C-1, Phase 6) is what the sign-off ADR enumerates.

**Gate G5 — round 1 (2026-08-25): `REJECTED`.** Invoked per `eval/gate-review-protocol.md` §1 from a `git archive`
of `main` @ `046f066c2783a098966965959d0c7351e0286a89`, ten upstream clones at their pins, loader digest
`466587e5…586ec` MATCH. Executing agent model `claude-fable-5`; reviewer model `claude-fable-5` — so §3.5's
non-Anthropic second pass is REQUIRED on any `APPROVED`. The reviewer's V5.1–V5.7 values agreed with the executor's;
the verdict turned on the §3.2 source spot-check, which contradicted four shortlisted rows and the disposition of a
fifth. Every finding held on re-reading the source, and each is remediated in place:

| # | Finding (reviewer) | Row | Disposition |
|---|---|---|---|
| 1 | Write target `~/.claude/session-data/` is fixed by the command and the file is shown *after* writing; the rationale's "shown for confirmation (C-3)" was wrong | `ecc/cmd-save-session` | **T-277** — `risk` 4→3, `shortlist` retained; distinguished from T-020 on D-18's own-data-directory clause (the T-042 shape); rationale replaced |
| 2 | Lines 142–200 are a MANDATORY section running fourteen `python ~/.claude/skills/<other-skill>/scripts/*.py` commands; `dependencies` 5 and "no shell side effects" false; section undisclosed | `davila7/development-clean-code` | **T-278** — `dependencies` 1, **`reject`**; standards content re-donated to `super-saiyan` |
| 3 | HR-7 clearance ground false: the JS/TS branch is `npx depcheck` / `npx ts-unused-exports`, the T-106 / T-136 ground | `davila7/development-tools-unused-code-cleaner` | **T-279** — `HR-7`, **`reject`**; Dynamic Usage Safety re-donated to `sharingan` |
| 4 | The whole mechanism is `claude --bg`, a background agent outliving the turn; HR-4 never adjudicated | `mattpocock/claude-handoff` | **T-280** — `HR-4`, **`reject`**; handoff discipline re-donated to `kaioken` |
| 5 | `risk` 3 asserts C-1 passes while the scored design says C-1 must be executed before ship — rubric §7 Example C | `claude-mem/session-memory` | **T-281** — `risk` 2, **`defer`** naming C-1 and Phase 6 |
| 6 | Process: executing and reviewer models equal ⇒ §3.5 second pass REQUIRED | — | Owner runs it from the package the executor prepared; output accompanies the ack request |

Escalation state: this is the **first** `REJECTED` on G5. The 2026-08-18 review the triage log calls the G5
rehearsal was run against Phase-2 artifacts before the gate existed and is distinguished from the real gate by
`eval/gate-review-protocol.md` §3.5 itself; §11 carried no G5 row before this one. Per §5 rule 1 the executor
remediated and resubmits the **whole gate**; a second `REJECTED` escalates to the owner.

**Verification (executor's re-derivation after remediation; the reviewer re-derives every value independently under
`eval/gate-review-protocol.md` §3.1, and this paragraph is not evidence for it).** V5.1 0 empty `verdict` cells and 0
values outside the §9 enum across 322 rows. V5.2 0 duplicate `id` values. V5.3 0 axis cells outside the integers 1–5
across 322 × 5 cells. V5.4 across the 96 shortlist rows: 0 carry a `hard_reject`, 0 axis cells sit below 3, 0 lack
exactly one owning plugin. V5.5 all ten `upstream.json` repositories: nine carry matrix rows and
`hesreallyhim/awesome-claude-code` carries zero by design, dispositioned at T-221…T-238 (V4.4). V5.6 the shortlist
implies at most two hooks — `super-saiyan` and, once its `defer` closes, `rinnegan`, the two §6 budgets — and the
matrix's one `hook`-type row is a `reject`. V5.7 every core plugin holds ≥ 1 shortlisted component (`super-saiyan` 27,
`sharingan` 8, `rinnegan` 2, `kaioken` 5, `bankai` 35, `domain` 9, `instinct` 6, `poneglyph` 4, `aura` 0); `aura`'s
recorded plan is `eval/shortlist.md` §6, grounded in `SPEC.md` §4 and T-235.

**Gate G5 — round 2:** resubmitted from a fresh `git archive` of the `main` commit that carries this record.

---

## 8. Phase 6 — Scaffold & Synthesize

**Objective.** Build the approved marketplace: repo structure, manifests, synthesized components, validation and CI, docs, and attribution.

> **Exit criteria (`SPEC.md` §10, verbatim):** Tree matches §3 exactly; `scripts/validate.sh` and `validate.ps1` both exit 0; CI green; a `SOURCES.md` row exists for every shipped component.

**Deliverables.**

- The full §3 tree, including the entries deferred from the foundation stage: `.claude-plugin/marketplace.json`, the nine `plugins/<name>/.claude-plugin/plugin.json` manifests, `tests/` fixtures, and `.github/workflows/upstream-watch.yml`.
- Synthesized components for every approved shortlist row — skills, commands, curated `bankai` agents, and the at most two budgeted hooks.
- CI running both validators on every PR — landed early as `.github/workflows/validate.yml` (SPEC v2.5), which also enforces the HD-12 twin-parity diff and is a required check on `main`. Phase 6 extends it to the release checks; V6.9 is unchanged.
- Completed `SOURCES.md` (every shipped component mapped), `NOTICE` entries where flagged, per-plugin `CHANGELOG.md`.

**Verification criteria.**

| # | Check | Expected |
|---|---|---|
| V6.1 | Tree conformance | The tree matches `SPEC.md` §3 exactly, with no entry still marked deferred |
| V6.2 | Validation | `bash scripts/validate.sh` and `pwsh -File scripts/validate.ps1` both exit 0 with final line `VALIDATE: PASS`, each on its own platform |
| V6.3 | Schema conformance | `marketplace.json`, every `plugin.json`, every skill frontmatter, and every agent definition validate against `schemas/*` |
| V6.4 | Catalog shape | `marketplace.json` lists exactly 9 plugins; names match the Tier-1 set, and every `plugins/<dir>` on disk appears in the catalog |
| V6.5 | Hook budget | Hook count per plugin ≤ 1; hooks present only in `super-saiyan` and `rinnegan`; each passes the C-1 checklist and declares a timeout |
| V6.6 | Policy grep | Repo-wide scan finds zero bare `Bash(*)` or unrestricted `Write(*)` allowlists, zero network calls in components, zero telemetry, zero franchise imagery |
| V6.7 | Install smoke test | `claude plugin marketplace add coltonbearden/awakened`, then install, exercise, and uninstall one plugin — a clean round trip on Windows 11 and WSL2 |
| V6.8 | Attribution completeness | Every shipped component has a `SOURCES.md` row; all flagged Apache-2.0 close adaptations appear in `NOTICE` |
| V6.9 | CI | Both validators green on the PR that lands the phase |
| V6.10 | Traceability | Every shipped component maps to an approved Phase-5 shortlist row or a recorded original-work plan |

**Gate G6:** owner sign-off → tag the first release → marketplace live.

---

## 9. Deferred Foundation Items

These `SPEC.md` §3 entries are Phase-6 deliverables and are **absent by design** at the foundation stage. `scripts/validate.*` treats them as expected-absent rather than as violations, and V6.1 is where their absence stops being acceptable:

| Entry | Owning phase |
|---|---|
| `.claude-plugin/marketplace.json` | 6 |
| `plugins/<name>/` contents and manifests (nine) | 6 |
| `tests/` fixtures | 6 |
| `.github/workflows/upstream-watch.yml` | 6 |
| `eval/claude-mem-rebuild.md` | 3 |

Ratified — SPEC v2.2, D-19 (formerly open as A-GAP-001 / B-GAP-001): `SPEC.md` §3 now tags its Phase-6 entries `[P6]`, so the first four rows above mirror §3 directly and `scripts/validate.*` treats them as expected-absent by default and as required under `--release` / `-Release` (ADR-019). The `eval/claude-mem-rebuild.md` row is a Phase-3 deliverable named in §10, not a `[P6]` entry, and sits outside D-19's scope.

## 10. Gate Protocol

1. **Inputs:** the phase's deliverables plus its verification table, all criteria green, and the §10 exit criteria quoted in that phase satisfied.
2. **Reviewer:** the project owner, or the executing agent under the owner's standing delegation, for the review gates G2–G4 and G6. **G5 is a hard approval gate** and is adjudicated by an **independent reviewer** under `eval/gate-review-protocol.md` (D-25), escalating to the owner on a second `REJECTED`. Phase 6 work of any kind before a recorded G5 approval is a process violation, and a reviewer `APPROVED` is not enough on its own — the owner must acknowledge it on the sign-off PR first.
3. **Record:** G5's approval is recorded as an ADR in `DECISIONS.md`. All gates additionally get a Gate Log row (§11) with date and verdict for at-a-glance status; G5 takes two — the reviewer's `APPROVED (reviewer) — pending owner ack`, then the owner's `OWNER ACK` with its date and comment URL. `APPROVED` opens the next phase — at G5, once the owner has acknowledged it; `REJECTED` loops the phase with noted remediations.
4. **Scope changes at a gate:** become superseding ADRs in `DECISIONS.md` before the next phase begins. Changes that touch `SPEC.md` go through the D-16 spec PR.

## 11. Gate Log

| Gate | Date | Verdict | Record |
|---|---|---|---|
| G1 | 2026-08-15 | APPROVED | Structural inventory ratified via `SPEC.md` §8 and §10 |
| G2 | 2026-08-18 | APPROVED | Phase-2 audit complete: V2.1–V2.10 all discharged (V2.8–V2.10 by SPEC v2.3, PR #2). Reviewed and approved under standing delegation D11 (2026-08-18); review record: PR #4 |
| G3 | 2026-08-22 | APPROVED | Phase-3 complete: V3.1–V3.7 all discharged. Reviewed and approved under standing delegation D11 (D-25 moved only G5); review record: PR #10. Scope change arising at the gate landed as D-26 / ADR-026 (SPEC v2.6) per §10 rule 4 |
| G4 | 2026-08-22 | APPROVED | Phase-4 complete across three passes: V4.1–V4.7 all discharged. Reviewed and approved under standing delegation D11 (§10 rule 2; D-25 moved only G5); review record: PR #13, PR #16 and PR #17. One open finding carried to Phase 5 rather than closed at the gate: the three capability gaps from the V4.4 scan. A second finding asserted in PR #17 — a `schemas/agent.schema.json` enforcement gap on `hooks`/`mcpServers` — was **retracted the same day as false**; see the correction in §6 |
| G5 | 2026-08-25 | **REJECTED** (reviewer, round 1) | Independent review under `eval/gate-review-protocol.md` v1.1 from a clean-room archive of `046f066`; four spot-check contradictions and one disposition finding, all confirmed on the source and remediated as T-277…T-281 (§7). First `REJECTED` on this gate; whole gate resubmitted |

G5 occupies two rows, not one: `APPROVED (reviewer) — pending owner ack` when the independent reviewer returns its verdict, then `OWNER ACK` with the date and the comment URL when the owner acknowledges it. Phase 6 opens on the second row (D-25 as amended at SPEC v2.5).

## 12. Sequence Overview

```text
Foundation ──▶ pin-upstream ──▶ [Phase 2] Tier-1 audit ──G2──▶ [Phase 3] ECC + claude-mem ──G3──▶
[Phase 4] Remaining sources ──G4──▶ [Phase 5] Matrix ══G5 (INDEPENDENT REVIEW + OWNER ACK, recorded as an ADR)══▶
[Phase 6] Scaffold & synthesize ──G6──▶ first release tag ──▶ §11 maintenance loop
                                                              (upstream-watch monthly · instinct review · tagged releases)
```

## 13. Post-v1 Backlog (out of scope until after G6)

- New plugin proposals — only via `SPEC.md` §5 Future Naming Logic (scope and boundaries first) plus a new ADR.
- `aura` preset expansion beyond the §5 tables — original work, same review path.
- Closing the ADR-017 residue: palette presets `super-saiyan` and `bankai` still duplicate Tier 1 plugin names, grandfathered by §5.
- Listing on community catalogs — discovery, not a dependency.
- Upstream-watch tuning based on the first months of live diff issues.
