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

**Denominator, measured — the same accounting the Phase-3 preamble made for skills.** At the pin ECC carries
**424** `*/commands/*.md` and **307** `*/agents/*.md` across the whole tree. The canonical sets are
the flat top-level directories: **94** `commands/*.md` and **68** `agents/*.md`, for a pass-1
denominator of **162**. The remainder are the same components at other paths — 280 command and 201
agent files under `docs/<lang>/`, 35 under `.opencode/`, 33 under `.kiro/`, 12 under
`legacy-command-shims/`, 3 under `.claude/`, and 5 under `skills/*/agents/`. This is the same
translation-and-harness-mirror pattern the Phase-3 preamble recorded for the 897-vs-285 `SKILL.md`
count, and it is
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

---

### Phase 4 preamble — pass 2: wshobson/agents, anthropics/skills, and the gap scan (2026-08-22)

Pass 2 of three. Pass 1 covered ECC `commands/` and `agents/`; pass 3 covers
`davila7/claude-code-templates`. **G4 stays open until pass 3 lands.**

**Pins verified before any component was read.** Each source was cloned fresh into this session's
scratchpad and checked out at its `upstream.json` pin; `git rev-parse HEAD` was compared to the pin
and `git status --porcelain` was empty in every case. **3/3 MATCH** — `wshobson/agents`
`367cb6a4a182cf7e9b0a17c9429f7411ddd9cf35`, `anthropics/skills`
`0a64e398ec6bb34a494f0c347e8ccae53a862f8e`, `hesreallyhim/awesome-claude-code`
`58cdbfde5058e175972f75624f65c009ab8b9180`.

**A correction to pass 1, made here rather than propagated.** Pass 1 assigned eight shortlisted ECC
agent rows to `sharingan` and `instinct` on the purpose each agent serves. `SPEC.md` B-6 reads
"`bankai` owns **all subagents** and their restricted tool permissions", §4's `bankai` row lists
**review** among its intended agent kinds and names ECC `agents/` as its lineage, and D-26 says the
same. B-6 is specific to the `agent` component type; B-2 governs `sharingan`'s *scope*, not the
component type, so there is no genuine two-owner conflict. All eight rows are replaced in place with
`target_plugin = bankai` and the mis-cited rule IDs corrected — recorded as T-149, no verdict moved.
Every `agent`-type row in the matrix now targets `bankai`.

#### wshobson/agents — category triage first

§10 Phase 4 scopes this source to "wshobson **shortlisted** plugins", so the unit of triage is the
category. All **91** plugin descriptions were read. **17** categories were selected as
general-purpose with exactly one owning plugin under B-1…B-8 (T-150); **31** were rejected at
category level with a stated ground each (T-151); the remaining **43** are language, framework,
cloud or business-domain packs (T-152). 91/91 accounted for. §8's "roughly 12–15 general-purpose
categories" is a dated Phase-1 role note, not an audit target — the measured figure is 17, and §8 is
left as written, as the Phase-3 preamble left its "~270 skills".

**Denominator.** The 17 selected categories hold **77** component files but only **68 distinct
bodies**: six components are published in more than one plugin with byte-identical bodies once
frontmatter is stripped, `code-reviewer` in five (T-153). One scored row per distinct body, keyed to
the alphabetically first plugin.

**The `id` convention, settled before the first row.** `wshobson/<plugin>-<component>`, mirroring
upstream's own namespaced `name` field. Measured: bare `<component>` collides **six** ways within
the selected set; `<plugin>-<component>` collides **zero** ways and zero ways against the existing
matrix. This is the pass-2 analogue of pass 1's V4.7 decision and rests on the same ground — the
source slug must keep denoting the `upstream.json` repo that check U1 pins to exactly ten.

**Agent `tools`, measured.** A pass-1 handoff note said wshobson's agents "declare no `tools` field
at all". That came from a two-file sample and is wrong: **10 of 30** agent files in the selected
categories declare one. Corrected here so it is not carried into pass 3.

#### The finding that disposed of the largest single family

Seventeen components across the `agent-teams` category — 4 agents, 7 commands, 6 skills — were
rejected on one ground, established by re-verifying against the live official reference under §0:
**agent teams are experimental and disabled by default**, requiring
`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`, and "without that variable, no team is set up at session
start". A component that does nothing for a default user cannot carry `dependencies` ≥ 3. The same
read found `team-lead` declaring `TeamCreate` and `TeamDelete` in its `tools` list while the
reference states **both tools no longer exist** as of v2.1.178. Without the fetch this family would
have shortlisted on the strength of its prose. That is the third time on this project that a live
fetch has overturned a reading taken from a dated one — the first two were the Phase-3 hooks-event
correction recorded in T-064…T-069 and the SPEC v2.7 §14 resolution of SPEC-GAP-001 — and it is why §0 binds re-verification to a gate rather than to a dated reading.

#### anthropics/skills — licensing measured, not assumed

19 skill directories at the pin. **14** carry an Apache-2.0 `LICENSE.txt`; **4** are proprietary
(`docx`, `pdf`, `pptx`, `xlsx`) and are excluded by D-24 without being audited as candidates
(T-154); and **one — `doc-coauthoring` — ships no `LICENSE` file at all**, in a repository with no
root license. It therefore carries no grant. It is rejected and **flagged**: excluding an unlicensed
component needs no judgment, but *including* one would be a licensing decision, which the standing
authority reserves to the owner. `upstream.json` and §8 record "Apache-2.0 (12)"; the measured figure
is 14, left as a dated role note on the same principle as §8's other Phase-1 counts.

`skill-creator` is §8's named lineage for `instinct`. It is **rejected on `bloat` 2** — 33.2KB plus
16 bundled Python scripts — and its lineage findings are recorded in full in its triage entry
instead. D-05 makes lineage a synthesis relationship, not a copy, so a lineage source needs no
shortlist row; §6's deliverable is that the findings are *recorded*, and they are.

**V4.5, NOTICE flags.** One flag raised: `anthropics/brand-guidelines` applies another
organisation's brand identity and typography. It is rejected on scope, and any close adaptation
would raise a NOTICE and trademark question rather than only an attribution one.

#### The gap scan (V4.4)

All **157** catalog rows across **18** categories are dispositioned as gap-scan entries T-221…T-238:
**9 mapped to an owning plugin, 9 explicitly out of scope, and zero merge candidates sourced from
this catalog**, as V4.4 requires. Where the catalog surfaced something real — its "Avoid AI Writing"
entry — the component was audited **at its actual source** under that source's own MIT license, which
is what D-24 requires of a CC-BY-NC-ND catalog.

**Three genuine gaps found**, all recorded rather than silently closed:

1. **Component-safety auditing** → `instinct`. Nothing shortlisted audits a skill, agent or hook for
   unsafe patterns: `ecc/security-scan` and `ecc/skill-comply` fell on HR-7, wshobson's
   `security-scanning` at category level, its `security-auditor` on bloat. Partially covered by
   `scripts/validate.*` checks P1–P3 — but that is repo tooling, not a shipped component.
2. **Component linting** → `instinct`. Same family as (1) and worth resolving with it.
3. **Statusline presets** → `aura`, **and this one must not be closed from upstream.** §4 records
   `aura`'s Source Lineage as *Original work*, which is exactly why `anthropics/theme-factory` was
   rejected despite being the closest match in either source. The gap closes by authoring at Phase 6.

#### Outcome

83 rows appended — **17 shortlist / 66 reject / 0 merge**, zero `defer`. The matrix reads **282
rows, 86 shortlist / 184 reject / 12 merge**. Eight of the ten §8 repositories now carry rows;
`hesreallyhim/awesome-claude-code` carries none by design (V4.4) and `davila7/claude-code-templates`
is pass 3. `bankai` moves from 10 shortlisted rows to **27** — the B-6 correction plus nine new agent
rows — and every `agent`-type row in the file now targets it.

### T-149 — agent-row-ownership-recalibration

- **Source:** affaan-m/ECC
- **Path:** agents/ (8 shortlisted rows: comment-analyzer, type-design-analyzer, silent-failure-hunter, pr-test-analyzer, code-simplifier, code-reviewer, security-reviewer, agent-evaluator)
- **HR/axis trigger IDs:** `n/a` — re-audit of eight shortlisted rows; no verdict change
- **Rationale:** **Re-audit.** Phase-4 pass 1 assigned seven ECC agent rows to `sharingan` and one to `instinct` on the purpose each agent serves. That is the wrong rule. `SPEC.md` B-6 reads "`bankai` owns **all subagents** and their restricted tool permissions", SPEC 4's `bankai` row lists **review** among its intended agent kinds and names ECC `agents/` as its Source Lineage, and D-26's own text says the same. B-6 is specific to the `agent` component type and B-2 governs `sharingan`'s scope, not the component type, so there is no genuine two-owner conflict to resolve under SPEC 4's closing rule. Previous `target_plugin`: `sharingan` x7, `instinct` x1. New: `bankai` x8. Every axis, `hard_reject` and `verdict` is unchanged and all eight remain `shortlist`; matrix rows replaced in place per `eval/rubric.md` SPEC 1, ids unchanged. Rationale text was corrected at the same time in the three rows that cited B-2 or B-7 as the ownership ground, because a rationale citing the wrong rule ID is the defect class T-069 was written to fix.
- **Date:** 2026-08-22

### T-150 — wshobson-category-selection

- **Source:** wshobson/agents
- **Path:** plugins/ (17 of 91 selected)
- **HR/axis trigger IDs:** `n/a` — scoping record, not a rejection
- **Rationale:** **Category triage.** `SPEC.md` SPEC 10 Phase 4 scopes this source to "wshobson shortlisted plugins" and SPEC 8 estimates "roughly 12-15 general-purpose categories worth mining", a dated Phase-1 role note rather than an audit target. All 91 plugin descriptions were read and 17 categories selected, each with exactly one owning plugin under B-1..B-8: `agent-orchestration` -> `bankai`; `agent-teams` -> `bankai`; `comprehensive-review` -> `sharingan`; `performance-testing-review` -> `sharingan`; `avoid-ai-writing` -> `sharingan`; `code-refactoring` -> `super-saiyan`; `debugging-toolkit` -> `super-saiyan`; `error-debugging` -> `super-saiyan`; `git-pr-workflows` -> `super-saiyan`; `tdd-workflows` -> `super-saiyan`; `before-you-build` -> `super-saiyan`; `context-management` -> `rinnegan`; `operating-kit` -> `kaioken`; `code-documentation` -> `domain`; `documentation-standards` -> `domain`; `skill-forge-essentials` -> `instinct`; `plugin-eval` -> `instinct`. Component-level ownership is decided per component, not inherited from the category - three operating-kit agents landed outside `kaioken` on their own grounds. 91/91 categories are accounted for across this entry, T-151 and T-152.
- **Date:** 2026-08-22

### T-151 — wshobson-non-general-purpose-categories

- **Source:** wshobson/agents
- **Path:** plugins/ (31 categories)
- **HR/axis trigger IDs:** `axis:user_scope_fit=1,axis:dependencies=1,B-1..B-8,D-15,HR-1,HR-6`
- **Rationale:** **Class reject, 31 categories, no matrix rows.** Categories rejected at category level, each with its stated ground: `developer-essentials` - B-1..B-8: an 11-skill bundle spanning Git, SQL optimization, auth, monorepo and E2E has no single owning plugin, which SPEC 4's closing rule makes unshortlistable; `codebase-cleanup` - duplicative: same technical-debt and refactoring surface as code-refactoring, which is shortlisted; `error-diagnostics` - duplicative: same error-tracing and root-cause surface as error-debugging, which is shortlisted; `documentation-generation` - axis:user_scope_fit - OpenAPI specification and API reference generation; bound to API projects; `c4-architecture` - axis:user_scope_fit - the C4 model is one specific architecture-documentation methodology; `full-stack-orchestration` - duplicative of agent-teams plus the ECC orch-pipeline concept already re-donated in Phase 3; `ship-mate` - duplicative: orchestrator to architect to developer to PR reviewer is the same pipeline shape as agent-teams and ECC orch-pipeline; `conductor` - duplicative: a Context to Spec to Implement project-management workflow overlapping kaioken (operating-kit) and super-saiyan planning; `team-collaboration` - B-1..B-8: standup automation and issue management map to no owning plugin among the nine; `unit-testing` - axis:user_scope_fit=1 - stated as 'for Python and JavaScript'; `security-scanning` - axis:user_scope_fit - SAST, container scanning and dependency CVE tooling; tool-bound rather than a general practice; `security-compliance` - axis:user_scope_fit=1 - SOC2/HIPAA/GDPR regulatory documentation, a compliance discipline; `dependency-management` - axis:user_scope_fit - package-ecosystem auditing and version management, per-ecosystem by nature; `accessibility-compliance` - axis:user_scope_fit=2 - WCAG UI auditing, the same domain-niche ground as ecc/agent-a11y-architect; `application-performance` - duplicative of performance-testing-review, which is shortlisted; `framework-migration` - axis:user_scope_fit - framework-version migration is per-framework by nature; `incident-response` - axis:user_scope_fit - production incident management, an operations discipline; `deployment-validation` - axis:user_scope_fit - deployment readiness, an operations discipline; `deployment-strategies` - axis:user_scope_fit - rollback automation and infrastructure templates, operations; `distributed-debugging` - axis:user_scope_fit=1 - microservice tracing, one architecture style; `observability-monitoring` - axis:user_scope_fit - metrics, tracing and SLO tooling, an operations discipline; `data-validation-suite` - axis:user_scope_fit - backend schema and streaming validation; `block-no-verify` - D-15: a PreToolUse hook, and the hook budget names only super-saiyan session-start and rinnegan capture. Concept re-donated: refuse --no-verify and --no-gpg-sign bypass flags; `review-agent-governance` - axis:dependencies=1 - Cedar policy enforcement and Ed25519 signed receipts, a runtime outside the P-5 exceptions. Concept re-donated: require a human approval signal before an agent posts a PR review; `protect-mcp` - axis:dependencies=1 - Cedar plus Ed25519 receipts on every tool call, same runtime requirement; `signed-audit-trails` - axis:dependencies=1 - a teaching skill for the same Cedar/Ed25519 stack; `file-conversion` - HR-1,HR-6 - routes conversions through the hosted ChangeThisFile API; `hermes-tweet` - HR-1,HR-6 - X/Twitter access through the hosted Hermes agent; `social-publishing` - HR-1,HR-6 - publishes to 13 hosted social platforms; `meigen-ai-design` - HR-1 - hosted AI image generation; `brand-landingpage` - HR-1 - routes design through the hosted Stitch service
- **Date:** 2026-08-22

