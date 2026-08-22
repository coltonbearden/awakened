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
T-030…T-036 — 40 + 94 + 40 + 33 + 20 + 24 + 20 + 14 = 285.

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
and `eval-harness` are the named margin cuts; they sit in T-035 and T-036.

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
- **Path:** skills/ (94 skills)
- **HR/axis trigger IDs:** `HR-3,axis:user_scope_fit=1`
- **Rationale:** A `SPEC.md` §8 named reject class, disposed without deep reads under §10 Phase 3 and §2 rule 2 of this log. 94 skills whose value is bound to one language, framework, runtime or UI stack — language-specific tooling at user scope (HR-3) and project- or language-specific reach (user_scope_fit 1). Members: accessibility, android-clean-architecture, angular-developer, api-design, backend-patterns, browser-qa, bun-runtime, click-path-audit, clickhouse-io, compose-multiplatform-patterns, content-hash-cache-pattern, cpp-coding-standards, cpp-testing, csharp-testing, dart-flutter-patterns, database-migrations, deployment-patterns, design-system, django-celery, django-patterns, django-security, django-tdd, django-verification, docker-patterns, dotnet-patterns, e2e-testing, fastapi-patterns, flutter-dart-code-review, foundation-models-on-device, frontend-a11y, frontend-design-direction, frontend-patterns, fsharp-testing, generating-python-installer, golang-patterns, golang-testing, hexagonal-architecture, ios-icon-gen, java-coding-standards, jpa-patterns, kotlin-coroutines-flows, kotlin-exposed-patterns, kotlin-ktor-patterns, kotlin-patterns, kotlin-testing, kubernetes-patterns, laravel-patterns, laravel-security, laravel-tdd, laravel-verification, liquid-glass-design, make-interfaces-feel-better, mcp-server-patterns, motion-advanced, motion-foundations, motion-patterns, motion-ui, mysql-patterns, nestjs-patterns, nextjs-turbopack, nodejs-keccak256, nuxt4-patterns, perl-patterns, perl-security, perl-testing, postgres-patterns, prisma-patterns, python-patterns, python-testing, pytorch-patterns, quarkus-patterns, quarkus-security, quarkus-tdd, quarkus-verification, react-native-patterns, react-patterns, react-performance, react-testing, redis-patterns, rust-patterns, rust-testing, springboot-patterns, springboot-security, springboot-tdd, springboot-verification, swift-actor-persistence, swift-concurrency-6-2, swift-protocol-di-testing, swiftui-patterns, tinystruct-patterns, ui-to-vue, vite-patterns, vue-patterns, windows-desktop-e2e.
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
- **Rationale:** A `SPEC.md` §8 named reject class ("dashboards"), widened to the third-party hosted surfaces that share its policy ground. 33 skills each requiring a named external account, API key, hosted endpoint or non-sanctioned MCP server: HR-1 on the accounts, HR-2 on MCP servers beyond Obsidian, Context7 and Claude Code, HR-6 on the network calls a shipped component would make. Members: agent-payment-x402, canary-watch, claude-devfleet, codehealth-mcp, council-multi-model, dashboard-builder, data-scraper-agent, deep-research, dmux-workflows, email-ops, exa-search, fal-ai-media, flox-environments, github-ops, google-workspace-ops, ito-compute, ito-inference, ito-training, jira-integration, knowledge-ops, laravel-plugin-discovery, mailtrap-email-integration, messages-ops, nasiko-control-plane, nutrient-document-processing, plankton-code-quality, project-flow-ops, repo-scan, social-publisher, uncloud, unified-notifications-ops, videodb, x-api.
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
- **Path:** skills/ (14 skills)
- **HR/axis trigger IDs:** `B-1..B-8`
- **Rationale:** 14 skills that are genuinely general but that no single Tier-1 plugin owns under B-1…B-8 — product discovery, API contract governance, paradigm-level architecture references, performance benchmarking, response-budget control, terminal launching. §9 rule 2 forbids shortlisting a component with no owner or two equally plausible owners. This class also absorbs the margin cut by the §10 Phase-3 deep-read cap; the cut is named in the Phase-3 preamble above rather than left implicit. Members: agentic-engineering, ai-first-engineering, api-connector-builder, benchmark, benchmark-optimization-loop, contract-first, data-throughput-accelerator, latency-critical-systems, product-capability, product-lens, regex-vs-llm-structured-text, security-bounty-hunter, terminal-opener, token-budget-advisor.
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
- **Rationale:** The shared engine behind the five `orch-*` wrappers (T-033). Every phase delegates to a named ECC agent or slash command — `code-explorer`, `planner`, `tdd-guide`, `code-reviewer`, security-reviewer,/feature-dev,/gan-build,rules/common/*.md — and to ECC's `rules/common/*.md`. Outside thatinstall it does nothing (dependencies 1), and no §4 plugin owns an orchestration engine bound to another marketplace's catalog. The blast-radius size classifier and the two human gates (after Plan, before Commit) re-donate.
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
- **Rationale:** `scan.sh`, `quick-diff.sh` and `save-results.sh` are the mandated Phase-1 and persistence steps and all three use `jq` unconditionally (dependencies 2). The results cache is written to ~/.claude/skills/skill-stocktake/results.json — inside another component's skill directoryrather than an owning plugin's data directory. Quick-Scan-versus-Full-Stocktake re-donates.
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
- **Rationale:** The shipped implementation, read at the pin. `plugin/hooks/hooks.json` registers seven command-handler entries across six lifecycle events (Setup, SessionStart ×2, UserPromptSubmit, PostToolUse, PreToolUse, Stop), each a bash one-liner that rewrites `PATH`, locates the plugin cache and runs `node scripts/bun-runner.js scripts/worker-service.cjs`. That worker is a per-user Express daemon on port `37700+(uid%100)` with a session manager, a process registry and a five-minute orphan reaper (**HR-4**). Storage is SQLite plus ChromaDB, and the package trusts `esbuild` and eleven tree-sitter native grammars while `engines` requires `bun` (**HR-5**). `plugin/.mcp.json` ships an `mcp-search` MCP server (**HR-2**). Dependencies include `posthog-node` (**HR-6**). `plugin/skills/cloud-sync` writes a cmem.ai Pro account token to `~/.claude-mem/settings.json` (**HR-1**). D-15 budgets one hook per plugin; this is seven, all command handlers, which D-24 bars. This is `eval/rubric.md` §7 Example A met in the field: the concept survives as `claude-mem/session-memory` and the file-based design in `eval/claude-mem-rebuild.md`; the implementation does not.
- **Date:** 2026-08-22


## 4. Statistics

Recomputed at each gate from the entries in §3, so the table can be checked against the file rather than trusted. The first four rows partition the entries by their trigger field under one stated precedence rule: an entry carrying **any** `HR-N` counts as hard-reject; otherwise any `axis:` trigger counts as axis-floor; otherwise a rule ID such as `B-1..B-8`, `D-15` or `D-24` counts as other-rule; `n/a` is its own row. 22 + 24 + 14 + 3 = 63.

| Metric | Count |
|---|---|
| Total entries | 63 |
| Hard-reject entries | 22 |
| Axis-floor entries | 24 |
| Other-rule entries | 14 |
| `n/a` entries | 3 |
| Bulk-reject classes | 9 |
| Gap-scan entries | 0 |
| Re-audit / re-pin entries | 3 |

The last three rows **overlap** the partition above and are not added to it: the nine bulk-reject classes are T-029…T-037, and seven of them also carry an `HR-N` or `axis:` trigger; the three re-audit entries are T-026…T-028.

Reconciliation with the v2.5 table, which read 28 / 12 / 7 / 0 / 0 / 3 after Phase 2: those numbers are unchanged under this rule. The Phase-2 entries still contribute 12 hard-reject and 7 axis-floor; the eight Phase-2 entries in the other-rule row are the six the paragraph below describes plus T-026 and T-027, which the v2.5 table counted only in the re-audit row.

The six Phase-2 entries counted in neither the hard-reject nor the axis-floor row are rejections on a rule that is neither an HR trigger nor an axis floor: five on `B-1..B-8` (no owning plugin exists, so `SPEC.md` §4 forbids shortlisting) and one on `D-15,D-24` (a hook whose dispatch and budget no plugin can carry). Their trigger-ID fields carry those rule IDs, which is what the §10 Phase-2 exit criterion checks.

The three re-audit entries (T-026…T-028) arose from the **G5 rehearsal review** of 2026-08-18: an independent reviewer, running the `eval/gate-review-protocol.md` standard against the artifacts and the pinned sources, returned `REJECTED` and named three defects the Phase-2 self-checks could not see, because all three were internally consistent and wrong about the source. None changed a verdict to `reject`, so the hard-reject and axis-floor counts are unchanged; T-027 moved a `merge` to `shortlist`, which is why the matrix read 27 / 25 / 3 at the end of Phase 2.

**Phase 3 (2026-08-22) added T-029…T-063**: nine bulk-reject classes covering 245 of ECC's 285 canonical skills plus its 41KB `hooks.json`, twenty-three individual rejects and two `merge` entries from the forty deep reads, and one reject for the shipped `thedotmack/claude-mem` implementation. `eval/matrix.csv` grew by 42 rows — 40 ECC (the §10 Phase-3 cap, which bound exactly) and 2 claude-mem — and now reads 97 rows, 43 shortlist / 49 reject / 5 merge.

The verdict vocabulary is `SPEC.md` §9 rule 3 — `shortlist`, `reject`, `merge`, `defer`. This log carries entries for `reject` (mandatory) and may carry them for `merge` and `defer` where the reasoning is worth preserving; `shortlist` rows need no entry.
