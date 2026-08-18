# DECISIONS.md — Architecture Decision Records

**Scope:** Formal record of every resolved architectural decision governing Awakened. ADR-001 through ADR-023 formalize the twenty-three decisions ratified in `SPEC.md` §12 (D-01…D-23), mirroring that table 1:1 as D-16 requires.

**Conventions**

- **IDs** are sequential and never reused. Next available: **ADR-024**.
- **Statuses:** `Proposed` → `Accepted` → (`Superseded by ADR-0NN` | `Deprecated`). Accepted ADRs are **immutable** — to change course, write a new ADR that supersedes the old one.
- **Format:** field table (Status, Date, Spec ref, Supersedes), Context, Decision, Alternatives Considered, Consequences, Enforcement.
- **Spec ref** cites the `D-NN` rule ID from `SPEC.md` §12, so the 1:1 mapping is mechanically checkable.
- An ADR **MUST NOT** supersede, override, or reclassify a `SPEC.md` cell (ADR-016). Deviating from any Accepted ADR without a superseding ADR is a policy violation (`CLAUDE.md` PD-4).

## Index

| ADR | Title | Status | Spec ref |
|---|---|---|---|
| 001 | Repository structure: multi-plugin marketplace monorepo | Accepted | D-01 |
| 002 | Distribution: GitHub repository only | Accepted | D-02 |
| 003 | Name: `awakened` under `coltonbearden/awakened` | Accepted | D-03 |
| 004 | Component priority: skills > commands > agents > hooks > rules/templates | Accepted | D-04 |
| 005 | Merge strategy: synthesize, don't clone | Accepted | D-05 |
| 006 | Audience: platform/language-agnostic general users | Accepted | D-06 |
| 007 | Risk policy: three-band model (hard reject / conditional / static review) | Accepted | D-07 |
| 008 | Licensing: MIT + SOURCES.md + NOTICE | Accepted | D-08 |
| 009 | Vetting: deep, phased audits with a human approval gate | Accepted | D-09 |
| 010 | Maintenance: pinned upstreams + monthly watch + dogfooded review | Accepted | D-10 |
| 011 | Lightweight definition: user-scope installable across all projects | Accepted | D-11 |
| 012 | Attribution mechanics: single SOURCES.md, no per-file headers | Accepted | D-12 |
| 013 | Naming system: two-tier, functional naming, plugin-level namespacing | Accepted | D-13 |
| 014 | Plugin cuts: `godspeed` and `nen` folded into existing plugins | Accepted | D-14 |
| 015 | Hooks budget: max one per plugin, load-bearing only | Accepted | D-15 |
| 016 | Spec change control: SPEC.md is canonical; changes land via PR + §14 row | Accepted | D-16 |
| 017 | Preset/plugin collision: Tier 2 preset IDs must not duplicate Tier 1 plugin names | Accepted | D-17 |
| 018 | Hook write scope: project directory or the owning plugin's data directory | Accepted | D-18 |
| 019 | Delivery staging: `[P6]` entries expected-absent at scaffold, required at release | Accepted | D-19 |
| 020 | Matrix provenance lives outside `matrix.csv`; the §9 header is immutable | Accepted | D-20 |
| 021 | Blocked-check verdict: §9 enum frozen; `defer` names a blocking check and a phase | Accepted | D-21 |
| 022 | C-1 scope: binds every hook regardless of handler type; `timeout` mandatory | Accepted | D-22 |
| 023 | `aura` statuslines: `plugins/aura/statuslines/`, `.sh`/`.ps1` twin pairs | Accepted | D-23 |

---

## ADR-001 — Repository Structure: Multi-Plugin Marketplace Monorepo

| Field | Value |
|---|---|
| Status | Accepted |
| Date | 2026-08-15 |
| Spec ref | D-01 |
| Supersedes | — |

**Context.** Awakened synthesizes capabilities from ten upstream repositories into nine plugins with strict responsibility boundaries. P-1 requires every plugin to be independently installable, testable, and removable. The official Claude Code plugin spec supports marketplace monorepos: a `.claude-plugin/marketplace.json` catalog at the root, with each plugin in `plugins/<name>/` carrying its own `.claude-plugin/plugin.json` manifest.

**Decision.** Awakened is a single multi-plugin marketplace monorepo, laid out exactly as `SPEC.md` §3 specifies: one marketplace catalog, nine plugin directories, shared `scripts/`, `schemas/`, `eval/`, `templates/`, `tests/`, and CI.

**Alternatives Considered.**

| Option | Verdict | Why |
|---|---|---|
| Single mega-plugin | Rejected | All-or-nothing install violates P-1; couples optional satellites (`poneglyph`, `aura`) to core; one bloated context surface |
| One repository per plugin | Rejected | Multiplies maintenance ×9 (upstream pinning, CI, validation, releases); fragments discovery; breaks the single `marketplace add` install story |
| Marketplace monorepo | **Accepted** | One add command, per-plugin install, shared validation/CI/upstream tooling, single audit trail |

**Consequences.**

- (+) One `claude plugin marketplace add coltonbearden/awakened`; users then install per plugin.
- (+) `upstream.json`, `scripts/validate.*`, and `.github/workflows/upstream-watch.yml` are written once and cover everything.
- (−) A monorepo makes cross-plugin coupling *easy*, so the B-1…B-8 boundary table must be actively enforced — satellites must never become core dependencies.

**Enforcement.** `scripts/validate.*` check S-group: the §3 layout is verified for every entry that exists at the current build phase; once Phase 6 lands, each plugin directory must carry exactly one `.claude-plugin/plugin.json`. PR review checks boundary compliance against B-1…B-8; `CONTRIBUTING.md` encodes both.

---

## ADR-002 — Distribution: GitHub Repository Only

| Field | Value |
|---|---|
| Status | Accepted |
| Date | 2026-08-15 |
| Spec ref | D-02 |
| Supersedes | — |

**Context.** Claude Code natively installs marketplaces from GitHub repos. Upstream `davila7/claude-code-templates` demonstrates the alternative — a heavy npm CLI installer with analytics — which collides directly with HR-6 (telemetry) and HR-7 (auto-installing packages).

**Decision.** Distribution is the GitHub repository only, consumed via `claude plugin marketplace add coltonbearden/awakened`. No installer, no registry, no website, no package publication.

**Alternatives Considered.**

| Option | Verdict | Why |
|---|---|---|
| npm CLI installer (davila7 pattern) | Rejected | Requires Node at install time; the reference implementation ships analytics; HR-6 and HR-7 both fire |
| Hosted registry / website | Rejected | External service to run and secure; contradicts the zero-infrastructure posture; adds nothing Claude Code needs |
| GitHub repo via native marketplace add | **Accepted** | Zero infrastructure; versioning rides git tags; trust surface is the repo itself |

**Consequences.**

- (+) Nothing to host, patch, or monitor; the install path is auditable because it is just the repo.
- (−) Discoverability is limited to GitHub search and community catalogs; accepted trade-off.

**Enforcement.** No publish scripts, registry package manifests, or installer binaries may enter the repo. `scripts/validate.*` check P4 fails on a `package.json` at repository root; PR review rejects any publish workflow.

---

## ADR-003 — Name: `awakened` Under `coltonbearden/awakened`

| Field | Value |
|---|---|
| Status | Accepted |
| Date | 2026-08-15 |
| Spec ref | D-03 |
| Supersedes | — |

**Context.** The marketplace needs a brand that fits the sci-fi/power-up/anime identity, types cleanly, and is legally safe. `SPEC.md` §2 records availability as verified on GitHub as of 2026-08-15: no colliding Claude marketplace or plugin repos. `awakened` is a generic dictionary word, so it carries none of the trademark exposure the themed plugin names manage under §7.

**Decision.** Marketplace name: `awakened`. Repository: `awakened`, canonical home `coltonbearden/awakened`, owner account `coltonbearden`. The v1 alternative `claude-awakened` is **retired** and is not to be reintroduced as a fallback, alias, or disambiguation option (§14 row 4).