### T-152 — wshobson-domain-and-language-packs

- **Source:** wshobson/agents
- **Path:** plugins/ (43 categories)
- **HR/axis trigger IDs:** `B-1..B-8,axis:user_scope_fit=1`
- **Rationale:** **Class reject, 43 categories, no matrix rows.** Every remaining plugin is bound to one language, framework, cloud, or business discipline: `api-scaffolding`, `api-testing-observability`, `arm-cortex-microcontrollers`, `backend-api-security`, `backend-development`, `blockchain-web3`, `business-analytics`, `cicd-automation`, `cloud-infrastructure`, `content-marketing`, `customer-sales-automation`, `data-engineering`, `database-cloud-optimization`, `database-design`, `database-migrations`, `dgx-spark-ops`, `dotnet-contribution`, `frontend-mobile-development`, `frontend-mobile-security`, `functional-programming`, `game-development`, `hr-legal-compliance`, `javascript-typescript`, `julia-development`, `jvm-languages`, `kubernetes-operations`, `llm-application-dev`, `llm-finetuning`, `machine-learning-ops`, `multi-platform-apps`, `payment-processing`, `pptx-deck-creation`, `python-development`, `quantitative-trading`, `reverse-engineering`, `seo-analysis-monitoring`, `seo-content-creation`, `seo-technical-optimization`, `shell-scripting`, `startup-business-analyst`, `systems-programming`, `ui-design`, `web-scripting`. Same ground as T-070, T-071 and T-072 for ECC - SPEC 4's nine plugins own no per-language or per-discipline implementation reference, and "project- or language-specific" is the SPEC 9 anchor-1 wording for `user_scope_fit`.
- **Date:** 2026-08-22

### T-153 — wshobson-duplicate-component-instances

- **Source:** wshobson/agents
- **Path:** plugins/ (9 redundant copies across 6 components)
- **HR/axis trigger IDs:** `n/a` — denominator record, not a rejection
- **Rationale:** **Denominator.** Within the 17 selected categories the tree holds 77 component files but only **68 distinct bodies**. Six components are published in more than one plugin with byte-identical bodies once frontmatter is stripped; the only difference is the namespaced `name` field. `context-manager` x2; `code-reviewer` x5; `context-restore` x2; `pr-enhance` x2; `debugger` x2; `multi-agent-review` x2. One scored row is written per distinct body, keyed to the alphabetically first plugin, rather than five identical rows for `code-reviewer`. This is the same duplicate-at-another-path pattern T-029 recorded for ECC's translations and T-070 for its harness mirrors, and it is also the sharpest argument for the `<plugin>-<name>` id convention: bare `<name>` collides six ways in this source, `code-reviewer` five ways.
- **Date:** 2026-08-22

### T-154 — anthropics-proprietary-skills

- **Source:** anthropics/skills
- **Path:** skills/docx, skills/pdf, skills/pptx, skills/xlsx
- **HR/axis trigger IDs:** `D-24`
- **Rationale:** **Class exclusion, 4 components, no matrix rows.** Each ships a LICENSE.txt reading "(c) 2025 Anthropic, PBC. All rights reserved." D-24 makes only the Apache-2.0 skills lineage-eligible and excludes these four by name. They were not audited as candidates, because they are not candidates. Measured at the pin: 19 skill directories, of which 14 carry an Apache-2.0 LICENSE.txt, 4 are proprietary and 1 - `doc-coauthoring` - ships no LICENSE file at all in a repository with no root license; that one carries its own row. `upstream.json` and SPEC 8 record "Apache-2.0 (12)", a dated Phase-1 role note; the measured figure is 14.
- **Date:** 2026-08-22

### T-155 — agent-orchestration-context-manager

- **Source:** wshobson/agents
- **Path:** plugins/agent-orchestration/agents/context-manager.md (+1 byte-identical copies: plugins/context-management/agents/context-manager)
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. 7.9KB and 98 bullets with no procedural step at all - an expert-persona capability list covering vector databases (Pinecone, Weaviate, Qdrant), knowledge graphs and enterprise SharePoint/Confluence integration. It describes building context systems for a product rather than managing this agent's own context.
- **Date:** 2026-08-22

### T-156 — agent-teams-team-debugger

- **Source:** wshobson/agents
- **Path:** plugins/agent-teams/agents/team-debugger.md
- **HR/axis trigger IDs:** `axis:dependencies=2`
- **Rationale:** axis:dependencies=2. agent teams are experimental and disabled by default - the official reference states they require CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 and that without it no team is set up - so a shipped component here does nothing for a default user. dependencies 2.
- **Date:** 2026-08-22

### T-157 — agent-teams-team-implementer

- **Source:** wshobson/agents
- **Path:** plugins/agent-teams/agents/team-implementer.md
- **HR/axis trigger IDs:** `axis:dependencies=2`
- **Rationale:** axis:dependencies=2. agent teams are experimental and disabled by default - the official reference states they require CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 and that without it no team is set up - so a shipped component here does nothing for a default user. dependencies 2.
- **Date:** 2026-08-22

### T-158 — agent-teams-team-lead

- **Source:** wshobson/agents
- **Path:** plugins/agent-teams/agents/team-lead.md
- **HR/axis trigger IDs:** `axis:dependencies=2`
- **Rationale:** axis:dependencies=2. agent teams are experimental and disabled by default - the official reference states they require CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 and that without it no team is set up - so a shipped component here does nothing for a default user. dependencies 2. This one additionally declares TeamCreate and TeamDelete in its tools list, and the reference states both tools no longer exist as of v2.1.178.
- **Date:** 2026-08-22

### T-159 — agent-teams-team-reviewer

- **Source:** wshobson/agents
- **Path:** plugins/agent-teams/agents/team-reviewer.md
- **HR/axis trigger IDs:** `axis:dependencies=2`
- **Rationale:** axis:dependencies=2. agent teams are experimental and disabled by default - the official reference states they require CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 and that without it no team is set up - so a shipped component here does nothing for a default user. dependencies 2.
- **Date:** 2026-08-22

### T-160 — code-documentation-code-reviewer

- **Source:** wshobson/agents
- **Path:** plugins/code-documentation/agents/code-reviewer.md (+4 byte-identical copies: plugins/code-refactoring/agents/code-reviewer, plugins/comprehensive-review/agents/code-reviewer, plugins/git-pr-workflows/agents/code-reviewer, plugins/tdd-workflows/agents/code-reviewer)
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. 8.4KB and 106 bullets with zero procedural steps; sections include Language-Specific Expertise, and its first capability block is integration with hosted AI review tools (Trag, Bito, Codiga, Copilot). This body is the most duplicated component in the source - five byte-identical copies across five plugins.
- **Date:** 2026-08-22

### T-161 — comprehensive-review-architect-review

- **Source:** wshobson/agents
- **Path:** plugins/comprehensive-review/agents/architect-review.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. 7.8KB and 99 bullets, no procedural steps - the same expert-persona capability-list shape as code-documentation-code-reviewer.
- **Date:** 2026-08-22

### T-162 — comprehensive-review-security-auditor

- **Source:** wshobson/agents
- **Path:** plugins/comprehensive-review/agents/security-auditor.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. 9.6KB and 89 bullets with no procedure; a capability inventory rather than an audit workflow.
- **Date:** 2026-08-22

### T-163 — debugging-toolkit-dx-optimizer

- **Source:** wshobson/agents
- **Path:** plugins/debugging-toolkit/agents/dx-optimizer.md
- **HR/axis trigger IDs:** `B-1..B-8`
- **Rationale:** B-1..B-8. Developer-experience tooling - IDE settings, git hooks, package.json scripts, Makefiles, .claude/commands additions - maps to no owning plugin among the nine, and SPEC 4's closing rule makes a component with no clear owner unshortlistable.
- **Date:** 2026-08-22

### T-164 — operating-kit-deploy-with-verification

- **Source:** wshobson/agents
- **Path:** plugins/operating-kit/agents/deploy-with-verification.md
- **HR/axis trigger IDs:** `B-1..B-8`
- **Rationale:** B-1..B-8. Deploying to production maps to no owning plugin among the nine. Its central principle is re-donated to super-saiyan's verification lineage: 'Exited 0' and 'live and serving the new code' are different claims, so confirm the live endpoint reflects the build you just shipped before reporting it shipped.
- **Date:** 2026-08-22

### T-165 — operating-kit-prod-logs-health-check

- **Source:** wshobson/agents
- **Path:** plugins/operating-kit/agents/prod-logs-health-check.md
- **HR/axis trigger IDs:** `B-1..B-8`
- **Rationale:** B-1..B-8. Production log triage is an operations discipline with no owning plugin. Re-donated: never analyse an incident from dashboard data or script stdout alone, state explicitly when logs were not checked, and never present inference as fact.
- **Date:** 2026-08-22

### T-166 — performance-testing-review-performance-engineer

- **Source:** wshobson/agents
- **Path:** plugins/performance-testing-review/agents/performance-engineer.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. 10.4KB and 97 bullets with no procedure - a capability inventory.
- **Date:** 2026-08-22

### T-167 — performance-testing-review-test-automator

- **Source:** wshobson/agents
- **Path:** plugins/performance-testing-review/agents/test-automator.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. 10.7KB and 143 bullets, the highest bullet count in the source, with no procedural steps.
- **Date:** 2026-08-22

### T-168 — plugin-eval-eval-orchestrator

- **Source:** wshobson/agents
- **Path:** plugins/plugin-eval/agents/eval-orchestrator.md
- **HR/axis trigger IDs:** `axis:dependencies=1`
- **Rationale:** axis:dependencies=1. Step 1 is uv run plugin-eval score against a Python CLI bundled in the plugin, so the scoring engine is a packaged binary outside the P-5 exceptions.
- **Date:** 2026-08-22

### T-169 — tdd-workflows-tdd-orchestrator

- **Source:** wshobson/agents
- **Path:** plugins/tdd-workflows/agents/tdd-orchestrator.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. 9.9KB and 114 bullets with no procedural steps.
- **Date:** 2026-08-22

### T-170 — agent-orchestration-improve-agent

- **Source:** wshobson/agents
- **Path:** plugins/agent-orchestration/commands/improve-agent.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. 9.1KB, and its first step invokes a context-manager command named analyze-agent-performance that exists nowhere in the source - the metrics baseline the rest of the workflow consumes is never actually produced.
- **Date:** 2026-08-22

### T-171 — agent-orchestration-multi-agent-optimize

- **Source:** wshobson/agents
- **Path:** plugins/agent-orchestration/commands/multi-agent-optimize.md
- **HR/axis trigger IDs:** `axis:dependencies=2`
- **Rationale:** axis:dependencies=2. Optimises multi-agent systems through the same context-manager surface as agent-orchestration-improve-agent.
- **Date:** 2026-08-22

### T-172 — agent-teams-team-debug

- **Source:** wshobson/agents
- **Path:** plugins/agent-teams/commands/team-debug.md
- **HR/axis trigger IDs:** `axis:dependencies=2`
- **Rationale:** axis:dependencies=2. agent teams are experimental and disabled by default - the official reference states they require CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 and that without it no team is set up - so a shipped component here does nothing for a default user. dependencies 2.
- **Date:** 2026-08-22

### T-173 — agent-teams-team-delegate

- **Source:** wshobson/agents
- **Path:** plugins/agent-teams/commands/team-delegate.md
- **HR/axis trigger IDs:** `axis:dependencies=2`
- **Rationale:** axis:dependencies=2. agent teams are experimental and disabled by default - the official reference states they require CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 and that without it no team is set up - so a shipped component here does nothing for a default user. dependencies 2.
- **Date:** 2026-08-22

### T-174 — agent-teams-team-feature

- **Source:** wshobson/agents
- **Path:** plugins/agent-teams/commands/team-feature.md
- **HR/axis trigger IDs:** `axis:dependencies=2`
- **Rationale:** axis:dependencies=2. agent teams are experimental and disabled by default - the official reference states they require CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 and that without it no team is set up - so a shipped component here does nothing for a default user. dependencies 2.
- **Date:** 2026-08-22

### T-175 — agent-teams-team-review

- **Source:** wshobson/agents
- **Path:** plugins/agent-teams/commands/team-review.md
- **HR/axis trigger IDs:** `axis:dependencies=2`
- **Rationale:** axis:dependencies=2. agent teams are experimental and disabled by default - the official reference states they require CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 and that without it no team is set up - so a shipped component here does nothing for a default user. dependencies 2.
- **Date:** 2026-08-22

### T-176 — agent-teams-team-shutdown

- **Source:** wshobson/agents
- **Path:** plugins/agent-teams/commands/team-shutdown.md
- **HR/axis trigger IDs:** `axis:dependencies=2`
- **Rationale:** axis:dependencies=2. agent teams are experimental and disabled by default - the official reference states they require CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 and that without it no team is set up - so a shipped component here does nothing for a default user. dependencies 2.
- **Date:** 2026-08-22

