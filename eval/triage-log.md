# Triage Log

**Purpose.** The rejection and audit-history record for the evaluation harness. Every `eval/matrix.csv` row whose `verdict` is `reject` has an entry here citing the rule IDs that disqualified it — that is the `SPEC.md` §10 Phase-2 exit criterion, in this file, mechanically checkable via the trigger-ID field.

**Relationship to `eval/matrix.csv`.** The matrix records **effective state**: one row per component `id`, replaced in place on re-audit. This log is **append-only history**: entries are never edited or deleted, and a re-audit adds a new entry recording what changed and why. Together they answer "what is the current disposition" and "how did it get there" without either file having to do both jobs.

**Phase 2 (Tier-1 deep audit) ran 2026-08-18.** The entries in §3 are its rejection record. Every `verdict = reject` row in `eval/matrix.csv` has exactly one entry here, written at the time the row was written.

---

## 1. Entry Template

Copy this block verbatim for each entry. Heading level is `###`, IDs are sequential from `T-001` and never reused.

```markdown
### T-NNN — <component-name>

- **Source:** <repo name exactly as it appears in `upstream.json`>
- **Path:** <path within the source repo at the pinned SHA>
- **HR/axis trigger IDs:** <comma-joined, e.g. `HR-4,HR-5` or `axis:user_scope_fit=1`>
- **Rationale:** <one or two sentences; cite the rule IDs and the deciding axis>
- **Date:** <YYYY-MM-DD>
```

### Field rules

| Field | Rule |
|---|---|
| Heading | `### T-NNN — <component-name>`, em-dash separator, `component-name` in kebab-case (N-3). The `T-NNN` matches nothing else in the repo and is the log's own ID space |
| Source | Must match a `repos[].name` value in `upstream.json` exactly; an unmatched source name is an audit-trail break |
| Path | Repo-relative, forward slashes, as it exists **at the pinned SHA** — not at branch HEAD |
| HR/axis trigger IDs | At least one ID. Hard rejects use the `HR-N` form; a rejection on an axis floor uses `axis:<column>=<score>`. This field is what `SPEC.md` §10 Phase 2 checks — prose in Rationale does not substitute for it |
| Rationale | Cites rule IDs, not adjectives. "Fails HR-5: bundles a native sqlite binary" is an entry; "too heavy" is not |
| Date | `YYYY-MM-DD`, the date the read happened |

---

## 2. Usage Rules