**Alternatives Considered.**

| Option | Verdict | Why |
|---|---|---|
| `claude-awakened` | Rejected and retired | Redundant prefix — the add command already lives inside the `claude` CLI; longer for zero disambiguation gain |
| Full technique name (e.g. `ultra-instinct`) | Rejected | Reserved for Tier 2 aura presets by D-13; too long and too specific for the marketplace identity |
| `awakened` | **Accepted** | Verified available, on-brand, generic word, trademark-safe, short |

**Consequences.**

- (+) Trademark-safe root identity; clean install command.
- (−) A generic word invites future name collisions elsewhere; mitigated by the §2 availability verification and early repo creation.
- Per N-4, the marketplace name never becomes a command namespace: `/awakened:*` **MUST NOT** exist, because a plugin named `awakened` would be the catch-all that N-4 prohibits.

**Enforcement.** `marketplace.json`'s `name` field is `awakened`, schema-validated by `schemas/marketplace.schema.json`. `scripts/validate.*` check N4 fails on any plugin directory named `awakened` and on any command file whose namespace resolves to the marketplace name.

---

## ADR-004 — Component Priority: skills > commands > agents (curated) > hooks (minimal) > rules/templates

| Field | Value |
|---|---|
| Status | Accepted |
| Date | 2026-08-15 |
| Spec ref | D-04 |
| Supersedes | — |

**Context.** Component types differ sharply in transparency and blast radius. Skills auto-invoke via description matching and are plain instructions; commands run only when typed; agents act semi-autonomously with tool access; hooks execute automatically and invisibly. Upstream ECC's 41KB `hooks.json` is the cautionary example of automation-first design (§8).

**Decision.** Capability ships in the highest-priority form that can do the job: **skills first**, then commands, then curated agents, then minimal hooks, then rules/templates. Authoring a lower-priority form requires a written justification in the PR description for why the higher forms cannot deliver.

**Alternatives Considered.**