### T-177 — agent-teams-team-spawn

- **Source:** wshobson/agents
- **Path:** plugins/agent-teams/commands/team-spawn.md
- **HR/axis trigger IDs:** `axis:dependencies=2`
- **Rationale:** axis:dependencies=2. agent teams are experimental and disabled by default - the official reference states they require CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 and that without it no team is set up - so a shipped component here does nothing for a default user. dependencies 2.
- **Date:** 2026-08-22

### T-178 — agent-teams-team-status

- **Source:** wshobson/agents
- **Path:** plugins/agent-teams/commands/team-status.md
- **HR/axis trigger IDs:** `axis:dependencies=2`
- **Rationale:** axis:dependencies=2. agent teams are experimental and disabled by default - the official reference states they require CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 and that without it no team is set up - so a shipped component here does nothing for a default user. dependencies 2.
- **Date:** 2026-08-22

### T-179 — code-documentation-code-explain

- **Source:** wshobson/agents
- **Path:** plugins/code-documentation/commands/code-explain.md
- **HR/axis trigger IDs:** `axis:bloat=1`
- **Rationale:** axis:bloat=1. 22.1KB across 63 headings - a large always-read instruction file for a single explain-this-code action.
- **Date:** 2026-08-22

### T-180 — code-documentation-doc-generate

- **Source:** wshobson/agents
- **Path:** plugins/code-documentation/commands/doc-generate.md
- **HR/axis trigger IDs:** `axis:bloat=1`
- **Rationale:** axis:bloat=1. 17.2KB across 47 headings.
- **Date:** 2026-08-22

### T-181 — code-refactoring-context-restore

- **Source:** wshobson/agents
- **Path:** plugins/code-refactoring/commands/context-restore.md (+1 byte-identical copies: plugins/context-management/commands/context-restore)
- **HR/axis trigger IDs:** `axis:value=2`
- **Rationale:** axis:value=2. The counterpart to context-management-context-save and written in the same expert-persona register; it restores context from artifacts that command's rejected pipeline would have produced. Two byte-identical copies across two plugins.
- **Date:** 2026-08-22

### T-182 — code-refactoring-refactor-clean

- **Source:** wshobson/agents
- **Path:** plugins/code-refactoring/commands/refactor-clean.md
- **HR/axis trigger IDs:** `axis:bloat=1`
- **Rationale:** axis:bloat=1. 22.9KB across 50 headings.
- **Date:** 2026-08-22

### T-183 — code-refactoring-tech-debt

- **Source:** wshobson/agents
- **Path:** plugins/code-refactoring/commands/tech-debt.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. 9.5KB for a technical-debt inventory that super-saiyan's shortlisted refactoring rows already cover.
- **Date:** 2026-08-22

### T-184 — comprehensive-review-full-review

- **Source:** wshobson/agents
- **Path:** plugins/comprehensive-review/commands/full-review.md
- **HR/axis trigger IDs:** `axis:bloat=1`
- **Rationale:** axis:bloat=1. 20.1KB across 54 headings.
- **Date:** 2026-08-22

### T-185 — comprehensive-review-pr-enhance

- **Source:** wshobson/agents
- **Path:** plugins/comprehensive-review/commands/pr-enhance.md (+1 byte-identical copies: plugins/git-pr-workflows/commands/pr-enhance)
- **HR/axis trigger IDs:** `axis:bloat=1`
- **Rationale:** axis:bloat=1. 19.7KB across 58 headings. Two byte-identical copies across two plugins.
- **Date:** 2026-08-22

### T-186 — context-management-context-save

- **Source:** wshobson/agents
- **Path:** plugins/context-management/commands/context-save.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. Carries no frontmatter at all, opens as an 'elite context engineering specialist' persona, and its capture strategy is built on vector-database integration naming Pinecone, Weaviate and Qdrant. The rinnegan memory design in eval/claude-mem-rebuild.md already settles this ground file-based and lexical, a choice the owner confirmed and T-227 records.
- **Date:** 2026-08-22

### T-187 — debugging-toolkit-smart-debug

- **Source:** wshobson/agents
- **Path:** plugins/debugging-toolkit/commands/smart-debug.md
- **HR/axis trigger IDs:** `HR-1,HR-6`
- **Rationale:** HR-1,HR-6. Its observability step queries hosted third-party services by name - Sentry, Rollbar, Bugsnag, DataDog, New Relic, Dynatrace, Jaeger, Honeycomb, Splunk, LogRocket - each requiring an account and a network call.
- **Date:** 2026-08-22

### T-188 — error-debugging-error-analysis

- **Source:** wshobson/agents
- **Path:** plugins/error-debugging/commands/error-analysis.md
- **HR/axis trigger IDs:** `axis:bloat=1`
- **Rationale:** axis:bloat=1. 35.8KB, the second-largest component in the source.
- **Date:** 2026-08-22

### T-189 — error-debugging-error-trace

- **Source:** wshobson/agents
- **Path:** plugins/error-debugging/commands/error-trace.md
- **HR/axis trigger IDs:** `axis:bloat=1`
- **Rationale:** axis:bloat=1. 39.3KB, the largest component in the source.
- **Date:** 2026-08-22

### T-190 — error-debugging-multi-agent-review

- **Source:** wshobson/agents
- **Path:** plugins/error-debugging/commands/multi-agent-review.md (+1 byte-identical copies: plugins/performance-testing-review/commands/multi-agent-review)
- **HR/axis trigger IDs:** `axis:value=2`
- **Rationale:** axis:value=2. Marketing register rather than procedure - it promises a 'distributed, specialized agent network' that 'transcends traditional single-perspective review' and then lists six abstract agent types with no concrete dispatch. Two byte-identical copies across two plugins.
- **Date:** 2026-08-22

### T-191 — git-pr-workflows-git-workflow

- **Source:** wshobson/agents
- **Path:** plugins/git-pr-workflows/commands/git-workflow.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. 17.4KB across 30 headings; superpowers' shortlisted git rows already hold this ground for super-saiyan.
- **Date:** 2026-08-22

### T-192 — git-pr-workflows-onboard

- **Source:** wshobson/agents
- **Path:** plugins/git-pr-workflows/commands/onboard.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. 14.2KB and 108 bullets.
- **Date:** 2026-08-22

### T-193 — performance-testing-review-ai-review

- **Source:** wshobson/agents
- **Path:** plugins/performance-testing-review/commands/ai-review.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. 14.8KB, and the review is routed through hosted AI review services rather than performed inline.
- **Date:** 2026-08-22

### T-194 — plugin-eval-certify

- **Source:** wshobson/agents
- **Path:** plugins/plugin-eval/commands/certify.md
- **HR/axis trigger IDs:** `axis:dependencies=1`
- **Rationale:** axis:dependencies=1. uv run plugin-eval certify against the bundled Python CLI; it also states the run takes 15-20 minutes.
- **Date:** 2026-08-22

### T-195 — plugin-eval-compare

- **Source:** wshobson/agents
- **Path:** plugins/plugin-eval/commands/compare.md
- **HR/axis trigger IDs:** `axis:dependencies=1`
- **Rationale:** axis:dependencies=1. uv run plugin-eval compare against the same bundled Python CLI.
- **Date:** 2026-08-22

### T-196 — plugin-eval-eval

- **Source:** wshobson/agents
- **Path:** plugins/plugin-eval/commands/eval.md
- **HR/axis trigger IDs:** `axis:dependencies=1`
- **Rationale:** axis:dependencies=1. uv run plugin-eval score against the same bundled Python CLI.
- **Date:** 2026-08-22

### T-197 — tdd-workflows-tdd-cycle

- **Source:** wshobson/agents
- **Path:** plugins/tdd-workflows/commands/tdd-cycle.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. 20.1KB across 43 headings; the three phase commands cover the same cycle in a fifth of the size.
- **Date:** 2026-08-22

### T-198 — tdd-workflows-tdd-refactor

- **Source:** wshobson/agents
- **Path:** plugins/tdd-workflows/commands/tdd-refactor.md
- **HR/axis trigger IDs:** `axis:dependencies=2`
- **Rationale:** axis:dependencies=2. Carries no frontmatter and delegates the whole job to the tdd-workflows-tdd-orchestrator agent, which is itself rejected on bloat; what remains is a design-pattern catalogue.
- **Date:** 2026-08-22

### T-199 — agent-teams-multi-reviewer-patterns

- **Source:** wshobson/agents
- **Path:** plugins/agent-teams/skills/multi-reviewer-patterns/SKILL.md
- **HR/axis trigger IDs:** `axis:dependencies=2`
- **Rationale:** axis:dependencies=2. agent teams are experimental and disabled by default - the official reference states they require CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 and that without it no team is set up - so a shipped component here does nothing for a default user. dependencies 2.
- **Date:** 2026-08-22

### T-200 — agent-teams-parallel-debugging

- **Source:** wshobson/agents
- **Path:** plugins/agent-teams/skills/parallel-debugging/SKILL.md
- **HR/axis trigger IDs:** `axis:dependencies=2`
- **Rationale:** axis:dependencies=2. agent teams are experimental and disabled by default - the official reference states they require CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 and that without it no team is set up - so a shipped component here does nothing for a default user. dependencies 2.
- **Date:** 2026-08-22

### T-201 — agent-teams-parallel-feature-development

- **Source:** wshobson/agents
- **Path:** plugins/agent-teams/skills/parallel-feature-development/SKILL.md
- **HR/axis trigger IDs:** `axis:dependencies=2`
- **Rationale:** axis:dependencies=2. agent teams are experimental and disabled by default - the official reference states they require CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 and that without it no team is set up - so a shipped component here does nothing for a default user. dependencies 2.
- **Date:** 2026-08-22

### T-202 — agent-teams-task-coordination-strategies

- **Source:** wshobson/agents
- **Path:** plugins/agent-teams/skills/task-coordination-strategies/SKILL.md
- **HR/axis trigger IDs:** `axis:dependencies=2`
- **Rationale:** axis:dependencies=2. agent teams are experimental and disabled by default - the official reference states they require CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 and that without it no team is set up - so a shipped component here does nothing for a default user. dependencies 2.
- **Date:** 2026-08-22

### T-203 — agent-teams-team-communication-protocols

- **Source:** wshobson/agents
- **Path:** plugins/agent-teams/skills/team-communication-protocols/SKILL.md
- **HR/axis trigger IDs:** `axis:dependencies=2`
- **Rationale:** axis:dependencies=2. agent teams are experimental and disabled by default - the official reference states they require CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 and that without it no team is set up - so a shipped component here does nothing for a default user. dependencies 2.
- **Date:** 2026-08-22

### T-204 — agent-teams-team-composition-patterns

- **Source:** wshobson/agents
- **Path:** plugins/agent-teams/skills/team-composition-patterns/SKILL.md
- **HR/axis trigger IDs:** `axis:dependencies=2`
- **Rationale:** axis:dependencies=2. agent teams are experimental and disabled by default - the official reference states they require CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 and that without it no team is set up - so a shipped component here does nothing for a default user. dependencies 2.
- **Date:** 2026-08-22

### T-205 — plugin-eval-evaluation-methodology

- **Source:** wshobson/agents
- **Path:** plugins/plugin-eval/skills/evaluation-methodology/SKILL.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. 22.2KB across 51 headings - the rubric documentation behind the plugin-eval CLI. The scoring dimensions worth keeping are already carried by the shortlisted plugin-eval-eval-judge row.
- **Date:** 2026-08-22

### T-206 — skill-forge-essentials-visual-edit-precision

- **Source:** wshobson/agents
- **Path:** plugins/skill-forge-essentials/skills/visual-edit-precision/SKILL.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=2`
- **Rationale:** axis:user_scope_fit=2. Framed entirely around UI and frontend work - element selections, annotations, screenshots, CSS and markup edits, responsive behaviour and aria attributes. Re-donated to super-saiyan: change exactly what was indicated and preserve everything else, which generalises past the UI framing.
- **Date:** 2026-08-22

### T-207 — skill-creator

- **Source:** anthropics/skills
- **Path:** skills/skill-creator/SKILL.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. 33.2KB, the largest Apache-2.0 skill here, plus 16 bundled Python scripts including run_loop.py, run_eval.py and package_skill.py, so the eval harness needs a Python runtime (dependencies 3). SPEC 8 names this instinct's lineage and D-05 makes lineage a synthesis relationship rather than a copy, so the findings are recorded here rather than the file being shortlisted. Lineage findings for instinct: capture intent before writing; interview and research before drafting; run with-skill and baseline evaluations in the SAME turn so the comparison is controlled; draft assertions while runs are in flight; grade, aggregate, then read the user's feedback; and optimise the description separately by generating trigger-eval queries and scoring which prompts should and should not fire.
- **Date:** 2026-08-22

### T-208 — claude-api

- **Source:** anthropics/skills
- **Path:** skills/claude-api/SKILL.md
- **HR/axis trigger IDs:** `axis:bloat=1`
- **Rationale:** axis:bloat=1. 74.3KB plus 65 files under shared/ - a reference library rather than a workflow, and the largest component seen in any source this phase.
- **Date:** 2026-08-22

### T-209 — academy-guide

- **Source:** anthropics/skills
- **Path:** skills/academy-guide/SKILL.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=1`
- **Rationale:** axis:user_scope_fit=1. Recommends courses and tutorials from academy.claude.com; the value is Anthropic-product onboarding, not project work, and the catalog is embedded in the file.
- **Date:** 2026-08-22

### T-210 — algorithmic-art