1. **One entry per rejected component.** Every `verdict = reject` row in `eval/matrix.csv` has exactly one entry here at the time the row is written — not batched at the end of a phase.
2. **Bulk rejects are logged as a class, once.** Where `SPEC.md` §10 Phase 3 authorizes disposing of a reject class without deep reads (ECC's 22 language packs, the 41KB hooks.json, dashboards, domain-niche skills), write one entry for the class: the component-name slot carries the class name, the Path slot carries the covering path prefix, and the Rationale states the count. Individual matrix rows are not written for bulk-rejected components.
3. **Re-pins that invalidate an audit get an entry.** When `scripts/pin-upstream.*` moves a SHA and a prior evaluation was read at the old one, append an entry recording the old and new SHAs and whether the evaluation still holds (`CLAUDE.md` §8).
4. **Re-audits get an entry, and the matrix row is replaced.** The entry records the previous scores and verdict, the new ones, and the reason. This is the only place a superseded score survives.
5. **Gap-scan findings are appended here.** §10 Phase 4's `hesreallyhim/awesome-claude-code` gap scan produces capability-gap findings, each mapped to one owning plugin or explicitly marked out of scope. Gap entries use the same template with `axis:` triggers or `n/a` where nothing was rejected.
6. **Never pre-decide.** This log records reads that happened. Writing an entry for a component that has not been read at a pinned SHA fabricates audit evidence and pre-empts the §10 Phase-5 human approval gate.
7. **No SHAs typed from memory.** Any SHA quoted in an entry is copied from `upstream.json` after `scripts/pin-upstream.*` wrote it (§8).

---

## 3. Entries

**Phase 2 — Tier-1 deep audit, 2026-08-18.** All four §10 Phase-2 sources read at their `upstream.json` pinned SHAs (`obra/superpowers` `b36e0829c6d0`, `mattpocock/skills` `9c9f36ccd399`, `kepano/obsidian-skills` `a1dc48e68138`, `vercel-labs/skills` `c6f69c631292`); each clone's `git rev-parse HEAD` was compared to the pin before reading. Coverage is 55 `SKILL.md` files — 14 / 35 / 5 / 1 — one `eval/matrix.csv` row each, and 22 of them rejected.

Two coverage notes, so the per-repo counts are checkable rather than surprising:

- `vercel-labs/skills` contributes **one** row. At the pinned SHA the repository is a TypeScript CLI (`src/providers/`, `tests/*.test.ts`, 116 blobs) with a single `SKILL.md`, `skills/find-skills/SKILL.md`. `SPEC.md` §8 classes it a meta-skill *concept* donor, which matches what is there.
- `mattpocock/skills` carries a `skills/deprecated/` directory holding no `SKILL.md`, so it contributes no row. Its six `skills/in-progress/` skills **are** audited and scored, since `ROADMAP.md` V2.2 admits no unrepresented skill file; upstream WIP status is not a `defer` ground under D-21, which requires a named blocking check.

### T-001 — brainstorming

- **Source:** obra/superpowers
- **Path:** skills/brainstorming/SKILL.md
- **HR/axis trigger IDs:** `HR-4`
- **Rationale:** Ships scripts/start-server.sh which nohup/disowns a node server.cjs with a PID file, watchdog and idle timeout (HR-4); the design-dialogue and approval-gate concept is re-donated to super-saiyan for synthesis without the visual companion.
- **Date:** 2026-08-18

### T-002 — ask-matt

- **Source:** mattpocock/skills
- **Path:** skills/engineering/ask-matt/SKILL.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=1`
- **Rationale:** A router over this repository's own skill set; axis:user_scope_fit=1 - it encodes one author's catalogue, not a portable capability.
- **Date:** 2026-08-18

### T-003 — improve-codebase-architecture

- **Source:** mattpocock/skills
- **Path:** skills/engineering/improve-codebase-architecture/SKILL.md
- **HR/axis trigger IDs:** `HR-6`
- **Rationale:** The HTML report template loads cdn.tailwindcss.com and cdn.jsdelivr.net at render time (HR-6); the deepening-opportunity scan concept survives for sharingan, the CDN-backed report does not.
- **Date:** 2026-08-18

### T-004 — setup-matt-pocock-skills

- **Source:** mattpocock/skills
- **Path:** skills/engineering/setup-matt-pocock-skills/SKILL.md
- **HR/axis trigger IDs:** `HR-1,axis:user_scope_fit=1`
- **Rationale:** Configures a repository against an external issue tracker (GitHub, Linear or Jira) requiring an account (HR-1), and installs one author's skill set; axis:user_scope_fit=1.
- **Date:** 2026-08-18

### T-005 — to-spec

- **Source:** mattpocock/skills
- **Path:** skills/engineering/to-spec/SKILL.md
- **HR/axis trigger IDs:** `HR-1,axis:user_scope_fit=2`
- **Rationale:** Publishes the synthesized spec to an external project issue tracker requiring an account (HR-1); axis:user_scope_fit=2 - the workflow presumes a specific tracker.
- **Date:** 2026-08-18

### T-006 — to-tickets

- **Source:** mattpocock/skills
- **Path:** skills/engineering/to-tickets/SKILL.md
- **HR/axis trigger IDs:** `HR-1,axis:dependencies=2`
- **Rationale:** Creates tracer-bullet tickets on an external issue tracker requiring an account (HR-1); the ticket-decomposition concept survives for kaioken without the tracker coupling.
- **Date:** 2026-08-18

### T-007 — triage

- **Source:** mattpocock/skills
- **Path:** skills/engineering/triage/SKILL.md
- **HR/axis trigger IDs:** `HR-1,axis:dependencies=2`
- **Rationale:** Moves issues and PRs through a state machine on an external tracker via gh and Linear (HR-1); axis:dependencies=2.
- **Date:** 2026-08-18

### T-008 — wayfinder

- **Source:** mattpocock/skills
- **Path:** skills/engineering/wayfinder/SKILL.md
- **HR/axis trigger IDs:** `HR-1,axis:dependencies=2`
- **Rationale:** Plans large work as decision tickets on an external issue tracker requiring an account (HR-1); 12KB, axis:dependencies=2.
- **Date:** 2026-08-18

### T-009 — wizard

- **Source:** mattpocock/skills
- **Path:** skills/engineering/wizard/SKILL.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=2`
- **Rationale:** Generates interactive bash wizards for provisioning; axis:user_scope_fit=2 - bash-only output fails C-1's Windows 11 PowerShell 7 clause, which synthesis cannot fix without changing what the skill produces.
- **Date:** 2026-08-18

### T-010 — loop-me

- **Source:** mattpocock/skills
- **Path:** skills/in-progress/loop-me/SKILL.md
- **HR/axis trigger IDs:** `axis:value=2,axis:user_scope_fit=2`
- **Rationale:** Scoped to grilling specs for workflows built within one author's workspace; axis:user_scope_fit=2 and axis:value=2 under P-2.
- **Date:** 2026-08-18

### T-011 — setup-ts-deep-modules

- **Source:** mattpocock/skills
- **Path:** skills/in-progress/setup-ts-deep-modules/SKILL.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=1`
- **Rationale:** Wires dependency-cruiser into a TypeScript repository; axis:user_scope_fit=1 - language-specific at user scope, which P-2 and HR-3's intent both bar. No install command is issued in the skill, so no HR-7.
- **Date:** 2026-08-18

### T-012 — writing-beats

- **Source:** mattpocock/skills
- **Path:** skills/in-progress/writing-beats/SKILL.md
- **HR/axis trigger IDs:** `B-1..B-8`
- **Rationale:** Prose-craft technique with no owning plugin under B-1 to B-8; SPEC 4 requires exactly one owner, and none of the nine covers long-form writing.
- **Date:** 2026-08-18

### T-013 — writing-fragments

- **Source:** mattpocock/skills
- **Path:** skills/in-progress/writing-fragments/SKILL.md
- **HR/axis trigger IDs:** `B-1..B-8`
- **Rationale:** Prose-craft technique with no owning plugin under B-1 to B-8; same ownership gap as mattpocock/writing-beats.
- **Date:** 2026-08-18

### T-014 — writing-shape

- **Source:** mattpocock/skills
- **Path:** skills/in-progress/writing-shape/SKILL.md
- **HR/axis trigger IDs:** `B-1..B-8`
- **Rationale:** Prose-craft technique with no owning plugin under B-1 to B-8; same ownership gap as mattpocock/writing-beats.
- **Date:** 2026-08-18

### T-015 — git-guardrails-claude-code

- **Source:** mattpocock/skills
- **Path:** skills/misc/git-guardrails-claude-code/SKILL.md
- **HR/axis trigger IDs:** `D-15,D-24`
- **Rationale:** Installs a bash PreToolUse hook into .claude/settings.json. D-15 budgets hooks only to super-saiyan and rinnegan, and D-24 bars command-handler hooks outright, so no owning plugin can carry it as shipped; it asks before writing, so C-3 holds and no HR fires.
- **Date:** 2026-08-18

### T-016 — migrate-to-shoehorn

- **Source:** mattpocock/skills
- **Path:** skills/misc/migrate-to-shoehorn/SKILL.md
- **HR/axis trigger IDs:** `HR-7,axis:dependencies=1,axis:user_scope_fit=1`
- **Rationale:** Instructs npm i @total-typescript/shoehorn as step one (HR-7) and is TypeScript-only; axis:user_scope_fit=1, axis:dependencies=1.
- **Date:** 2026-08-18

### T-017 — scaffold-exercises

- **Source:** mattpocock/skills
- **Path:** skills/misc/scaffold-exercises/SKILL.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=1`
- **Rationale:** Creates course-exercise directory structures; axis:user_scope_fit=1 - a single content-authoring workflow, not a general capability under P-2.
- **Date:** 2026-08-18

### T-018 — setup-pre-commit

- **Source:** mattpocock/skills
- **Path:** skills/misc/setup-pre-commit/SKILL.md
- **HR/axis trigger IDs:** `HR-7,axis:user_scope_fit=2`
- **Rationale:** Runs npx husky init, fetching and executing a package at runtime (HR-7); Node-ecosystem-only, axis:user_scope_fit=2.
- **Date:** 2026-08-18

### T-019 — teach

- **Source:** mattpocock/skills
- **Path:** skills/productivity/teach/SKILL.md
- **HR/axis trigger IDs:** `B-1..B-8`
- **Rationale:** Teaching workflow with no owning plugin under B-1 to B-8; 9.5KB plus five siblings. The example URLs are illustrative, not fetched, so no HR-6.
- **Date:** 2026-08-18

### T-020 — to-questionnaire

- **Source:** mattpocock/skills
- **Path:** skills/productivity/to-questionnaire/SKILL.md
- **HR/axis trigger IDs:** `B-1..B-8`
- **Rationale:** Turns an unanswerable decision into a questionnaire; no owning plugin under B-1 to B-8 - it is neither session momentum (B-5) nor structural context (B-4).
- **Date:** 2026-08-18

### T-021 — wait-what

- **Source:** mattpocock/skills
- **Path:** skills/productivity/wait-what/SKILL.md
- **HR/axis trigger IDs:** `axis:value=2,B-1..B-8`
- **Rationale:** A 325-byte re-pitch prompt; axis:value=2 - a one-line corrective with no recurring workflow behind it, and no owner under B-1 to B-8.
- **Date:** 2026-08-18

### T-022 — defuddle

- **Source:** kepano/obsidian-skills
- **Path:** skills/defuddle/SKILL.md
- **HR/axis trigger IDs:** `HR-6,HR-7`
- **Rationale:** Runs defuddle parse <url> to fetch and strip web pages (HR-6) after npm install -g defuddle (HR-7); the only kepano skill EXC-1 cannot adopt.
- **Date:** 2026-08-18

---

## 4. Statistics

Recomputed by hand at each gate from the entries in §3, so the table can be checked against the file rather than trusted.

| Metric | Count |
|---|---|
| Total entries | 22 |
| Hard-reject entries | 10 |
| Axis-floor entries | 6 |
| Bulk-reject classes | 0 |
| Gap-scan entries | 0 |
| Re-audit / re-pin entries | 0 |

The six entries not counted in the hard-reject or axis-floor rows are rejections on a rule other than an HR trigger or an axis floor: five on `B-1..B-8` (no owning plugin exists for the component, so `SPEC.md` §4 forbids shortlisting it) and one on `D-15,D-24` (a hook whose dispatch and budget no plugin can carry). Their trigger IDs carry those rule IDs, which is what the §10 Phase-2 exit criterion checks.

The verdict vocabulary is `SPEC.md` §9 rule 3 — `shortlist`, `reject`, `merge`, `defer`. This log carries entries for `reject` (mandatory) and may carry them for `merge` and `defer` where the reasoning is worth preserving; `shortlist` rows need no entry.