| Option | Verdict | Why |
|---|---|---|
| Automation-first (hooks/agents preferred) | Rejected | Hidden automation contradicts P-3; maximizes risk surface and audit cost |
| No stated priority (author's choice) | Rejected | Produces inconsistent plugins and unreviewable risk decisions |
| Explicit descending priority | **Accepted** | Transparency by default; risk concentrated where it can be budgeted (D-15) |

**Consequences.**

- (+) Most capability is inspectable text; the risky forms are rare, curated, and justified.
- (−) Some conveniences (ambient automation) are deliberately forgone; users type a command instead.

**Enforcement.** The PR checklist in `CONTRIBUTING.md` requires the justification for agents and hooks. `scripts/validate.*` check H1 counts hook files per plugin, and check B6 fails on an `agents/` directory in any plugin other than `bankai` (B-6).

---

## ADR-005 — Merge Strategy: Synthesize, Don't Clone

| Field | Value |
|---|---|
| Status | Accepted |
| Date | 2026-08-15 |
| Spec ref | D-05 |
| Supersedes | — |

**Context.** The ten sources vary in quality, size, and license (MIT, Apache-2.0, CC0 per §8). Importing files verbatim would import their bloat and risk verbatim, cap quality at upstream's level, and create derivative-work bookkeeping across licenses. P-6's stance: components are new implementations combining the best logic of multiple sources — never verbatim copies, never lesser-quality rewrites.

**Decision.** Every shipped component is synthesized: a new implementation informed by one or more sources, credited in `SOURCES.md`. Exactly one recorded exception — **EXC-1** — permits `poneglyph` to adapt `kepano/obsidian-skills` (MIT, 5 skills) near-verbatim, because upstream is already minimal, high quality, MIT-licensed, and scoped exactly to the plugin's purpose.

**Alternatives Considered.**

| Option | Verdict | Why |
|---|---|---|
| Vendor or fork files verbatim | Rejected | Imports upstream bloat and §6 violations wholesale; forces per-file license headers; quality ceiling equals upstream |
| Git submodules to upstreams | Rejected | No curation possible; users pull whatever upstream ships; violates the curated-marketplace premise |
| Naive rewrite for its own sake | Rejected | Explicitly barred by P-6 — "never lesser-quality rewrites"; synthesis must meet or beat the source |
| Synthesis with one recorded exception | **Accepted** | Best-of logic, clean licensing, quality floor set here rather than upstream |

**Consequences.**

- (+) Clear of derivative-work concerns while preserving quality (§7); every component fits §6 by construction.
- (+) Lineage is explicit: `SOURCES.md` maps every component to its informing repos.
- (−) Slower than copying; requires the Phases 2–5 evaluation machinery before any building.
- Apache-2.0-informed rebuilds (claude-mem concepts, anthropics/skills patterns) receive `NOTICE` entries where adaptation is close.

**Enforcement.** PR checklist requires a `SOURCES.md` entry for every new component; review compares against upstream for verbatim spans. `poneglyph` is the only directory exempt under EXC-1, and its exemption is itself documented in `SOURCES.md`.

---

## ADR-006 — Audience: Platform/Language-Agnostic General Users

| Field | Value |
|---|---|
| Status | Accepted |
| Date | 2026-08-15 |
| Spec ref | D-06 |
| Supersedes | — |

**Context.** Upstream ECC ships 22 language packs and language-specific tooling (§8); that model serves niches at the cost of user-scope safety. Awakened installs at user scope, so every component is present on *every* project the user opens — a single-language skill is dead weight, or worse noise, everywhere else.

**Decision.** The audience is the general Claude Code user on any platform, language, and stack. Every shipped component must provide value across arbitrary projects. Language packs, LSP integrations, and stack-specific tooling are out of scope at user level.

**Alternatives Considered.**

| Option | Verdict | Why |
|---|---|---|
| Serve language niches (ECC model) | Rejected | Violates P-2; multiplies audit surface; bloats every unrelated project's context |
| Split audience (general core + language add-ons) | Rejected | Reintroduces the language-pack maintenance treadmill under a different name |
| General users only | **Accepted** | One coherent quality bar; the User-scope fit axis becomes enforceable |

**Consequences.**

- (+) Every plugin is safe to leave installed permanently.
- (−) Legitimate language-specific value is deliberately left on the table; users source that elsewhere at project scope.

**Enforcement.** HR-3 hard-rejects LSP and language-specific tooling at user scope; the §9 rubric scores User-scope fit with a shortlist minimum of 3; Phase 2–4 audits reject on this axis regardless of other merits.

---

## ADR-007 — Risk Policy: Three-Band Model

| Field | Value |
|---|---|
| Status | Accepted |
| Date | 2026-08-15 |
| Spec ref | D-07 |
| Supersedes | — |

**Context.** Upstream material ranges from clean instruction files to 41KB hook configs, sqlite daemons, cloud sync, and analytics. Risk decisions made case-by-case without written policy are inconsistent and unauditable; trusting upstream is how the bloat and risk arrived in the originals.

**Decision.** Adopt `SPEC.md` §6's three-band model as the project's risk policy, without restating it here:

1. **Hard reject** — HR-1…HR-8. Automatic fail, overriding all rubric scores. HR-8's write-scope rule is read together with D-18 (ADR-018).
2. **Conditional** — C-1…C-3. Audited; kept only if every check passes.
3. **Static review, every component** — E-1, plus the mandatory `scripts/validate.*` pass required by E-2 before merge.

**Alternatives Considered.**

| Option | Verdict | Why |
|---|---|---|
| Trust upstream vetting | Rejected | Upstream is where the risk came from |
| Case-by-case judgment, no written bands | Rejected | Inconsistent, unauditable, unteachable to contributors |
| Written three-band policy with stable IDs | **Accepted** | Deterministic hard line, audited middle, universal floor — and every rejection cites an ID |

**Consequences.**

- (+) The rubric's Risk axis binds to a written policy; rejections are explainable and logged with rule IDs.
- (−) Some genuinely useful upstream capabilities (for example daemon-backed memory) are categorically excluded and must be redesigned file-based — see `rinnegan` and B-3.

**Enforcement.** `eval/rubric.md` and `eval/rubric.json` encode HR-1…HR-8 as hard-reject triggers; `eval/triage-log.md` records every rejection with its rule ID; `scripts/validate.*` P-group lints the mechanically detectable violations; PR static review covers the rest.

---

## ADR-008 — Licensing: MIT + SOURCES.md + NOTICE

| Field | Value |
|---|---|
| Status | Accepted |
| Date | 2026-08-15 |
| Spec ref | D-08 |
| Supersedes | — |

**Context.** Per `SPEC.md` §8 the sources are MIT (superpowers, mattpocock, ECC, wshobson, kepano, vercel-labs, davila7), Apache-2.0 (anthropics/skills, claude-mem), and CC0 (awesome-claude-code). Synthesis (D-05) keeps outputs original work, but close adaptations of Apache-2.0 material carry attribution and NOTICE expectations, and themed plugin names reference trademarked anime franchises.

**Decision.** Awakened is released under **MIT**. Attribution is centralized: `SOURCES.md` maps every component to its informing repo(s); `NOTICE` covers anything adapted closely from the Apache-2.0 sources. Plugin names may reference franchises per standard fan-project convention; franchise artwork and logos are prohibited everywhere in the repo and README. `awakened` itself is a generic word and fully safe.

License facts are those recorded in `SPEC.md` §8. They are re-verified against the live repositories at each pin (D-10); a discrepancy is corrected by a spec PR under D-16, never by an ADR overriding a §8 cell.

**Alternatives Considered.**

| Option | Verdict | Why |
|---|---|---|
| Apache-2.0 for the repo | Rejected | Heavier license with no benefit here; MIT matches the majority of sources and the project's posture |
| Per-file license headers | Rejected | Clutter and merge noise; superseded by centralized attribution (D-12) |
| MIT + SOURCES.md + NOTICE | **Accepted** | Simple for users, correct for Apache-2.0 adaptations, clean trademark posture |

**Consequences.**

- (+) One-file answers for "what license" (`LICENSE`) and "where did this come from" (`SOURCES.md`).
- (−) Discipline required: a close Apache-2.0 adaptation without a NOTICE entry is a compliance bug, so review must ask the question every time.

**Enforcement.** `LICENSE`, `NOTICE`, `SOURCES.md`, and `CONTRIBUTING.md` ship in the foundation. The PR checklist includes lineage and NOTICE assessment; repo review rejects any franchise imagery.

---

## ADR-009 — Vetting: Deep, Phased Audits With a Human Approval Gate

| Field | Value |
|---|---|
| Status | Accepted |
| Date | 2026-08-15 |
| Spec ref | D-09 |
| Supersedes | — |

**Context.** The candidate pool is large — `SPEC.md` §8 records ECC alone at roughly 95 commands, 70 agents, and 270 skills. Descriptions do not reveal injection patterns, hidden network calls, or bloat; only reading component bodies does. Bulk-importing and pruning later would put unvetted material in the tree.

**Decision.** Vetting is deep and phased per §10: Phase 2 reads every skill file in the four Tier-1 quality sources; Phase 3 triages ECC's skills to a shortlist of at most 40 rows for deep reading, plus extracts claude-mem concepts into `eval/claude-mem-rebuild.md`; Phase 4 covers the remaining sources; Phase 5 consolidates the full scored matrix and stops at a **mandatory human approval gate** before any building (Phase 6).

**Alternatives Considered.**

| Option | Verdict | Why |
|---|---|---|
| Bulk import, prune later | Rejected | Unvetted material enters the tree; curation debt compounds; §6 violations ship |
| Metadata-only scoring | Rejected | Injection patterns and bloat live in bodies, not descriptions |
| Deep phased audit plus a human gate | **Accepted** | Every shipped component has a read, a score, and a recorded rationale |

**Consequences.**

- (+) The `eval/` artifacts (rubric, matrix, triage log) form a complete audit trail.
- (−) Slow by design; building cannot start until Phase 5 sign-off.

**Enforcement.** `ROADMAP.md` defines per-phase verification criteria and gates G2–G6. Per §10 Phase 5, the human approval gate is recorded **as an ADR in this file** — the sign-off ADR is the authorization for Phase 6, and a `ROADMAP.md` gate-log row is a convenience index to it, not the record itself.

---

## ADR-010 — Maintenance: Pinned Upstreams + Monthly Watch + Dogfooded Review

| Field | Value |
|---|---|
| Status | Accepted |
| Date | 2026-08-15 |
| Spec ref | D-10 |
| Supersedes | — |

**Context.** Evaluations are only reproducible against fixed inputs, and upstreams keep moving. Chasing every upstream commit is unsustainable for a solo maintainer; ignoring upstream entirely lets improvements and fixes pass by.

**Decision.** `upstream.json` pins every source repo to a commit SHA. Per §8, SHAs are `null` at scaffold time and are resolved **only** by `scripts/pin-upstream.*` against live remotes — no SHA is ever typed from memory. `.github/workflows/upstream-watch.yml` runs monthly in CI: it diffs upstreams against pins and opens an issue summarizing changes worth re-evaluating. `instinct` dogfoods the process — its upstream-review skill evaluates those diffs using Claude Code itself. Releases are versioned via git tags with a `CHANGELOG.md` per plugin.

**Alternatives Considered.**

| Option | Verdict | Why |
|---|---|---|
| Track upstream HEAD continuously | Rejected | Non-reproducible evaluations; unbounded maintenance load |
| Never revisit upstreams | Rejected | Forfeits fixes and ideas; pins rot silently |
| Pin, monthly automated diff, curated re-evaluation | **Accepted** | Reproducibility with bounded, scheduled attention |

**Consequences.**

- (+) Every eval row references a known SHA; drift is detected on a schedule rather than chased.
- (+) The maintenance loop exercises the marketplace's own tooling (`instinct`).
- (−) Up to a month of latency on upstream changes; acceptable for a curated project.
- The pin script and the watch workflow are the sole sanctioned network users in this repository (HR-6). Neither is a shipped plugin component and neither ever runs on a user's machine.

**Enforcement.** `scripts/validate.*` check U1 fails if `upstream.json` does not contain exactly the ten repositories §8 names, and check U2 fails if a `commit` value is a non-null string while `pinned_at` is `null`. SHA changes land only via the pin script; re-pins that affect a prior evaluation get an `eval/triage-log.md` entry.

---

## ADR-011 — Lightweight Definition: User-Scope Installable Across All Projects

| Field | Value |
|---|---|
| Status | Accepted |
| Date | 2026-08-15 |
| Spec ref | D-11 |
| Supersedes | — |

**Context.** "Lightweight" is usually a vibe; here it needs teeth. The operative constraint is install scope: Awakened plugins live at user scope, present in every session on every project. Anything that only pays rent on some projects is bloat on all the others.

**Decision.** Lightweight is defined as **user-scope safe**: every component provides value across any project, language, and stack; nothing project-specific, language-specific, or LSP-dependent ships at user level; token and context overhead must be justified by payoff. One subtle case is clarified explicitly: `domain` installs at user scope but *generates* project-scoped artifacts into the active project. Generating project artifacts on demand is permitted; shipping project-specific tooling is not.

**Alternatives Considered.**

| Option | Verdict | Why |
|---|---|---|
| Lightweight equals small file sizes only | Rejected | Misses the real cost: irrelevant capability loaded into every session |
| Project-scope distribution instead | Rejected | Contradicts the product premise — install once, benefit everywhere |
| User-scope-fit definition | **Accepted** | Testable per component; becomes a rubric axis |

**Consequences.**

- (+) A crisp accept/reject question for every candidate: is it useful on an arbitrary project?
- (−) Excludes some high-value niche components; by design, see ADR-006.

**Enforcement.** The §9 rubric axes User-scope fit and Bloat, with a shortlist minimum of 3 on each; HR-3 for LSP and language tooling; Phase 2–4 audits apply it to every candidate.

---

## ADR-012 — Attribution Mechanics: Single SOURCES.md, No Per-File Headers

| Field | Value |
|---|---|
| Status | Accepted |
| Date | 2026-08-15 |
| Spec ref | D-12 |
| Supersedes | — |

**Context.** With synthesis (D-05), most files have multi-repo lineage; per-file headers would be long, noisy, and constantly wrong after edits. Attribution still must be complete and findable — both as license hygiene and as intellectual honesty toward the upstream authors.

**Decision.** Attribution is centralized in a single `SOURCES.md` mapping every component to the repo(s) that informed it; `CONTRIBUTING.md` makes the lineage entry a required part of every component PR. No per-file attribution headers anywhere in the tree.

**Alternatives Considered.**

| Option | Verdict | Why |
|---|---|---|
| Per-file headers | Rejected | Clutter, merge noise, drifts stale; misrepresents multi-source synthesis as single-source derivation |
| Git history as attribution | Rejected | Invisible to marketplace users; unreadable as a lineage map |
| Single SOURCES.md plus a CONTRIBUTING requirement | **Accepted** | One authoritative, reviewable lineage map |

**Consequences.**

- (+) Lineage answers live in one file; upstream authors are credited visibly.
- (−) `SOURCES.md` becomes release-blocking documentation — an unmapped shipped component is a violation of the Phase 6 exit criteria.

**Enforcement.** `SOURCES.md` ships in the foundation with a row per planned Tier-1 plugin; the PR checklist requires the entry; §10 Phase 6 verification includes "a `SOURCES.md` row exists for every shipped component."

---

## ADR-013 — Naming System: Two-Tier, Functional Naming, Plugin-Level Namespacing

| Field | Value |
|---|---|
| Status | Accepted |
| Date | 2026-08-15 |
| Spec ref | D-13 |
| Supersedes | — |

**Context.** The brand wants drama; the command line wants brevity. `/domain-expansion:map` loses to `/domain:map` every time it is typed, but the dramatic names are the identity. Meanwhile, skills auto-invoke on frontmatter `description` matching — a cleverly named, vaguely described skill never fires.

**Decision.** Adopt the `SPEC.md` §5 two-tier system in full:

- **Tier 1** — plugin names are concise ability words, typed often; the nine names are fixed in §5 (N-1). The v1 renames `domain-expansion` → `domain` and `ultra-instinct` → `instinct` stand.
- **Tier 2** — full dramatic technique names live only as `aura` preset identifiers, selected once in settings and never typed as commands (N-1). The statusline preset set is `power-level`, `transformation`, `barrier` — see ADR-017 for the `barrier` rename.
- **Functional naming rule** — plugin names carry theme; skill and command names carry function; descriptions carry explicit triggers (N-2). All machine-facing names are lowercase kebab-case (N-3).
- **Namespacing** — commands namespace under the plugin name. `/awakened:*` **MUST NOT** exist, because it would imply a catch-all plugin, which N-4 prohibits.
- **Future names** follow §5's Future Naming Logic: scope first, name second; technique names stay reserved for presets; reject vague, long, implementation-bound, or overlapping names (N-6).

**Alternatives Considered.**

| Option | Verdict | Why |
|---|---|---|
| Full dramatic names as plugins | Rejected | Typing cost on every command; the v1 experience proved it |
| Purely functional plugin names, no theme | Rejected | Discards the brand identity for no capability gain |
| Marketplace-level command namespace | Rejected | Implies a catch-all plugin, which N-4 prohibits |
| Two-tier split | **Accepted** | Drama where it is selected once; brevity where it is typed daily |

**Consequences.**

- (+) Short commands, intact brand, deterministic auto-invocation via functional descriptions.
- (−) Two name inventories to police; Tier 2 names must never leak into command space.

**Enforcement.** `scripts/validate.*` check N3 enforces the kebab-case regex case-sensitively on every machine-facing name; check N1 enforces the fixed Tier-1 name set; check N4 rejects `awakened` as a plugin or command namespace; `schemas/skill.schema.json` requires a trigger-bearing `description`.

---

## ADR-014 — Plugin Cuts: `godspeed` and `nen` Folded Into Existing Plugins

| Field | Value |
|---|---|
| Status | Accepted |
| Date | 2026-08-15 |
| Spec ref | D-14 |
| Supersedes | — |

**Context.** The v1 lineup included `godspeed` (session speed and parallelism) and `nen` (capability classification). Both failed the boundary test: their responsibilities already had owners, and thin plugins with overlapping scope create exactly the ambiguity the B-1…B-8 boundary table exists to prevent.

**Decision.** Both are cut from the lineup. Scope disposition:

| Cut plugin | Scope | New owner |
|---|---|---|
| `godspeed` | Session speed and momentum | `kaioken` (B-5) |
| `godspeed` | Parallel task planning | `bankai` (B-6), with superpowers' dispatching-parallel-agents lineage |
| `nen` | Capability classification, auditing, validation | `instinct` (B-7) |

The Tier-1 lineup is final at nine plugins — seven core and two optional satellites — for v1.

**Alternatives Considered.**

| Option | Verdict | Why |
|---|---|---|
| Keep both as thin plugins | Rejected | Scope overlap with kaioken/bankai/instinct; violates one-owner-per-responsibility |
| Merge into one "misc" plugin | Rejected | A catch-all by another name; prohibited posture (N-4) |
| Fold scope into existing owners | **Accepted** | Boundaries stay crisp; no capability lost |

**Consequences.**

- (+) A nine-plugin lineup with a clean boundary table; fewer manifests to maintain.
- (−) The names `godspeed` and `nen` return to the future-name pool only via a new ADR with defined scope per §5.

**Enforcement.** B-1…B-8 is the arbiter for all future scope disputes; `scripts/validate.*` check N1 holds the plugin-name set to the nine in §5, which excludes the cut names; reintroduction requires a superseding ADR.

---

## ADR-015 — Hooks Budget: Max One Per Plugin, Load-Bearing Only

| Field | Value |
|---|---|
| Status | Accepted |
| Date | 2026-08-15 |
| Spec ref | D-15 |
| Supersedes | — |

**Context.** Hooks are the highest-risk component class: they execute automatically, invisibly, and — upstream — often expansively. ECC's 41KB `hooks.json` is the anti-pattern on record (§8). Yet two capabilities genuinely need a hook to exist at all: injecting skill discipline at session start (superpowers' proven pattern) and capturing memory as sessions run.