- **Source:** anthropics/skills
- **Path:** skills/algorithmic-art/SKILL.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=1`
- **Rationale:** axis:user_scope_fit=1. Generative art with p5.js and seeded randomness - a creative-coding niche.
- **Date:** 2026-08-22

### T-211 — brand-guidelines

- **Source:** anthropics/skills
- **Path:** skills/brand-guidelines/SKILL.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=1`
- **Rationale:** axis:user_scope_fit=1. Applies one company's brand identity - Anthropic's colors and Poppins/Lora typography - through python-pptx. A general marketplace shipping another organisation's brand styling would also be a NOTICE and trademark question, flagged under V4.5 rather than resolved here.
- **Date:** 2026-08-22

### T-212 — canvas-design

- **Source:** anthropics/skills
- **Path:** skills/canvas-design/SKILL.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=1`
- **Rationale:** axis:user_scope_fit=1. Visual art into .png and .pdf, shipping 81 extra files including eight bundled TTF font families.
- **Date:** 2026-08-22

### T-213 — frontend-design

- **Source:** anthropics/skills
- **Path:** skills/frontend-design/SKILL.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=2`
- **Rationale:** axis:user_scope_fit=2. Aesthetic direction and typography for UI work - a design discipline, the same ground the wshobson ui-design and accessibility-compliance categories were rejected on.
- **Date:** 2026-08-22

### T-214 — internal-comms

- **Source:** anthropics/skills
- **Path:** skills/internal-comms/SKILL.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=1`
- **Rationale:** axis:user_scope_fit=1. Status reports, leadership updates, company newsletters and FAQs in one organisation's preferred formats.
- **Date:** 2026-08-22

### T-215 — mcp-builder

- **Source:** anthropics/skills
- **Path:** skills/mcp-builder/SKILL.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=2,axis:dependencies=2`
- **Rationale:** axis:user_scope_fit=2,axis:dependencies=2. A guide to building MCP servers in Python FastMCP or the Node/TypeScript SDK, shipping scripts/requirements.txt and evaluation.py. Consistent with rejecting the wshobson api-scaffolding class: building one integration surface is a specialised task, not general engineering.
- **Date:** 2026-08-22

### T-216 — slack-gif-creator

- **Source:** anthropics/skills
- **Path:** skills/slack-gif-creator/SKILL.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=1`
- **Rationale:** axis:user_scope_fit=1. Animated GIFs sized for Slack, with a bundled Python package and requirements.txt.
- **Date:** 2026-08-22

### T-217 — theme-factory

- **Source:** anthropics/skills
- **Path:** skills/theme-factory/SKILL.md
- **HR/axis trigger IDs:** `B-1..B-8`
- **Rationale:** B-1..B-8. Ten preset color-and-font themes for artifacts is the closest match in this source to aura's stated scope, but SPEC 4 records aura's Source Lineage as Original work and B-8 keeps aura an optional satellite, so no plugin can own it. Recorded because the near-miss is worth stating rather than leaving implicit.
- **Date:** 2026-08-22

### T-218 — web-artifacts-builder

- **Source:** anthropics/skills
- **Path:** skills/web-artifacts-builder/SKILL.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=1`
- **Rationale:** axis:user_scope_fit=1. React, Tailwind and shadcn/ui artifacts for claude.ai, shipping init-artifact.sh, bundle-artifact.sh and a shadcn-components.tar.gz.
- **Date:** 2026-08-22

### T-219 — webapp-testing

- **Source:** anthropics/skills
- **Path:** skills/webapp-testing/SKILL.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=2,axis:dependencies=2`
- **Rationale:** axis:user_scope_fit=2,axis:dependencies=2. Playwright-driven testing of local web applications, with a bundled with_server.py harness. Web applications only.
- **Date:** 2026-08-22

### T-220 — doc-coauthoring

- **Source:** anthropics/skills
- **Path:** skills/doc-coauthoring/SKILL.md
- **HR/axis trigger IDs:** `D-24`
- **Rationale:** D-24. A licensing reject, not a scoring one - the axes below describe the component honestly and none of them is the ground. This skill ships NO LICENSE file, and anthropics/skills carries no root license, so there is no grant covering it. SPEC 8 records the per-skill licensing and D-24 makes only the Apache-2.0 skills lineage-eligible. Excluding an unlicensed component needs no judgment; INCLUDING one would be a licensing decision reserved to the owner, so it is flagged rather than decided.
- **Date:** 2026-08-22

### T-221 — gap-observability-monitoring

- **Source:** hesreallyhim/awesome-claude-code
- **Path:** THE_RESOURCES_TABLE_NEW.csv (23 catalog rows, category "Observability & Monitoring")
- **HR/axis trigger IDs:** `n/a` — gap-scan finding, out of scope
- **Rationale:** **Out of scope.** Usage-and-cost meters, session monitors and telemetry dashboards. HR-6 bars telemetry, analytics and network calls outright, and SPEC 8 ratifies dashboards as an ECC reject class; the same ground disposes of this category. No plugin should own it.
- **Date:** 2026-08-22

### T-222 — gap-documentation-knowledge-learning

- **Source:** hesreallyhim/awesome-claude-code
- **Path:** THE_RESOURCES_TABLE_NEW.csv (20 catalog rows, category "Documentation, Knowledge & Learning")
- **HR/axis trigger IDs:** `n/a` — gap-scan finding, mapped to `domain`
- **Rationale:** **Mapped, covered.** Documentation and knowledge tooling is domain's under B-4, and the four Obsidian entries map to poneglyph, whose four near-verbatim kepano rows already hold that ground under EXC-1. No gap.
- **Date:** 2026-08-22

### T-223 — gap-security

- **Source:** hesreallyhim/awesome-claude-code
- **Path:** THE_RESOURCES_TABLE_NEW.csv (16 catalog rows, category "Security")
- **HR/axis trigger IDs:** `n/a` — gap-scan finding, mapped to `instinct`
- **Rationale:** **Mapped, GAP.** Entries such as SkillSpector and SkilLock audit skills, agents and hooks themselves for unsafe patterns. Nothing shortlisted owns that: ecc/security-scan and ecc/skill-comply were rejected on HR-7, the wshobson security-scanning category was rejected at category level, and wshobson comprehensive-review-security-auditor on bloat. Component-safety auditing is instinct's under B-7. Partially covered today by scripts/validate.* checks P1, P2 and P3, but that is repo tooling, not a shipped component.
- **Date:** 2026-08-22

### T-224 — gap-start-here

- **Source:** hesreallyhim/awesome-claude-code
- **Path:** THE_RESOURCES_TABLE_NEW.csv (15 catalog rows, category "Start Here")
- **HR/axis trigger IDs:** `n/a` — gap-scan finding, out of scope
- **Rationale:** **Out of scope.** Tutorials, guides and blog posts about using Claude Code. Educational content, not installable components.
- **Date:** 2026-08-22

### T-225 — gap-from-anthropic

- **Source:** hesreallyhim/awesome-claude-code
- **Path:** THE_RESOURCES_TABLE_NEW.csv (11 catalog rows, category "From Anthropic")
- **HR/axis trigger IDs:** `n/a` — gap-scan finding, out of scope
- **Rationale:** **Out of scope as a discovery source.** Official documentation and actions. The lineage-eligible half is already a pinned SPEC 8 source (anthropics/skills) and audited in this pass; the documentation half is what the SPEC 0 re-verify rule consults directly.
- **Date:** 2026-08-22

### T-226 — gap-agent-orchestration

- **Source:** hesreallyhim/awesome-claude-code
- **Path:** THE_RESOURCES_TABLE_NEW.csv (10 catalog rows, category "Agent Orchestration")
- **HR/axis trigger IDs:** `n/a` — gap-scan finding, mapped to `bankai`
- **Rationale:** **Mapped, partially covered.** Subagent orchestration is bankai's under B-6 and bankai now holds 27 shortlisted rows. The autonomous-loop subclass (the three Ralph Wiggum entries and the harness runners) stays out of scope: HR-4 bars background daemons and watchers, and the ECC loop-start, loop-status and loop-operator components were rejected on that and on D-15.
- **Date:** 2026-08-22

### T-227 — gap-memory-context-persistence

- **Source:** hesreallyhim/awesome-claude-code
- **Path:** THE_RESOURCES_TABLE_NEW.csv (10 catalog rows, category "Memory & Context Persistence")
- **HR/axis trigger IDs:** `n/a` — gap-scan finding, mapped to `rinnegan`
- **Rationale:** **Mapped, covered by design.** Temporal memory is rinnegan's under B-3. Three shortlisted rows plus eval/claude-mem-rebuild.md, whose two open design calls the owner confirmed on 2026-08-22 (no recall hook, lexical search). No gap.
- **Date:** 2026-08-22

### T-228 — gap-remote-control-notifications-voice-i-o

- **Source:** hesreallyhim/awesome-claude-code
- **Path:** THE_RESOURCES_TABLE_NEW.csv (8 catalog rows, category "Remote Control, Notifications & Voice I/O")
- **HR/axis trigger IDs:** `n/a` — gap-scan finding, out of scope
- **Rationale:** **Out of scope.** Telegram, WhatsApp, voice and notification bridges all require third-party accounts and network calls - HR-1 and HR-6.
- **Date:** 2026-08-22

### T-229 — gap-providers-runtime-integration-infrastructure

- **Source:** hesreallyhim/awesome-claude-code
- **Path:** THE_RESOURCES_TABLE_NEW.csv (7 catalog rows, category "Providers, Runtime & Integration Infrastructure")
- **HR/axis trigger IDs:** `n/a` — gap-scan finding, out of scope
- **Rationale:** **Out of scope.** LLM routers, CDP bridges and WSL2 setup are runtime and environment infrastructure, not plugin components; HR-3 and HR-6 apply to the parts that are.
- **Date:** 2026-08-22

### T-230 — gap-alternative-clients

- **Source:** hesreallyhim/awesome-claude-code
- **Path:** THE_RESOURCES_TABLE_NEW.csv (7 catalog rows, category "Alternative Clients")
- **HR/axis trigger IDs:** `n/a` — gap-scan finding, out of scope
- **Rationale:** **Out of scope.** GUI and web clients for Claude Code. Not plugin components at all.
- **Date:** 2026-08-22

### T-231 — gap-design-ui-ux

- **Source:** hesreallyhim/awesome-claude-code
- **Path:** THE_RESOURCES_TABLE_NEW.csv (6 catalog rows, category "Design & UI/UX")
- **HR/axis trigger IDs:** `n/a` — gap-scan finding, out of scope
- **Rationale:** **Out of scope.** A design discipline. Consistent with rejecting anthropics/frontend-design, the wshobson ui-design and accessibility-compliance categories, and ecc/agent-a11y-architect on axis:user_scope_fit.
- **Date:** 2026-08-22

### T-232 — gap-linting

- **Source:** hesreallyhim/awesome-claude-code
- **Path:** THE_RESOURCES_TABLE_NEW.csv (6 catalog rows, category "Linting")
- **HR/axis trigger IDs:** `n/a` — gap-scan finding, mapped to `instinct`
- **Rationale:** **Mapped, GAP.** Linting authored components - agents.md conventions, context linting, skill structure. Instinct owns validation under B-7 but holds no shortlisted component that lints a component file. Same gap family as Security above and worth resolving with it.
- **Date:** 2026-08-22

### T-233 — gap-skills

- **Source:** hesreallyhim/awesome-claude-code
- **Path:** THE_RESOURCES_TABLE_NEW.csv (5 catalog rows, category "Skills")
- **HR/axis trigger IDs:** `n/a` — gap-scan finding, mapped to `super-saiyan`
- **Rationale:** **Mapped, covered.** Superpowers is already SPEC 8's ratified spine and contributes 14 rows. No gap.
- **Date:** 2026-08-22

### T-234 — gap-creative-media

- **Source:** hesreallyhim/awesome-claude-code
- **Path:** THE_RESOURCES_TABLE_NEW.csv (4 catalog rows, category "Creative Media")
- **HR/axis trigger IDs:** `n/a` — gap-scan finding, out of scope
- **Rationale:** **Out of scope.** Video, motion and replay tooling. Same ground as anthropics/algorithmic-art and slack-gif-creator.
- **Date:** 2026-08-22

### T-235 — gap-status-lines

- **Source:** hesreallyhim/awesome-claude-code
- **Path:** THE_RESOURCES_TABLE_NEW.csv (3 catalog rows, category "Status Lines")
- **HR/axis trigger IDs:** `n/a` — gap-scan finding, mapped to `aura`
- **Rationale:** **Mapped, GAP that must NOT be closed from upstream.** Statusline presets are aura's under D-23, and aura holds zero rows by design because SPEC 4 records its Source Lineage as Original work. The gap is real and is closed by authoring at Phase 6, not by sourcing a candidate. anthropics/theme-factory was rejected on exactly this ground.
- **Date:** 2026-08-22

### T-236 — gap-research-scientific-inquiry

- **Source:** hesreallyhim/awesome-claude-code
- **Path:** THE_RESOURCES_TABLE_NEW.csv (2 catalog rows, category "Research & Scientific Inquiry")
- **HR/axis trigger IDs:** `n/a` — gap-scan finding, mapped to `super-saiyan`
- **Rationale:** **Mapped, covered.** Research-before-coding is held by the shortlisted ecc/search-first row. No gap.
- **Date:** 2026-08-22

### T-237 — gap-writing-prose-quality

- **Source:** hesreallyhim/awesome-claude-code
- **Path:** THE_RESOURCES_TABLE_NEW.csv (2 catalog rows, category "Writing & Prose Quality")
- **HR/axis trigger IDs:** `n/a` — gap-scan finding, mapped to `sharingan`
- **Rationale:** **Mapped, closed this pass.** The catalog's Avoid AI Writing entry is the same upstream component as wshobson/avoid-ai-writing-avoid-ai-writing, shortlisted for sharingan in this pass. The catalog surfaced it; the audit was done at its actual source under that source's own MIT license, as D-24 requires.
- **Date:** 2026-08-22

### T-238 — gap-infrastructure-devops

- **Source:** hesreallyhim/awesome-claude-code
- **Path:** THE_RESOURCES_TABLE_NEW.csv (2 catalog rows, category "Infrastructure & DevOps")
- **HR/axis trigger IDs:** `n/a` — gap-scan finding, out of scope
- **Rationale:** **Out of scope.** Terraform and OpenTelemetry tooling - an operations discipline, the same ground the wshobson cloud-infrastructure and observability-monitoring categories were rejected on.
- **Date:** 2026-08-22

---

### Phase 4 preamble — pass 3: davila7/claude-code-templates (2026-08-22)

The last of the three passes. **G4 closes with it.**

**Pin verified before any component was read.** Cloned fresh into this session's scratchpad, checked
out at the `upstream.json` pin: `git rev-parse HEAD` = `8546d44fdec5c9775bf92ef881090820e568198e`,
byte-equal to `upstream.json`; `git status --porcelain` empty. **1/1 MATCH.**

**Denominator.** §8 scopes this source to the components directory only. It holds **1,664** canonical
component files — 895 `SKILL.md`, 423 agent `.md`, 346 command `.md` — across **82** category
directories, carrying 1,592 distinct names. It is the largest source in §8: more components than ECC's
skills, commands and agents combined. Everything outside `cli-tool/components/` — the npm CLI,
`analytics-ui/`, `dashboard/`, `cli-rust/`, `cloudflare-workers/` — is out of scope by §8 and carries
zero rows, which is V4.2.

**Method, and the authority it rests on.** Unlike wshobson, §10 gives this source no
shortlisted-category wording and no deep-read cap. So the grounds used are the ones that bind in
every phase regardless: **B-1…B-8** (a component with no owning plugin is not shortlistable) and the
§9 `user_scope_fit` anchor. 82 categories reviewed → **12** taken forward (444 components) and **70**
rejected as a class (T-241). Inside the 12, a breadth screen on name and declared description removed
**181** — 61 already dispositioned at their actual source, 79 vendor-bound, 41 language-bound — leaving
**263**. **40** were deep-read and scored; the remaining **223 are named** in T-243 rather than
silently dropped, as the Phase-3 preamble named its own twelve margin cuts. The 40-cap is a **stated
method choice adopted by analogy** to
§10 Phase 3's ECC cap, not a §10 grant, and it is written down as such so a reviewer can disagree with
it explicitly.

**Yield.** Of the 40 deep-read: **14 shortlist, 24 reject, 2 merge**. The low yield is the finding, not
a shortfall — this source is an aggregator whose components are largely re-hosts, vendor integrations
and per-language packs.

#### Two licensing findings

1. **It re-hosts Anthropic's four source-available skills under an MIT root license.**
   `skills/document-processing/{docx,pdf,pptx,xlsx}` sit inside a repository whose root `LICENSE` is
   MIT, while the source's own `skills/ANTHROPIC_ATTRIBUTION.md` says they are "**NOT open source**"
   and "**Do not redistribute as your own**". D-24 already excludes those four, so no verdict moves —
   but an MIT root license does not relicense third-party proprietary content, and a future re-pin
   must not read it as covering them (T-244).
2. **GPL-3.0 enters through FFmpeg.** The same attribution file declares FFmpeg 7.0.2 under **GNU GPL
   v3.0** in the media skills, plus Pillow (MIT-CMU) and SIL-OFL fonts. GPL-3.0 is copyleft and is not
   compatible with distributing a close adaptation under this project's MIT terms (D-08). No
   shortlisted row touches a media skill, so nothing is blocked — the flag exists so a later pass does
   not adopt one without the owner deciding the license question (T-245). **This is the second V4.5
   NOTICE flag of Phase 4**, after `anthropics/brand-guidelines`.

#### A defect in our own enforcement, found while auditing

`davila7/security-read-only-auditor` promises a guarantee "enforced at the hook level, not just by
convention", using `hooks:` in its **agent frontmatter** with `type: command` PreToolUse matchers.
Three of our own rules bite: D-24 bars command handlers; D-15 caps hooks at one per plugin for
`super-saiyan` and `rinnegan` only; and D-24 also records that the official plugins reference states
`hooks` are **not supported for plugin-shipped agents for security reasons** — so shipped from a
plugin the enforcement would silently not exist while the description still promised it.

~~Checking that against our own schema surfaced a real gap…~~ **RETRACTED, same day.** This preamble
as merged in PR #17 claimed that `schemas/agent.schema.json` prohibits `hooks` and `mcpServers` in its
`$comment` while declaring only `permissionMode`. **That claim was false.** All three fields are
declared and enforced: `hooks` and `mcpServers` use the JSON Schema boolean form `false`, which
validates no instance and is semantically identical to `permissionMode`'s `{"not": {}}`. Verified
with `jsonschema` 4.19.2 — an agent carrying any of the three is rejected, a clean agent validates.
The error was in the checking script, which treated the falsy value `false` as an absent declaration.
No schema change was needed and none was made. Corrected in place rather than appended, because it is
a factual claim in a preamble rather than a verdict in an entry (the D-49 precedent), and the
retraction is stated rather than silent.

**The re-donation worth keeping:** `read-only-auditor`'s guarantee needs no hook at all.
`tools: Read, Grep, Glob` — which that agent already declares — *is* the enforcement, and it is what
C-2 asks for.

#### Outcome

40 rows appended — **14 shortlist / 24 reject / 2 merge**, zero `defer`. The matrix reads **322 rows,
100 shortlist / 207 reject / 15 merge** after the T-273 corrections. **All ten §8 repositories are now represented or
dispositioned**: nine carry rows and `hesreallyhim/awesome-claude-code` carries none by design, its
157 catalog rows dispositioned as gap-scan entries in pass 2 (V4.4). `bankai` holds **36** shortlisted
rows, `super-saiyan` 28, `domain` 9, `sharingan` 8, `instinct` 6, `kaioken` 6, `poneglyph` 4,
`rinnegan` 3, and `aura` 0 by design.

### T-239 — davila7-denominator

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/
- **HR/axis trigger IDs:** `n/a` — denominator record, not a rejection
- **Rationale:** **Denominator.** `SPEC.md` SPEC 8 scopes this source to the components directory only. At the pin it holds **1,664** canonical component files - **895** `SKILL.md`, **423** agent `.md`, **346** command `.md** - across **82** category directories (29 skill, 28 agent, 25 command), carrying **1,592** distinct component names. The 5,657 total files under `skills/` are mostly bundled assets and references, not components, which is why the file count is not the denominator. Everything outside the components directory - the npm CLI, `cli-tool/analytics-ui/`, `dashboard/`, `cli-rust/`, `cloudflare-workers/` - is out of scope by SPEC 8 and carries no rows (V4.2).
- **Date:** 2026-08-22

