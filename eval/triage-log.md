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

**Phase 2 — Tier-1 deep audit, 2026-08-18.** All four `SPEC.md` §10 Phase-2 sources were read at their `upstream.json` pinned SHAs — `obra/superpowers` `b36e0829c6d0`, `mattpocock/skills` `9c9f36ccd399`, `kepano/obsidian-skills` `a1dc48e68138`, `vercel-labs/skills` `c6f69c631292` — with each clone's `git rev-parse HEAD` compared to the pin before any file was read (V2.7). Coverage is 55 `SKILL.md` files — 14 / 35 / 5 / 1 — one `eval/matrix.csv` row each. Every skill's whole directory was screened, not just its `SKILL.md`: the policy screen for HR-4 (backgrounding, servers, watchers), HR-5 (sqlite, native binaries), HR-6 (hosts and fetch calls), HR-7 (every install and `npx` form) and HR-2 (MCP) ran across all sibling files, because a skill's risk lives in what it ships, not only in what it says.

Two coverage notes, so the per-repo counts are checkable rather than surprising:

- `vercel-labs/skills` contributes **one** row. At the pinned SHA the repository is a TypeScript CLI (`src/providers/`, `tests/*.test.ts`, 116 blobs) with a single `SKILL.md`, `skills/find-skills/SKILL.md`. `SPEC.md` §8 classes it a meta-skill *concept* donor, which matches what is there.
- `mattpocock/skills` carries a `skills/deprecated/` directory holding no `SKILL.md`, so it contributes no row. Its six `skills/in-progress/` skills **are** audited and scored, since `ROADMAP.md` V2.2 admits no unrepresented skill file; upstream WIP status is not a `defer` ground under D-21, which requires a named blocking check.

Four candidates were screened as hard-reject hits and **cleared on the evidence**, recorded because a policy screen that only ever confirms suspicions is not a screen: `writing-skills`' `brew install graphviz` / `apt install graphviz` are `console.error` strings printed by an optional helper when graphviz is absent, and its `pip install pypdf` is quoted example text inside a best-practices document; `mattpocock/tdd`'s `fetch(` is example TypeScript in mocking guidance; every `mcp` match across the four repos is incidental prose, so no HR-2 fires anywhere.

### T-001 — brainstorming

- **Source:** obra/superpowers
- **Path:** skills/brainstorming/SKILL.md
- **HR/axis trigger IDs:** `HR-4`
- **Rationale:** Ships scripts/start-server.sh which nohup/disowns a node server.cjs with a PID file, watchdog and idle timeout (HR-4); the design-dialogue and approval-gate concept is re-donated to super-saiyan for synthesis without the visual companion.
- **Date:** 2026-08-18

### T-002 — using-git-worktrees

- **Source:** obra/superpowers
- **Path:** skills/using-git-worktrees/SKILL.md
- **HR/axis trigger IDs:** `HR-7`
- **Rationale:** Step 2 Project Setup auto-runs npm install, pip install -r, poetry install and go mod download on detection, with no prompt - runtime dependency fetching (HR-7). The worktree-isolation and baseline-verification concept is re-donated to super-saiyan without the setup step.
- **Date:** 2026-08-18

### T-003 — ask-matt

- **Source:** mattpocock/skills
- **Path:** skills/engineering/ask-matt/SKILL.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=1`
- **Rationale:** A router over this repository's own skill set; axis:user_scope_fit=1 - it encodes one author's catalogue, not a portable capability.
- **Date:** 2026-08-18

### T-004 — improve-codebase-architecture

- **Source:** mattpocock/skills
- **Path:** skills/engineering/improve-codebase-architecture/SKILL.md
- **HR/axis trigger IDs:** `HR-6`
- **Rationale:** The HTML report template loads cdn.tailwindcss.com and cdn.jsdelivr.net at render time (HR-6); the deepening-opportunity scan concept survives for sharingan, the CDN-backed report does not.
- **Date:** 2026-08-18

### T-005 — setup-matt-pocock-skills

- **Source:** mattpocock/skills
- **Path:** skills/engineering/setup-matt-pocock-skills/SKILL.md
- **HR/axis trigger IDs:** `HR-1,axis:user_scope_fit=1`
- **Rationale:** Configures a repository against an external issue tracker (GitHub, Linear or Jira) requiring an account (HR-1), and installs one author's skill set; axis:user_scope_fit=1.
- **Date:** 2026-08-18

### T-006 — to-spec

- **Source:** mattpocock/skills
- **Path:** skills/engineering/to-spec/SKILL.md
- **HR/axis trigger IDs:** `HR-1,axis:user_scope_fit=2`
- **Rationale:** Publishes the synthesized spec to an external project issue tracker requiring an account (HR-1); axis:user_scope_fit=2 - the workflow presumes a specific tracker.
- **Date:** 2026-08-18

### T-007 — to-tickets

- **Source:** mattpocock/skills
- **Path:** skills/engineering/to-tickets/SKILL.md
- **HR/axis trigger IDs:** `HR-1,axis:dependencies=2`
- **Rationale:** Creates tracer-bullet tickets on an external issue tracker requiring an account (HR-1); the ticket-decomposition concept survives for kaioken without the tracker coupling.
- **Date:** 2026-08-18

### T-008 — triage

- **Source:** mattpocock/skills
- **Path:** skills/engineering/triage/SKILL.md
- **HR/axis trigger IDs:** `HR-1,axis:dependencies=2`
- **Rationale:** Moves issues and PRs through a state machine on an external tracker via gh and Linear (HR-1); axis:dependencies=2.
- **Date:** 2026-08-18

### T-009 — wayfinder

- **Source:** mattpocock/skills
- **Path:** skills/engineering/wayfinder/SKILL.md
- **HR/axis trigger IDs:** `HR-1,axis:dependencies=2`
- **Rationale:** Plans large work as decision tickets on an external issue tracker requiring an account (HR-1); 12KB, axis:dependencies=2.
- **Date:** 2026-08-18

### T-010 — wizard

- **Source:** mattpocock/skills
- **Path:** skills/engineering/wizard/SKILL.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=2`
- **Rationale:** Generates interactive bash wizards for provisioning; axis:user_scope_fit=2 - bash-only output fails C-1's Windows 11 PowerShell 7 clause, which synthesis cannot fix without changing what the skill produces.
- **Date:** 2026-08-18

### T-011 — loop-me

- **Source:** mattpocock/skills
- **Path:** skills/in-progress/loop-me/SKILL.md
- **HR/axis trigger IDs:** `axis:value=2,axis:user_scope_fit=2`
- **Rationale:** Scoped to grilling specs for workflows built within one author's workspace; axis:user_scope_fit=2 and axis:value=2 under P-2.
- **Date:** 2026-08-18

### T-012 — setup-ts-deep-modules

- **Source:** mattpocock/skills
- **Path:** skills/in-progress/setup-ts-deep-modules/SKILL.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=1`
- **Rationale:** Wires dependency-cruiser into a TypeScript repository; axis:user_scope_fit=1 - language-specific at user scope, which P-2 and HR-3's intent both bar. No install command is issued in the skill, so no HR-7.
- **Date:** 2026-08-18

### T-013 — writing-beats

- **Source:** mattpocock/skills
- **Path:** skills/in-progress/writing-beats/SKILL.md
- **HR/axis trigger IDs:** `B-1..B-8`
- **Rationale:** Prose-craft technique with no owning plugin under B-1 to B-8; SPEC 4 requires exactly one owner, and none of the nine covers long-form writing.
- **Date:** 2026-08-18

### T-014 — writing-fragments

- **Source:** mattpocock/skills
- **Path:** skills/in-progress/writing-fragments/SKILL.md
- **HR/axis trigger IDs:** `B-1..B-8`
- **Rationale:** Prose-craft technique with no owning plugin under B-1 to B-8; same ownership gap as mattpocock/writing-beats.
- **Date:** 2026-08-18

### T-015 — writing-shape

- **Source:** mattpocock/skills
- **Path:** skills/in-progress/writing-shape/SKILL.md
- **HR/axis trigger IDs:** `B-1..B-8`
- **Rationale:** Prose-craft technique with no owning plugin under B-1 to B-8; same ownership gap as mattpocock/writing-beats.
- **Date:** 2026-08-18

### T-016 — git-guardrails-claude-code

- **Source:** mattpocock/skills
- **Path:** skills/misc/git-guardrails-claude-code/SKILL.md
- **HR/axis trigger IDs:** `D-15,D-24`
- **Rationale:** Installs a bash PreToolUse hook into .claude/settings.json. D-15 budgets hooks only to super-saiyan and rinnegan, and D-24 bars command-handler hooks outright, so no owning plugin can carry it as shipped; it asks before writing, so C-3 holds and no HR fires.
- **Date:** 2026-08-18

### T-017 — migrate-to-shoehorn

- **Source:** mattpocock/skills
- **Path:** skills/misc/migrate-to-shoehorn/SKILL.md
- **HR/axis trigger IDs:** `HR-7,axis:dependencies=1,axis:user_scope_fit=1`
- **Rationale:** Instructs npm i @total-typescript/shoehorn as step one (HR-7) and is TypeScript-only; axis:user_scope_fit=1, axis:dependencies=1.
- **Date:** 2026-08-18

### T-018 — scaffold-exercises

- **Source:** mattpocock/skills
- **Path:** skills/misc/scaffold-exercises/SKILL.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=1`
- **Rationale:** Creates course-exercise directory structures; axis:user_scope_fit=1 - a single content-authoring workflow, not a general capability under P-2.
- **Date:** 2026-08-18

### T-019 — setup-pre-commit

- **Source:** mattpocock/skills
- **Path:** skills/misc/setup-pre-commit/SKILL.md
- **HR/axis trigger IDs:** `HR-7,axis:user_scope_fit=2`
- **Rationale:** Runs npx husky init, fetching and executing a package at runtime (HR-7); Node-ecosystem-only, axis:user_scope_fit=2.
- **Date:** 2026-08-18

### T-020 — handoff

- **Source:** mattpocock/skills
- **Path:** skills/productivity/handoff/SKILL.md
- **HR/axis trigger IDs:** `axis:risk=1,C-3`
- **Rationale:** Directs the handoff document to the OS temporary directory, explicitly not the workspace - outside every location C-3 permits, so axis:risk=1 on the SPEC 9 anchor. SPEC 4 names it kaioken lineage, so the concept is re-donated to kaioken writing inside the project directory.
- **Date:** 2026-08-18

### T-021 — teach

- **Source:** mattpocock/skills
- **Path:** skills/productivity/teach/SKILL.md
- **HR/axis trigger IDs:** `B-1..B-8`
- **Rationale:** Teaching workflow with no owning plugin under B-1 to B-8; 9.5KB plus five siblings. The example URLs are illustrative, not fetched, so no HR-6.
- **Date:** 2026-08-18

### T-022 — to-questionnaire

- **Source:** mattpocock/skills
- **Path:** skills/productivity/to-questionnaire/SKILL.md
- **HR/axis trigger IDs:** `B-1..B-8`
- **Rationale:** Turns an unanswerable decision into a questionnaire; no owning plugin under B-1 to B-8 - it is neither session momentum (B-5) nor structural context (B-4).
- **Date:** 2026-08-18

### T-023 — wait-what

- **Source:** mattpocock/skills
- **Path:** skills/productivity/wait-what/SKILL.md
- **HR/axis trigger IDs:** `axis:value=2,B-1..B-8`
- **Rationale:** A 325-byte re-pitch prompt; axis:value=2 - a one-line corrective with no recurring workflow behind it, and no owner under B-1 to B-8.
- **Date:** 2026-08-18

### T-024 — defuddle

- **Source:** kepano/obsidian-skills
- **Path:** skills/defuddle/SKILL.md
- **HR/axis trigger IDs:** `HR-6,HR-7`
- **Rationale:** Runs defuddle parse <url> to fetch and strip web pages (HR-6) after npm install -g defuddle (HR-7); the only kepano skill EXC-1 cannot adopt.
- **Date:** 2026-08-18

### T-025 — find-skills

- **Source:** vercel-labs/skills
- **Path:** skills/find-skills/SKILL.md
- **HR/axis trigger IDs:** `HR-6,HR-7`
- **Rationale:** Drives the npx skills CLI - add, find, update, init - including npx skills add <pkg> -g -y, a global install with confirmations skipped (HR-7), and queries the skills.sh registry and leaderboard (HR-6). SPEC 4 names it instinct lineage; the discovery concept survives, this implementation does not.
- **Date:** 2026-08-18

### T-026 — code-review

- **Source:** mattpocock/skills
- **Path:** skills/engineering/code-review/SKILL.md
- **HR/axis trigger IDs:** `n/a (re-audit)`
- **Rationale:** Re-audit. Previous: `5,4,5,4,5`, `shortlist`, rationale claiming the tracker "degrades to asking the user, so the tracker is optional". That misdescribed the source: line 13 unconditionally tells the user to run `/setup-matt-pocock-skills` (itself an HR-1 reject, T-005) when `docs/agents/issue-tracker.md` is absent, and the steps 2.2–2.4 fallback covers the *spec source*, not the tracker. New: `5,4,5,3,5`, `shortlist` retained — HR-1 still does not fire because the tracker is not the substrate (Standards reads repo docs; the Spec axis degrades or skips) — with `dependencies` cut 4→3 and synthesis required to drop the line-13 coupling. Recorded as knowingly contested, to be re-examined at G5.
- **Date:** 2026-08-18

### T-027 — claude-handoff