**Decision.** Hard budget: **maximum one hook per plugin, only where load-bearing.** The complete v1 hook budget, per §6:

| Plugin | Hook | Notes |
|---|---|---|
| `super-saiyan` | Session-start skill-discipline injector | superpowers lineage |
| `rinnegan` | Memory-capture (optional) | Rebuilt lightweight — no workers, no daemons |

Everything else ships as skills and commands. Every hook must pass C-1 in full and write only within the D-18 scope (ADR-018). Repo standard timeout: ≤ 10 seconds wall clock, declared explicitly. A failing hook logs and never blocks the session.

**Alternatives Considered.**

| Option | Verdict | Why |
|---|---|---|
| No hooks at all | Rejected | Session-start discipline injection and passive memory capture cannot be typed commands by nature |
| Uncapped hooks with review | Rejected | Review without a budget drifts; the upstream evidence is conclusive |
| Budget of one per plugin, enumerated | **Accepted** | Risk is countable, auditable, and justified per hook |

**Consequences.**

- (+) The entire automatic-execution surface of the marketplace is two enumerated hooks.
- (−) Capabilities that would be "nicer" as hooks ship as explicit commands instead; accepted per ADR-004.

**Enforcement.** `scripts/validate.*` check H1 counts hook files per plugin and fails above one; check H2 fails if any plugin outside `super-saiyan` and `rinnegan` ships a hook; check H3 requires a declared `timeout`. Adding a third budgeted hook requires a superseding ADR **and** a `SPEC.md` §6 amendment; `templates/hook.json` embeds the safety checklist.

---

## ADR-016 — Spec Change Control: SPEC.md Is Canonical