### T-240 — davila7-category-triage

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/ (82 categories)
- **HR/axis trigger IDs:** `n/a` — scoping record, not a rejection
- **Rationale:** **Category triage.** All 82 category directories were reviewed by name and contents listing. **12** were taken forward as candidate categories - agents `development-tools`, `git`, `modernization`, `documentation`, `deep-research-team`, `security`, `performance-testing`; skills `productivity`, `development`, `utilities`; commands `utilities`, `testing`, `git-workflow`, `documentation` - yielding a 444-component candidate pool. The other **70** are rejected as a class in T-241. Unlike wshobson, SPEC 10 gives this source no shortlisted-category wording, so the ground for every category rejection is B-1..B-8 and the SPEC 9 `user_scope_fit` anchor, which bind every component in every phase, rather than a phase-specific grant.
- **Date:** 2026-08-22

### T-241 — davila7-non-candidate-categories

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/ (70 categories, ~1,220 files)
- **HR/axis trigger IDs:** `B-1..B-8,axis:user_scope_fit=1`
- **Rationale:** **Class reject, 70 categories, no matrix rows.** Each is bound to one vendor, platform, language or business discipline, so no plugin among the nine can own it under B-1..B-8. Representative: `google-workspace` (107 commands), `programming-languages` (50 agents), `data-ai` (40), `devops-infrastructure` (40), `ai-research` (130 skills), `scientific` (139), `business-marketing`, `career`, `creative-design`, `enterprise-communication`, `doordash`, `gmod-addon-maker`, `sports`, `pocketbase`, `railway`, `sentry`, `azure`, `nextjs-vercel`, `svelte`, `blockchain-web3`, `finance`, `game-development`, `ffmpeg-clip-team`, `podcast-creator-team`, `ocr-extraction-team`, `ui-analysis`, `realtime`, `api-graphql`, `database`, `mcp-dev-team`. `obsidian-ops-team` is rejected on a different ground worth stating: Obsidian work is `poneglyph`'s, but SPEC 4 records `poneglyph`'s Source Lineage as kepano/obsidian-skills under EXC-1, so a second Obsidian source has no owner - the same lineage-bar reasoning that rejected anthropics/theme-factory for `aura`.
- **Date:** 2026-08-22

### T-242 — davila7-candidate-pool-screen

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/ (181 of the 444-component candidate pool)
- **HR/axis trigger IDs:** `B-1..B-8,axis:user_scope_fit=1`
- **Rationale:** **Class reject, 181 components, no matrix rows.** Inside the 12 candidate categories the pool was screened on name and declared description before any deep read. **61** are components already dispositioned at their actual source - davila7 re-hosts material from superpowers, ECC, wshobson and anthropics, and D-24's rule for catalog-surfaced candidates is that they are audited at their real source under that source's own license, which this phase already did. **79** name a specific vendor or hosted platform. **41** name a specific language or framework. Examples of the re-host class: `brainstorming`, `executing-plans`, `writing-plans`, `skill-creator`, `claude-api`, `avoid-ai-writing`, `architecture-decision-records`, `code-reviewer`, `context-manager`, `dx-optimizer`, `error-detective`, `debugger`, `test-automator`, `docx`.
- **Date:** 2026-08-22

### T-243 — davila7-deep-read-margin

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/ (223 components)
- **HR/axis trigger IDs:** `n/a` — margin record, not a rejection
- **Rationale:** **Named margin, 223 components, no matrix rows.** After the screen, **263** components survived inside the candidate categories and **40** were deep-read and scored. The remaining **223** are named here rather than silently dropped, following the Phase-3 preamble, which named its twelve margin cuts for the same reason. SPEC 10 Phase 4 sets no deep-read cap for this source - unlike Phase 3, which capped ECC at 40 - so the cap here is a stated method choice, adopted by analogy to that precedent because the source is the largest in SPEC 8 and its yield is demonstrably low: of the 40 deep-read, 14 shortlisted and 2 merged. Distribution by category: development 97, utilities 21, development-tools 18, productivity 17, documentation 15, git-workflow 13, deep-research-team 12, testing 12, security 10, performance-testing 5, modernization 2, git 1. Representative names not deep-read: tooling-engineer, thinking-beast-mode, test-engineer, test-automator, playwright-tester, performance-profiler, performance-engineer, mcp-expert, general-purpose, error-detective, dx-optimizer, dependency-manager, debugger, command-expert, cli-developer, ascii-ui-mockup-generator, architect-reviewer, accessibility-tester, git-workflow-manager, legacy-modernizer, cloud-migration-specialist, tech-debt-remediation-plan, se-technical-writer, documentation-engineer, changelog-generator, arch, api-documenter, technical-researcher, research-orchestrator, research-coordinator, research-brief-generator, research-analyst, report-generator, multi-source-searcher, data-researcher, data-analyst. Anything in this list may be promoted to a scored row later without renumbering, since the log is append-only.
- **Date:** 2026-08-22

### T-244 — davila7-anthropic-proprietary-rehost

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/skills/document-processing/{docx,pdf,pptx,xlsx}
- **HR/axis trigger IDs:** `D-24`
- **Rationale:** **Licensing finding, no matrix rows.** This source re-hosts Anthropic's four source-available document skills inside a repository whose root LICENSE is MIT. Its own `skills/ANTHROPIC_ATTRIBUTION.md` states they are "**NOT open source**", that they are "provided by Anthropic as reference examples", and instructs "**Do not redistribute as your own**". D-24 already excludes these four from lineage eligibility, so no verdict changes - but the finding is recorded because an MIT root license does not relicense third-party proprietary content, and a future re-pin must not read the root LICENSE as covering them. `pdf` is vendored here as `pdf-anthropic`.
- **Date:** 2026-08-22

### T-245 — davila7-third-party-license-exposure

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/skills/ (ANTHROPIC_ATTRIBUTION.md, THIRD_PARTY_NOTICES.md)
- **HR/axis trigger IDs:** `n/a` — licensing finding, flagged for V4.5
- **Rationale:** **NOTICE finding.** The same attribution file declares third-party dependencies carried by some skills: **FFmpeg 7.0.2 under GNU GPL v3.0** in the video and media skills, Pillow 11.3.0 under MIT-CMU/HPND, and fonts under the SIL Open Font License v1.1. GPL v3.0 is a copyleft license and is not compatible with distributing a close adaptation under this project's MIT terms (D-08). No shortlisted davila7 row touches a media skill, so nothing is blocked today; the flag exists so a later pass or re-pin does not adopt one without deciding the license question, which is the owner's under the standing authority.
- **Date:** 2026-08-22

