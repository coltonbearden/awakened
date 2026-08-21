# ROADMAP.md — Awakened Build Phases

**Derived from:** `SPEC.md` §10 (Build Phases & Exit Criteria), §9 (Evaluation Rubric), §11 (Ongoing Maintenance).
**Rule:** phases execute in order; each phase ends at a gate (G1–G6). A gate closes only when every verification criterion passes and the gate decision is recorded per §11 below. **G5 is a hard approval gate — adjudicated by an independent reviewer (D-25), the sign-off recorded as an ADR in `DECISIONS.md`; Phase 6 stays barred until the owner acknowledges the reviewer's `APPROVED` on the sign-off PR (§10 Phase 5).**

Each phase below reproduces `SPEC.md` §10's exit criteria **verbatim** in a quoted block, then expands them into checkable verification rows. Where a verification row and the quoted criterion disagree, the quoted criterion wins.

## 1. Status Board

| Phase | Name | Status | Gate |
|---|---|---|---|
| 1 | Structural inventory | **Complete** (2026-08-15) | G1 — passed |
| 2 | Tier-1 deep audit | **Complete** (2026-08-18) — 55 rows, 27 shortlist / 25 reject / 3 merge | G2 — passed |
| 3 | ECC triage + claude-mem extraction | Not started (next) | G3 |
| 4 | Remaining sources | Not started | G4 |
| 5 | Evaluation matrix consolidation | Not started | **G5 — independent-reviewer gate + owner ack** |
| 6 | Scaffold & synthesize | Not started | G6 |

## 2. Foundation Suite — Entry Criteria for Phase 2

Before Phase 2 begins, the governance, evaluation, schema, template, and legal foundation must be committed. The foundation is the 28 authored files plus `SPEC.md` shipped verbatim (D-16) — the count is historical, taken at Phase-2 entry; the tree has since gained `eval/gate-review-protocol.md` (SPEC v2.4) and `.github/workflows/validate.yml` (SPEC v2.5):

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

## 5. Phase 3 — ECC Triage + claude-mem Extraction

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

**Gate G3 (human review):** owner approves the ECC shortlist and the rinnegan rebuild design; approves Phase 4.

---

## 6. Phase 4 — Remaining Sources

**Objective.** Complete candidate coverage across the remaining sources.

> **Exit criteria (`SPEC.md` §10, verbatim):** Matrix rows appended for each; gap-scan findings appended to `eval/triage-log.md`.

**Deliverables.**

- **wshobson/agents:** the shortlisted general-purpose categories audited and scored; agent candidates annotated with proposed restricted tool allowlists (C-2).
- **anthropics/skills:** reference patterns reviewed; skill-creator lineage findings recorded for `instinct`; NOTICE-relevant close adaptations flagged.
- **davila7/claude-code-templates:** components directory only; the npm CLI and analytics surfaces are out of scope per §8 and HR-6/HR-7.
- **hesreallyhim/awesome-claude-code:** gap scan — discovery only, not merge material. Output is a capability-gap list, each gap mapped to an owning plugin or marked out of scope, appended to `eval/triage-log.md`.

**Verification criteria.**

| # | Check | Expected |
|---|---|---|
| V4.1 | Coverage | Matrix rows appended for all wshobson shortlisted categories, anthropics/skills patterns, and davila7 component candidates |
| V4.2 | davila7 boundary | Every davila7 row's `component_path` is inside the components directory; zero CLI or analytics rows |
| V4.3 | Agent safety annotations | 100% of agent candidates carry a proposed restricted allowlist with no bare `Bash(*)` or unrestricted `Write(*)` |
| V4.4 | Gap scan output | Gap findings appended to `eval/triage-log.md`; every entry mapped to one owning plugin or explicitly out of scope; zero merge candidates sourced from awesome-claude-code |
| V4.5 | NOTICE flags | Apache-2.0 close-adaptation candidates flagged for `NOTICE` |

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