| Field | Value |
|---|---|
| Status | Accepted |
| Date | 2026-08-15 |
| Spec ref | D-16 |
| Supersedes | — |

**Context.** Awakened's governance depends on there being exactly one normative document. During foundation work a competing pattern emerged: recording corrections to `SPEC.md` in subordinate artifacts (ADRs, `upstream.json`) and treating the spec's own cells as "superseded facts". That inverts precedence — `CLAUDE.md` §1 ranks `SPEC.md` above `DECISIONS.md` — and produces a repository where the authoritative value of any given fact depends on which file you read last.

**Decision.** `SPEC.md` at repository root is canonical and ships verbatim; no other document restates its normative content, only references it. Every change to the spec lands as a PR that (a) edits `SPEC.md` itself and (b) appends a row to the §14 changelog. `DECISIONS.md` mirrors §12 one-to-one: ADR-0NN ↔ D-NN, no gaps, no reuse, no ADR occupying an ID whose §12 row says something else. An ADR **MUST NOT** supersede, override, or reclassify a `SPEC.md` cell; where an ADR would need to, the change goes through the spec PR instead.

**Alternatives Considered.**

| Option | Verdict | Why |
|---|---|---|
| Corrections via ADR plus operational data files | Rejected | Inverts document precedence; readers of §8 must know to look elsewhere; splits the source of truth |
| Freeze SPEC.md entirely | Rejected | The spec must evolve; §14 exists precisely to version that evolution |
| Spec PR plus §14 changelog row, ADRs mirror §12 | **Accepted** | One source of truth, one audit trail, mechanically checkable ADR/decision parity |

**Consequences.**

- (+) "What is true?" always has one answer: `SPEC.md` at the ratified version.
- (+) ADR/decision parity is mechanically checkable — the validator counts ADRs and matches `Spec ref` fields against §12.
- (−) Correcting an external fact, such as an upstream license, costs a spec PR rather than an ADR. Accepted: that cost is the control.

**Enforcement.** `scripts/validate.*` check D1 asserts `SPEC.md` is present at root and carries the governing version string; check D2 asserts `DECISIONS.md` contains exactly 18 `## ADR-` headings whose `Spec ref` fields cover D-01…D-18 without duplication. *(Amended 2026-08-16 by ADR-019…ADR-023 / SPEC v2.2 §14: check D2 now asserts exactly 23 ADR headings covering D-01…D-23.)* PR review rejects any ADR whose `Supersedes` field names a `SPEC.md` section.

---

## ADR-017 — Preset/Plugin Collision: Tier 2 IDs Must Not Duplicate Tier 1 Names

| Field | Value |
|---|---|
| Status | Accepted |
| Date | 2026-08-15 |
| Spec ref | D-17 |
| Supersedes | — |

**Context.** The two-tier naming system (D-13) puts short ability words in Tier 1 (plugins, typed constantly) and full dramatic technique names in Tier 2 (`aura` presets, selected once in settings). The v1 statusline preset list included one named `domain` — identical to the Tier 1 plugin `domain`. A single token then means two different things depending on context: `/domain:map` addresses the plugin, `/aura:equip domain` addresses the statusline preset. Tooling that resolves names across both inventories cannot disambiguate, and the validator's kebab-case and name-set checks would pass a colliding pair silently.

**Decision.** Tier 2 preset identifiers **MUST NOT** duplicate any Tier 1 plugin name. The colliding statusline preset `domain` is renamed **`barrier`** — it reports active project context and rules status, and "barrier" carries the domain-expansion imagery without consuming the plugin's token. The full statusline preset set is `power-level`, `transformation`, `barrier`. Palette presets are unaffected: `ultra-instinct`, `super-saiyan`, `domain-expansion`, `gear-fifth`, `six-eyes`, `bankai` — note that `super-saiyan` and `bankai` *do* duplicate Tier 1 names and are grandfathered by the §5 palette table, which N-5 does not reach; a future ADR should close that residue.

**Alternatives Considered.**

| Option | Verdict | Why |
|---|---|---|
| Namespace presets (`aura/domain`) | Rejected | Presets are typed once at `/aura:equip`; a namespace prefix adds friction and does not remove the ambiguity in settings files |
| Rename the plugin instead | Rejected | `domain` is Tier 1, typed daily, and fixed by D-13/ADR-013; the preset is the cheaper thing to move |
| Rename the preset to `barrier` | **Accepted** | Zero cost — presets are selected once — and the name describes what the statusline shows |

**Consequences.**

- (+) Every identifier resolves to exactly one thing; name-resolution tooling stays simple.
- (+) `barrier` describes the behavior better than `domain` did.
- (−) Two name inventories must still be policed against each other on every addition.

**Enforcement.** `scripts/validate.*` check N5 intersects the Tier 2 statusline preset ID set against the nine Tier 1 plugin names and fails (exit class 1) on any non-empty intersection outside the grandfathered palette entries. `aura`'s preset directory names are the checked surface.

---

## ADR-018 — Hook Write Scope: Project Directory or the Owning Plugin's Data Directory

| Field | Value |
|---|---|
| Status | Accepted |
| Date | 2026-08-15 |
| Spec ref | D-18 |
| Supersedes | — |

**Context.** HR-8 originally rejected any hook writing outside the project directory, while C-3 permitted writes to "explicit user-approved locations". Read strictly together, the pair made `rinnegan`'s memory-capture hook impossible: session memory that must survive across projects cannot live inside one project's directory, yet writing anywhere else tripped HR-8. The contradiction was load-bearing — it blocked a budgeted hook (D-15) that the plugin's core promise depends on.

**Decision.** Hooks may write to exactly two classes of location: (a) the active project directory, and (b) the owning plugin's own data directory under the user's Claude configuration directory. Any other write target is rejected under HR-8. The plugin data directory is scoped per plugin — `rinnegan` may not write into another plugin's data directory — and remains subject to every C-1 requirement: idempotent, read-only by default, timeout-bounded, cross-platform. This carve-out is the *only* relaxation of HR-8; it does not license writes to the user's home directory generally, to global Claude settings, or to any path outside the two named classes.

**Alternatives Considered.**

| Option | Verdict | Why |
|---|---|---|
| Keep HR-8 absolute; drop the rinnegan hook | Rejected | Removes a load-bearing capability that motivated the plugin; the concept survives but the promise does not |
| Permit any user-approved location | Rejected | "User-approved" is not mechanically checkable; HR-8's value is that it is a bright line |
| Two named classes: project dir plus owning plugin data dir | **Accepted** | Preserves the bright line, is mechanically checkable, and unblocks exactly one capability |

**Consequences.**

- (+) `rinnegan`'s file-based memory is legal without weakening HR-8 into a judgment call.
- (+) The permitted set is enumerable, so `scripts/validate.*` can check write targets by prefix.
- (−) Every restatement of HR-8 in subordinate docs must carry the carve-out or it re-creates the contradiction; documentation drift here is a policy bug, not a typo.

**Enforcement.** `scripts/validate.*` check P3 scans hook command strings and any referenced hook scripts for write operations whose target resolves outside the project directory or the plugin's data directory, failing at exit class 1. Every document restating HR-8 must reproduce the carve-out.

---

## ADR-019 — Delivery Staging: `[P6]` Entries Expected-Absent at Scaffold, Required at Release

| Field | Value |
|---|---|
| Status | Accepted |
| Date | 2026-08-16 |
| Spec ref | D-19 |
| Supersedes | — |

**Context.** `SPEC.md` §3 lists the complete shipped tree, while the foundation scaffold delivers a subset: `.claude-plugin/marketplace.json`, the nine `plugins/<name>/` contents and manifests, `tests/`, and `.github/workflows/upstream-watch.yml` are all assigned to Phase 6 by §10. Read literally, §3 made the scaffold non-conformant from its first commit, and every coverage audit re-litigated the same four entry classes. The synthesis pass applied the safest reading provisionally — expected-absent at scaffold, required at release — left a provisional marker citing A-GAP-001 / B-GAP-001 in `CLAUDE.md` §2, `ROADMAP.md` §9 and both validator headers, and escalated it as HD-1. That provisional reading is what let `scripts/validate.*` exit 0 at all.