### T-246 — davila7-self-nested-paths

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/agents/business-marketing/cli-tool/components/agents/...
- **HR/axis trigger IDs:** `n/a` — denominator record, not a rejection
- **Rationale:** **Upstream defect, recorded so the count is reproducible.** The tree contains a self-nested copy of its own path: `agents/business-marketing/cli-tool/components/agents/business-marketing/vital-health-content-agent.md` and one further level below that. Two agent files sit at these nested depths. They are in a category rejected by T-241 regardless, so no verdict turns on them, but a reader recounting `find ... -name '*.md'` will meet them and should know they are duplicates of one component, not distinct ones.
- **Date:** 2026-08-22

### T-247 — development-tools-refactoring-specialist

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/agents/development-tools/refactoring-specialist.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. One of six agents in this source built from a shared role template - Communication Protocol, <role> Assessment, Development Workflow, then numbered Analysis / Implementation / Excellence sections - each carrying 168-183 bullets and no executable procedure. The template also embeds a {'requesting_agent': ..., 'request_type': ...} JSON query addressed to a context-manager coordination protocol that does not exist in Claude Code, so the opening step of every one of them is inert.
- **Date:** 2026-08-22

### T-248 — development-tools-qa-expert

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/agents/development-tools/qa-expert.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. One of six agents in this source built from a shared role template - Communication Protocol, <role> Assessment, Development Workflow, then numbered Analysis / Implementation / Excellence sections - each carrying 168-183 bullets and no executable procedure. The template also embeds a {'requesting_agent': ..., 'request_type': ...} JSON query addressed to a context-manager coordination protocol that does not exist in Claude Code, so the opening step of every one of them is inert.
- **Date:** 2026-08-22

### T-249 — development-tools-build-engineer

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/agents/development-tools/build-engineer.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. One of six agents in this source built from a shared role template - Communication Protocol, <role> Assessment, Development Workflow, then numbered Analysis / Implementation / Excellence sections - each carrying 168-183 bullets and no executable procedure. The template also embeds a {'requesting_agent': ..., 'request_type': ...} JSON query addressed to a context-manager coordination protocol that does not exist in Claude Code, so the opening step of every one of them is inert.
- **Date:** 2026-08-22

### T-250 — development-tools-chaos-engineer

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/agents/development-tools/chaos-engineer.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. One of six agents in this source built from a shared role template - Communication Protocol, <role> Assessment, Development Workflow, then numbered Analysis / Implementation / Excellence sections - each carrying 168-183 bullets and no executable procedure. The template also embeds a {'requesting_agent': ..., 'request_type': ...} JSON query addressed to a context-manager coordination protocol that does not exist in Claude Code, so the opening step of every one of them is inert. Chaos experiments against live systems are also an operations discipline with no owning plugin.
- **Date:** 2026-08-22

### T-251 — security-security-engineer

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/agents/security/security-engineer.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. One of six agents in this source built from a shared role template - Communication Protocol, <role> Assessment, Development Workflow, then numbered Analysis / Implementation / Excellence sections - each carrying 168-183 bullets and no executable procedure. The template also embeds a {'requesting_agent': ..., 'request_type': ...} JSON query addressed to a context-manager coordination protocol that does not exist in Claude Code, so the opening step of every one of them is inert.
- **Date:** 2026-08-22

### T-252 — documentation-technical-writer

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/agents/documentation/technical-writer.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. One of six agents in this source built from a shared role template - Communication Protocol, <role> Assessment, Development Workflow, then numbered Analysis / Implementation / Excellence sections - each carrying 168-183 bullets and no executable procedure. The template also embeds a {'requesting_agent': ..., 'request_type': ...} JSON query addressed to a context-manager coordination protocol that does not exist in Claude Code, so the opening step of every one of them is inert.
- **Date:** 2026-08-22

### T-253 — development-tools-technical-debt-manager

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/agents/development-tools/technical-debt-manager.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. 17.6KB across 68 headings and 184 bullets. The debt-category taxonomy is re-donated to sharingan; the file itself is a large always-read instruction surface for one analysis.
- **Date:** 2026-08-22

### T-254 — security-read-only-auditor

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/agents/security/read-only-auditor.md
- **HR/axis trigger IDs:** `D-24,D-15`
- **Rationale:** D-24,D-15. Its stated guarantee is enforced by hooks: in the agent frontmatter - PreToolUse matchers on Write|Edit|MultiEdit and Bash, each a type: command hook running a shell echo-and-exit. D-24 bars command handlers pending a P-5-sanctioned dual-platform interpreter, D-15 caps hooks at one per plugin for super-saiyan and rinnegan only, and D-24 also records that the official plugins reference states hooks are NOT SUPPORTED for plugin-shipped agents for security reasons. Shipped from a plugin the enforcement would silently not exist while the description still promised it. Re-donated and important: the same guarantee needs no hook at all - tools: Read, Grep, Glob, which this agent already declares, is the enforcement.
- **Date:** 2026-08-22

### T-255 — security-supply-chain-security

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/agents/security/supply-chain-security.md
- **HR/axis trigger IDs:** `axis:dependencies=2`
- **Rationale:** axis:dependencies=2. Its instructions are built on npm audit, syft, CycloneDX SBOM generation and vulnerability scanners - each a tool outside the P-5 exceptions with no degraded path. The SBOM-then-scan sequence is re-donated to instinct.
- **Date:** 2026-08-22

### T-256 — git-git-flow-manager

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/agents/git/git-flow-manager.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=2`
- **Rationale:** axis:user_scope_fit=2. Bound to the Git Flow branching model specifically - develop, feature, release and hotfix branch types with their prescribed merge targets - rather than to git. A project on trunk-based development gets nothing.
- **Date:** 2026-08-22

### T-257 — deep-research-team-fact-checker

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/agents/deep-research-team/fact-checker.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. 21.4KB - the largest davila7 component read - for claim verification and source-credibility assessment. The evidence-evaluation criteria are re-donated to sharingan.
- **Date:** 2026-08-22

### T-258 — productivity-concise-planning

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/skills/productivity/concise-planning/SKILL.md
- **HR/axis trigger IDs:** n/a — `merge`, not a rejection
- **Rationale:** Fully absorbed by ecc/cmd-plan. Its whole output is a plan with scope in/out, 6-10 atomic verb-first action items and a validation step, which cmd-plan's artifact template already carries alongside pattern grounding. The one rule worth keeping into synthesis - ask at most one or two questions and only when truly blocking - is re-donated rather than lost.
- **Date:** 2026-08-22

### T-259 — productivity-think-tank

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/skills/productivity/think-tank/SKILL.md
- **HR/axis trigger IDs:** n/a — `merge`, not a rejection
- **Rationale:** Fully absorbed by ecc/council, already shortlisted for bankai. A structured multi-persona debate producing a decision is exactly what council does, and council adds two things this does not: role-scoped subagents dispatched with deliberately minimal context as an anti-anchoring device, and a ban on shadow writes. Nothing here survives that council does not already carry.
- **Date:** 2026-08-22

### T-260 — productivity-devil

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/skills/productivity/devil/SKILL.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. 19KB for an adversarial sign-off persona. Its two habits - the pre-mortem and the silence check, asking what the document does not say - are re-donated to sharingan; the persona framing around them is the bulk.
- **Date:** 2026-08-22

### T-261 — productivity-skill-judge

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/skills/productivity/skill-judge/SKILL.md
- **HR/axis trigger IDs:** `axis:bloat=1`
- **Rationale:** axis:bloat=1. 31KB and a 120-point rubric across named dimensions. The evaluation concept is already held by the shortlisted wshobson/plugin-eval-eval-judge row, which does the same job with anchored 0.0-1.0 rubrics in 3KB.
- **Date:** 2026-08-22

### T-262 — productivity-kaizen

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/skills/productivity/kaizen/SKILL.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. 17.5KB organised around four manufacturing pillars (Kaizen, Poka-Yoke, Standardized Work, JIT) mapped onto code quality. The error-proofing idea is re-donated; the framework scaffolding is the bulk.
- **Date:** 2026-08-22

### T-263 — productivity-naming-analyzer

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/skills/productivity/naming-analyzer/SKILL.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=2`
- **Rationale:** axis:user_scope_fit=2. Half the file is per-language convention tables - JavaScript/TypeScript, Python, Java, Go - which is the per-language reference SPEC 4's nine plugins do not own under B-1..B-8 - the ground the ecc/error-handling row states.
- **Date:** 2026-08-22

### T-264 — productivity-humanizer

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/skills/productivity/humanizer/SKILL.md
- **HR/axis trigger IDs:** n/a — `merge`, not a rejection
- **Rationale:** Fully absorbed by wshobson/avoid-ai-writing-avoid-ai-writing, shortlisted for sharingan in pass 2. Same job - strip machine-generated tells from prose - at 17.9KB against 7.7KB, and without the absorbing row's two safeguards: the false-positive caveat forbidding use for attribution decisions, and the rule against ADDING fake voice during a rewrite.
- **Date:** 2026-08-22