- **Source:** mattpocock/skills
- **Path:** skills/in-progress/claude-handoff/SKILL.md
- **HR/axis trigger IDs:** `n/a (re-audit)`
- **Rationale:** Re-audit. Previous: `4,5,4,5,5`, `merge` into `mattpocock/handoff`. That absorber was itself moved to `reject` (T-020, C-3 — it writes to the OS temporary directory), leaving the merge pointing at a rejected row and the absorbed value unrecoverable. New: `shortlist`, `target_plugin = kaioken`, scores unchanged. It stands alone — it names no write location, so handoff's C-3 defect does not apply, and B-5 gives session handoff to kaioken.
- **Date:** 2026-08-18

### T-028 — diagnosing-bugs

- **Source:** mattpocock/skills
- **Path:** skills/engineering/diagnosing-bugs/SKILL.md
- **HR/axis trigger IDs:** `axis:risk=4 (re-audit)`
- **Rationale:** Re-audit. Previous: `risk = 5` on the "pure skills/commands; read-only; no shell side effects" anchor, with a rationale clearing `fetch(` hits — a clearance that belongs to `mattpocock/tdd`'s `mocking.md`, not this directory, which contains no `fetch(` at all. New: `risk = 4`; the skill ships `scripts/hitl-loop.template.sh`, a foreground human-in-the-loop prompter with no backgrounding or network, so the read-only anchor does not hold. `agents/openai.yaml` was checked and is display metadata only — no keys, no service calls, no HR-1. `shortlist` retained; no threshold crossed.
- **Date:** 2026-08-18

---

**Phase 3 — ECC triage + claude-mem extraction, 2026-08-22.** Both sources were read at their
`upstream.json` pinned SHAs — `affaan-m/ECC` `06c5e118c4d3`, `thedotmack/claude-mem`
`fae697a45d10` — with each clone's `git rev-parse HEAD` compared to the pin before any component
file was read. 2/2 matched.

**The denominator, stated so the arithmetic is checkable.** `affaan-m/ECC` contains **897**
`SKILL.md` files at the pin, not the ~270 `SPEC.md` §8 estimates. Only **285** are canonical
(`skills/<name>/SKILL.md`); the other **612** are the same skills duplicated for translation
(`docs/ja-JP` 229, `docs/zh-CN` 183, `docs/tr` 38, `docs/es` 38, `docs/zh-TW` 16, `docs/ko-KR` 15
= 519) and for other agent harnesses (`.kiro` 43, `.agents` 39, `.cursor` 11 = 93). §8's figure is
a dated role note and is left as written; **285** is the Phase-3 denominator. Every one of the 285
is dispositioned exactly once: 40 deep-read (T-038…T-062) plus 245 in the seven classes
T-030…T-036 — 40 + 93 + 40 + 33 + 20 + 24 + 20 + 15 = 285. *(Class sizes updated 2026-08-22 by
T-064, which moved one skill between two of them; the total and the partition are unchanged.)*

**Procedural difference from Phase 2, stated because it inverts the earlier rule.** Phase 2 wrote
one `eval/matrix.csv` row per skill file. `ROADMAP.md` V3.3 requires the opposite here: fully
scored ECC rows exist **only** for components the breadth pass selected for a deep read. The 245
class-rejected skills therefore have no matrix rows — writing rows for components that were never
deep-read would fabricate audit evidence (§2 rule 6).

**"Shortlist" in V3.3 means the breadth-pass selection, not the final verdict.** All 40 deep-read
components carry matrix rows; 15 end at `shortlist`, 2 at `merge`, and 23 at `reject`. A reject row
whose component *was* deep-read is the intended outcome of a deep read, not a V3.3 violation.