**Decision.** §3 now carries the stage on the entry itself: entries tagged `[P6]` are Phase-6 deliverables and are expected-absent at scaffold stage; untagged entries are scaffold-stage and required from the first commit. Validators **MUST** treat `[P6]` entries as expected-absent by default and as required under `--release` (bash) / `-Release` (PowerShell). This ratifies synthesis DEVIATION-001 — the release-flag deviation — as spec rather than as a validator liberty, and resolves A-GAP-001 and B-GAP-001.

**Alternatives Considered.**

| Option | Verdict | Why |
|---|---|---|
| Add a stage column beside the §3 tree | Rejected | §3 is a code-fenced tree, not a table; a parallel column would duplicate the tree and drift from it |
| Keep the classification in `CLAUDE.md` only | Rejected | A subordinate document would be silently amending §3, which D-16 forbids, and the contradiction stays live in the normative text |
| Drop release-mode strictness and always tolerate absence | Rejected | Phase 6 would then have no mechanical completion check and `ROADMAP.md` V6.1 would be unenforceable |
| Tag the entries `[P6]` in §3, split validator behavior by flag | **Accepted** | The stage lives on the entry it describes, the normative text is true at every stage, and one flag separates "correct today" from "correct at release" |

**Consequences.**

- (+) §3 is accurate at scaffold stage and at release, so a coverage audit no longer reconciles §3 against §10 by hand.
- (+) The validators' leniency is a spec-mandated behavior with a named flag, not an undocumented allowance.
- (+) `ROADMAP.md` §9's deferred-items table becomes a mirror of §3 rather than an independent reading of it.
- (−) Two validation modes must both be kept green; a check added to only one mode is a parity bug that a default-mode run will not catch.
- (−) Every new §3 entry now carries a tagging decision, and an untagged Phase-6 entry fails the scaffold run rather than waiting for release.

**Enforcement.** `SPEC.md` §3's delivery-staging paragraph is the normative statement. `scripts/validate.*` check S3 enumerates the `[P6]` entries and the per-plugin manifests, reporting them `INFO` when absent in scaffold mode and `ERROR` at exit class 1 when absent under `--release` / `-Release`; the active mode is announced in the run banner. `ROADMAP.md` V6.1 is where their absence stops being acceptable.

---

## ADR-020 — Matrix Provenance Lives Outside `matrix.csv`

| Field | Value |
|---|---|
| Status | Accepted |
| Date | 2026-08-16 |
| Spec ref | D-20 |
| Supersedes | — |

**Context.** `SPEC.md` §9 fixes a byte-exact `eval/matrix.csv` header with no column for the pinned SHA a row was read at, nor for the auditor or the date — yet §10 Phase 2 scores components at pinned state and `ROADMAP.md` V2.7 requires re-pins to be traceable. Audits had nowhere spec-sanctioned to record what a row was read against. The synthesis pass applied the reading that the header stays byte-exact and provenance lives elsewhere, left a provisional marker citing A-GAP-002 in `eval/rubric.md` §1, and escalated it as HD-2 with three options: extend the header via a §14 row, declare provenance external, or add a companion provenance file.

**Decision.** Provenance lives outside the matrix. The pin state of record is `upstream.json.pinned_at` at scoring time, together with the `repos[].commit` values; per-component provenance notes — auditor, date, the SHA a re-audit was read at, and the reason for re-auditing — go in `eval/triage-log.md`, which is the append-only surface. The §9 header is immutable and **MUST NOT** gain provenance columns. Resolves A-GAP-002.

**Alternatives Considered.**

| Option | Verdict | Why |
|---|---|---|
| Extend the §9 header with SHA, auditor and date columns | Rejected | Invalidates every row written against the byte-exact header and turns a stable contract into a moving one |
| Add a companion `eval/provenance.csv` | Rejected | A third file to keep in sync with two others; `eval/triage-log.md` already exists for exactly this narrative |
| Carry provenance in the `rationale` free-text column | Rejected | Unparseable, and it competes for space with the scoring justification the column exists for |
| Pin state in `upstream.json`, notes in `eval/triage-log.md` | **Accepted** | Both files already exist, both are already required by §8 and §10, and neither touches the frozen header |

**Consequences.**

- (+) `eval/matrix.csv` keeps a byte-exact header that check M1 compares literally, so header drift is a one-line failure rather than a schema negotiation.
- (+) The matrix stays "current state" and the triage log stays "history", which is what `ROADMAP.md` V5.2's duplicate-ID check already assumes.
- (+) A re-audit is reconstructable: `pinned_at` says what the tree was pinned to, the triage-log entry says what changed and why.
- (−) Reconstructing one row's provenance requires reading two files; the matrix alone cannot answer "what SHA was this scored at".
- (−) The discipline is documentary, not mechanical — no validator check can prove a triage-log entry was written for a given re-audit.

**Enforcement.** `SPEC.md` §9 rule 4 is the normative statement. Header immutability is enforced by `scripts/validate.*` check M1, which compares `eval/matrix.csv`'s header byte-for-byte against the §9 normative line and fails at exit class 1 on any difference, an added provenance column included. Check U2 asserts `upstream.json` pin coherence so `pinned_at` is meaningful when a row cites it. `eval/rubric.md` §1 carries the audit-time restatement.

---

## ADR-021 — Blocked-Check Verdict: The §9 Enum Is Frozen and `defer` Names Its Blocker

| Field | Value |
|---|---|
| Status | Accepted |
| Date | 2026-08-16 |
| Spec ref | D-21 |
| Supersedes | — |

**Context.** Some C-1…C-3 checks — idempotence, timeout behavior, real cross-platform execution — cannot be settled from a static read of an upstream file, yet §10 Phase 5 demands zero empty `verdict` cells before the human approval gate. §9's enum offered no value meaning "audited; blocked on a named check", so an auditor's only honest options were to reject a component that had not actually failed, or to leave the cell empty and stall Phase 5. Audit Set A proposed adding a `hold` value; the synthesis pass declined to invent an enum value, used `defer` with a mandatory named phase, left a provisional marker citing A-GAP-003 in `eval/rubric.md` §4, and escalated it as HD-3.

**Decision.** The §9 verdict enum is frozen at `shortlist` | `reject` | `merge` | `defer`; `hold` is not adopted. A `defer` **MUST** name the blocking check ID — C-1 idempotence, for example — and the phase where it resolves. A named `defer` satisfies Phase 5's zero-empty-verdict rule, but the Phase 5 sign-off ADR **MUST** enumerate every open `defer`, so nothing reaches the approval gate as an unexamined deferral. Resolves A-GAP-003.

**Alternatives Considered.**

| Option | Verdict | Why |
|---|---|---|
| Add `hold` to the §9 enum | Rejected | A fifth value with semantics nearly identical to a named `defer`, widening the enum permanently to describe a temporary state |
| Reject anything not statically verifiable | Rejected | Writes a non-rejection into the triage log as a rejection and discards components that would pass a runtime check |
| Allow an empty `verdict` until the blocking check runs | Rejected | Directly contradicts §10 Phase 5's exit criterion and hides the backlog from the approval gate |
| Freeze the enum; require `defer` to name a check and a phase | **Accepted** | Uses the existing value, makes the block explicit and addressable, and forces every open deferral onto the sign-off ADR |

**Consequences.**

- (+) The enum is stable, so `matrix.csv` row lint stays a fixed-set membership test rather than a versioned one.
- (+) Every `defer` is actionable: it names what blocks it and when that clears, instead of meaning "not sure yet".
- (+) The Phase 5 approval gate sees the complete deferral backlog, so an approval cannot silently absorb unresolved checks.
- (−) The Phase 5 sign-off ADR grows with the number of open defers and must be reissued if any resolve after it is written.
- (−) `defer` now carries two readings in the corpus — "blocked on a named check" and "revisit in a later phase" — separable only by whether a check ID is present in the `rationale`.