### T-265 — productivity-nowait

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/skills/productivity/nowait/SKILL.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=1`
- **Rationale:** axis:user_scope_fit=1. Implements an inference-time technique for R1-style reasoning models named as QwQ and similar. It tunes a third-party model's decoding, not the user's project.
- **Date:** 2026-08-22

### T-266 — development-code-review-checklist

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/skills/development/code-review-checklist/SKILL.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. 11.6KB across 53 headings and 167 bullets. sharingan already holds ecc/cmd-code-review and wshobson/operating-kit-code-review-preshipment, the latter with a ten-section walk and an explicit SHIP verdict in a quarter of the size.
- **Date:** 2026-08-22

### T-267 — development-production-code-audit

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/skills/development/production-code-audit/SKILL.md
- **HR/axis trigger IDs:** `axis:bloat=2`
- **Rationale:** axis:bloat=2. 15.8KB, and its Step 3 is Automatic Fixes and Optimizations - an autonomous line-by-line transformation of an entire codebase with no approval gate, which is a risk posture nothing else in the shortlist takes.
- **Date:** 2026-08-22

### T-268 — development-software-architecture

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/skills/development/software-architecture/SKILL.md
- **HR/axis trigger IDs:** `axis:value=3`
- **Rationale:** axis:value=3 with no unique surface: 3.5KB of general code-style and best-practice bullets that super-saiyan's existing mattpocock and superpowers rows already carry. Nothing survives synthesis that is not duplicated.
- **Date:** 2026-08-22

### T-269 — development-domain-driven-design

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/skills/development/domain-driven-design/SKILL.md
- **HR/axis trigger IDs:** `axis:user_scope_fit=2`
- **Rationale:** axis:user_scope_fit=2. DDD is one modelling methodology; the skill is a routing map between its strategic and tactical patterns. Its structure is worth noting - an explicit Do not use this skill when section and a viability check before proceeding - and both are re-donated.
- **Date:** 2026-08-22

### T-270 — utilities-explain-code

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/commands/utilities/explain-code.md
- **HR/axis trigger IDs:** `axis:value=3`
- **Rationale:** axis:value=3 with no unique surface. 6.7KB of explanation prompts largely duplicated by ecc/agent-code-explorer and davila7/development-tools-codebase-explorer, both of which produce a structured model rather than prose.
- **Date:** 2026-08-22

### T-271 — utilities-directory-deep-dive

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/commands/utilities/directory-deep-dive.md
- **HR/axis trigger IDs:** `axis:value=2`
- **Rationale:** axis:value=2. 1.2KB that walks a directory and summarises it - fully covered by the shortlisted codebase-explorer and codebase-pattern-finder rows.
- **Date:** 2026-08-22

### T-272 — testing-test-quality-analyzer

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/commands/testing/test-quality-analyzer.md
- **HR/axis trigger IDs:** `axis:value=3`
- **Rationale:** axis:value=3 with no unique surface: 2.4KB asking for test-suite quality metrics, which ecc/agent-pr-test-analyzer already covers with gap severity rating and ecc/cmd-test-coverage with a worst-first gap list.
- **Date:** 2026-08-22

### T-273 — resolvable-citation-and-coherence-corrections

- **Source:** affaan-m/ECC, wshobson/agents, anthropics/skills, davila7/claude-code-templates
- **Path:** eval/matrix.csv (4 rows), eval/triage-log.md (4 entries and 6 preamble passages)
- **HR/axis trigger IDs:** `n/a` — re-audit; one verdict moved, no scores invalidated
- **Rationale:** **Re-audit.** A sweep of the Phase-4 output for the defect class T-069 and SPEC v2.5 SPEC 14 row 8 corrected found three kinds of problem, all introduced by this phase. **(1) Unresolvable citations.** Eleven references to `D36`, `D40`, `D41`, `D48` and `D53` cited *session* decisions recorded in an unversioned `HANDOFF.md` outside the repository, which a G5 reviewer working clean-room from a `git archive` export cannot resolve; SPEC 0 requires citations to resolve. Two sat in scored matrix rationales - `wshobson/context-management-context-save` cited `(D53)` and `davila7/productivity-naming-analyzer` cited `(the D41 ground)` - and nine in pass preambles. All eleven now point at an in-repo referent or state the fact directly: the D53 reference becomes T-227 plus `eval/claude-mem-rebuild.md`, the D41 reference becomes B-1..B-8 and the `ecc/error-handling` row. **(2) A trigger field contradicting its own row.** `anthropics/doc-coauthoring` carried `axis:dependencies=1` while its row scores `dependencies` 5. The axis was never the ground - the component ships no license in a repository with no root license - so the trigger is now `D-24` alone and the rationale no longer claims an axis. **(3) Three more trigger/row contradictions** found by cross-checking every entry against its row: `wshobson/code-refactoring-context-restore` and `davila7/utilities-directory-deep-dive` are rescored `value` 3 to **2**, which is what their rationales already argued; and `davila7/productivity-think-tank` moves from `reject` to **`merge`** naming `ecc/council`, because its own rationale said the deciding ground was that nothing survives which council does not already carry, and that is the merge definition rather than a bloat floor. All 222 entries that map to a matrix row were then cross-checked mechanically: zero remaining contradictions. Matrix totals move from 100/208/14 to **100 shortlist / 207 reject / 15 merge**; no row was added or removed and no shortlist verdict changed.
- **Date:** 2026-08-22

### T-274 — code-review

- **Source:** mattpocock/skills
- **Path:** skills/engineering/code-review/SKILL.md
- **HR/axis trigger IDs:** `n/a (re-audit)`
- **Rationale:** **Re-audit at G5**, closing the "re-examine at G5" flag T-026 left open. Re-read in full at the pinned commit `9c9f36ccd3995266cd675468af71639c8dde1ec5`. Previous: `5,4,5,3,5`, `shortlist`. **What the source says.** Line 13 reads, verbatim: "The issue tracker should have been provided to you. If `docs/agents/issue-tracker.md` is missing, tell the user to run `/setup-matt-pocock-skills`." — T-026 described it accurately. Step 2 lists four spec sources in order; only the first (issue references in commit messages, fetched "via the workflow in `docs/agents/issue-tracker.md`") needs the tracker, and sources 2-4 are a path the user passed, a spec file under `docs/`, `specs/` or `.scratch/`, and asking the user. Line 72: "If the spec is missing, skip the Spec sub-agent and note this in the final report." The Standards axis reads whatever the repository documents plus a twelve-item Fowler smell baseline embedded in the file, so it needs nothing external. Every shell command is `git diff`, `git log` or `git rev-parse` - read-only. The file ships no key, endpoint or account; the HR-1 component is `/setup-matt-pocock-skills` itself (T-005), reached only through the line-13 instruction. **Adjudication.** HR-1 does not fire on this file. `dependencies` stays 3 on the `SPEC.md` §9 anchor: the coupling is one instruction line with a working path around it, not a hard requirement on a non-P-5 tool, which would be 1. One point the original rationale did not address: the two axes run as "parallel sub-agents". B-6 gives `bankai` subagent *definitions* and their allowlists; this file defines no agent and grants no tools - it asks the harness to run two prompts it supplies - so nothing B-6 owns ships with it, and B-2 holds because it reviews and does not execute. **Synthesis constraints**, now explicit: drop line 13 entirely (the Spec axis already degrades without it), and keep an inline sequential fallback for the two axes so `sharingan` carries no dependency on subagent availability. New: `5,4,5,3,5`, `shortlist` - unchanged. The matrix rationale is replaced in place under §2 rule 4 to record the re-examination and drop the contested flag; no score moved. **Contested status: closed.**
- **Date:** 2026-08-25

### T-275 — cmd-plan

- **Source:** affaan-m/ECC
- **Path:** commands/plan.md
- **HR/axis trigger IDs:** `n/a (re-audit)`
- **Rationale:** **Re-audit at G5**, closing the contested flag the pass-1 row carried. Re-read in full at the pinned commit `06c5e118c4d3e6c3b7f9445f973a2194c82de193`. Previous: `4,3,5,5,5`, `shortlist`. **What the source says.** `/plan-canvas` appears exactly twice. Lines 114-117 are a blockquote: "instead of asking for a typed confirmation, you can open the artifact in the browser Plan Canvas (`/plan-canvas`, or the `plan-canvas` skill)"; line 189, under Integration with Other Commands: "Use `/plan-canvas` to run the confirmation gate visually in the browser (annotate + approve)". Both are offered as alternatives. The command's own gate is the typed confirmation: line 17 "MUST receive user approval before proceeding", line 112 "WAIT for confirmation before writing code", line 174 "WAITING FOR CONFIRMATION", line 179 "will NOT write any code until you explicitly confirm". Line 10 - "Run inline by default. Do not call the Task tool or any subagent by default" - holds, and the optional planner agent (lines 199-206) falls back inline when absent. Writes are `.claude/plans/<name>.plan.md` and one PRD milestone row, both inside the project (C-3). **Adjudication.** The Plan Canvas surface is the HR-4 reject T-050 (a detached loopback server); in this file the coupling is two removable sentences, not the mechanism, and the typed gate is complete without them, so no HR fires and the scores hold. One thing the original rationale did not note: the worked example (lines 119-175) is stack-specific - BullMQ/Redis, SendGrid/Resend, Supabase - as illustration; the procedure itself names no stack, so `user_scope_fit` 5 holds for the procedure. **Synthesis constraints**, now explicit: drop both `/plan-canvas` references and keep the typed gate; replace the worked example with a stack-neutral one. New: `4,3,5,5,5`, `shortlist` - unchanged; matrix rationale replaced in place under §2 rule 4. **Contested status: closed.**
- **Date:** 2026-08-25

### T-276 — phase-5-consolidation-record

- **Source:** eval/matrix.csv, eval/triage-log.md, eval/shortlist.md
- **Path:** eval/shortlist.md (all sections); eval/triage-log.md §4
- **HR/axis trigger IDs:** `n/a` — consolidation record; no component read, no verdict moved
- **Rationale:** **Phase-5 consolidation.** Recorded here so the reviewer can find the phase's dispositions in the versioned artifacts. **(1) The three capability gaps carried out of G4** (`ROADMAP.md` §6) are dispositioned as recorded plans for original work in `eval/shortlist.md` §5: component-safety auditing (T-223) and component linting (T-232) to `instinct` under B-7; statusline presets (T-235) to `aura`, which **must not** be closed from upstream because `SPEC.md` §4 records its lineage as Original work - the ground on which two candidates were already rejected. **(2) Re-donated concepts.** Thirty concepts donated by rejected or merged components across Phases 2-4 are listed in `eval/shortlist.md` §7 as Phase-6 synthesis inputs, each citing its donor entry, and deliberately **not** scored as `concept` rows. `eval/rubric.md` §7 Example A's concept row presupposes a design to score - the one such row, `claude-mem/session-memory`, has `eval/claude-mem-rebuild.md` behind it - and scoring a concept with no design would write audit evidence for a read that has not happened (§2 rule 6). A concept re-enters as a scored row only when Phase 6 writes a design for it. **(3) Zero `defer` rows.** The matrix carries 322 rows: 100 `shortlist`, 207 `reject`, 15 `merge`, 0 `defer`; the enumeration `SPEC.md` §9 rule 3 requires of the sign-off ADR is therefore empty, and is stated as empty. **(4) A transcription defect in §4 corrected in place.** The overlap paragraph below the statistics table said "the sixteen bulk-reject classes" and "the ten re-audit entries" while the table read 19 and 11 and the paragraph's own lists enumerate 19 and 11; the words went stale when pass 3 added T-241 and T-242 and when T-149 and T-273 joined the re-audits. Recounting the nineteen class entries' trigger fields also found that THIRTEEN, not sixteen, carry an `HR-N` or `axis:` trigger - the six that do not carry a rule ID (`B-1..B-8`, `D-15,D-24`, `D-24`) or an `n/a` scoping field instead: T-029, T-036, T-037, T-150, T-154 and T-240. The table was correct; the words are corrected in place and the correction is stated here so it is not a silent edit. **(5) V5.1-V5.7 re-derived by the executor** from the files - the reviewer re-derives them independently and this record is not evidence for it: V5.1 0 empty `verdict` cells and 0 values outside the enum across 322 rows; V5.2 0 duplicate ids; V5.3 0 axis cells outside the integers 1-5 across 322 x 5 cells; V5.4 across 100 shortlist rows, 0 with a `hard_reject`, 0 axis cells below 3, 0 without exactly one kebab-case owning plugin; V5.5 rows per `upstream.json` repository - `obra/superpowers` 14; `mattpocock/skills` 35; `affaan-m/ECC` 142; `thedotmack/claude-mem` 2; `wshobson/agents` 68; `anthropics/skills` 15; `kepano/obsidian-skills` 5; `vercel-labs/skills` 1; `hesreallyhim/awesome-claude-code` 0; `davila7/claude-code-templates` 40 - the one zero being `hesreallyhim/awesome-claude-code`, discovery-only by design and dispositioned at T-221...T-238; V5.6 the shortlist implies exactly two hooks, `super-saiyan` (lineage `superpowers/using-superpowers`) and `rinnegan` (lineage `claude-mem/session-memory`), and the matrix's one `hook`-type row (`claude-mem/memory-hooks`) is a `reject`; V5.7 shortlisted rows per plugin - `super-saiyan` 28, `sharingan` 8, `rinnegan` 3, `kaioken` 6, `bankai` 36, `domain` 9, `instinct` 6, `poneglyph` 4, `aura` 0 - with `aura`'s recorded plan at `eval/shortlist.md` §5 on the basis of `SPEC.md` §4 and T-235.
- **Date:** 2026-08-25

### T-277 — save-session

- **Source:** affaan-m/ECC
- **Path:** commands/save-session.md
- **HR/axis trigger IDs:** `n/a (re-audit)`
- **Rationale:** **Re-audit after the G5 round-1 spot-check** (`ROADMAP.md` §7), re-read in full at the pinned commit `06c5e118c4d3e6c3b7f9445f973a2194c82de193`. Previous: `4,4,4,5,5`, `shortlist`, rationale "Writes are user-invoked and shown for confirmation (C-3)". **The reviewer's finding was correct on the source and the rationale was wrong.** Line 2 and line 274 fix the write target as `~/.claude/session-data/`; line 32 is `mkdir -p ~/.claude/session-data`; step 5 (lines 54-64) is "After writing, display the full contents and ask" - the file is shown *after* it is written, so the write is not user-approved before it happens, and the location is chosen by the command, not the user. Line 37 names `SESSION_FILENAME_REGEX` in `session-manager.js` as the source of a naming rule and then states the rule inline; nothing executes node, so "no node" stands as "no node executed" and the reference is disclosed here. **Adjudication.** The reviewer asked for consistency with T-020. The standard the matrix has actually applied to config-dir writes is D-18's own-data-directory clause: T-042 cleared `ecc/ck` writing `~/.claude/ck/` because that is the component's own directory under the user's Claude config dir; T-057 faulted `skill-stocktake` for writing inside *another component's* directory; T-020 rejected `mattpocock/handoff` for the OS temporary directory, which is outside the config dir altogether and which D-18 never reaches. `~/.claude/session-data/` is the sessions family's own dedicated directory under the config dir - the T-042 shape, not the T-020 shape - so C-3 holds on that clause and the row is not the T-020 case. What does not hold is `risk` 4: the interpolated "writes within bounds, no conditional raised" reading is wrong because C-3 *is* the conditional in play, and the SPEC §9 anchor for conditional behaviour passing its checks is 3. **New: `4,4,3,5,5`, `shortlist` retained**, rationale replaced in place (§2 rule 4) to state the write target, the after-the-fact review, and the regex reference honestly. Synthesis constraints: the write moves to `kaioken`'s own plugin data directory (D-18), the review step moves before the write, and the `session-manager.js` reference becomes a stated naming rule.
- **Date:** 2026-08-25

### T-278 — development-clean-code

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/skills/development/clean-code/SKILL.md
- **HR/axis trigger IDs:** `axis:dependencies=1`
- **Rationale:** **Re-audit after the G5 round-1 spot-check**, re-read in full at the pinned commit `8546d44fdec5c9775bf92ef881090820e568198e`. Previous: `4,4,5,5,5`, `shortlist`, rationale "Stack-agnostic, 6.7KB" with no mention of any script. **The reviewer's finding was correct and this is the §1 failure mode - the file was profiled, not read to the end.** Lines 142-200 of the 201-line, 6,676-byte file are a section headed "Verification Scripts (MANDATORY)": a table of fourteen `python ~/.claude/skills/<skill>/scripts/<script>.py` commands drawn from thirteen *other* davila7 skills (frontend-design, api-patterns, mobile-design, database-design, vulnerability-scanner, seo-fundamentals, geo-fundamentals, performance-profiling, testing-patterns, webapp-testing, lint-and-validate, i18n-localization), keyed to davila7 agent names, followed by "**VIOLATION:** Running script and ignoring output = FAILED task". **Adjudication.** As shipped that is a hard requirement on tooling outside P-5 with no degraded path - the `dependencies` 1 anchor verbatim, and the ground on which `ecc/orch-pipeline` (T-049) was rejected for doing nothing outside its own install. `risk` 5 ("no shell side effects") is also false as shipped; it runs fourteen external scripts. The standards content in lines 1-141 is genuinely stack-agnostic and would have shortlisted on its own; rubric §4's deficiency clause was weighed and does not reach a section the file itself calls MANDATORY and a third of its length. **New: `4,4,3,1,5`, `reject`.** Re-donated to `super-saiyan`: the rules-not-philosophy framing, the anti-pattern list (no unnecessary comments, no over-engineering) and the THINK FIRST gate, landing in `ecc/intent-driven-development`; the T-206 and T-262 concepts that had been assigned to this row move with them.
- **Date:** 2026-08-25

### T-279 — development-tools-unused-code-cleaner

- **Source:** davila7/claude-code-templates
- **Path:** cli-tool/components/agents/development-tools/unused-code-cleaner.md
- **HR/axis trigger IDs:** `HR-7`
- **Rationale:** **Re-audit after the G5 round-1 spot-check**, re-read in full at the pinned commit `8546d44fdec5c9775bf92ef881090820e568198e`. Previous: `4,4,4,5,4`, `shortlist`, rationale "HR-7 CLEARED: the language tooling it names is the project's own, not a fetch". **The clearance was wrong about the source.** Lines 96-97, the JavaScript/TypeScript branch of Language-Specific Analysis, are `npx depcheck` and `npx ts-unused-exports tsconfig.json`; line 126, Validation Commands, is `npx eslint file.js`. `depcheck` and `ts-unused-exports` are analysis tools, not a project's own runner: `npx` fetches them at run time when they are not installed, which is HR-7's "runtime dependency fetching" verbatim. The distinction that cleared `ecc/cmd-test-coverage` - `npx` invoking the project's *installed* jest or vitest - does not apply, and the ground is the one that rejected `ecc/cmd-refactor-clean` (T-106) and `ecc/agent-refactor-cleaner` (T-136) for `npx knip`, `npx depcheck`, `npx ts-prune`. That the Python branch (`python -m ast`) fetches nothing does not clear the component: a hard reject fires on any trigger. **New: `4,4,4,2,4`, `hard_reject = HR-7`, `reject`.** The proposed allowlist is moot. Re-donated to `sharingan`, beside T-136's SAFE/CAREFUL/RISKY triage: the Dynamic Usage Safety rule - skip `importlib` and other dynamic-import paths rather than deleting on a static miss. `bankai` drops to 35 shortlisted rows.
- **Date:** 2026-08-25

### T-280 — claude-handoff

- **Source:** mattpocock/skills
- **Path:** skills/in-progress/claude-handoff/SKILL.md
- **HR/axis trigger IDs:** `HR-4`
- **Rationale:** **Re-audit after the G5 round-1 spot-check**, re-read in full at the pinned commit `9c9f36ccd3995266cd675468af71639c8dde1ec5`. Previous: `4,5,4,5,5`, `shortlist` (T-027), rationale addressing only the write-location defect of its former absorber. **The reviewer's finding was correct: the launch mechanism was never adjudicated.** Line 8 is the whole skill: "Write a handoff summary ... Instead of saving it, launch a background agent seeded with the summary as its prompt: `claude --bg --name "<descriptive name>" "<handoff summary>"`. It starts in the current working directory and returns immediately; the user manages it with `claude agents`." There is no other mechanism - the summary is never written anywhere. **Adjudication.** A process the component starts that returns immediately and runs on after the turn is a background worker: the HR-4 shape as this matrix applies it, drawn at `superpowers/brainstorming` (T-001, a detached server) and stated as the boundary in the shortlisted `ecc/parallel-execution-optimizer` row ("forbids background processes outliving the turn"). That the process is a harness agent rather than a shipped binary does not change what it is, and whether the harness exposes `claude --bg` and `claude agents` at all cannot be settled from the artifacts - if it does not, the skill does nothing. `risk` 1 on the SPEC §9 anchor (policy check against §6). **New: `4,5,1,5,5`, `hard_reject = HR-4`, `reject`.** T-027's promotion is superseded; the row that T-020 merged it into is also a reject, so the mattpocock handoff lineage now survives only as a re-donation. Re-donated to `kaioken`, landing in the file-persisting `ecc/cmd-save-session` and `ecc/cmd-resume-session`: reference existing artifacts by path instead of duplicating them, name the skills the next session should call, redact secrets because the summary becomes a prompt. `kaioken` drops to 5 shortlisted rows.
- **Date:** 2026-08-25

### T-281 — session-memory

- **Source:** thedotmack/claude-mem
- **Path:** docs/architecture-overview.md (concept row); eval/claude-mem-rebuild.md (the design scored)
- **HR/axis trigger IDs:** `n/a (re-audit)`
- **Rationale:** **Re-audit after the G5 round-1 review.** Previous: `5,4,3,5,5`, `shortlist`. The reviewer found that `risk` 3 ("conditional behaviors passing all C-1..C-3 checks") is asserted while the design being scored says the opposite: `eval/claude-mem-rebuild.md` open item 1 reads "C-1 idempotence and the 10-second timeout must be *executed* on Windows 11 PowerShell 7 and WSL2 before the hook ships; a static design cannot close them (`eval/rubric.md` §7 Example C)". Example C's prescribed disposition for exactly that situation is `risk = 2` and `verdict = defer` naming the blocking check and the phase that resolves it. **Adjudication.** The reviewer is right that the matrix cannot both score the row as C-1-passing and cite a design that says C-1 is unclosed. The earlier reasoning - that the executed check attaches to the Phase-6 implementation rather than the concept - describes *when* the check runs, which is what a `defer`'s named phase is for; it is not a reason to score the check as passed. The concept is the one entry in this matrix whose `component_type` is `concept` and whose design exists, so it is also the one entry a `defer` fits without pre-deciding anything (§2 rule 6). **New: `5,4,2,5,5`, `defer` — blocking check C-1, resolving in Phase 6**, at the G6 gate, by executing the authored hook on both platforms before it ships; the row's verdict is replaced only then, by a further re-audit entry recording the executed result. Consequences: the matrix now carries **one** `defer` row, which the Phase-5 sign-off ADR enumerates (SPEC §9 rule 3); T-276 item (3)'s "zero `defer` rows" is superseded by this entry; `rinnegan`'s V5.7 roster rests on `ecc/architecture-decision-records` and `ecc/growth-log`; V5.6 still implies at most one `rinnegan` hook and none until C-1 closes. `eval/claude-mem-rebuild.md` is unchanged - it already said this.
- **Date:** 2026-08-25

## 4. Statistics

Recomputed at each gate from the entries in §3, so the table can be checked against the file rather than trusted. The first four rows partition the entries by their trigger field under one stated precedence rule: an entry carrying **any** `HR-N` counts as hard-reject; otherwise any `axis:` trigger counts as axis-floor; otherwise a rule ID such as `B-1..B-8`, `D-15` or `D-24` counts as other-rule; a field beginning `n/a` is its own row **including the `n/a (re-audit)` form**, which the v2.6 table wrongly filed under other-rule (T-069). 46 + 148 + 37 + 50 = 281.

| Metric | Count |
|---|---|
| Total entries | 281 |
| Hard-reject entries | 46 |
| Axis-floor entries | 148 |
| Other-rule entries | 37 |
| `n/a` entries | 50 |
| Bulk-reject classes | 19 |
| Gap-scan entries | 18 |
| Re-audit / re-pin entries | 18 |

The last three rows **overlap** the partition above and are not added to it: the nineteen bulk-reject classes are T-029…T-037, T-070…T-072 and T-151, T-152, T-154 plus the T-150 and T-240 scoping records and T-241, T-242 from pass 3, thirteen of which also carry an `HR-N` or `axis:` trigger; the eighteen re-audit entries are T-026…T-028 (the 2026-08-18 G5 rehearsal), T-064…T-069 (the 2026-08-22 review corrections), T-149 (the B-6 agent-ownership recalibration), T-273 (the resolvable-citation and trigger-coherence sweep), T-274, T-275 (the Phase-5 re-examination of the two knowingly-contested shortlist rows) and T-277…T-281 (the G5 round-1 remediation, three of which are also rejects counted in the hard-reject and axis-floor rows). The words "sixteen", "sixteen" and "ten" that stood in this sentence until 2026-08-25 were stale against the table and are corrected at T-276. **Gap-scan entries move off 0 for the first time**: T-221…T-238 disposition all 157 rows of `hesreallyhim/awesome-claude-code`'s catalog across its 18 categories — 9 mapped to an owning plugin, 9 explicitly out of scope, zero merge candidates sourced from it (V4.4).

Reconciliation with the v2.5 table, which read 28 / 12 / 7 / 0 / 0 / 3 after Phase 2: the Phase-2 entries still contribute 12 hard-reject and 7 axis-floor. Six sit in the other-rule row, described below, and T-026 / T-027 sit in the `n/a` row rather than the other-rule row — the correction T-069 records. The v2.6 table published 22 / 24 / 14 / 3; the differences are that fix plus T-066's withdrawal of `HR-3` from T-030, which moves that class from hard-reject to axis-floor.

The six Phase-2 entries counted in neither the hard-reject nor the axis-floor row are rejections on a rule that is neither an HR trigger nor an axis floor: five on `B-1..B-8` (no owning plugin exists, so `SPEC.md` §4 forbids shortlisting) and one on `D-15,D-24` (a hook whose dispatch and budget no plugin can carry). Their trigger-ID fields carry those rule IDs, which is what the §10 Phase-2 exit criterion checks.

The three Phase-2 re-audit entries (T-026…T-028) arose from the **G5 rehearsal review** of 2026-08-18: an independent reviewer, running the `eval/gate-review-protocol.md` standard against the artifacts and the pinned sources, returned `REJECTED` and named three defects the Phase-2 self-checks could not see, because all three were internally consistent and wrong about the source. None changed a verdict to `reject`; T-027 moved a `merge` to `shortlist`, which is why the matrix read 27 / 25 / 3 at the end of Phase 2.

**Phase 3 (2026-08-22) added T-029…T-063**: nine bulk-reject classes covering 245 of ECC's 285 canonical skills plus its 41KB `hooks.json`, twenty-three individual rejects and two `merge` entries from the forty deep reads, and one reject for the shipped `thedotmack/claude-mem` implementation. `eval/matrix.csv` grew by 42 rows — 40 ECC (the §10 Phase-3 cap, which bound exactly) and 2 claude-mem — and now reads 97 rows, 43 shortlist / 49 reject / 5 merge.

**The 2026-08-22 review corrections added T-064…T-069**, from an independent Fable-5 artifacts-only read of the Phase-3 output against both pinned clones. Same shape as the G5 rehearsal and the same lesson: the findings that mattered were claims that were internally coherent and wrong about the source or the standard. No verdict changed; three shortlisted rows were rescored on the §9 risk anchor, one rationale was completed, two class trigger sets were re-grounded, one skill moved between classes, and the counting rule in this section was made to match what it implements.

**Phase 4 pass 1 (2026-08-22) added T-070…T-148**: three ratified reject classes covering 60 of ECC's 162 canonical commands and agents (T-070 the 22 language-pack commands, T-071 the 28 language-pack agents, T-072 the 10 domain-niche agents), sixty-nine individual rejects and seven `merge` entries from the 102 deep reads. `eval/matrix.csv` grew by 102 rows — 72 commands and 30 agents, the first `command` and `agent` rows in the file — and now reads 199 rows, 69 shortlist / 118 reject / 12 merge. Zero `defer` rows exist. The pass covers only the ECC half of `SPEC.md` §10 Phase 4; the four remaining sources run in passes 2 and 3.

**Phase 4 pass 2 (2026-08-22) added T-149…T-238**: one re-audit correcting eight pass-1 agent rows to `bankai` under B-6, a category-triage record and three class rejects covering 91 wshobson plugins and four proprietary anthropics skills, a denominator record for nine byte-identical duplicate component copies, sixty-six individual rejects, and the eighteen gap-scan entries. `eval/matrix.csv` grew by 83 rows — 68 wshobson and 15 anthropics — and now reads 282 rows, 86 shortlist / 184 reject / 12 merge. Zero `defer` rows exist. Eight of the ten `SPEC.md` §8 repositories now carry rows; `hesreallyhim/awesome-claude-code` carries none by design and `davila7/claude-code-templates` is pass 3, after which G4 can close.

**Phase 4 pass 3 (2026-08-22) added T-239…T-272**, completing the phase: a denominator and category-triage record for the largest source in §8, three class rejects covering 70 non-candidate categories and 181 screened components, a named 223-component margin, two licensing findings, an upstream self-nesting record, and twenty-six individual rejects and merges from the forty deep reads. `eval/matrix.csv` grew by 40 rows and now reads **322 rows, 100 shortlist / 207 reject / 15 merge** after the T-273 corrections, still with zero `defer`. **All ten `SPEC.md` §8 repositories are now represented or dispositioned** — nine carry rows, and `hesreallyhim/awesome-claude-code` carries none by design with its catalog dispositioned as the eighteen gap-scan entries. **T-273** then swept the whole phase for unresolvable citations and trigger/row contradictions and corrected four rows and four entries; every one of the 222 entries that maps to a row was cross-checked mechanically afterwards.

**Phase 5 (2026-08-25) added T-274…T-276**: two re-audits closing the knowingly-contested flags on `mattpocock/code-review` (T-026) and `ecc/cmd-plan`, each re-read at its pinned commit with scores and verdicts unchanged and the matrix rationale replaced in place, and one consolidation record carrying the phase's dispositions - the three G4 capability gaps as recorded original-work plans, thirty re-donated concepts listed unscored, zero `defer` rows, the §4 prose correction, and the executor's V5.1-V5.7 values. `eval/matrix.csv` stays at 322 rows, 100 shortlist / 207 reject / 15 merge; `eval/shortlist.md` (SPEC v2.8) is the roster the gate reviews.

**Gate G5 round 1 (2026-08-25) returned `REJECTED` and added T-277…T-281** (`ROADMAP.md` §7 carries the verdict and findings): the reviewer's source spot-check contradicted four shortlisted rows and the disposition of a fifth, and every finding held on re-reading the source. `ecc/cmd-save-session` rescored `risk` 4→3 and retained; `davila7/development-clean-code` (a MANDATORY external-script section the rationale never disclosed), `davila7/development-tools-unused-code-cleaner` (`npx depcheck`, HR-7) and `mattpocock/claude-handoff` (a background agent outliving the turn, HR-4) moved to `reject`; `claude-mem/session-memory` moved to `defer` on C-1 per rubric §7 Example C. `eval/matrix.csv` stays at 322 rows: **96 shortlist / 210 reject / 15 merge / 1 defer**.

The verdict vocabulary is `SPEC.md` §9 rule 3 — `shortlist`, `reject`, `merge`, `defer`. This log carries entries for `reject` (mandatory) and may carry them for `merge` and `defer` where the reasoning is worth preserving; `shortlist` rows need no entry.