**The ≤ 40 cap bound exactly.** The breadth pass produced more than 40 plausible survivors, so the
margin was ranked by §8 mining intent and axis strength and pushed back into the breadth pass as
class rejects rather than being carried as `defer` — a `defer` needs a scored matrix row, which
V3.3 forbids for anything not deep-read. `token-budget-advisor`, `contract-first`,
`hexagonal-architecture`, `product-capability`, `product-lens`, `benchmark`,
`benchmark-optimization-loop`, `security-bounty-hunter`, `dev-team`, `team-builder`, `agent-eval`
and `eval-harness` are the named margin cuts; they sit in T-035 and T-036. *(Corrected 2026-08-22
by T-064: eleven of the twelve do. `hexagonal-architecture` was filed in T-030, which does not fit
it; T-064 moves it to T-036's ground.)*

**Two screening adjudications, recorded because a screen that varies silently is not a screen.**

1. *Harness search tools are not a component network call.* HR-6 bars network calls by shipped
   components. A skill that directs the agent to use the harness's own web or `gh` search at the
   user's request opens no socket and ships no endpoint, so it does not fire HR-6; a component that
   requires a named third-party service, API key or hosted endpoint does (T-032). This is what
   separates `search-first` and `skill-scout` (kept) from `exa-search` and `deep-research`
   (rejected).
2. *Documented optional installs are not HR-7.* Phase 2 rejected `superpowers/using-git-worktrees`
   because its setup step **auto-ran** `npm install` with no prompt. By that standard an `npx` or
   `pip install` line offered as one alternative path is not an auto-install (`gateguard`,
   `git-workflow`), while a workflow whose every step *is* `npx <tool>` is (`security-scan`,
   `skill-comply`).

As in Phase 2, the whole directory was screened for each deep-read component, not only its
`SKILL.md`: 463 blobs sit under `skills/` against 285 `SKILL.md` files, and the HR-4, HR-5, HR-6,
HR-7 and HR-2 patterns were run across every sibling. Four flagged candidates were **cleared on the
evidence** and are recorded because a screen that only ever confirms suspicions is not a screen:
`codebase-onboarding`'s `npx prisma migrate dev` is template example text; `git-workflow`'s
`npx conventional-changelog` is an optional alternative to `git log`; `security-review`'s `npm ci`
is advice about which command to prefer; and `tdd-workflow`'s installer mention is policy text
*rejecting* fetch-and-execute. `ck`'s `~/.claude/ck/` writes were checked against D-18 and found to
be its own data directory, so HR-8 does **not** fire there — it is rejected on other grounds.


### T-029 — non-canonical-skill-duplicates

- **Source:** affaan-m/ECC
- **Path:** docs/<lang>/skills/, .kiro/skills/, .agents/skills/, .cursor/skills/
- **HR/axis trigger IDs:** n/a — not distinct components
- **Rationale:** 612 `SKILL.md` files that duplicate the canonical `skills/` tree for six translations (519) and three other agent harnesses (93). Nothing is rejected on its merits: these are the same components at other paths, and counting them would triple the denominator. Recorded so the 897-vs-285 arithmetic is on the record rather than inferred.
- **Date:** 2026-08-22

### T-030 — language-and-framework-packs

- **Source:** affaan-m/ECC
- **Path:** skills/ (93 skills)
- **HR/axis trigger IDs:** `axis:user_scope_fit=1`
- **Rationale:** A `SPEC.md` §8 named reject class, disposed without deep reads under §10 Phase 3 and §2 rule 2 of this log. 93 skills whose value is bound to one language, framework, runtime or UI stack — language-specific tooling at user scope (HR-3) and project- or language-specific reach (user_scope_fit 1). *(Amended 2026-08-22 by T-066: the HR-3 trigger is withdrawn — HR-3 names "LSP servers or language-specific tooling at user scope", and these 94 are prompt-only pattern documents, not tooling. The axis floor carries the class alone, as it did for T-012 in Phase 2. T-064 additionally removes `hexagonal-architecture` from the membership below, leaving 93.)* Members: accessibility, android-clean-architecture, angular-developer, api-design, backend-patterns, browser-qa, bun-runtime, click-path-audit, clickhouse-io, compose-multiplatform-patterns, content-hash-cache-pattern, cpp-coding-standards, cpp-testing, csharp-testing, dart-flutter-patterns, database-migrations, deployment-patterns, design-system, django-celery, django-patterns, django-security, django-tdd, django-verification, docker-patterns, dotnet-patterns, e2e-testing, fastapi-patterns, flutter-dart-code-review, foundation-models-on-device, frontend-a11y, frontend-design-direction, frontend-patterns, fsharp-testing, generating-python-installer, golang-patterns, golang-testing, ios-icon-gen, java-coding-standards, jpa-patterns, kotlin-coroutines-flows, kotlin-exposed-patterns, kotlin-ktor-patterns, kotlin-patterns, kotlin-testing, kubernetes-patterns, laravel-patterns, laravel-security, laravel-tdd, laravel-verification, liquid-glass-design, make-interfaces-feel-better, mcp-server-patterns, motion-advanced, motion-foundations, motion-patterns, motion-ui, mysql-patterns, nestjs-patterns, nextjs-turbopack, nodejs-keccak256, nuxt4-patterns, perl-patterns, perl-security, perl-testing, postgres-patterns, prisma-patterns, python-patterns, python-testing, pytorch-patterns, quarkus-patterns, quarkus-security, quarkus-tdd, quarkus-verification, react-native-patterns, react-patterns, react-performance, react-testing, redis-patterns, rust-patterns, rust-testing, springboot-patterns, springboot-security, springboot-tdd, springboot-verification, swift-actor-persistence, swift-concurrency-6-2, swift-protocol-di-testing, swiftui-patterns, tinystruct-patterns, ui-to-vue, vite-patterns, vue-patterns, windows-desktop-e2e.
- **Date:** 2026-08-22

### T-031 — domain-niche-skills

- **Source:** affaan-m/ECC
- **Path:** skills/ (40 skills)
- **HR/axis trigger IDs:** `axis:user_scope_fit=1`
- **Rationale:** A `SPEC.md` §8 named reject class. 40 skills encoding a vertical industry, regulated domain or specialist infrastructure practice — healthcare and HIPAA, logistics and freight, energy, manufacturing, trade compliance, prediction markets and DeFi, scientific databases, home and carrier networking. Each is codified expertise for one industry, which is the user_scope_fit 1 anchor exactly. Members: carrier-relationship-management, cisco-ios-patterns, customer-billing-ops, customs-trade-compliance, defi-amm-security, energy-procurement, evm-token-decimals, finance-billing-ops, healthcare-cdss-patterns, healthcare-emr-patterns, healthcare-eval-harness, healthcare-phi-compliance, hipaa-compliance, homelab-network-readiness, homelab-network-setup, homelab-pihole-dns, homelab-vlan-segmentation, homelab-wireguard-vpn, inventory-demand-planning, ito-baskets, llm-trading-agent-security, logistics-exception-management, ml-adoption-playbook, mle-workflow, netmiko-ssh-automation, network-bgp-diagnostics, network-config-validation, network-interface-health, prediction-market-oracle-research, prediction-market-risk-review, production-scheduling, quality-nonconformance, recsys-pipeline-architect, returns-reverse-logistics, scientific-db-pubmed-database, scientific-db-uspto-database, scientific-pkg-gget, scientific-thinking-literature-review, scientific-thinking-scholar-evaluation, visa-doc-translate.
- **Date:** 2026-08-22

### T-032 — dashboards-and-hosted-services

- **Source:** affaan-m/ECC
- **Path:** skills/ (33 skills)
- **HR/axis trigger IDs:** `HR-1,HR-2,HR-6`
- **Rationale:** A `SPEC.md` §8 named reject class ("dashboards"), widened to the third-party hosted surfaces that share its policy ground. 33 skills each requiring a named external account, API key, hosted endpoint or non-sanctioned MCP server: HR-1 on the accounts, HR-2 on MCP servers beyond Obsidian, Context7 and Claude Code, HR-6 on the network calls a shipped component would make. *(Amended 2026-08-22 by T-065: "each requiring" overstates it. `dmux-workflows` requires no account, endpoint or MCP — it is a local tmux pane manager — and `flox-environments`' hosted FloxHub path is optional. Both still reject, on `axis:dependencies=1`, not on an HR trigger.)* Members: agent-payment-x402, canary-watch, claude-devfleet, codehealth-mcp, council-multi-model, dashboard-builder, data-scraper-agent, deep-research, dmux-workflows, email-ops, exa-search, fal-ai-media, flox-environments, github-ops, google-workspace-ops, ito-compute, ito-inference, ito-training, jira-integration, knowledge-ops, laravel-plugin-discovery, mailtrap-email-integration, messages-ops, nasiko-control-plane, nutrient-document-processing, plankton-code-quality, project-flow-ops, repo-scan, social-publisher, uncloud, unified-notifications-ops, videodb, x-api.
- **Date:** 2026-08-22

### T-033 — ecc-installation-specific-skills

- **Source:** affaan-m/ECC
- **Path:** skills/ (20 skills)
- **HR/axis trigger IDs:** `axis:user_scope_fit=1,B-1..B-8`
- **Rationale:** 20 skills that operate ECC's own repository, command catalog, cost log, agent roster or products, and have no meaning outside an ECC install. Project-specific by construction (user_scope_fit 1), and none maps to a plugin under `SPEC.md` §4's B-1…B-8 boundaries, which §9 rule 2 requires before anything may be shortlisted. This class carries the five `orch-*` operation wrappers; their shared engine, `orch-pipeline`, was deep-read separately (T-049). Members: agent-sort, automation-audit-ops, configure-ecc, cost-tracking, ecc-guide, ecc-recipes, ecc-tools-cost-audit, hermes-imports, nanoclaw-repl, opensource-pipeline, orch-add-feature, orch-build-mvp, orch-change-feature, orch-fix-defect, orch-refine-code, plan-orchestrate, prompt-optimizer, research-ops, terminal-ops, workspace-surface-audit.
- **Date:** 2026-08-22

### T-034 — content-and-creative-production

- **Source:** affaan-m/ECC
- **Path:** skills/ (24 skills)
- **HR/axis trigger IDs:** `axis:user_scope_fit=1,B-1..B-8`
- **Rationale:** 24 skills for marketing, brand, social publishing, investor materials, competitive research and video, motion or slide production. `SPEC.md` §1 scopes awakened to Claude Code engineering workflow; none of the nine Tier-1 plugins owns content production (B-1…B-8), and the value is bound to one line of work (user_scope_fit 1). Members: article-writing, benchmark-methodology, blender-motion-state-inspection, brand-discovery, brand-voice, competitive-platform-analysis, competitive-report-structure, connections-optimizer, content-engine, crosspost, frontend-slides, investor-materials, investor-outreach, lead-intelligence, manim-video, market-research, marketing-campaign, openclaw-persona-forge, remotion-video-creation, seo, social-graph-ranker, taste, ui-demo, video-editing.
- **Date:** 2026-08-22

### T-035 — third-party-agent-frameworks

- **Source:** affaan-m/ECC
- **Path:** skills/ (20 skills)
- **HR/axis trigger IDs:** `B-1..B-8,HR-4`
- **Rationale:** 20 skills for building or operating *other* autonomous agent frameworks, harnesses, control planes and eval rigs. `SPEC.md` §4's lineup has no plugin that owns agent-framework construction — `bankai` owns awakened's own subagents and their allowlists under B-6, not third-party runtimes — and several in the class background long-lived processes (HR-4). `continuous-learning-v2` was deep-read separately and carries the proof (T-043); `continuous-learning` sits here because upstream marks it DEPRECATED in favour of v2. Members: agent-architecture-audit, agent-eval, agent-harness-construction, agent-introspection-debugging, agentic-os, ai-regression-testing, autonomous-agent-harness, autonomous-loops, continuous-agent-loop, continuous-learning, cost-aware-llm-pipeline, dev-team, dynamic-workflow-mode, enterprise-agent-ops, eval-harness, gan-style-harness, loop-design-check, ralphinho-rfc-pipeline, team-agent-orchestration, team-builder.
- **Date:** 2026-08-22

### T-036 — general-purpose-without-an-owning-plugin

- **Source:** affaan-m/ECC
- **Path:** skills/ (15 skills)
- **HR/axis trigger IDs:** `B-1..B-8`
- **Rationale:** 15 skills that are genuinely general but that no single Tier-1 plugin owns under B-1…B-8 — product discovery, API contract governance, paradigm-level architecture references, performance benchmarking, response-budget control, terminal launching. §9 rule 2 forbids shortlisting a component with no owner or two equally plausible owners. This class also absorbs the margin cut by the §10 Phase-3 deep-read cap; the cut is named in the Phase-3 preamble above rather than left implicit. *(Amended 2026-08-22 by T-064: gains `hexagonal-architecture`, moved from T-030 — it spans four languages, so a single-stack class never fitted it.)* Members: agentic-engineering, ai-first-engineering, api-connector-builder, benchmark, benchmark-optimization-loop, contract-first, data-throughput-accelerator, hexagonal-architecture, latency-critical-systems, product-capability, product-lens, regex-vs-llm-structured-text, security-bounty-hunter, terminal-opener, token-budget-advisor.
- **Date:** 2026-08-22

### T-037 — hooks-json-monolith

- **Source:** affaan-m/ECC
- **Path:** hooks/hooks.json
- **HR/axis trigger IDs:** `D-15,D-24`
- **Rationale:** A `SPEC.md` §8 named reject class, measured at the pin: **41,204 bytes**, 23 hook entries across 7 lifecycle events (PreToolUse, PreCompact, SessionStart, PostToolUse, PostToolUseFailure, Stop, SessionEnd). D-15 budgets one load-bearing hook per plugin and both slots are allocated; D-24 bars command handlers with no P-5-sanctioned dual-platform interpreter. Outside the 285-skill denominator and carrying no matrix row; logged because `ROADMAP.md` §5 names it among the classes Phase 3 must dispose.
- **Date:** 2026-08-22

### T-038 — blueprint

- **Source:** affaan-m/ECC
- **Path:** skills/blueprint/SKILL.md
- **HR/axis trigger IDs:** `B-1..B-8`
- **Rationale:** Its Review phase — "Every plan is reviewed by a strongest-model sub-agent" — is core, not optional, so adopting it would make `super-saiyan` depend on agents, which B-1 forbids; B-6 gives `bankai` subagents and their allowlists, not planning skills. No single owner exists (§9 rule 2). Clean on policy otherwise: the skill states it is pure Markdown with no hooks or executable code, which the directory confirms. Cold-start context briefs and the plan-mutation protocol re-donate.
- **Date:** 2026-08-22

### T-039 — ck

- **Source:** affaan-m/ECC
- **Path:** skills/ck/SKILL.md
- **HR/axis trigger IDs:** `D-24,axis:dependencies=1`
- **Rationale:** Ships `hooks/session-start.mjs` plus seven `.mjs` command scripts invoked as `node ...` — a command handler with no P-5-sanctioned dual-platform interpreter (D-24) — and requires a Node runtime outside P-5 (dependencies 1). HR-8 was checked and does **not** fire: `~/.claude/ck/` is the component's own data directory under the user's Claude config dir, which D-18 permits. The `context.json` source-of-truth with a generated `CONTEXT.md` view, unsaved-session detection and git-activity delta re-donate to `eval/claude-mem-rebuild.md`.
- **Date:** 2026-08-22

### T-040 — code-tour

- **Source:** affaan-m/ECC
- **Path:** skills/code-tour/SKILL.md
- **HR/axis trigger IDs:** `axis:dependencies=2,axis:user_scope_fit=2`
- **Rationale:** Writes `.tour` JSON whose only consumer is the CodeTour editor extension — a third-party tool outside the P-5 exceptions (dependencies 2) and tied to one editor (user_scope_fit 2). The skill itself is a clean pure prompt and verifies every file and line anchor before writing.
- **Date:** 2026-08-22

### T-041 — coding-standards

- **Source:** affaan-m/ECC
- **Path:** skills/coding-standards/SKILL.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=2`
- **Rationale:** Its own description claims "baseline cross-project coding conventions", but the body is TypeScript, React, Next.js `NextResponse` and Supabase throughout, including a React Best Practices section and Supabase query examples. Leans on one ecosystem (user_scope_fit 2) — the same ground as T-030, reached by reading the body rather than the frontmatter.
- **Date:** 2026-08-22

### T-042 — config-gc

- **Source:** affaan-m/ECC
- **Path:** skills/config-gc/SKILL.md
- **HR/axis trigger IDs:** `axis:dependencies=2`
- **Rationale:** Channel 4 (permissions) edits `~/.claude/settings.local.json` through `jq` unconditionally — a third-party CLI outside P-5 (dependencies 2). The delete path is otherwise well designed: soft delete first, one `[y/n/skip]` per candidate with no bulk approval, an undo log, and an explicit rule never to touch anything outside `~/.claude`; C-3 passes on the user-approved-location clause, so risk is 3 rather than 1.
- **Date:** 2026-08-22

### T-043 — continuous-learning-v2

- **Source:** affaan-m/ECC
- **Path:** skills/continuous-learning-v2/SKILL.md
- **HR/axis trigger IDs:** `HR-4,axis:dependencies=1`
- **Rationale:** `agents/start-observer.sh` line 203 runs `nohup env ... observer-loop.sh` with a PID file and a session guardian — a detached background watcher, not example text (HR-4). It also ships `hooks/observe.sh` and a Python instinct CLI, and depends on Python plus ECC's homunculus layout (dependencies 1).
- **Date:** 2026-08-22

### T-044 — delivery-gate

- **Source:** affaan-m/ECC
- **Path:** skills/delivery-gate/SKILL.md
- **HR/axis trigger IDs:** `D-15,D-24`
- **Rationale:** A Stop hook installed as `cp quality-gate.py ~/.claude/scripts/` and registered in `~/.claude/settings.json`. D-15 budgets hooks only to `super-saiyan` and `rinnegan` and both slots are allocated; D-24 bars command handlers with no P-5-sanctioned dual-platform interpreter. Same ground as `mattpocock/git-guardrails-claude-code` (T-016). The hook body was read: it only reads mtimes, disk usage and the transcript tail, so HR-8 does not fire.
- **Date:** 2026-08-22

### T-045 — error-handling

- **Source:** affaan-m/ECC
- **Path:** skills/error-handling/SKILL.md
- **HR/axis trigger IDs:** `B-1..B-8`
- **Rationale:** A per-language implementation reference — typed error classes and a Result type in TypeScript, an exception hierarchy and a FastAPI handler in Python, sentinel errors and wrapping in Go. Spanning three languages keeps user_scope_fit at 3, but §4's nine plugins include no owner for language references: that is precisely the class T-030 disposes of, and consistency requires the same answer when the pack covers three stacks instead of one (§9 rule 2).
- **Date:** 2026-08-22

### T-046 — gateguard

- **Source:** affaan-m/ECC
- **Path:** skills/gateguard/SKILL.md
- **HR/axis trigger IDs:** `D-15,D-24`
- **Rationale:** A PreToolUse hook shipped as `scripts/hooks/gateguard-fact-force.js`, blocking Edit, Write, MultiEdit and Bash. D-15 has no free budget and D-24 bars command handlers. Its `pip install gateguard-ai` sits under "Option B: Full package with config", an alternative to the zero-install Option A, so it is a documented user-run install rather than an auto-install and HR-7 does not fire on the `using-git-worktrees` standard. The deny-force-allow fact-forcing sequence — demand importers, schemas and the verbatim user instruction before the first edit — re-donates.
- **Date:** 2026-08-22

### T-047 — git-workflow

- **Source:** affaan-m/ECC
- **Path:** skills/git-workflow/SKILL.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** 15.2KB of general git reference: branching strategies, a config cheat-sheet, an alias list, a gitignore sample and a command table. Large instruction file for a marginal payoff (bloat 2), and the adoptable parts are already carried by `superpowers/finishing-a-development-branch` and `mattpocock/resolving-merge-conflicts`. Its `npx conventional-changelog` line is offered as an alternative to `git log v1.1.0..v1.2.0`, so it is not an auto-install.
- **Date:** 2026-08-22

### T-048 — hookify-rules

- **Source:** affaan-m/ECC
- **Path:** skills/hookify-rules/SKILL.md
- **HR/axis trigger IDs:** `axis:dependencies=1`
- **Rationale:** Documents the frontmatter and condition syntax of the third-party hookify rule engine and its `/hookify*` commands. The rule files it teaches land inside the project (`.claude/hookify.*.local.md`), so C-3 is fine, but without the engine — outside P-5 — they do nothing (dependencies 1), and shipping the engine would need hook budget D-15 has not got. Named as a `SPEC.md` §8 mining target, so the rejection is of this documentation-of-another-engine, not of the goal: ECC's own `commands/hookify*.md` enter Phase-4 scope under D-26. The declarative pattern-to-message rule format re-donates.
- **Date:** 2026-08-22

### T-049 — orch-pipeline

- **Source:** affaan-m/ECC
- **Path:** skills/orch-pipeline/SKILL.md
- **HR/axis trigger IDs:** `axis:dependencies=1,B-1..B-8`
- **Rationale:** The shared engine behind the five `orch-*` wrappers (T-033). Every phase delegates to a named ECC agent or slash command — `code-explorer`, `planner`, `tdd-guide`, `code-reviewer`, `security-reviewer`, `/feature-dev`, `/gan-build` — and to ECC's `rules/common/*.md`. Outside that install it does nothing (dependencies 1), and no §4 plugin owns an orchestration engine bound to another marketplace's catalog. The blast-radius size classifier and the two human gates (after Plan, before Commit) re-donate.
- **Date:** 2026-08-22

### T-050 — plan-canvas

- **Source:** affaan-m/ECC
- **Path:** skills/plan-canvas/SKILL.md
- **HR/axis trigger IDs:** `HR-4,axis:dependencies=1`
- **Rationale:** "It manages a detached loopback server (`127.0.0.1:4517`) shared by all sessions" — a background service (HR-4), the same shape as `superpowers/brainstorming` (T-001). It is driven by the `ecc-plan-canvas` bin from the `ecc-universal` npm package (dependencies 1) and registers a `stop:plan-canvas-pending` hook for which D-15 has no budget. The point-at-the-element human review gate re-donates.
- **Date:** 2026-08-22

### T-051 — recursive-decision-ledger

- **Source:** affaan-m/ECC
- **Path:** skills/recursive-decision-ledger/SKILL.md
- **HR/axis trigger IDs:** `axis:value=2`
- **Rationale:** An append-only ledger for repeated rollouts, stochastic search and ensemble comparison, with promotion gates written for trading and capital allocation. Narrow, occasional value for a minority of users (value 2) rather than a recurring general workflow. Its promotion discipline — recursive confidence is not approval; default to dry-run — is sound but does not lift the axis.
- **Date:** 2026-08-22

### T-052 — rules-distill

- **Source:** affaan-m/ECC
- **Path:** skills/rules-distill/SKILL.md
- **HR/axis trigger IDs:** `axis:dependencies=2`
- **Rationale:** Phase 1 is mandated as `bash scan-skills.sh` and `bash scan-rules.sh`; both scripts use `jq` throughout to build and merge their JSON output — an unconditional third-party CLI outside P-5 (dependencies 2), the same test that set `mattpocock/code-review` to 3 for an unconditional instruction. The scripts are otherwise read-only and path-validated. Promoting a principle that recurs across 2+ skills into a rule re-donates.
- **Date:** 2026-08-22

### T-053 — safety-guard

- **Source:** affaan-m/ECC
- **Path:** skills/safety-guard/SKILL.md
- **HR/axis trigger IDs:** `HR-8,D-15,D-24`
- **Rationale:** "Uses PreToolUse hooks to intercept Bash, Write, Edit, and MultiEdit" and "Logs all blocked actions to `~/.claude/safety-guard.log`" — a hook writing to the root of the user's Claude config dir, which is neither the project directory nor any owning plugin's own data directory (HR-8 as reconciled by D-18). D-15 and D-24 bar it independently. Its watched-pattern list and the freeze-to-a-directory mode re-donate.
- **Date:** 2026-08-22

### T-054 — security-review

- **Source:** affaan-m/ECC
- **Path:** skills/security-review/SKILL.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=2,axis:bloat=2`
- **Rationale:** Presented as a comprehensive security checklist; the body is TypeScript, zod, Next.js and Supabase in every example, with §9 "Blockchain Security (Solana)" as a dedicated section (user_scope_fit 2). 12.5KB plus a 10.2KB `cloud-infrastructure-security.md` sibling (bloat 2). `npm ci  # Instead of npm install` is advice about which command to prefer, not an install step, so HR-7 does not fire. The universal security lens survives in `production-audit`, which carries it without the stack lock-in.
- **Date:** 2026-08-22

### T-055 — security-scan

- **Source:** affaan-m/ECC
- **Path:** skills/security-scan/SKILL.md
- **HR/axis trigger IDs:** `HR-7,axis:dependencies=1`
- **Rationale:** "AgentShield must be installed", then every command in the skill is `npx ecc-agentshield ...`, with `npm install -g ecc-agentshield` as the recommended prerequisite. `npx` fetches and executes the package at run time and it is the whole workflow, not an aside — runtime dependency fetching (HR-7), dependencies 1. Named as a `SPEC.md` §8 mining target, so the rejection is of the implementation, not the goal: `production-audit` carries the local-evidence version and is shortlisted.
- **Date:** 2026-08-22

### T-056 — skill-comply

- **Source:** affaan-m/ECC
- **Path:** skills/skill-comply/SKILL.md
- **HR/axis trigger IDs:** `HR-7,axis:dependencies=1`
- **Rationale:** Every documented invocation is `uv run python -m scripts.run`, which resolves and installs the `pyproject.toml` dependency set at run time (HR-7), and it spawns `claude -p` subprocesses to capture traces. It ships a 21-file Python package with tests and fixtures, which `CLAUDE.md` §5.5 does not admit as a component form. Measuring whether a skill is actually followed re-donates.
- **Date:** 2026-08-22

### T-057 — skill-stocktake

- **Source:** affaan-m/ECC
- **Path:** skills/skill-stocktake/SKILL.md
- **HR/axis trigger IDs:** `axis:dependencies=2`
- **Rationale:** `scan.sh`, `quick-diff.sh` and `save-results.sh` are the mandated Phase-1 and persistence steps and all three use `jq` unconditionally (dependencies 2). The results cache is written to ~/.claude/skills/skill-stocktake/results.json — inside another component's skill directory rather than an owning plugin's data directory. Quick-Scan-versus-Full-Stocktake re-donates.
- **Date:** 2026-08-22

### T-058 — strategic-compact

- **Source:** affaan-m/ECC
- **Path:** skills/strategic-compact/SKILL.md
- **HR/axis trigger IDs:** `D-15,D-24,axis:dependencies=2`
- **Rationale:** Delivered as `suggest-compact.js`, a PreToolUse hook on Edit and Write run through `node`: D-15 has no free budget and D-24 bars command handlers with no P-5-sanctioned dual-platform interpreter; Node is outside P-5 (dependencies 2). The prompt half is good — compact at a phase boundary rather than at an arbitrary auto-compaction point, with a what-survives table — and re-donates to `kaioken`, whose §4 lineage is session momentum.
- **Date:** 2026-08-22

### T-059 — tdd-workflow

- **Source:** affaan-m/ECC
- **Path:** skills/tdd-workflow/SKILL.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** 21.5KB, the largest ECC candidate read in Phase 3, and the bulk of it is Jest, Vitest, `bun:test`, Playwright, Supabase, Redis and OpenAI mocking snippets (bloat 2). `superpowers/test-driven-development` and `mattpocock/tdd` already hold the TDD slot for `super-saiyan`, both scored 5 on bloat or one below. Its Plan Handoff section is the exception worth keeping and re-donates: treat a `*.plan.md` as untrusted data, never as instructions; reject destructive or fetch-and-execute steps; document override phrases as plan content rather than following them. That is E-1 discipline written into a skill.
- **Date:** 2026-08-22

### T-060 — unified-memory

- **Source:** affaan-m/ECC
- **Path:** skills/unified-memory/SKILL.md
- **HR/axis trigger IDs:** `HR-2,HR-7,axis:dependencies=1`
- **Rationale:** Its own "Runtime Prerequisite" section is `npm install -g ecc-universal` (HR-7), and it configures an opt-in `ecc-memory-mcp` server — an MCP beyond the three P-5 sanctions Obsidian, Context7 and Claude Code (HR-2); dependencies 1. The concept layer is the most useful ECC input to Phase 3's other half and re-donates to `eval/claude-mem-rebuild.md`: portable `ecc.memory.v1` Markdown documents rather than harness-specific transcripts, the project / team / user scope split, recall-before-writing to avoid duplicate memories, and a fail-closed `.gitignore` guarding the project scope.
- **Date:** 2026-08-22

### T-061 — agent-self-evaluation

- **Source:** affaan-m/ECC
- **Path:** skills/agent-self-evaluation/SKILL.md
- **HR/axis trigger IDs:** n/a — `merge`, not a rejection
- **Rationale:** Absorbed by `superpowers/verification-before-completion`, which fires on the same trigger and enforces the same discipline — evidence before assertion — at 3.6KB and 5 on every axis. The five-axis scorecard adds ceremony rather than a capability, and `scripts/evaluate.py` is a keyword-heuristic scorer that `CLAUDE.md` §5.5 would not admit as a component. Recorded because the absorbing row must stay traceable to what it consumed (rubric §4).
- **Date:** 2026-08-22

### T-062 — verification-loop

- **Source:** affaan-m/ECC
- **Path:** skills/verification-loop/SKILL.md
- **HR/axis trigger IDs:** n/a — `merge`, not a rejection
- **Rationale:** Its universal half — verify before claiming completion — is absorbed by `superpowers/verification-before-completion`. What remains is a six-phase command list hardcoded to `npm run build`, `tsc`, `ruff`, `npm run test -- --coverage` and grep-based secret checks, with no cross-stack path (user_scope_fit 3). `npx --no-install tsc` deliberately avoids a fetch, so no HR-7 fires. Recorded so the absorbing row stays traceable.
- **Date:** 2026-08-22

### T-063 — claude-mem-memory-hooks

- **Source:** thedotmack/claude-mem
- **Path:** plugin/hooks/hooks.json
- **HR/axis trigger IDs:** `HR-1,HR-2,HR-4,HR-5,HR-6,D-15,D-24`
- **Rationale:** The shipped implementation, read at the pin. `plugin/hooks/hooks.json` registers seven command-handler entries across six lifecycle events (Setup, SessionStart ×2, UserPromptSubmit, PostToolUse, PreToolUse, Stop), each a bash one-liner that rewrites `PATH`, locates the plugin cache and runs `node scripts/bun-runner.js scripts/worker-service.cjs`. That worker is a per-user Express daemon on port `37700+(uid%100)` with a session manager, a process registry and a five-minute orphan reaper (**HR-4**). Storage is SQLite plus ChromaDB, and the package trusts `esbuild` and ten tree-sitter entries — nine grammars plus `tree-sitter-cli` — while `engines` requires `bun` (**HR-5**). `plugin/.mcp.json` ships an `mcp-search` MCP server (**HR-2**). Dependencies include `posthog-node` (**HR-6**). `plugin/skills/cloud-sync` writes a cmem.ai Pro account token to `~/.claude-mem/settings.json` (**HR-1**). D-15 budgets one hook per plugin; this is seven, all command handlers, which D-24 bars. This is `eval/rubric.md` §7 Example A met in the field: the concept survives as `claude-mem/session-memory` and the file-based design in `eval/claude-mem-rebuild.md`; the implementation does not.
- **Date:** 2026-08-22


---

**Phase-3 review corrections, 2026-08-22.** An independent Fable-5 reviewer read the Phase-3
artifacts and both pinned clones cold — artifacts-only, no executor reasoning — and returned ten
findings. All ten were re-verified against the sources before anything was changed here. Nine are
recorded below or fixed in place; the tenth (`SPEC.md`'s header date and supersedes line, and a
`D-31` citation that resolves to a session decision outside the repository) is a governance defect
and is fixed in `SPEC.md`, `DECISIONS.md` and `ROADMAP.md` rather than in this log.

Four defects were **transcription damage from this session's own tooling**, not judgments, and are
corrected in place rather than by re-audit: a regex pass that normalised the trigger-ID fields also
stripped backticks and spaces inside two rationales (T-049, T-057), the claude-mem grammar count in
T-063 read eleven where the manifest holds ten entries of which nine are grammars, and a doubled
horizontal rule preceded the Phase-3 preamble. Correcting a mangled character is not rewriting a
verdict; §2 rule 4 governs the latter, and every judgment change is an appended entry below.

No verdict changes. The matrix stays at 97 rows, 43 shortlist / 49 reject / 5 merge.

### T-064 — hexagonal-architecture

- **Source:** affaan-m/ECC
- **Path:** skills/hexagonal-architecture/SKILL.md
- **HR/axis trigger IDs:** `B-1..B-8`
- **Rationale:** **Re-audit of a class filing.** Previously: a member of T-030, the language-and-framework-pack class, whose definition is "94 skills whose value is bound to **one** language, framework, runtime or UI stack". Now: T-036's ground, `B-1..B-8`. The skill's own frontmatter reads "across TypeScript, Java, Kotlin, and Go services" — it is not bound to one stack, so the class definition does not fit it. T-045 handled the exactly parallel case, `error-handling` across three languages, individually and on `B-1..B-8` at `user_scope_fit` 3; filing this one under a single-stack class was inconsistent with the log's own reasoning one entry later. The disposition is unchanged — reject, no owning plugin for a paradigm-level architecture reference — and no matrix row exists or is created, because it was never deep-read. T-030's membership falls to 93 and T-036's rises to 15; the 285 partition is unaffected.
- **Date:** 2026-08-22

### T-065 — dashboards-and-hosted-services-class-grounds

- **Source:** affaan-m/ECC
- **Path:** skills/ (T-032 class)
- **HR/axis trigger IDs:** `axis:dependencies=1`
- **Rationale:** **Re-audit of a class trigger set.** T-032 asserts its 33 members "each" require a named external account, API key, hosted endpoint or non-sanctioned MCP server, and stamps the class `HR-1,HR-2,HR-6`. Two members do not. `dmux-workflows` is a local tmux pane manager installed from its own repository (`SKILL.md` line 26) with no account, endpoint or MCP anywhere in the file — its only install lines are `brew install tmux` / `apt install tmux`, and its "token" matches are LLM context tokens, not credentials. `flox-environments` is a local CLI whose FloxHub hosted path is optional rather than required. Both still reject, on `axis:dependencies=1` — a third-party CLI outside the P-5 exceptions — and the class disposition for the other 31 members stands. Recorded because stamping a component with an HR trigger it does not fire is the same defect the `ck` HR-8 clearance in T-039 was careful to avoid, and a bulk entry is the one place it can go unnoticed.
- **Date:** 2026-08-22

### T-066 — language-and-framework-pack-class-grounds

- **Source:** affaan-m/ECC
- **Path:** skills/ (T-030 class)
- **HR/axis trigger IDs:** `axis:user_scope_fit=1`
- **Rationale:** **Re-audit of a class trigger set.** T-030 carried `HR-3,axis:user_scope_fit=1`. The HR-3 trigger is withdrawn: `SPEC.md` §6 defines HR-3 as "LSP servers or language-specific **tooling** at user scope", and the class members are prompt-only pattern and convention documents that ship no tooling at all. The Phase-2 precedent is T-012, which rejected a TypeScript-specific skill on the axis floor alone. The axis floor carries the class unchanged, every member's disposition is unchanged, and no matrix row is affected — but the trigger-ID field is the field `SPEC.md` §10 checks, so an unsupported ID in it is a defect in the audit record even when the outcome is right.
- **Date:** 2026-08-22

### T-067 — risk-axis-recalibration

- **Source:** affaan-m/ECC
- **Path:** skills/architecture-decision-records, skills/codebase-onboarding, skills/living-docs-governance
- **HR/axis trigger IDs:** `n/a` — re-audit of three shortlisted rows; no verdict change
- **Rationale:** **Re-audit.** Three shortlisted rows scored `risk = 5` while their own rationales cite a C-3 file-write trigger. `SPEC.md` §9 anchors 5 at "Pure skills/commands; read-only; no shell side effects" and 3 at "Conditional behaviors passing all C-1…C-3 checks"; a component that writes files in the project raises C-3 and cannot be read-only. The same session scored the identical situation at 3 twice — `ecc/inherit-legacy-style` ("C-3, risk 3") and `ecc/config-gc` in T-042 — so the file contradicted itself. Previous scores: `architecture-decision-records` 4,4,**5**,5,5; `codebase-onboarding` 5,4,**5**,5,5; `living-docs-governance` 4,4,**5**,5,5. New: risk **3** on all three. Every axis stays >= 3 and all three remain `shortlist`; matrix rows replaced in place per `eval/rubric.md` §22, ids unchanged.
- **Date:** 2026-08-22

### T-068 — search-first

- **Source:** affaan-m/ECC
- **Path:** skills/search-first/SKILL.md
- **HR/axis trigger IDs:** `n/a` — re-audit of a shortlisted row's rationale; no verdict change
- **Rationale:** **Re-audit.** The original rationale defended the skill's remote-search channels against HR-6 but never addressed its MCP surface: workflow step 5 is "Install package / **Configure MCP**" (`SKILL.md` line 49) and Quick Mode step 2 is "Is there an MCP for this? -> Check `~/.claude/settings.json` and search" (line 84). `CLAUDE.md` §10 prohibits a shipped component from adding MCP server configuration beyond Obsidian, Context7 and Claude Code. This is a deficiency synthesis can fix by striking one branch and one line, so under `eval/rubric.md` §4 it does not force a reject; the verdict and all five axis scores stand. The rationale is replaced in place to name the surface and carry the synthesis constraint, so the obligation is not lost between here and Phase 6.
- **Date:** 2026-08-22

### T-069 — phase-3-statistics-and-class-counts

- **Source:** affaan-m/ECC
- **Path:** eval/triage-log.md §4, ROADMAP.md §5
- **HR/axis trigger IDs:** `n/a` — record correction, no component affected
- **Rationale:** **Record correction.** Two counting defects. (1) §4's stated precedence rule — "`n/a` is its own row" — was not what the published table implemented: T-026 and T-027 carry the trigger `n/a (re-audit)` and were counted under other-rule, giving 14/3 where the rule yields 12/5. The rule now names the re-audit case explicitly and the table is recomputed from the file. (2) `ROADMAP.md` §5's G3 evidence read "245 in nine aggregate classes" and "9/9 classes carry rule-ID triggers". The 245 canonical skills sit in **seven** classes, T-030…T-036; T-029 covers the 612 duplicates outside the denominator and T-037 covers `hooks.json`, which is not a skill. And T-029's trigger is a stated `n/a`, so nine of nine do not carry rule IDs. Corrected in `ROADMAP.md`; the underlying dispositions and the 285 partition are unchanged.
- **Date:** 2026-08-22

---

### Phase 4 preamble — pass 1: ECC `commands/` and `agents/` (2026-08-22)

`SPEC.md` §10 Phase 4 covers the four upstream sources with no rows yet **and**, since v2.6 / D-26,
ECC's `commands/` and `agents/`. This preamble covers **pass 1**, the ECC half. The owner set the
pass structure at plan time: pass 1 ECC `commands/` + `agents/`; pass 2 `wshobson/agents`,
`anthropics/skills` and the `hesreallyhim/awesome-claude-code` gap scan; pass 3
`davila7/claude-code-templates` components alone, which measures larger than all of ECC. **G4 stays
open until all three land**, and the Gap-scan entries row in §4 stays at 0 until pass 2 runs it.

**Pin verified before any component was read.** ECC was cloned fresh into this session's scratchpad
and checked out at the `upstream.json` pin. `git rev-parse HEAD` returned
`06c5e118c4d3e6c3b7f9445f973a2194c82de193`, byte-equal to `upstream.json`'s `affaan-m/ECC` commit,
and `git status --porcelain` was empty. 1/1 MATCH.

**Denominator, measured — the D36 analogue for commands and agents.** At the pin ECC carries
**424** `*/commands/*.md` and **307** `*/agents/*.md` across the whole tree. The canonical sets are
the flat top-level directories: **94** `commands/*.md` and **68** `agents/*.md`, for a pass-1
denominator of **162**. The remainder are the same components at other paths — 280 command and 201
agent files under `docs/<lang>/`, 35 under `.opencode/`, 33 under `.kiro/`, 12 under
`legacy-command-shims/`, 3 under `.claude/`, and 5 under `skills/*/agents/`. This is the same
translation-and-harness-mirror pattern D36 recorded for the 897-vs-285 `SKILL.md` count, and it is
written down for the same reason: a reviewer counting files should not have to reconstruct it.

**The `id` convention V4.7 requires — settled before the first row was written.** All 94 command
rows use `ecc/cmd-<name>` and all 68 agent names use `ecc/agent-<name>`, **uniformly, not only for
the colliding names**. Measured collisions: nine names exist as both a skill and a command
(`ecc-guide`, `marketing-campaign`, the five `orch-*` wrappers, `plan-canvas`, `security-scan`);
`skills/ ∩ agents/` and `commands/ ∩ agents/` are both empty. Of the nine, only **two** collide
with an `id` already in `eval/matrix.csv` — `ecc/security-scan` and `ecc/plan-canvas`, both Phase-3
`reject` rows. The source slug stays `ecc` because `eval/rubric.md` §5 fixes the shape as
`<source-slug>/<component-name>` and the slug denotes the `upstream.json` repo, which check U1 pins
to exactly ten; a slug like `ecc-cmd/` would name a repository that does not exist. Disambiguating
inside the component-name half keeps the slug honest and stays kebab-case under N-3. A uniform rule
was chosen over a collisions-only rule because a rule that applies sometimes drifts. The 40 existing
`ecc/<name>` skill rows are untouched, and the two colliding pairs reached the **same** verdict
independently, on the same rule, from separate reads.

**Class authority — narrower than Phase 3's, stated so it is not read as drift.** `SPEC.md` §10
Phase 4 grants no bulk-reject authority of its own; §10 Phase 3's "shortlist → deep-read shortlist
only" was specific to that phase. The authority used here is `SPEC.md` §8's ECC row, which ratifies
reject classes at **source** level: "22 language packs, 41KB hooks.json, dashboards, domain niche
skills". Only classes named there are disposed in aggregate — T-070, T-071 and T-072. Every other
ECC command and agent carries its own deep read and its own scored matrix row, including families
that would have been convenient to batch: `epic-*` (7), the `orch-*` wrappers (5) and `multi-*` (5)
each carry individual rows. Class membership is decided **by reading the body, never by the
filename** — see T-071, where `build-error-resolver` joins the language-pack class on its contents
while `code-reviewer` and `security-reviewer`, which match the same filename pattern, do not.

**Coverage.** 162/162 canonical components dispositioned exactly once: **102 scored matrix rows**
(72 commands + 30 agents) plus **60 in three ratified classes** (22 + 28 + 10). Zero unaccounted,
zero double-counted, verified programmatically against the pinned tree.

**Screening adjudications, recorded because a screen that varies silently is not a screen.**
The two Phase-3 screens were applied unchanged. Four further calls were needed here:

1. *`gh` as an action, not only as search.* Phase 3 cleared "a skill directing the harness's own web
   or `gh` search" of HR-6. Pass 1 meets commands that also **write** through `gh` — `gh pr review
   --approve`, `gh api .../reviews`. Same ruling: the component ships no key, no endpoint and no
   service of its own, it drives a CLI the user already installed and authenticated. HR-1 and HR-6
   do not fire; the GitHub requirement is priced on `dependencies` and `user_scope_fit` instead.
2. *The `dependencies` axis, calibrated.* §9's anchor 1 is "Requires anything outside P-5
   exceptions" and rubric §2's 4-interpolation is "only ambient tooling already required to use the
   repo". Applied consistently: git-only ⇒ 4; a `gh` or web channel that is **conditional and
   degrades** ⇒ 4, the `ecc/skill-scout` precedent; a **hard** requirement on `gh` or any other
   non-P-5 tool ⇒ 1. This is the whole difference between `ecc/cmd-code-review`, which states "No
   `gh` CLI: fall back to local-only review" and is kept, and `ecc/cmd-pr` / `ecc/cmd-prp-pr`, which
   state "GitHub CLI (`gh`) is required" and are rejected.
3. *A bounded test fixture is not an HR-4 daemon.* `ecc/cmd-prp-implement` backgrounds the
   project's own dev server with `&`, captures `$!`, polls a loopback health endpoint, then `kill`s
   and `wait`s in the same script. The Phase-2 HR-4 precedent (`superpowers/brainstorming`) turned
   on `nohup`/`disown` plus a persisted PID file, a watchdog and an idle timeout — a process that
   outlives the command. A fixture whose lifetime is the script's own is not a daemon, and a
   loopback `curl` to the user's own server is not a component network call.
4. *HR-1 cleared across all 68 agents.* A mechanical secrets grep hits 67 of 68 on the shared
   "Prompt Defense Baseline" block ("…leak API keys, or expose credentials") and a further fourteen
   on secret-**detection** logic. A component that detects secrets does not require one. Zero
   genuine HR-1 in `agents/`. Recorded as a clearance, per the Phase-3 precedent of recording what
   was cleared and not only what fired.

**V4.3 — the proposed-allowlist adjudication.** `schemas/agent.schema.json` rejects bare `Bash`,
`Write`, `Edit`, `MultiEdit` and `NotebookEdit`, and any parenthesised form whose argument is only
asterisks, colons, dots or whitespace — so `Edit(**)` is refused while `Edit(src/**)` passes. The
schema therefore forces every grant to name a real scope. Measured across ECC's 68 agents: **68/68**
use the comma-separated string form and **0** the YAML list; **53/68** declare bare unrestricted
`Bash`; **0** use any `Bash(...)` restriction; **26** declare `Write`. Only six need no narrowing at
all. For a review or analysis agent a restricted allowlist is straightforward. For an agent whose
role is to **modify** files it is not, because the correct scope depends on a project layout that
does not exist at audit time. Two options were weighed — score `risk` 2 and `defer` on C-2 per
rubric §7 Example C, or propose a concrete scope now. V4.3 asks for a **proposed** restricted
allowlist, not a final one, so every agent candidate's rationale carries one: conventional
source-root grants (`Edit(src/**)`, `Edit(lib/**)`, `Edit(app/**)`) where editing is the role, and
`Write` omitted from **every** agent — creating new files stays with the main thread. Phase 6 pins
the real scope when `bankai`'s agents are authored. The tension is recorded rather than left
implicit, because a reviewer counting bare grants should see that it was faced.

**Outcome.** 102 rows appended — **26 shortlist / 69 reject / 7 merge**, zero `defer`. By owning
plugin the shortlist reads `sharingan` 8, `super-saiyan` 6, `kaioken` 4, `instinct` 3, `bankai` 3,
`domain` 2. `kaioken`'s roster, which held a single shortlisted row after Phase 3, gains four
(`cmd-save-session`, `cmd-resume-session`, `cmd-aside`, `cmd-checkpoint`) — the §4 lineage D-26 was
written to reach. All seven `merge` rows name their absorbing row's `id`, as `eval/rubric.md` §4
requires, and every absorbing row is itself shortlisted.

### T-070 — ecc-language-pack-commands

- **Source:** affaan-m/ECC
- **Path:** commands/ (22 files: cpp-*, flutter-*, go-*, gradle-build, kotlin-*, react-*, rust-*, fastapi-review, python-review, vue-review)
- **HR/axis trigger IDs:** `B-1..B-8,axis:user_scope_fit=1`
- **Rationale:** **Class reject, 22 components, no matrix rows.** Each binds one stack's toolchain - clang/cmake/ctest, dart/flutter, go/golangci-lint, gradle/ktlint/detekt, cargo/clippy, mypy/pytest/ruff, vitest/jest, eslint/tsc - and 15 of the 22 delegate to a same-stack ECC resolver or reviewer agent. SPEC 4's nine plugins own no per-language implementation reference, the ground ecc/error-handling was rejected on, and `project- or language-specific` is the SPEC 9 anchor-1 wording for user_scope_fit. The count matches SPEC 8's ratified ECC reject class `22 language packs` exactly; that figure describes commands/, not skills/, which the Phase-3 language-pack class (93 skills) already showed.
- **Date:** 2026-08-22

### T-071 — ecc-language-pack-agents

- **Source:** affaan-m/ECC
- **Path:** agents/ (28 files: 16 <lang>-reviewer, 11 <lang>-build-resolver, build-error-resolver)
- **HR/axis trigger IDs:** `B-1..B-8,axis:user_scope_fit=1`
- **Rationale:** **Class reject, 28 components, no matrix rows.** Same ground as T-070 on the agent side. Membership was decided by reading, not by filename: `build-error-resolver` is named generically but every diagnostic it runs is `npx tsc --noEmit`, `npm run build` or `npx eslint`, its fix table is TypeScript-specific, and its Quick Recovery step is `rm -rf node_modules package-lock.json && npm install` - so it is a TypeScript pack and additionally fires HR-7. Conversely `code-reviewer` and `security-reviewer` match the same `-reviewer` filename pattern and were NOT classed: both are general-purpose and carry their own scored rows.
- **Date:** 2026-08-22

### T-072 — ecc-domain-niche-agents

- **Source:** affaan-m/ECC
- **Path:** agents/ (10 files: database-reviewer, healthcare-reviewer, mle-reviewer, rag-pipeline-reviewer, network-config-reviewer, network-architect, network-troubleshooter, homelab-architect, marketing-agent, seo-specialist)
- **HR/axis trigger IDs:** `B-1..B-8,axis:user_scope_fit=1`
- **Rationale:** **Class reject, 10 components, no matrix rows.** SPEC 8 ratifies `domain niche` as an ECC reject class. Each addresses a discipline rather than a project type - PostgreSQL tuning, PHI and clinical-safety review, ML training pipelines, RAG retrieval quality, router and switch configs, network and homelab topology, marketing campaigns, technical SEO - and none maps to an owning plugin under B-1..B-8, which SPEC 4's closing rule makes unshortlistable.
- **Date:** 2026-08-22

### T-073 — cmd-feature-dev

- **Source:** affaan-m/ECC
- **Path:** commands/feature-dev.md
- **HR/axis trigger IDs:** n/a - merge, not a rejection
- **Rationale:** Fully absorbed by ecc/cmd-plan. Seven phases whose substance is three ECC agent dispatches (code-explorer, code-architect, code-reviewer); the universal residue - understand existing code before writing, gate on approval, summarize with follow-ups - is already carried by ecc/cmd-plan and superpowers' shortlisted planning rows.
- **Date:** 2026-08-22

### T-074 — cmd-review-pr

- **Source:** affaan-m/ECC
- **Path:** commands/review-pr.md
- **HR/axis trigger IDs:** n/a - merge, not a rejection
- **Rationale:** Fully absorbed by ecc/cmd-code-review. It is a dispatch list for six ECC agents; its unique residue is the confidence >= 80 reporting rule and a three-tier severity split, both of which cmd-code-review already carries in its own severity matrix.
- **Date:** 2026-08-22

### T-075 — cmd-santa-loop

- **Source:** affaan-m/ECC
- **Path:** commands/santa-loop.md
- **HR/axis trigger IDs:** n/a - merge, not a rejection
- **Rationale:** Fully absorbed by ecc/santa-method, already shortlisted for bankai. The skill holds the whole method - two context-isolated reviewers, both must PASS, fresh agents each round, three-round cap then escalate. The command's only residue is an optional codex/gemini CLI branch for model diversity and an unconditional git push -u origin HEAD on the NICE path, which is a liability rather than value.
- **Date:** 2026-08-22

### T-076 — cmd-gan-build

- **Source:** affaan-m/ECC
- **Path:** commands/gan-build.md
- **HR/axis trigger IDs:** n/a - merge, not a rejection
- **Rationale:** Fully absorbed by ecc/santa-method. A generator/evaluator loop with bounded iterations, a scored rubric and an escalation cap - the same bounded multi-agent convergence shape santa-method already carries as a shortlisted row - plus a gan-harness/ directory convention and three ECC-specific agents (gan-planner, gan-generator, gan-evaluator).
- **Date:** 2026-08-22

### T-077 — cmd-learn

- **Source:** affaan-m/ECC
- **Path:** commands/learn.md
- **HR/axis trigger IDs:** n/a - merge, not a rejection
- **Rationale:** Fully absorbed by ecc/cmd-learn-eval, which is the same extraction step plus the three things this one lacks: a quality gate before writing, a Global-versus-Project save-location decision, and an overlap grep against existing skills.
- **Date:** 2026-08-22

### T-078 — cmd-sessions

- **Source:** affaan-m/ECC
- **Path:** commands/sessions.md
- **HR/axis trigger IDs:** `D-24`
- **Rationale:** Every action is a node -e handler requiring bundled $CLAUDE_PLUGIN_ROOT/scripts/lib/session-manager + session-aliases. D-24 bars command handlers pending a P-5 dual-platform interpreter; dependencies=1. Concept (session index, aliases, branch/worktree metadata) re-donated to kaioken.
- **Date:** 2026-08-22

### T-079 — cmd-project-init

- **Source:** affaan-m/ECC
- **Path:** commands/project-init.md
- **HR/axis trigger IDs:** `D-24`
- **Rationale:** Resolves its plan through ECC's own node scripts/install-plan.js and scripts/install-apply.js plus config/project-stack-mappings.json - a node command handler (D-24) onto repo-specific tooling; dependencies=1, and it onboards ECC rather than the user's project. Concept re-donated to domain: dry-run first, never replace CLAUDE.md without a diff and approval, narrow generated permissions.
- **Date:** 2026-08-22

### T-080 — cmd-hookify

- **Source:** affaan-m/ECC
- **Path:** commands/hookify.md
- **HR/axis trigger IDs:** `D-15`
- **Rationale:** Generates arbitrary .claude/hookify.*.local.md rule files bound to bash/file/stop/prompt/all events. D-15 caps hooks at one per plugin, load-bearing only, and SPEC 6 names the only two (super-saiyan session-start, rinnegan capture); a hook FACTORY cannot live inside that budget. Same ground as the Phase-3 rejection of ecc/hookify-rules. Step 1 also depends on ECC's own conversation-analyzer agent. Declarative rule format re-donated.
- **Date:** 2026-08-22

### T-081 — cmd-hookify-configure

- **Source:** affaan-m/ECC
- **Path:** commands/hookify-configure.md
- **HR/axis trigger IDs:** `D-15`
- **Rationale:** Toggles the enabled: field in hookify rule files; has no value without cmd-hookify, which D-15 rejects.
- **Date:** 2026-08-22

### T-082 — cmd-hookify-list

- **Source:** affaan-m/ECC
- **Path:** commands/hookify-list.md
- **HR/axis trigger IDs:** `D-15`
- **Rationale:** Tabulates hookify rule files; same D-15 dependency as cmd-hookify-configure.
- **Date:** 2026-08-22

### T-083 — cmd-hookify-help

- **Source:** affaan-m/ECC
- **Path:** commands/hookify-help.md
- **HR/axis trigger IDs:** `D-15`
- **Rationale:** Pure documentation for the hookify system D-15 bars the marketplace from shipping.
- **Date:** 2026-08-22

### T-084 — cmd-security-scan

- **Source:** affaan-m/ECC
- **Path:** commands/security-scan.md
- **HR/axis trigger IDs:** `HR-7`
- **Rationale:** HR-7: the deterministic engine is npx ecc-agentshield scan, with npm run scan as the only alternative - a workflow whose every executable step is npx/npm-backed (Phase-3 screen 2). Also pins affaan-m/agentshield@v1 and a hosted repo. Identical ground to the skill twin ecc/security-scan, which the id convention keeps as a separate row.
- **Date:** 2026-08-22

### T-085 — cmd-plan-canvas

- **Source:** affaan-m/ECC
- **Path:** commands/plan-canvas.md
- **HR/axis trigger IDs:** `HR-4`
- **Rationale:** HR-4: ecc-plan-canvas open then await runs a local browser review server that blocks until the page reports back, backed by scripts/plan-canvas.js. Same ground as the skill twin ecc/plan-canvas (HR-4), kept as a separate row under the id convention.
- **Date:** 2026-08-22

### T-086 — cmd-prp-plan

- **Source:** affaan-m/ECC
- **Path:** commands/prp-plan.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. 13.9KB, the second-largest command, with a 7-phase pipeline and a plan template running to six named pattern sections; ECC's own cmd-plan calls this 'the legacy PRP flow'. Same ground as the Phase-3 rejection of ecc/tdd-workflow at 21.5KB. Concepts re-donated to super-saiyan: Mandatory Reading (files that MUST be read before implementing) and an explicit NOT Building section.
- **Date:** 2026-08-22

### T-087 — cmd-prp-prd

- **Source:** affaan-m/ECC
- **Path:** commands/prp-prd.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. 14.1KB, the largest command, 7 interactive phases including market-research and technical-feasibility grounding. cmd-plan-prd is the lean shortlisted equivalent and cuts those two phases deliberately as research ceremony, so this is not a merge - the unique content is excluded on purpose, not absorbed.
- **Date:** 2026-08-22

### T-088 — cmd-prp-pr

- **Source:** affaan-m/ECC
- **Path:** commands/prp-pr.md
- **HR/axis trigger IDs:** `axis:dependencies=1`
- **Rationale:** axis:dependencies=1. Hard-requires the GitHub CLI and says so - 'No gh CLI: Stop with: GitHub CLI (gh) is required' - with no degraded path, and gh sits outside the P-5 exceptions, which is the dependencies=1 anchor verbatim. Contrast cmd-code-review, which degrades to local-only and scores 4. Concepts re-donated: ordered PR-template discovery (.github/PULL_REQUEST_TEMPLATE/ -> .md -> docs/), and linking planning artifacts into the PR body.
- **Date:** 2026-08-22

### T-089 — cmd-pr

- **Source:** affaan-m/ECC
- **Path:** commands/pr.md
- **HR/axis trigger IDs:** `axis:dependencies=1`
- **Rationale:** axis:dependencies=1. A near-duplicate of cmd-prp-pr (27 differing lines in ~180) and it carries the same hard gh requirement with no degraded path - 'No gh CLI: Stop with: GitHub CLI (gh) is required'. Rejected on its own ground rather than merged, because the row it would name is itself a reject.
- **Date:** 2026-08-22

### T-090 — cmd-auto-update

- **Source:** affaan-m/ECC
- **Path:** commands/auto-update.md
- **HR/axis trigger IDs:** `HR-7`
- **Rationale:** Runs node scripts/auto-update.js behind a 900-character inlined node root-resolver, pulls ECC's upstream repo and reruns install-apply.js. D-24 command handler, HR-7 reinstall, and it maintains ECC itself rather than the user's project.
- **Date:** 2026-08-22

### T-091 — cmd-model-route

- **Source:** affaan-m/ECC
- **Path:** commands/model-route.md
- **HR/axis trigger IDs:** `axis:value=2`
- **Rationale:** axis:value=2. 697 bytes recommending a haiku/sonnet/opus tier from a three-line heuristic. Narrow, occasional value, and it hardcodes model tier names that drift with each model release.
- **Date:** 2026-08-22

### T-092 — cmd-quality-gate

- **Source:** affaan-m/ECC
- **Path:** commands/quality-gate.md
- **HR/axis trigger IDs:** `D-24,D-15`
- **Rationale:** Operator entry point for ECC's post:quality-gate PostToolUse hook - node scripts/hooks/quality-gate.js fed hook-shaped JSON on stdin, wired through hooks/hooks.json. D-24 command handler plus D-15: the marketplace ships no PostToolUse hook and the budget names only super-saiyan's session-start and rinnegan's capture. Also requires Biome or Prettier, gofmt and ruff.
- **Date:** 2026-08-22

### T-093 — cmd-loop-start

- **Source:** affaan-m/ECC
- **Path:** commands/loop-start.md
- **HR/axis trigger IDs:** `D-15`
- **Rationale:** D-15. Step 3 is 'Enable required hooks/profile for the chosen mode' and the safety checks read ECC_HOOK_PROFILE, so the command's core is ECC's hook-profile machinery, which the D-15 budget does not admit. It also offers an infinite loop pattern whose stop condition is advisory.
- **Date:** 2026-08-22

### T-094 — cmd-cost-report

- **Source:** affaan-m/ECC
- **Path:** commands/cost-report.md
- **HR/axis trigger IDs:** `D-24,D-15`
- **Rationale:** A node -e handler (D-24) over ~/.claude/metrics/costs.jsonl, a file written by ECC's stop:cost-tracker hook. D-15 admits no such hook, so the data source does not exist in this marketplace.
- **Date:** 2026-08-22

### T-095 — cmd-ecc-guide

- **Source:** affaan-m/ECC
- **Path:** commands/ecc-guide.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=1`
- **Rationale:** axis:user_scope_fit=1. A conversational map of ECC's own repository - it inspects README.md, AGENTS.md, agent.yaml, manifests/install-*.json and node scripts/ci/catalog.js --json. Value exists only inside an ECC checkout.
- **Date:** 2026-08-22

### T-096 — cmd-evolve

- **Source:** affaan-m/ECC
- **Path:** commands/evolve.md
- **HR/axis trigger IDs:** `D-24`
- **Rationale:** python3 ${CLAUDE_PLUGIN_ROOT}/skills/continuous-learning-v2/scripts/instinct-cli.py evolve - a D-24 command handler onto the continuous-learning-v2 skill, which Phase 3 already rejected on HR-4. dependencies=1.
- **Date:** 2026-08-22

### T-097 — cmd-harness-audit

- **Source:** affaan-m/ECC
- **Path:** commands/harness-audit.md
- **HR/axis trigger IDs:** `D-24`
- **Rationale:** node scripts/harness-audit.js is declared the source of truth for all scoring (D-24), and the 12-category rubric scores ECC-shaped repositories, four of its categories keyed to Vercel/Netlify/Cloudflare/Fly markers. Concept re-donated to instinct: a deterministic scorecard whose output the agent must use directly - 'do not rescore manually'.
- **Date:** 2026-08-22

### T-098 — cmd-instinct-export

- **Source:** affaan-m/ECC
- **Path:** commands/instinct-export.md
- **HR/axis trigger IDs:** `axis:dependencies=1`
- **Rationale:** axis:dependencies=1. Reads and exports the instinct store at ~/.claude/homunculus/, which only the continuous-learning-v2 skill populates; that skill is a Phase-3 HR-4 reject, so the store never exists here.
- **Date:** 2026-08-22

### T-099 — cmd-instinct-import

- **Source:** affaan-m/ECC
- **Path:** commands/instinct-import.md
- **HR/axis trigger IDs:** `HR-6`
- **Rationale:** HR-6: imports instincts from HTTP(S) URLs - the documented example fetches https://github.com/org/repo/instincts.yaml - and runs through python3 instinct-cli.py (D-24). Fetching and then trusting a remote behavior file is also an E-1 injection surface.
- **Date:** 2026-08-22

### T-100 — cmd-instinct-status

- **Source:** affaan-m/ECC
- **Path:** commands/instinct-status.md
- **HR/axis trigger IDs:** `D-24`
- **Rationale:** python3 '$ECC_ROOT/skills/continuous-learning-v2/scripts/instinct-cli.py' status behind the inlined node root-resolver. D-24, and the same dead ~/.claude/homunculus/ store as cmd-instinct-export.
- **Date:** 2026-08-22

### T-101 — cmd-jira

- **Source:** affaan-m/ECC
- **Path:** commands/jira.md
- **HR/axis trigger IDs:** `HR-1,HR-2,HR-6`
- **Rationale:** HR-1,HR-2,HR-6. Reaches Jira 'via MCP jira_get_issue or REST API': a hosted third-party service needing an account (HR-1), an MCP server outside the three P-5 permits (HR-2), and a direct REST call (HR-6).
- **Date:** 2026-08-22

### T-102 — cmd-promote

- **Source:** affaan-m/ECC
- **Path:** commands/promote.md
- **HR/axis trigger IDs:** `axis:dependencies=1,D-24`
- **Rationale:** axis:dependencies=1. python3 ${CLAUDE_PLUGIN_ROOT}/skills/continuous-learning-v2/scripts/instinct-cli.py promote (D-24) writing ~/.claude/homunculus/instincts/personal/; the backing skill is a Phase-3 HR-4 reject so the store never exists.
- **Date:** 2026-08-22

### T-103 — cmd-prune

- **Source:** affaan-m/ECC
- **Path:** commands/prune.md
- **HR/axis trigger IDs:** `axis:dependencies=1,D-24`
- **Rationale:** axis:dependencies=1. Same instinct-cli.py handler (D-24) and the same dead homunculus store; deletes pending instincts older than 30 days.
- **Date:** 2026-08-22

### T-104 — cmd-projects

- **Source:** affaan-m/ECC
- **Path:** commands/projects.md
- **HR/axis trigger IDs:** `axis:dependencies=1,D-24`
- **Rationale:** axis:dependencies=1. Same instinct-cli.py handler (D-24); reads ~/.claude/homunculus/projects.json.
- **Date:** 2026-08-22

### T-105 — cmd-setup-pm

- **Source:** affaan-m/ECC
- **Path:** commands/setup-pm.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=1,D-24`
- **Rationale:** axis:user_scope_fit=1. node scripts/setup-package-manager.js (D-24) choosing among npm, pnpm, yarn and bun - one ecosystem only - and writing ~/.claude/package-manager.json.
- **Date:** 2026-08-22

### T-106 — cmd-refactor-clean

- **Source:** affaan-m/ECC
- **Path:** commands/refactor-clean.md
- **HR/axis trigger IDs:** `HR-7,axis:user_scope_fit=1`
- **Rationale:** HR-7,axis:user_scope_fit=1. Every detection tool is an npx fetch of a JavaScript-only package - npx knip, npx depcheck, npx ts-prune - with no path for any other stack; a workflow whose every step is npx <tool> is the Phase-3 screen-2 case. The verify-after-each-deletion loop is re-donated to super-saiyan.
- **Date:** 2026-08-22

### T-107 — cmd-pm2

- **Source:** affaan-m/ECC
- **Path:** commands/pm2.md
- **HR/axis trigger IDs:** `HR-4,HR-7`
- **Rationale:** HR-4,HR-7. PM2 is a process manager that keeps services resident, and step 1 is 'Check PM2 (install via npm install -g pm2 if missing)' - an unconditional global auto-install.
- **Date:** 2026-08-22

### T-108 — cmd-loop-status

- **Source:** affaan-m/ECC
- **Path:** commands/loop-status.md
- **HR/axis trigger IDs:** `HR-7`
- **Rationale:** HR-7: the cross-session path is npx --package ecc-universal ecc loop-status --json, the same ecc-universal package that carried ecc/unified-memory to an HR-2,HR-7 reject in Phase 3.
- **Date:** 2026-08-22

### T-109 — cmd-gan-design

- **Source:** affaan-m/ECC
- **Path:** commands/gan-design.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=2`
- **Rationale:** axis:user_scope_fit=2. The same harness narrowed to 'frontend or visual work', with a rubric weighted Design Quality 0.35 / Originality 0.30 / Craft 0.25 / Functionality 0.10. Leans on one discipline with partial value elsewhere.
- **Date:** 2026-08-22

### T-110 — cmd-marketing-campaign

- **Source:** affaan-m/ECC
- **Path:** commands/marketing-campaign.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=1`
- **Rationale:** axis:user_scope_fit=1. Positioning, landing-page copy, email sequences, ad variants and content calendars - a marketing discipline, not a project type, and SPEC 8 ratifies domain-niche as an ECC reject class.
- **Date:** 2026-08-22

### T-111 — cmd-orch-review

- **Source:** affaan-m/ECC
- **Path:** commands/orch-review.md
- **HR/axis trigger IDs:** `axis:dependencies=1`
- **Rationale:** axis:dependencies=1. A surface for ECC's own native orch-review Workflow, which is what performs the review; without it the command has no engine. Concept re-donated to sharingan: the fail-closed contract, and the strict PR-URL validation that rejects any input that is not exactly https://github.com/<owner>/<repo>/pull/<N>.
- **Date:** 2026-08-22

### T-112 — cmd-skill-health

- **Source:** affaan-m/ECC
- **Path:** commands/skill-health.md
- **HR/axis trigger IDs:** `D-24`
- **Rationale:** node '$ECC_ROOT/scripts/skills-health.js' --dashboard behind the inlined node root-resolver - a D-24 command handler, and dashboards are one of the four ECC reject classes SPEC 8 ratifies by name.
- **Date:** 2026-08-22

### T-113 — cmd-epic-claim

- **Source:** affaan-m/ECC
- **Path:** commands/epic-claim.md
- **HR/axis trigger IDs:** `HR-5`
- **Rationale:** HR-5. node scripts/github-coordination.js claim (D-24) and its stated effect is 'Updates labels and the local SQLite cache' - a native sqlite store.
- **Date:** 2026-08-22

### T-114 — cmd-epic-decompose

- **Source:** affaan-m/ECC
- **Path:** commands/epic-decompose.md
- **HR/axis trigger IDs:** `axis:dependencies=1,D-24`
- **Rationale:** axis:dependencies=1. node scripts/github-coordination.js decompose (D-24); the coordination block it reconciles exists only inside ECC's GitHub issue schema.
- **Date:** 2026-08-22

### T-115 — cmd-epic-publish

- **Source:** affaan-m/ECC
- **Path:** commands/epic-publish.md
- **HR/axis trigger IDs:** `axis:dependencies=1,D-24`
- **Rationale:** axis:dependencies=1. node scripts/github-coordination.js publish (D-24), writing a coordination block back into a GitHub issue body.
- **Date:** 2026-08-22

### T-116 — cmd-epic-review

- **Source:** affaan-m/ECC
- **Path:** commands/epic-review.md
- **HR/axis trigger IDs:** `axis:dependencies=1,D-24`
- **Rationale:** axis:dependencies=1. node scripts/github-coordination.js review (D-24); review state lives in ECC's issue coordination block.
- **Date:** 2026-08-22

### T-117 — cmd-epic-sync

- **Source:** affaan-m/ECC
- **Path:** commands/epic-sync.md
- **HR/axis trigger IDs:** `HR-5`
- **Rationale:** HR-5. node scripts/github-coordination.js sync (D-24) whose stated job is 'Keeps the SQLite cache aligned with GitHub'.
- **Date:** 2026-08-22

### T-118 — cmd-epic-unblock

- **Source:** affaan-m/ECC
- **Path:** commands/epic-unblock.md
- **HR/axis trigger IDs:** `axis:dependencies=1,D-24`
- **Rationale:** axis:dependencies=1. node scripts/github-coordination.js unblock (D-24), sweeping ECC-schema epic issues.
- **Date:** 2026-08-22

### T-119 — cmd-epic-validate

- **Source:** affaan-m/ECC
- **Path:** commands/epic-validate.md
- **HR/axis trigger IDs:** `axis:dependencies=1,D-24`
- **Rationale:** axis:dependencies=1. node scripts/github-coordination.js validate (D-24); validates ECC's coordination policy, not the user's project.
- **Date:** 2026-08-22

### T-120 — cmd-orch-add-feature

- **Source:** affaan-m/ECC
- **Path:** commands/orch-add-feature.md
- **HR/axis trigger IDs:** `axis:dependencies=1`
- **Rationale:** axis:dependencies=1. A launcher for the orch-add-feature skill 'via the shared orch-pipeline engine'; ecc/orch-pipeline is already a matrix reject, and the pipeline dispatches ECC's code-reviewer and security-reviewer agents. The two-gate Research-Plan-TDD-Review-Commit shape was re-donated in Phase 3.
- **Date:** 2026-08-22

### T-121 — cmd-orch-build-mvp

- **Source:** affaan-m/ECC
- **Path:** commands/orch-build-mvp.md
- **HR/axis trigger IDs:** `axis:dependencies=1`
- **Rationale:** axis:dependencies=1. Same orch-pipeline engine, and step 3 additionally drives the GAN harness through /gan-build --skip-planner, adding the gan-planner, gan-generator and gan-evaluator agents to the dependency set.
- **Date:** 2026-08-22

### T-122 — cmd-orch-change-feature

- **Source:** affaan-m/ECC
- **Path:** commands/orch-change-feature.md
- **HR/axis trigger IDs:** `axis:dependencies=1`
- **Rationale:** axis:dependencies=1. Same orch-pipeline engine. Its distinction from the sibling commands - update the existing tests first, which is what makes a change a tweak rather than a fix - is re-donated to super-saiyan.
- **Date:** 2026-08-22

### T-123 — cmd-orch-fix-defect

- **Source:** affaan-m/ECC
- **Path:** commands/orch-fix-defect.md
- **HR/axis trigger IDs:** `axis:dependencies=1`
- **Rationale:** axis:dependencies=1. Same orch-pipeline engine, plus the code-explorer agent for root-cause scoping. Its write-a-failing-regression-test-first rule is already held by superpowers' shortlisted TDD rows.
- **Date:** 2026-08-22

### T-124 — cmd-orch-refine-code

- **Source:** affaan-m/ECC
- **Path:** commands/orch-refine-code.md
- **HR/axis trigger IDs:** `axis:dependencies=1`
- **Rationale:** axis:dependencies=1. Same orch-pipeline engine, plus delegation to the refactor-cleaner agent. Its characterization-tests-green-before-touching rule is re-donated to super-saiyan.
- **Date:** 2026-08-22

### T-125 — cmd-multi-backend

- **Source:** affaan-m/ECC
- **Path:** commands/multi-backend.md
- **HR/axis trigger IDs:** `HR-1,HR-2,HR-7`
- **Rationale:** HR-1,HR-2,HR-7. Unconditional prerequisite 'Requires the external ccg-workflow runtime ... Initialize it with npx ccg-workflow' (HR-7), mcp__ace-tool__* beyond the three permitted MCP servers (HR-2), and it is Codex-led, driving a hosted third-party model (HR-1).
- **Date:** 2026-08-22

### T-126 — cmd-multi-execute

- **Source:** affaan-m/ECC
- **Path:** commands/multi-execute.md
- **HR/axis trigger IDs:** `HR-1,HR-2,HR-7`
- **Rationale:** HR-1,HR-2,HR-7. Same ccg-workflow prerequisite, same ace-tool MCP, and it orchestrates hosted Codex sessions with run_in_background and a 10-minute timeout.
- **Date:** 2026-08-22

### T-127 — cmd-multi-frontend

- **Source:** affaan-m/ECC
- **Path:** commands/multi-frontend.md
- **HR/axis trigger IDs:** `HR-1,HR-2,HR-7`
- **Rationale:** HR-1,HR-2,HR-7. Same ccg-workflow prerequisite and ace-tool MCP; Antigravity-led, a hosted third-party model.
- **Date:** 2026-08-22

### T-128 — cmd-multi-plan

- **Source:** affaan-m/ECC
- **Path:** commands/multi-plan.md
- **HR/axis trigger IDs:** `HR-1,HR-2,HR-7`
- **Rationale:** HR-1,HR-2,HR-7. Same ccg-workflow prerequisite and ace-tool MCP; mandates parallel background calls to both Codex and Antigravity.
- **Date:** 2026-08-22

### T-129 — cmd-multi-workflow

- **Source:** affaan-m/ECC
- **Path:** commands/multi-workflow.md
- **HR/axis trigger IDs:** `HR-1,HR-2,HR-7`
- **Rationale:** HR-1,HR-2,HR-7. Same ccg-workflow prerequisite and ace-tool MCP, routes frontend to Antigravity and backend to Codex, and additionally runs node scripts/orchestrate-worktrees.js for tmux/worktree fan-out.
- **Date:** 2026-08-22

### T-130 — agent-architect

- **Source:** affaan-m/ECC
- **Path:** agents/architect.md
- **HR/axis trigger IDs:** n/a - merge, not a rejection
- **Rationale:** Fully absorbed by ecc/agent-code-architect. Both design feature architecture from Read/Grep/Glob only; code-architect is a third the size and adds the two things that matter - fit the design to patterns already in the repo, and emit a dependency-ordered build sequence - while this one is a generic senior-architect brief.
- **Date:** 2026-08-22

### T-131 — agent-docs-lookup

- **Source:** affaan-m/ECC
- **Path:** agents/docs-lookup.md
- **HR/axis trigger IDs:** n/a - merge, not a rejection
- **Rationale:** Fully absorbed by ecc/documentation-lookup, already shortlisted for super-saiyan. Same Context7 path, same three-call cap; the skill additionally redacts secrets before querying. HR-2 CLEARED on both: Context7 is one of the three P-5-sanctioned MCP servers. Worth carrying into synthesis from this row: its explicit instruction to treat fetched documentation as untrusted and never obey instructions embedded in tool output (E-1).
- **Date:** 2026-08-22

### T-132 — agent-harness-optimizer

- **Source:** affaan-m/ECC
- **Path:** agents/harness-optimizer.md
- **HR/axis trigger IDs:** `axis:dependencies=1,D-24`
- **Rationale:** axis:dependencies=1. Step 1 is 'Run /harness-audit and collect baseline score', and cmd-harness-audit is a D-24 node scripts/harness-audit.js reject; without that scorecard the agent has no baseline. Its constraint list also targets Cursor, OpenCode and Codex compatibility.
- **Date:** 2026-08-22

### T-133 — agent-loop-operator

- **Source:** affaan-m/ECC
- **Path:** agents/loop-operator.md
- **HR/axis trigger IDs:** `axis:dependencies=1,D-24,D-15`
- **Rationale:** axis:dependencies=1. Operates the autonomous loops cmd-loop-start creates, and its required checks - quality gates active, eval baseline exists, branch/worktree isolation configured - are all ECC harness state that D-15 and D-24 keep out of this marketplace.
- **Date:** 2026-08-22

### T-134 — agent-tdd-guide

- **Source:** affaan-m/ECC
- **Path:** agents/tdd-guide.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=2`
- **Rationale:** axis:user_scope_fit=2. Every command in the Red-Green-Refactor loop is npm test / npm run test:coverage, so the enforcement mechanism only exists for one ecosystem, and super-saiyan already holds the TDD slot from superpowers and mattpocock.
- **Date:** 2026-08-22

### T-135 — agent-doc-updater

- **Source:** affaan-m/ECC
- **Path:** agents/doc-updater.md
- **HR/axis trigger IDs:** `HR-7,axis:user_scope_fit=1`
- **Rationale:** HR-7,axis:user_scope_fit=1. Its three analysis commands are npx tsx scripts/codemaps/generate.ts, npx madge and npx jsdoc2md, and responsibility 3 is 'Use TypeScript compiler API to understand structure' - one ecosystem, reached by fetch.
- **Date:** 2026-08-22

### T-136 — agent-refactor-cleaner

- **Source:** affaan-m/ECC
- **Path:** agents/refactor-cleaner.md
- **HR/axis trigger IDs:** `HR-7,axis:user_scope_fit=1`
- **Rationale:** HR-7,axis:user_scope_fit=1. Detection is entirely npx knip, npx depcheck, npx ts-prune, npx eslint; same ground as ecc/cmd-refactor-clean. Its SAFE/CAREFUL/RISKY risk triage and grep-for-dynamic-imports check are re-donated to sharingan.
- **Date:** 2026-08-22

### T-137 — agent-spec-miner

- **Source:** affaan-m/ECC
- **Path:** agents/spec-miner.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. 15.1KB, the largest ECC agent, and its output is bound to the OpenSpec openspec/specs/<capability>/spec.md convention. Re-donated and notable: it is the only ECC agent that scopes its own grants in prose - 'Write may only create openspec/specs/<capability>/spec.md' and 'Bash must stay read-only' - which is exactly what C-2 asks to be expressed in the tools field instead, e.g. Write(openspec/specs/**).
- **Date:** 2026-08-22

### T-138 — agent-conversation-analyzer

- **Source:** affaan-m/ECC
- **Path:** agents/conversation-analyzer.md
- **HR/axis trigger IDs:** `axis:dependencies=1,D-15`
- **Rationale:** axis:dependencies=1. It exists to feed cmd-hookify - it mines corrections, reverts and repeated frustrations into candidate hook rules - and D-15 bars the hook factory it serves.
- **Date:** 2026-08-22

### T-139 — agent-performance-optimizer

- **Source:** affaan-m/ECC
- **Path:** agents/performance-optimizer.md
- **HR/axis trigger IDs:** `HR-6,HR-7,axis:user_scope_fit=1`
- **Rationale:** HR-6,HR-7,axis:user_scope_fit=1. npx lighthouse https://your-app.com fetches a tool and then calls out to a URL, and the rest - npx bundle-analyzer, npx source-map-explorer, npx webpack-bundle-analyzer, React DevTools Profiler - is one ecosystem reached entirely by fetch.
- **Date:** 2026-08-22

### T-140 — agent-e2e-runner

- **Source:** affaan-m/ECC
- **Path:** agents/e2e-runner.md
- **HR/axis trigger IDs:** `HR-7`
- **Rationale:** HR-7. Its primary tool section opens with npm install -g agent-browser && agent-browser install - an unconditional global install, not one alternative of two - with npx Playwright as the fallback.
- **Date:** 2026-08-22

### T-141 — agent-chief-of-staff

- **Source:** affaan-m/ECC
- **Path:** agents/chief-of-staff.md
- **HR/axis trigger IDs:** `HR-1,HR-2,HR-6`
- **Rationale:** HR-1,HR-2,HR-6. Triages Gmail via a Gmail CLI, a calendar, LINE/Messenger scripts and Slack via MCP: hosted accounts (HR-1), an MCP server outside the three P-5 permits (HR-2), and network fetches (HR-6).
- **Date:** 2026-08-22

### T-142 — agent-a11y-architect

- **Source:** affaan-m/ECC
- **Path:** agents/a11y-architect.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=2`
- **Rationale:** axis:user_scope_fit=2. WCAG 2.2 compliance for web and mobile UI - aria-label, focus containment, screen-reader semantics - leaning on one discipline with partial value elsewhere. Re-donated: its ADR-ACC template, which records an accessibility decision the way ecc/architecture-decision-records records an architectural one.
- **Date:** 2026-08-22

### T-143 — agent-gan-planner

- **Source:** affaan-m/ECC
- **Path:** agents/gan-planner.md
- **HR/axis trigger IDs:** `axis:dependencies=1`
- **Rationale:** axis:dependencies=1. Writes gan-harness/spec.md for the Generator and Evaluator to consume; it has no function outside that three-agent harness, whose entry point cmd-gan-build is itself a merge into ecc/santa-method.
- **Date:** 2026-08-22

### T-144 — agent-gan-generator

- **Source:** affaan-m/ECC
- **Path:** agents/gan-generator.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=1`
- **Rationale:** axis:user_scope_fit=1. Its build loop starts npm run dev on port 3000 and iterates against gan-harness/feedback/*, so it only works for a Node web app inside that harness.
- **Date:** 2026-08-22

### T-145 — agent-gan-evaluator

- **Source:** affaan-m/ECC
- **Path:** agents/gan-evaluator.md
- **HR/axis trigger IDs:** `HR-2`
- **Rationale:** HR-2. Step 2 drives Playwright MCP to interact with the live application - an MCP server outside the three P-5 permits (Obsidian, Context7, Claude Code) - and it depends on a dev server the Generator left running.
- **Date:** 2026-08-22

### T-146 — agent-opensource-forker

- **Source:** affaan-m/ECC
- **Path:** agents/opensource-forker.md
- **HR/axis trigger IDs:** `B-1..B-8`
- **Rationale:** B-1..B-8. Forking a private project into an open-source-ready copy maps to no owning plugin among the nine, and SPEC 4's closing rule makes a component with no clear owner unshortlistable. Re-donated to sharingan: its secret-detection regex library (API keys, AWS credentials, database URLs with credentials, 3-segment JWTs, private keys, GitHub personal/server/OAuth tokens, Google OAuth).
- **Date:** 2026-08-22

### T-147 — agent-opensource-packager

- **Source:** affaan-m/ECC
- **Path:** agents/opensource-packager.md
- **HR/axis trigger IDs:** `B-1..B-8`
- **Rationale:** B-1..B-8. Generates CLAUDE.md, setup.sh and packaging for open-source release; same missing owner as agent-opensource-forker, and stage 3 of the same pipeline.
- **Date:** 2026-08-22

### T-148 — agent-opensource-sanitizer

- **Source:** affaan-m/ECC
- **Path:** agents/opensource-sanitizer.md
- **HR/axis trigger IDs:** `B-1..B-8`
- **Rationale:** B-1..B-8. Same pipeline, same missing owner. Worth re-donating on its own account: it is an independent auditor that by design 'never trusts the forker's work' and re-verifies everything, with any secret match a hard FAIL - the same adversarial-independence shape D-25 gives awakened's own G5 reviewer.
- **Date:** 2026-08-22

## 4. Statistics

Recomputed at each gate from the entries in §3, so the table can be checked against the file rather than trusted. The first four rows partition the entries by their trigger field under one stated precedence rule: an entry carrying **any** `HR-N` counts as hard-reject; otherwise any `axis:` trigger counts as axis-floor; otherwise a rule ID such as `B-1..B-8`, `D-15` or `D-24` counts as other-rule; a field beginning `n/a` is its own row **including the `n/a (re-audit)` form**, which the v2.6 table wrongly filed under other-rule (T-069). 42 + 62 + 29 + 15 = 148.

| Metric | Count |
|---|---|
| Total entries | 148 |
| Hard-reject entries | 42 |
| Axis-floor entries | 62 |
| Other-rule entries | 29 |
| `n/a` entries | 15 |
| Bulk-reject classes | 12 |
| Gap-scan entries | 0 |
| Re-audit / re-pin entries | 9 |

The last three rows **overlap** the partition above and are not added to it: the twelve bulk-reject classes are T-029…T-037 and T-070…T-072, ten of which also carry an `HR-N` or `axis:` trigger; the nine re-audit entries are T-026…T-028 (the 2026-08-18 G5 rehearsal) and T-064…T-069 (the 2026-08-22 review corrections). **Gap-scan entries stay at 0**: `SPEC.md` §10 Phase 4's `hesreallyhim/awesome-claude-code` scan runs in pass 2, and G4 cannot close until it does.

Reconciliation with the v2.5 table, which read 28 / 12 / 7 / 0 / 0 / 3 after Phase 2: the Phase-2 entries still contribute 12 hard-reject and 7 axis-floor. Six sit in the other-rule row, described below, and T-026 / T-027 sit in the `n/a` row rather than the other-rule row — the correction T-069 records. The v2.6 table published 22 / 24 / 14 / 3; the differences are that fix plus T-066's withdrawal of `HR-3` from T-030, which moves that class from hard-reject to axis-floor.

The six Phase-2 entries counted in neither the hard-reject nor the axis-floor row are rejections on a rule that is neither an HR trigger nor an axis floor: five on `B-1..B-8` (no owning plugin exists, so `SPEC.md` §4 forbids shortlisting) and one on `D-15,D-24` (a hook whose dispatch and budget no plugin can carry). Their trigger-ID fields carry those rule IDs, which is what the §10 Phase-2 exit criterion checks.

The three Phase-2 re-audit entries (T-026…T-028) arose from the **G5 rehearsal review** of 2026-08-18: an independent reviewer, running the `eval/gate-review-protocol.md` standard against the artifacts and the pinned sources, returned `REJECTED` and named three defects the Phase-2 self-checks could not see, because all three were internally consistent and wrong about the source. None changed a verdict to `reject`; T-027 moved a `merge` to `shortlist`, which is why the matrix read 27 / 25 / 3 at the end of Phase 2.

**Phase 3 (2026-08-22) added T-029…T-063**: nine bulk-reject classes covering 245 of ECC's 285 canonical skills plus its 41KB `hooks.json`, twenty-three individual rejects and two `merge` entries from the forty deep reads, and one reject for the shipped `thedotmack/claude-mem` implementation. `eval/matrix.csv` grew by 42 rows — 40 ECC (the §10 Phase-3 cap, which bound exactly) and 2 claude-mem — and now reads 97 rows, 43 shortlist / 49 reject / 5 merge.

**The 2026-08-22 review corrections added T-064…T-069**, from an independent Fable-5 artifacts-only read of the Phase-3 output against both pinned clones. Same shape as the G5 rehearsal and the same lesson: the findings that mattered were claims that were internally coherent and wrong about the source or the standard. No verdict changed; three shortlisted rows were rescored on the §9 risk anchor, one rationale was completed, two class trigger sets were re-grounded, one skill moved between classes, and the counting rule in this section was made to match what it implements.

**Phase 4 pass 1 (2026-08-22) added T-070…T-148**: three ratified reject classes covering 60 of ECC's 162 canonical commands and agents (T-070 the 22 language-pack commands, T-071 the 28 language-pack agents, T-072 the 10 domain-niche agents), sixty-nine individual rejects and seven `merge` entries from the 102 deep reads. `eval/matrix.csv` grew by 102 rows — 72 commands and 30 agents, the first `command` and `agent` rows in the file — and now reads 199 rows, 69 shortlist / 118 reject / 12 merge. Zero `defer` rows exist. The pass covers only the ECC half of `SPEC.md` §10 Phase 4; the four remaining sources run in passes 2 and 3.

The verdict vocabulary is `SPEC.md` §9 rule 3 — `shortlist`, `reject`, `merge`, `defer`. This log carries entries for `reject` (mandatory) and may carry them for `merge` and `defer` where the reasoning is worth preserving; `shortlist` rows need no entry.