**Enforcement.** `SPEC.md` §9 rule 3 is the normative statement; `eval/rubric.md` §4 is the audit-time restatement. `scripts/validate.*` check M2 lints each `eval/matrix.csv` row's `verdict` against the frozen enum and fails at exit class 1 on any other value, so an invented value cannot reach the matrix. The named-check and named-phase requirements are enforced at review time against the row's `rationale`, and at Phase 5 by the sign-off ADR's enumeration.

---

## ADR-022 — C-1 Binds Every Hook Regardless of Handler Type

| Field | Value |
|---|---|
| Status | Accepted |
| Date | 2026-08-16 |
| Spec ref | D-22 |
| Supersedes | — |

**Context.** C-1's v2.1 text was scoped to hooks "executing shell commands", but the repository's budgeted session-start hook ships a `prompt` handler, which executes no shell. Read literally, C-1's idempotence, read-only-by-default and timeout requirements did not reach it — so the one hook the scaffold actually ships was the one hook C-1 did not govern. `templates/hook.json` nonetheless declares `timeout: 5` and validator check H3 requires a timeout on every hook entry, leaving the template and the validator stricter than the rule they implement. The synthesis pass applied the safest reading — C-1 binds every hook — left a provisional marker citing A-GAP-005 in `CLAUDE.md` §6.4, and escalated it as HD-4.

**Decision.** C-1 binds every hook regardless of handler type: shell, prompt, or other. Every hook **MUST** be idempotent, read-only by default, and timeout-bounded, and a populated `timeout` field is mandatory on every hook entry. One clause stays handler-specific: hooks executing shell commands **MUST** additionally be cross-platform (Windows 11 PowerShell 7 + WSL2 bash), because a prompt handler has no shell to be incompatible with. Resolves A-GAP-005.

**Alternatives Considered.**

| Option | Verdict | Why |
|---|---|---|
| Leave C-1 scoped to shell-command hooks | Rejected | Leaves the shipped prompt hook ungoverned and puts `templates/hook.json` and check H3 ahead of the spec they implement |
| Extend all of C-1, cross-platform included, to every hook | Rejected | "Cross-platform" is meaningless for a handler that never invokes a shell; the requirement would be unfalsifiable |
| Write a separate conditional for prompt handlers | Rejected | Duplicates three of four clauses and creates a second place for the rule to drift |
| Bind all of C-1 to every hook; keep cross-platform additive for shell handlers | **Accepted** | One rule covers every handler type, and the only platform-specific clause stays attached to the only handler type it can describe |

**Consequences.**

- (+) A prompt-only hook is unambiguously subject to the timeout budget, so check H3 enforces the spec rather than exceeding it.
- (+) `templates/hook.json`'s `timeout: 5` is spec-backed rather than a template convention.
- (+) A new handler type added later inherits C-1 automatically; no rule has to be re-scoped to reach it.
- (−) Timeout semantics for non-shell handlers are required without a spec-level definition of what is being timed; the repo standard of ≤ 10 seconds wall clock fills that gap operationally, not normatively.
- (−) Every restatement of C-1 in a subordinate document must now carry the handler-type split, or it re-creates the ambiguity this ADR closed.

**Enforcement.** `SPEC.md` §6 C-1 is the normative statement. `scripts/validate.*` check H3 asserts that every hook entry, of any handler type, declares a `timeout`, failing at exit class 1 otherwise; checks H1 and H2 hold the D-15 budget alongside it. The idempotence and read-only-by-default clauses are not statically decidable and are enforced by the §7 static review at PR time. `CLAUDE.md` §6.4 carries the operational restatement including the handler-type split.

---

## ADR-023 — `aura` Statuslines Get a Home in §3 as `.sh`/`.ps1` Twin Pairs

| Field | Value |
|---|---|
| Status | Accepted |
| Date | 2026-08-16 |
| Spec ref | D-23 |
| Supersedes | — |

**Context.** §5 states that `aura` "ships as statusline scripts with ANSI palettes", but §3's per-plugin layout offered only `commands/`, `agents/`, `skills/`, and `hooks/`. `aura` therefore could not be scaffolded without violating one section or the other: place the scripts anywhere and §3 is contradicted, omit them and §5 is. The synthesis pass recorded this as A-GAP-006 and escalated it as HD-6 — advisory rather than blocking, because `CLAUDE.md` §5.5 already permitted the script pairs and validator check N5 already read preset IDs from a `statuslines/` directory. No §3 amendment was made at that time and, unlike the other decisions ratified in v2.2, no provisional marker was ever emitted for it.

**Decision.** `statuslines/` is added to §3's per-plugin layout, scoped to `aura` only. Preset scripts ship at `plugins/aura/statuslines/` as `.sh`/`.ps1` twin pairs, and the cross-platform pairing rule applies to them exactly as it does to repo-root `scripts/` — identical inputs, outputs, side effects, and exit codes, with behavioral drift between twins treated as a bug rather than a variant. Resolves A-GAP-006.

**Alternatives Considered.**

| Option | Verdict | Why |
|---|---|---|
| Place them under `plugins/aura/scripts/` | Rejected | Invents a second general-purpose directory in the per-plugin layout for one plugin's need, and collides conceptually with repo-root `scripts/` |
| Ship presets as data files consumed by a shared runner | Rejected | The statusline contract takes an executable; a runner adds indirection and the kind of dependency P-5 resists |
| Leave the layout silent and rely on `CLAUDE.md` §5.5 | Rejected | A subordinate document would again be amending §3, which D-16 forbids, and the §3/§5 contradiction stays live |
| Add `statuslines/`, aura-scoped, as `.sh`/`.ps1` pairs | **Accepted** | Closes the contradiction in the normative text, matches what the validators already do, and reuses the pairing rule already in force |

**Consequences.**

- (+) `aura` can be scaffolded without violating §3 or §5, and the directory the validator already reads is now the one the spec names.
- (+) Statusline presets inherit the twin-pair discipline, so a preset that works under WSL2 cannot silently be missing on Windows 11.
- (+) Scoping to `aura` keeps the per-plugin layout minimal — no other plugin gains a `statuslines/` directory by default.
- (−) `aura` becomes the one plugin shipping executable content, so P-5's zero-dependency rule and HR-5/HR-7's no-compiled-code rules must be re-checked against it specifically at every review.
- (−) Every preset costs two files instead of one, and a drifted pair is a defect the validators cannot fully detect from a static read.

**Enforcement.** `SPEC.md` §3's per-plugin tree names `statuslines/` as aura-only, and §5's implementation note states the twin-pair requirement. `scripts/validate.*` check N5 reads Tier-2 statusline preset IDs from `plugins/aura/statuslines/` and fails at exit class 1 if any collides with a Tier-1 plugin name (N-5, D-17); check L1 holds LF and no-BOM over the script pairs. The `.sh`/`.ps1` pairing itself is enforced at review time under `CLAUDE.md` §3.2, exactly as for repo-root `scripts/`.

---

## Prompt-Review Log — 2026-08-16 (claude.ai closure prompt)

**Status:** Review only. No code, spec, or governance file was changed by this review, and
nothing was committed, pushed, or filed. This section is a record, not a decision — it
deliberately carries no ADR heading and no spec-ref row, because check D2 requires
`DECISIONS.md` to hold exactly twenty-three ADR headings mapping 1:1 onto D-01…D-23.

**Subject.** An autonomous five-phase "closure run" prompt authored by claude.ai (web
chat) for this repository: fix a PowerShell UNC defect, `git init` and push to a new
private GitHub repo, file a backlog issue, then pin upstream SHAs and verify licenses. The
prompt was written without filesystem or network access, so every claim in it was an
assertion. This log records the result of checking those assertions against the real tree,
the real validators, and the live GitHub API before the prompt is executed.

**Method.** Validators executed on both legs (WSL2 bash; Windows PowerShell 7 over
`\\wsl.localhost` via WSL interop). The proposed PowerShell fix was applied to a scratchpad
copy of the tree and run under UNC; `04-master` itself was not modified. GitHub facts come
from `gh api` against the live repositories.

### 1. Claims verified as accurate

| Claim under review | Finding |
|---|---|
| Defect site is the `ReadAllBytes` / `Resolve-Path` expression at check M1 | Accurate — `scripts/validate.ps1:455` |
| The crash is a provider-qualified path rejected by .NET under UNC | Reproduced verbatim: `Exception calling "ReadAllBytes"… '\\wsl.localhost\…\04-master\Microsoft.PowerShell.Core\FileSystem::\wsl.localhost\…\eval\matrix.csv'`. The run aborts at M1 with exit 1; every check from M1 through L1 was therefore unproven on Windows before this review |
| The prescribed `Join-Path $Root` fix is correct | Confirmed and proven. `$Root` derives from `$PSCommandPath`, not from `Resolve-Path`, so it is never provider-qualified. A patched copy ran the complete check list under UNC: `0 error(s), 0 warning(s)`, `VALIDATE: PASS`, exit 0. (`.ProviderPath` in place of `.Path` is an equally valid fix; `Join-Path` was retained) |
| Exactly one site needs the change | Confirmed. Every `[System.IO.*]` and `Resolve-Path` occurrence in the file was audited; line 455 is the only .NET IO call fed a non-`$Root`-anchored path. All others receive `$f.FullName` or `$Root` |
| The two validators' numbered check lists are identical | Confirmed — both extract to a byte-identical 27-entry list |
| The bash leg is green before any change | Confirmed — `VALIDATE: PASS`, exit 0 |
| Running `validate.ps1` from `\\wsl.localhost` needs `-ExecutionPolicy Bypass` | Confirmed. Without it: `SecurityError: …validate.ps1 cannot be loaded… is not digitally signed`, exit 1. Effective policy is `RemoteSigned` at both CurrentUser and LocalMachine |
| bash check D2 omits a heading-set test the PowerShell twin covers | Real divergence. The bash OK-branch fires on heading *count* plus the spec-ref set, dropping the `sorted(heads) == expected_adr` comparison; the PowerShell twin gates the same OK on all three tests via `$d2Bad`. A file with twenty-three headings that are not exactly ADR-001…ADR-023 emits both an error line and an OK line on bash |
| check P3 is anchored on bash and unanchored on PowerShell | Real divergence, and the PowerShell side is the permissive one. bash matches allowed prefixes with an anchored `re.match`; PowerShell uses `-cmatch`, which searches anywhere in the string. A write target of `../../etc/passwd` is correctly rejected on bash and silently allowed on Windows, because the `\./` allow-pattern occurs inside `../` |
| Repository state permits the ship phase | Confirmed. No git repository exists at `04-master`; `coltonbearden/awakened` does not exist on GitHub; `gh` is authenticated with `coltonbearden` active; `git config user.name` and `user.email` are both set |
| The advisory Human Decisions cited for the backlog issue exist | Confirmed — HD-7, HD-8, HD-11, HD-12 are all present and all classified Advisory |

A third P3 divergence was found that the prompt does not mention: the bash twin lints a
JSON round-trip of each hook file while the PowerShell twin lints the raw file text, so the
two search different strings for the same rule. It belongs in the same backlog issue.

### 2. Deviations found

**DEV-1 — the license phase hits a hard API error, and it lands after the irreversible
steps.** `gh api repos/anthropics/skills/license` returns HTTP 404: that repository
declares no root license, so the endpoint has nothing to return. The prompt exempts only a
*value mismatch* from its halt rule; a command error falls under its blanket "on any gate
failure, HALT". A literal executor therefore stops after the repository has been created,
pushed, and issued — but before the pin commit — leaving a rewritten `upstream.json`
uncommitted on disk. This is the one defect that can strand the run. The phase must be
instructed to record an undetectable license as `NONE` and continue.

**DEV-2 — the license re-verification contradicts SPEC section 8 in two rows, and both
previously rejected upstream corrections turn out to have been right.** HD-10 recorded two
license claims that contradicted section 8 — a CC-BY-NC-ND assertion against section 8's
CC0, and a per-skill split for `anthropics/skills` — declined them as unsourced, and
directed that licenses be re-verified at the first pin. This is that re-verification.

| Repository | Section 8 and upstream.json | Verified at HEAD | Verdict |
|---|---|---|---|
| hesreallyhim/awesome-claude-code | CC0 | GitHub reports `NOASSERTION`; the `LICENSE` file reads "licensed under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International" | MISMATCH |
| anthropics/skills | Apache-2.0 | No root license (API 404). Sixteen per-skill `LICENSE.txt` files: twelve Apache-2.0, four proprietary — `pdf`, `pptx`, `xlsx`, `docx` carry "© 2025 Anthropic, PBC. All rights reserved" | MISMATCH |
| obra/superpowers, mattpocock/skills, affaan-m/ECC, wshobson/agents, kepano/obsidian-skills, vercel-labs/skills, davila7/claude-code-templates | MIT | MIT | match |
| thedotmack/claude-mem | Apache-2.0 | Apache-2.0 | match |

Exposure is limited but non-zero. `awesome-claude-code` is a discovery-only source that is
explicitly never merge material, so the NonCommercial and NoDerivatives terms do not bite
today — but the repository currently publishes a false CC0 claim about someone else's work.
For `anthropics/skills`, `skill-creator` — the one component section 8 names as the
`instinct` lineage — is Apache-2.0, so the intended use is clear; the blanket section 8
claim is nonetheless wrong, and four skills in that repository are not open-source at all.

Per HD-10 and ADR-016, the correction is a spec pull request. No file was edited under this
review, and `SPEC.md`, `NOTICE`, and `SOURCES.md` must not be silently amended to match
these findings.

**DEV-3 — the backlog issue body carries two citations that do not resolve.** It cites
"R5 flags 9-10" as its source; the only R5 artifact in the project is
`00-prompts/cc-spec-v22.md`, which contains no flags and no items 9 or 10. The claim is
unsupported. It also points readers at `03-synthesis/SYNTHESIS_LOG.md`, a path that exists
in the working tree but is outside the published repository, so the reference is
unfollowable from GitHub. Both would be permanent in a filed issue. The underlying
technical claims are sound — only the provenance is wrong.

**DEV-4 — the "repo must not exist" gate has an inverted exit code.** `gh repo view` exits
1 on the expected 404. Combined with the prompt's blanket halt-on-failure rule, a literal
executor halts on the success case. The gate must be evaluated on output text.

**DEV-5 — ten empty directories will not survive the push.** `.claude-plugin/` and the nine
`plugins/*` directories contain no files, and git cannot commit an empty directory, so the
published tree will not mirror the local one. Verified harmless: a simulated post-clone tree
with those directories removed still returns `VALIDATE: PASS`, exit 0, because check S3
treats them as absent-by-design at scaffold. Placeholder files should not be added — they
would invent structure section 3 does not name.

**DEV-6 — the intake gates do not pin the GitHub account.** Two accounts are authenticated
on this machine and section 2 names one of them as never permitted to own this repository.
The active account is correct and the create command names the owner explicitly, so a
failure would be loud rather than silent, but the gate should assert the active login.

**DEV-7 — the pin is committed and pushed without revalidation.** `pin-upstream.sh`
rewrites `upstream.json`, which check U2 governs. The write-back is atomic, so the result
should be coherent, but no validator run stands between the rewrite and the push.

### 3. Disposition

- DEV-1, DEV-3, DEV-4, DEV-6, DEV-7 are corrected in the amended prompt at
  `00-prompts/cc-closure-v2.md`. None require a repository change.
- DEV-2 requires a spec pull request against section 8 under ADR-016. It is recorded here as
  evidence discharging HD-10's "re-verify licenses at the first pin" instruction. It is not
  authority to edit the spec, the notice file, or the sources map.
- DEV-5 is accepted as-is.
- The third P3 divergence found in section 1 should be added to the backlog issue alongside
  the two the prompt already lists.
