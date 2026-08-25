# Awakened — Project Specification

**Version:** 2.8
**Date:** 2026-08-25
**Status:** Governing spec — supersedes SPEC.md v2.7 (2026-08-22), v2.6 (2026-08-22), v2.5 (2026-08-21), v2.4 (2026-08-18), v2.3 (2026-08-18), v2.2 (2026-08-16), v2.1 (2026-08-15), `awakened-notes-v2.md` (v2.0), and `awakened-notes.md` (v1)
**Canonical path:** `SPEC.md` at repository root. This file is the single source of truth; no other document may restate its content — only reference it.

---

## 0. Conformance & Citation

- The key words **MUST**, **MUST NOT**, **SHOULD**, **SHOULD NOT**, and **MAY** are to be interpreted as in RFC 2119.
- Every normative rule carries a stable ID (`P-*` principles, `HR-*` hard rejects, `C-*` conditionals, `E-*` universal requirements, `N-*` naming rules, `B-*` boundaries, `D-*` decisions, `EXC-*` exceptions). Audits and ADRs **MUST** cite rule IDs, not prose.
- External standard of record: the official Claude Code plugin documentation at `https://code.claude.com/docs/en/plugins` and the plugin-marketplace reference adjacent to it. Host verified 2026-08-18: `docs.claude.com/en/docs/claude-code/*` returns `301 Moved Permanently` to `code.claude.com/docs/en/*`, which is canonical for Claude Code documentation. URLs **MUST** be re-verified against live docs at every subsequent phase gate; any conflict between this spec's structural assumptions and current official docs is a `SPEC-GAP` requiring human resolution.

---

## 1. Mission

**Awakened** is a curated Claude Code plugin marketplace: a "best-of" synthesis of the strongest open-source Claude Code repos, rebuilt from scratch with the bloat, risk, and friction of the originals engineered out.

Core promise: **curated, lightweight, safe, modular upgrades for Claude Code.**

### Design Principles

| ID | Principle |
|---|---|
| P-1 | Install only the capabilities needed — every plugin **MUST** be independently installable, testable, and removable. |
| P-2 | Lightweight means **user-scope safe**: every component **MUST** provide value across any project, language, or stack. Nothing project-specific, language-specific, or LSP-dependent ships at user level. |
| P-3 | Prefer skills and commands over hidden automation. |
| P-4 | Hooks are exceptional — at most one per plugin, only where load-bearing, and only after passing strict safety, cross-platform, and dependency checks (§6). |
| P-5 | No third-party tooling, external services, API keys, daemons, or databases. Sole exceptions: Obsidian, Context7, and Claude Code itself. |
| P-6 | Synthesize, don't clone. Components are new implementations combining the best logic of multiple sources — never verbatim copies, never lesser-quality rewrites. (Sole exception: EXC-1, §7.) |

---

## 2. Marketplace Identity

| Item | Value |
|---|---|
| Marketplace name | `awakened` |
| Repository | `coltonbearden/awakened` (repo name finalized `awakened`; the `claude-awakened` alternative is retired) |
| GitHub owner | `coltonbearden` (personal account — **never** `FirstCastSolutions423`) |
| Brand style | Sci-fi, power-up, transformation, anime-inspired developer tooling |
| Primary distribution | GitHub repo via `claude plugin marketplace add coltonbearden/awakened` |
| Plugin philosophy | Independently installable, user-scope friendly, dependency-minimal modules |
| License | MIT (see §7) |
| Name availability | Verified clear on GitHub as of 2026-08-15 — no colliding Claude marketplace/plugin repos |
| Plugin spec of record | Official Claude Code plugin docs (§0) — URL verified at the 2026-08-18 Phase-2 pass; canonical host `code.claude.com` |

---

## 3. Repository Architecture

Multi-plugin marketplace monorepo, per the official Claude Code plugin spec.

**Delivery staging (D-19):** entries tagged `[P6]` below are **Phase-6 deliverables** — expected-absent at scaffold stage. Validators **MUST** treat `[P6]` entries as expected-absent by default and as required under `--release` (bash) / `-Release` (PowerShell). Untagged entries are scaffold-stage and required from the first commit.

```text
awakened/
├── .claude-plugin/
│   └── marketplace.json          # [P6] Marketplace catalog: name, owner, plugin list
├── plugins/                      # dirs scaffold-stage; contents [P6]
│   ├── super-saiyan/             # Core engineering workflow
│   ├── sharingan/                # Code review & analysis
│   ├── rinnegan/                 # Persistent memory (temporal)
│   ├── kaioken/                  # Session management & momentum
│   ├── bankai/                   # Specialist subagents
│   ├── domain/                   # Project-scoped structural context
│   ├── instinct/                 # Marketplace meta tooling
│   ├── poneglyph/                # OPTIONAL: Obsidian integration
│   └── aura/                     # OPTIONAL: themes, palettes, statuslines
├── schemas/
│   ├── marketplace.schema.json   # Validates .claude-plugin/marketplace.json
│   ├── plugin.schema.json        # Validates plugins/<name>/.claude-plugin/plugin.json
│   ├── skill.schema.json         # Validates skill frontmatter
│   └── agent.schema.json         # Enforces subagent tool allowlists (C-2)
├── scripts/
│   ├── validate.sh               # POSIX/WSL2 structure + frontmatter + policy lint
│   ├── validate.ps1              # PowerShell 7 equivalent — identical checks, identical exit codes
│   ├── pin-upstream.sh           # Resolves upstream.json commit SHAs from live remotes
│   └── pin-upstream.ps1          # PowerShell 7 equivalent
├── eval/
│   ├── rubric.md                 # Human-readable scoring guide (§9)
│   ├── rubric.json               # Machine-readable rubric (§9)
│   ├── matrix.csv                # Candidate scoring log (normative header: §9)
│   ├── triage-log.md             # Rejection log with rule-ID rationales
│   ├── gate-review-protocol.md   # G5 independent-reviewer standard (§10, D-25)
│   ├── claude-mem-rebuild.md     # Phase-3 file-based memory design for rinnegan (§10, D-26)
│   └── shortlist.md              # Phase-5 per-plugin roster proposed for synthesis (§10; ROADMAP.md §7)
├── templates/
│   ├── plugin/plugin.json        # Base plugin manifest template
│   ├── skill.md                  # Skill template (frontmatter + trigger-description rules)
│   ├── command.md                # Slash command template (plugin-namespaced)
│   ├── agent.md                  # Subagent template (restricted allowlists, handoff contract)
│   └── hook.json                 # Minimal load-bearing hook template (§6 budget)
├── tests/                        # [P6] Component test fixtures
├── .github/
│   └── workflows/
│       ├── upstream-watch.yml    # [P6] Monthly upstream diff monitor
│       └── validate.yml          # CI: both validators + HD-12 twin-parity diff on every PR and push to main; required on main
├── .gitattributes                # LF line endings enforced for *.sh, *.ps1, *.json, *.md
├── CLAUDE.md                     # Repo-session execution rules for Claude Code
├── CONTEXT.md                    # System overview, non-goals, user profile
├── DECISIONS.md                  # ADR-001…ADR-026, 1:1 with §12
├── ROADMAP.md                    # Phases 1–6 with exit criteria (§10)
├── SPEC.md                       # THIS FILE — canonical, shipped verbatim
├── upstream.json                 # Source repo registry; SHAs pinned via scripts/pin-upstream.*
├── SOURCES.md                    # Attribution & lineage for every component
├── CONTRIBUTING.md               # Contribution + component acceptance criteria
├── NOTICE                        # Apache-2.0 adaptation notices
├── LICENSE                       # MIT
└── README.md
```

Each plugin follows the official layout — manifest in `.claude-plugin/`, components at plugin root:

```text
plugins/<name>/
├── .claude-plugin/
│   └── plugin.json
├── commands/
├── agents/
├── skills/
├── hooks/                        # Rare. Max one hook per plugin, load-bearing only.
└── statuslines/                  # aura ONLY (D-23). Preset scripts as .sh/.ps1 twin pairs.
```

---

## 4. Plugin Lineup (Tier 1)

| Plugin | Primary Responsibility | Intended Contents | Source Lineage |
|---|---|---|---|
| `super-saiyan` | Core engineering workflow | Planning, implementation, TDD, systematic debugging, verification-before-completion, git workflow guidance | superpowers × mattpocock |
| `sharingan` | Code review & analysis | Code review, architecture inspection, regression analysis, pattern detection, security-oriented review | superpowers × mattpocock × ECC × wshobson |
| `rinnegan` | Persistent memory — **temporal** | Decision history, session context, searchable project notes, recall across sessions. File-based only. | claude-mem (concepts rebuilt, zero daemons/sqlite/workers) |
| `kaioken` | Session management & momentum | Save/resume sessions, handoffs, focused execution plans, rapid iteration | ECC sessions × mattpocock handoff |
| `bankai` | Specialist subagents | Curated general-purpose agents: research, implementation, debugging, review, planning, synthesis. Restricted tool allowlists. | wshobson (curated) × ECC agents |
| `domain` | Project context — **structural** | Project maps, architecture context, conventions, rules, CLAUDE.md scaffolding, domain modeling | mattpocock × ECC × wshobson |
| `instinct` | Marketplace meta tooling | Skill creation, component auditing, validation, upstream evaluation, release checks | anthropics skill-creator × superpowers writing-skills × vercel find-skills |
| `poneglyph` (optional) | Obsidian knowledge-vault integration | obsidian-markdown, obsidian-cli, obsidian-bases, json-canvas, defuddle | kepano/obsidian-skills (near-verbatim — EXC-1) |
| `aura` (optional) | Personalization & DX | Color palettes, statusline presets, output styles, `/aura:equip` | Original work |

### Cut / Merged from v1

- **`godspeed` — cut.** Session-speed scope belongs to `kaioken`; parallel task planning belongs to `bankai` (and superpowers' dispatching-parallel-agents lineage).
- **`nen` — cut.** "Capability classification" is `instinct`'s auditing/validation job.

### Responsibility Boundaries

| ID | Boundary |
|---|---|
| B-1 | `super-saiyan` is the stable baseline. It **MUST NOT** depend on agents, memory infrastructure, or project-specific tooling. |
| B-2 | `sharingan` analyzes and reviews. It **MUST NOT** become the implementation/execution plugin. |
| B-3 | `rinnegan` owns **temporal** context: what happened, what was decided, what to recall. File-based storage only — no background workers, databases, or cloud sync. |
| B-4 | `domain` owns **structural** context: current-state architecture, conventions, rules. Installed at user scope; generates project-scoped artifacts (CLAUDE.md, rules). It **MUST NOT** store history — that is rinnegan's. |
| B-5 | `kaioken` improves temporary session momentum. It **MUST NOT** duplicate planning, debugging, or review systems. |
| B-6 | `bankai` owns all subagents and their restricted tool permissions. No bare `Bash(*)` allowlists (C-2). |
| B-7 | `instinct` owns marketplace maintenance, validation, quality gates, and creation/refinement of future capabilities. |
| B-8 | `poneglyph` and `aura` are optional satellites. Neither **MAY** ever become a dependency of a core plugin. |

Every accepted component **MUST** have exactly one owning plugin under B-1…B-8. A component with no clear owner, or two plausible owners, is not shortlistable (§9).

---

## 5. Two-Tier Naming System

**The rule (N-1):** Tier 1 plugin names are concise ability words that get typed. Tier 2 names are full dramatic technique names that live inside `aura` presets — selected once in settings, never typed as commands.

### Tier 1 — Plugins (typed often, kept short)

`super-saiyan` · `sharingan` · `rinnegan` · `kaioken` · `bankai` · `domain` · `instinct` · `poneglyph` · `aura`

Changes from v1: `domain-expansion` → `domain`, `ultra-instinct` → `instinct`. Fans still read them instantly; `/domain:map` beats `/domain-expansion:map`.

### Tier 2 — Aura presets (never typed, full drama allowed)

**Color palettes:**

| Preset | Palette |
|---|---|
| `ultra-instinct` | Silver/white base + electric blue accents |
| `super-saiyan` | Gold/yellow energy |
| `domain-expansion` | Deep void + barrier accent color |
| `gear-fifth` | White/bright, cartoon-vivid |
| `six-eyes` | Cyan / limitless blue |
| `bankai` | Crimson/black |

**Statusline presets:**

| Preset | Behavior |
|---|---|
| `power-level` | Context window usage rendered as a rising power level |
| `transformation` | Current mode as a state: planning → `base-form`, executing → `super-saiyan`, parallel agents → `kaioken-x20` |
| `barrier` | Active project context/rules status (renamed from `domain` in v2.0 — D-17: Tier 2 preset IDs **MUST NOT** collide with Tier 1 plugin names) |

Implementation note: Claude Code's native theming is limited, so `aura` ships as statusline scripts with ANSI palettes + output styles + `/aura:equip <preset>` to swap the active preset in settings. File-based, reversible, zero dependencies. Preset scripts live in `plugins/aura/statuslines/` as `.sh`/`.ps1` twin pairs (D-23) — the cross-platform pairing rule applies to them exactly as it does to `scripts/`.

### Naming Rules

| ID | Rule |
|---|---|
| N-1 | Two tiers as defined above. Full technique names (`domain-expansion`, `ultra-instinct`, `gear-fifth`) are reserved for aura presets. |
| N-2 | Plugin names carry the theme; **skill and command names carry the function.** Skills auto-invoke via frontmatter `description` matching, not by name recognition — a skill named something clever with a vague description will never fire. |
| N-3 | All machine-facing names **MUST** be lowercase kebab-case: `^[a-z0-9]+(-[a-z0-9]+)*$`. |
| N-4 | Commands namespace under the **plugin** name, never the marketplace name. `/awakened:*` **MUST NOT** exist unless a plugin is literally named `awakened` (it isn't — that would be a catch-all, which is prohibited). |
| N-5 | Tier 2 preset identifiers **MUST NOT** duplicate any Tier 1 plugin name (D-17). |
| N-6 | Reject candidate names that are too vague to communicate purpose, too long for practical command use (Tier 1), too tied to a temporary implementation, or likely to overlap an existing plugin. |

### Command Namespace Map (illustrative baseline)

```text
/super-saiyan:plan      /super-saiyan:debug     /super-saiyan:verify
/sharingan:review       /sharingan:inspect
/rinnegan:recall        /rinnegan:record
/kaioken:handoff        /kaioken:resume
/bankai:dispatch        /bankai:research
/domain:map             /domain:context
/instinct:validate      /instinct:audit
/aura:equip <preset>
```

### Future Naming Logic

Name new plugins only after scope and boundaries are defined. Preferred sources:

- Transformation states: `ascended`, `transcendence`, `limit-break`
- Perception/intelligence: `byakugan`, `six-eyes`, `observation`
- Execution/speed: `instant-transmission`, `flash-step`
- Knowledge/artifacts: `grimoire`, `codex`, `archive`
- Agents/coordination: `summon`, `legion`, `vanguard`
- Context/environments: `nexus`, `sanctuary`, `realm`

---

## 6. Safety & Risk Policy

### Hard Reject (automatic fail, overrides all scores)

| ID | Hard reject |
|---|---|
| HR-1 | Third-party API keys, external services, or accounts |
| HR-2 | MCP servers beyond Obsidian, Context7, and Claude Code |
| HR-3 | LSP servers or language-specific tooling at user scope |
| HR-4 | Background daemons, workers, watchers, or services |
| HR-5 | sqlite/native binary dependencies |
| HR-6 | Telemetry, analytics, or network calls of any kind (sole exception: `scripts/pin-upstream.*` and `upstream-watch.yml`, which are repo-maintenance tooling, not shipped plugin components) |
| HR-7 | Auto-installing packages or runtime dependency fetching |
| HR-8 | Hooks that write outside (a) the project directory or (b) the owning plugin's own data directory under the user's Claude config dir (D-18). Any other write target is rejected. |

### Conditional (audited, kept only if all pass)

| ID | Conditional requirement |
|---|---|
| C-1 | Every hook, regardless of handler type (shell, prompt, or other), **MUST** be idempotent, read-only by default, and timeout-bounded — a populated `timeout` field is mandatory on every hook entry (D-22). Hooks executing shell commands **MUST** additionally be cross-platform (Windows 11 PowerShell 7 + WSL2 bash) — dispatch constrained by D-24, §6 Hook Dispatch. |
| C-2 | Subagents **MUST** declare restricted tool allowlists; bare `Bash(*)` or unrestricted `Write(*)` are prohibited. `schemas/agent.schema.json` enforces this mechanically. |
| C-3 | File writes are permitted only inside the project directory, the owning plugin's data directory (HR-8), or explicit user-approved locations. |

### Every Component

| ID | Universal requirement |
|---|---|
| E-1 | Static review for prompt-injection patterns ("always run X without asking"), secrets handling, and obfuscation. |
| E-2 | **MUST** pass `scripts/validate.*` (structure, frontmatter, naming, policy lint) before merge. |

### Hooks Budget

Maximum one hook per plugin, only where load-bearing (D-15):

- `super-saiyan`: session-start hook injecting skill discipline (superpowers lineage)
- `rinnegan`: optional memory-capture hook, rebuilt lightweight — no workers, no daemons; writes only per HR-8

Everything else is skills and commands.

### Hook Dispatch (D-24)

Verified against the live official hooks reference at Phase 2 (§0): Claude Code documents five hook handler types (`command`, `http`, `mcp_tool`, `prompt`, `agent`), a per-hook `shell` selector for shell-form command strings, an exec form (`command` plus an `args` array, executed without shell interpretation), and `${CLAUDE_PLUGIN_ROOT}` / `${CLAUDE_PLUGIN_DATA}` path expansion.

- Awakened hooks satisfy C-1's cross-platform clause **shell-free**: budgeted hooks **MUST** use the `prompt` or `agent` handler types, which execute no shell on either platform. (`http` handlers are barred by HR-6. `mcp_tool` handlers are barred not by HR-2 — which permits three servers — but because the §6 Hooks Budget under D-15 allocates hooks only to the core plugins `super-saiyan` and `rinnegan`, and B-8 bars a core plugin from depending on the optional satellites that carry MCP.) An `agent`-type hook's prompt **MUST** state its write targets explicitly, so E-1 static review can lint them against HR-8. (The official docs mark `agent` hooks experimental — re-verify at Phase 3 before `rinnegan`'s hook is designed; ADR-024.)
- A `command` handler **MAY** be adopted only through a superseding decision, and then only in exec form with `${CLAUDE_PLUGIN_ROOT}`-anchored paths and a **guaranteed** interpreter — one the `CONTRIBUTING.md` environment matrix *requires* on both Windows 11 and WSL2. None qualifies today: that matrix scopes `python3` to WSL2 only, and P-5 sanctions no third-party interpreter. Command-handler hooks are therefore prohibited today. Shell-form command strings and the `shell` field **MUST NOT** appear in shipped hooks.

Resolves B-GAP-002 (HD-5).

---

## 7. Licensing & Attribution

- Awakened is released under **MIT**.
- All components are **synthesized** — new implementations informed by sources, not copied files (P-6). This keeps the project clear of derivative-work concerns while preserving quality.
- **EXC-1 (poneglyph exception):** `kepano/obsidian-skills` (MIT, 5 skills) **MAY** be adapted near-verbatim into `poneglyph`. Rationale: upstream is already minimal, high quality, MIT-licensed, and scoped exactly to the plugin's purpose; a rewrite would be a lesser-quality clone, violating P-6's own intent. Full attribution in `SOURCES.md`.
- **`SOURCES.md`** maps every component to the repo(s) that informed it. Single attribution file — no per-file header clutter (D-12).
- **`NOTICE`** covers anything adapted closely from Apache-2.0 sources (anthropics/skills, claude-mem).
- Plugin names reference trademarked anime franchises (Shueisha/Bandai et al.). Standard fan-project convention: names are fine; the repo and README **MUST NOT** contain franchise artwork, logos, or copyrighted graphical assets. `awakened` itself is a generic word and fully safe.

---

## 8. Source Repositories & Roles

| Repo | Role | License | Notes |
|---|---|---|---|
| [obra/superpowers](https://github.com/obra/superpowers) | **Spine** — core workflow skills | MIT | 14 skills, minimal session-start hook. Proven daily driver. |
| [mattpocock/skills](https://github.com/mattpocock/skills) | **Quality bar** | MIT | ~24 skills, highest signal-to-noise ratio of all sources |
| [affaan-m/ECC](https://github.com/affaan-m/ECC) | **Idea donor** | MIT | ~95 cmds / ~70 agents / ~270 skills. Mine: sessions, plan/prp family, build-fix, code-review, hookify, security-scan, project-init. Reject: 22 language packs, 41KB hooks.json, dashboards, domain niche skills |
| [thedotmack/claude-mem](https://github.com/thedotmack/claude-mem) | **Concept donor** — memory | Apache-2.0 | Take the concept (session memory, searchable history). Rebuild file-based; reject sqlite/bun/workers/docker/cloud-sync |
| [wshobson/agents](https://github.com/wshobson/agents) | **Agent donor** | MIT | 95 plugins; ~12–15 general-purpose categories worth mining |
| [anthropics/skills](https://github.com/anthropics/skills) | **Reference implementations** | No root license — per-skill `LICENSE.txt`: Apache-2.0 (12, incl. skill-creator) / proprietary (4: pdf, pptx, xlsx, docx), as verified at the 2026-08-18 pin | Official skill patterns; skill-creator lineage for instinct. Only Apache-2.0 components are lineage-eligible; the four proprietary skills are excluded (D-24) |
| [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) | **Obsidian source** | MIT | 5 skills, near-verbatim into poneglyph (EXC-1) |
| [vercel-labs/skills](https://github.com/vercel-labs/skills) | **Meta-skill concept** | MIT | find-skills discovery concept feeds instinct |
| [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | **Discovery source** | CC-BY-NC-ND-4.0 | Catalog for gap-scanning, not merge material. Candidates it surfaces are audited at their actual source under that source's own license (D-24) |
| [davila7/claude-code-templates](https://github.com/davila7/claude-code-templates) | **Template mining** | MIT | Caution: heavy npm CLI + analytics. Mine components dir only |

`upstream.json` **MUST** contain exactly these 10 repositories. Commit SHAs are runtime data: they are recorded as `null` at scaffold time and resolved by `scripts/pin-upstream.*` before Phase 2 begins. No SHA may ever be typed from memory.

---

## 9. Evaluation Rubric

Every candidate component is scored 1–5 on each axis during Phases 2–4. **Polarity is uniform: 5 is always best.**

| Axis | Question | 1 (fail) | 3 (floor) | 5 (ideal) |
|---|---|---|---|---|
| Value | Does it solve a real, recurring problem for general users? | Niche/one-off; useful in a single project type | Useful in some common workflows | Recurring problem for nearly all users and stacks |
| Bloat | Token/context overhead vs. payoff; instruction-file size discipline | Large always-loaded instruction files; heavy context tax | Moderate footprint, loaded on demand | Minimal tokens; tight instructions; pay-for-use |
| Risk | Policy check against §6 | Conditional-category behavior failing ≥1 check | Conditional behaviors passing all C-1…C-3 checks | Pure skills/commands; read-only; no shell side effects |
| Dependencies | Zero-dependency preferred; allowed exceptions only | Requires anything outside P-5 exceptions | Uses an allowed exception (Obsidian/Context7) | Zero dependencies beyond Claude Code |
| User-scope fit | Useful across any project, language, and stack? | Project- or language-specific | Broad but with stack assumptions | Universal |

**Rules:**

1. Any HR-1…HR-8 trigger ⇒ verdict `reject`, regardless of scores. Log in `eval/triage-log.md` with the HR ID.
2. Shortlist requires: no hard rejects, **every axis ≥ 3**, and exactly one owning plugin per §4 boundaries.
3. Verdict enum (frozen — D-21): `shortlist` | `reject` | `merge` (fold into another candidate — name it) | `defer`. A `defer` **MUST** name the blocking check ID (e.g. C-1 idempotence) and the phase where it resolves; a named `defer` satisfies Phase 5's zero-empty-verdict rule, but the Phase 5 sign-off ADR **MUST** enumerate every open `defer`.
4. Row provenance lives outside the matrix (D-20): the pin state of record is `upstream.json.pinned_at` at scoring time, and per-component provenance notes go in `eval/triage-log.md`. The header above is immutable and **MUST NOT** gain provenance columns.

**Normative `eval/matrix.csv` header (byte-exact, one line):**

```csv
id,source_repo,component_path,component_type,target_plugin,value,bloat,risk,dependencies,user_scope_fit,hard_reject,verdict,rationale
```

`component_type` enum: `skill` | `command` | `agent` | `hook` | `template` | `concept`. `hard_reject` is empty or a comma-joined list of HR IDs.

---

## 10. Build Phases & Exit Criteria

| Phase | Scope | Exit criteria (all required) |
|---|---|---|
| 1 — Structural inventory | ✅ Complete 2026-08-15 | All 10 repos crawled; structure, counts, licenses mapped. |
| 2 — Tier-1 deep audit | ✅ Complete 2026-08-18 — Read every skill file in superpowers, mattpocock/skills, kepano/obsidian-skills, vercel-labs/skills | `upstream.json` SHAs pinned (no nulls); one `matrix.csv` row per skill file in all four repos; every `reject` has a triage-log entry citing rule IDs; §0 official-docs verification complete — the five `UNVERIFIED-EXTERNAL` assumptions (synthesis HD-9) adjudicated, the hook dispatch mechanism decided (HD-5) via a §14 changelog row, and all ten §8 licenses re-verified against the pinned commits (HD-10). |
| 3 — ECC triage + claude-mem extraction | 270 ECC skills → shortlist → deep-read shortlist only; extract claude-mem memory concepts | ECC shortlist ≤ 40 rows deep-read (bulk rejects logged in aggregate); file-based rebuild design written to `eval/claude-mem-rebuild.md`. |
| 4 — Remaining sources | wshobson shortlisted plugins (~12–15), anthropics/skills, davila7 components dir, awesome-claude-code gap scan, **and ECC `commands/` + `agents/`** (D-26) | Matrix rows appended for each; gap-scan findings appended to `eval/triage-log.md`. |
| 5 — Evaluation matrix | Full scored matrix | Zero empty `verdict` cells; **independent-reviewer approval gate** — G5 adjudicated by a reviewer that receives the artifacts only, never the executing agent's reasoning, against `eval/gate-review-protocol.md`; a second `REJECTED` on the gate escalates to the project owner. Sign-off recorded as an ADR in `DECISIONS.md` before any building (D-25). A reviewer `APPROVED` is provisional: the `ROADMAP.md` gate log records it as `APPROVED (reviewer) — pending owner ack`, and Phase 6 work of any kind is barred until the owner posts an acknowledgement comment on the sign-off PR (D-25, amended v2.5). |
| 6 — Scaffold & synthesize | Repo structure, marketplace.json, synthesized components, validation + CI, docs | Tree matches §3 exactly; `scripts/validate.sh` and `validate.ps1` both exit 0; CI green; a `SOURCES.md` row exists for every shipped component. |

---

## 11. Ongoing Maintenance

- `upstream.json` pins every source repo to a commit SHA (resolved by `scripts/pin-upstream.*`).
- `.github/workflows/upstream-watch.yml` runs monthly: diffs upstream repos, opens an issue summarizing changes worth re-evaluating.
- `instinct` dogfoods the process — its upstream-review skill evaluates diffs using Claude Code itself.
- Versioned releases via git tags; CHANGELOG per plugin.

---

## 12. Resolved Decisions Log

| # | Decision | Outcome |
|---|---|---|
| D-01 | Structure | Multi-plugin marketplace monorepo |
| D-02 | Distribution | GitHub repo only |
| D-03 | Name | `awakened` (verified available 2026-08-15); repo `coltonbearden/awakened` |
| D-04 | Component priority | skills > commands > agents (curated) > hooks (minimal) > rules/templates |
| D-05 | Merge strategy | Synthesize — new implementations from best-of logic (EXC-1 sole exception) |
| D-06 | Audience | Platform/language-agnostic, general users |
| D-07 | Risk policy | §6 — hard reject / conditional / static review |
| D-08 | Licensing | MIT + SOURCES.md + NOTICE; synthesis approach |
| D-09 | Vetting | Deep, phased |
| D-10 | Maintenance | Ongoing — upstream.json + monthly Action + dogfooded review |
| D-11 | Lightweight definition | User-scope installable across all projects; no per-project tooling |
| D-12 | Attribution | SOURCES.md + CONTRIBUTING.md; no per-file headers |
| D-13 | Naming system | Two-tier: short plugin names, dramatic aura preset names |
| D-14 | godspeed / nen | Cut — scope folded into kaioken/bankai and instinct |
| D-15 | Hooks budget | Max one per plugin, load-bearing only |
| D-16 | Spec change control | Canonical spec is `SPEC.md` at repo root; changes land via PR that edits SPEC.md and appends a §14 changelog row; DECISIONS.md ADRs mirror this table 1:1 |
| D-17 | Preset/plugin collision | Tier 2 preset IDs must not duplicate Tier 1 plugin names; statusline preset `domain` renamed `barrier` |
| D-18 | Hook write scope | Hooks may write only to the project directory or the owning plugin's data directory under the user's Claude config dir; reconciles HR-8 with C-3 and enables rinnegan's file-based memory hook |
| D-19 | Delivery staging | §3 entries tagged `[P6]` are Phase-6 deliverables, expected-absent at scaffold; validators lenient by default, strict under `--release`/`-Release` (ratifies synthesis DEVIATION-001; resolves A-GAP-001/B-GAP-001) |
| D-20 | Matrix provenance | Provenance lives outside `matrix.csv` — `upstream.json.pinned_at` + `eval/triage-log.md`; the §9 header is immutable (resolves A-GAP-002) |
| D-21 | Blocked-check verdict | §9 enum frozen; `defer` requires a named blocking check + resolution phase; Phase 5 sign-off enumerates open defers (resolves A-GAP-003; Set A's `hold` not adopted) |
| D-22 | C-1 scope | C-1 binds every hook regardless of handler type; `timeout` mandatory on all hook entries (resolves A-GAP-005) |
| D-23 | aura statuslines | `plugins/aura/statuslines/` added to the per-plugin layout, scoped to `aura` only; preset scripts ship as `.sh`/`.ps1` twin pairs (resolves A-GAP-006) |
| D-24 | Phase-2 §0 verification | §8 licenses corrected at the first pin (HD-10); hook dispatch decided — shell-free `prompt`/`agent` handlers, command handlers barred pending a P-5-sanctioned dual-platform interpreter (HD-5, resolves B-GAP-002); five HD-9 assumptions adjudicated against the live official docs — outcomes in ADR-024. **Amended v2.7 (2026-08-22):** SPEC-GAP-001 is resolved — an agent's `tools` is emitted as the comma-separated string the official sub-agents reference documents; the YAML list stays accepted on read. A second residue of the same kind is opened as SPEC-GAP-002 and is settled empirically at the Phase-6 gate, not from documentation |
| D-25 | G5 adjudication | Gate G5 is decided by an **independent reviewer** on a different model from the executing agent, artifact-only, against the versioned `eval/gate-review-protocol.md`; a mandatory source spot-check, uncertainty resolving to `REJECTED`, and escalation to the owner on a second `REJECTED`. Scope is G5 alone — G3, G4 and G6 remain review gates. Amended v2.5 (ADR-025 in place): a reviewer `APPROVED` is provisional until the owner acknowledges it on the sign-off PR — no Phase 6 work before the ack; reviews run clean-room from a `git archive` workspace under an explicit MUST-NOT-read list; the reviewer loader is sha256-pinned in the protocol (§0, verified at Step 0 — mismatch ⇒ automatic `REJECTED`); a non-Anthropic second pass is a non-binding SHOULD at the real G5, REQUIRED where the executing agent's model equals the reviewer's. Outcomes in ADR-025 |
| D-26 | Phase-4 ECC scope | `SPEC.md` §10 Phase 4 covers ECC's `commands/` and `agents/` alongside the four sources it already names. Of the seven mining targets §8 ratifies, the `sessions` family, `build-fix`, `code-review` and `project-init` exist **only** under `commands/`; §4 names ECC's `agents/` as `bankai`'s lineage and the sessions commands as `kaioken`'s. §10 Phase 3 is skills-only and no other phase named ECC, so those components had no phase that would audit them. Landed at the G3 boundary under `ROADMAP.md` §10 rule 4. Outcomes in ADR-026 |

---

## 13. Glossary

| Term | Definition |
|---|---|
| User scope | Installed once for the user, active across all projects. The bar every shipped component must clear (P-2, D-11). |
| Project scope | Artifacts generated into a single repository (e.g., `domain`'s CLAUDE.md output). Fine as *output*, prohibited as an *installation requirement*. |
| Load-bearing hook | A hook without which the plugin's core promise does not function. The only kind permitted (P-4, D-15). |
| Temporal context | History: what happened, what was decided, recall. Owned by `rinnegan` (B-3). |
| Structural context | Current state: architecture, conventions, rules. Owned by `domain` (B-4). |
| Synthesis | A new implementation informed by one or more sources' logic — not a copied or lightly edited file (P-6). |
| Hard reject | An HR-1…HR-8 trigger; automatic fail overriding all rubric scores. |
| Tier 1 / Tier 2 | Typed plugin names / never-typed aura preset names (N-1). |

---

## 14. Spec Change Control & Changelog

The spec is versioned `MAJOR.MINOR`: MINOR for clarifications and additive decisions, MAJOR for changes that invalidate prior audits. Every change appends a row here (D-16).

### v2.0 → v2.1 (2026-08-15)

| # | Change | Kind |
|---|---|---|
| 1 | File renamed `awakened-notes-v2.md` → `SPEC.md`; declared canonical repo-root path | Editorial |
| 2 | Added §0 conformance keywords (RFC 2119) and stable rule IDs (P/HR/C/E/N/B/D/EXC) throughout | Editorial |
| 3 | §3 tree reconciled with build plan: added `schemas/`, `eval/`, `templates/`, `scripts/pin-upstream.*`, `.gitattributes`, and root governance docs (CLAUDE.md, CONTEXT.md, DECISIONS.md, ROADMAP.md, SPEC.md) | Semantic |
| 4 | Repo name finalized `awakened`; `claude-awakened` alternative retired; owner fixed `coltonbearden` | Semantic (closes D-03 residue) |
| 5 | Statusline preset `domain` → `barrier` (N-5) | Semantic → D-17 |
| 6 | HR-8/C-3 hook-write contradiction reconciled: plugin data dir carve-out | Semantic → D-18 |
| 7 | §9 rubric: per-axis 1/3/5 anchors, uniform polarity (5 = best), verdict enum, byte-exact matrix.csv header | Clarifying |
| 8 | §10 phases: exit criteria with expected values; claude-mem rebuild design artifact named `eval/claude-mem-rebuild.md` | Clarifying |
| 9 | Poneglyph near-verbatim exception formalized as EXC-1 under P-6 | Clarifying |
| 10 | §8: upstream.json SHA policy — `null` at scaffold, resolved by pin script, never typed from memory; HR-6 maintenance-tooling exception noted | Semantic |
| 11 | Added §13 glossary, §14 change control; decisions extended D-16…D-18 | Additive |

### v2.1 → v2.2 (2026-08-16) — ratification of synthesis Human Decisions HD-1…HD-4, HD-6

| # | Change | Kind |
|---|---|---|
| 1 | §3: delivery staging — `[P6]` tags on Phase-6 entry classes (`.claude-plugin/marketplace.json`, `plugins/<n>/` contents, `tests/`, `.github/workflows/upstream-watch.yml`); validators lenient by default, strict under `--release`/`-Release` | Semantic → D-19 (HD-1) |
| 2 | §9: matrix provenance rule — `upstream.json.pinned_at` + triage-log; header immutable | Clarifying → D-20 (HD-2) |
| 3 | §9: `defer` semantics — named blocking check + resolution phase; enum frozen; Phase 5 sign-off enumerates open defers | Clarifying → D-21 (HD-3) |
| 4 | §6 C-1: binds every hook regardless of handler type; `timeout` mandatory on all hook entries | Semantic → D-22 (HD-4) |
| 5 | §3/§5: `plugins/aura/statuslines/` added to the per-plugin layout, aura-scoped, `.sh`/`.ps1` twin pairing | Semantic → D-23 (HD-6) |
| 6 | §10 Phase 2 exit criteria: added §0 official-docs verification — HD-9's five `UNVERIFIED-EXTERNAL` assumptions, hook dispatch mechanism decision (HD-5, still open), and §8 license re-verification against pinned commits (HD-10) | Additive |
| 7 | §12 decisions extended D-19…D-23; §3 comment updated to ADR-001…ADR-023 | Additive |

Open items intentionally **not** resolved in v2.2: HD-5 (cross-platform hook dispatch mechanism) and HD-9's assumptions — both gated on Phase 2 §0 verification; HD-7, HD-8, HD-11, HD-12 remain advisory in `03-synthesis/SYNTHESIS_LOG.md`.

### v2.2 → v2.3 (2026-08-18) — Phase-2 §0 verification: licenses at first pin (HD-10), hook dispatch (HD-5), assumption adjudication (HD-9)

| # | Change | Kind |
|---|---|---|
| 1 | §8: `anthropics/skills` license cell corrected — no root license; per-skill `LICENSE.txt`: 12 Apache-2.0 (incl. skill-creator, the named `instinct` lineage) / 4 proprietary (pdf, pptx, xlsx, docx). `hesreallyhim/awesome-claude-code` corrected CC0 → CC-BY-NC-ND-4.0. Verified at the first pin via the GitHub API and, where the API reports no license or `NOASSERTION`, the repository's LICENSE file (HD-10); `upstream.json`, `NOTICE`, `SOURCES.md` aligned in the same PR | Semantic → D-24 |
| 2 | §6: Hook Dispatch subsection added — hooks satisfy C-1 shell-free (`prompt`/`agent` handlers); command handlers only by superseding decision, exec form, with a P-5-sanctioned dual-platform interpreter (none today). Resolves B-GAP-002 (HD-5) | Semantic → D-24 |
| 3 | HD-9's five `UNVERIFIED-EXTERNAL` assumptions adjudicated against the live official docs; conclusive outcomes tightened into `schemas/agent.schema.json` (`permissionMode` rejected — unsupported for plugin-shipped agents) and `schemas/marketplace.schema.json` (git-source pin fields `sha`/`ref` declared); full outcomes and SPEC-GAP-001 in ADR-024 | Clarifying → D-24 |
| 4 | §12 decisions extended D-24; §3 comment updated to ADR-001…ADR-024 | Additive |
| 5 | §0/§2: external standard-of-record URL corrected to `https://code.claude.com/docs/en/plugins` — `docs.claude.com/en/docs/claude-code/*` now `301`-redirects to `code.claude.com/docs/en/*`. §2's "re-verify URL at Phase 2" note discharged; §0's re-verify rule re-bound to every subsequent phase gate | Clarifying → D-24 |

Open items after v2.3: HD-7, HD-8, HD-11, HD-12 remain advisory in `03-synthesis/SYNTHESIS_LOG.md`. SPEC-GAP-001 (ADR-024): the official sub-agents reference documents agents' `tools` as a comma-separated string and does not explicitly document the YAML list form the templates standardize — resolve during the Phase-2 audit, before any agent ships.

### v2.3 → v2.4 (2026-08-18) — G5 adjudicated by an independent reviewer (D-25)

| # | Change | Kind |
|---|---|---|
| 1 | §10 Phase 5: "human approval gate" → **independent-reviewer approval gate**. G5 is adjudicated by a reviewer on a different model that receives the artifacts only — never the executing agent's reasoning, transcript or PR narrative — against the versioned standard `eval/gate-review-protocol.md`. Sign-off is still recorded as an ADR before any building | Semantic → D-25 |
| 2 | §3: `eval/gate-review-protocol.md` added to the tree — the G5 review standard of record, versioned so an auditor can answer "what standard was applied" at the commit the gate was decided | Additive → D-25 |
| 3 | Escalation bounds the delegation: a first `REJECTED` loops the phase, a second `REJECTED` **on the same gate** escalates to the project owner. The executor may not invoke a third review in place of escalating, nor narrow the resubmission to the questioned parts | Semantic → D-25 |
| 4 | Scope is **G5 only**. G3, G4 and G6 remain review gates disposed by the executing agent under the owner's standing delegation; G5 is the one hard gate before building and the only one moved | Clarifying → D-25 |
| 5 | §12 decisions extended D-25; §3 comment updated to ADR-001…ADR-025; validators re-bound to the v2.4 line and the 25-ADR mapping | Additive |

Rationale of record: the Phase-2 audit shortlisted two components that violate hard rejects (`vercel/find-skills`, `superpowers/using-git-worktrees`, both HR-7) and they survived every internal consistency check, because those checks verify the matrix against itself rather than against the sources. A G5 rehearsal under this protocol then found three further defects the same self-checks had passed. The gate's value is adversarial reading; what changes is who reads, not how hard.

### v2.4 → v2.5 (2026-08-21) — G5 owner-ack tripwire, clean-room review, loader pin, CI gate (D-25 amended)

| # | Change | Kind |
|---|---|---|
| 1 | §10 Phase 5 and §12 D-25: a reviewer `APPROVED` is provisional — the `ROADMAP.md` gate log records `APPROVED (reviewer) — pending owner ack`, and Phase 6 work of any kind is barred until the owner posts an acknowledgement comment on the sign-off PR. A second `REJECTED` still escalates to the owner | Semantic → D-25 (amended in place, ADR-025) |
| 2 | `eval/gate-review-protocol.md` §1: G5 reviews run **clean room**. The executor builds the review workspace with `git archive --prefix=04-master/`, so it carries no `.git`, clones each pinned upstream beside it, and the invocation carries only the gate ID, the workspace, the repository `HEAD`, the executing agent's model string and absolute artifact paths. Absolute-path discipline replaces any assumption about the working directory a subagent inherits, and an explicit MUST-NOT-read list names what Bash can reach but the reviewer may not read | Semantic → D-25 |
| 3 | `eval/gate-review-protocol.md` §3 Step 0: the **reviewer** now verifies the loader's path and sha256 itself; a mismatch is an automatic `REJECTED` pending owner review of the loader diff, and consumes no escalation round because nothing was reviewed. It is the single read permitted outside the workspace. The §0 pin itself landed before this version, as protocol v1.0.1 (PR #8); §0 rule 3 gains the dated evidence for how the reviewer registers | Semantic → D-25 |
| 4 | `eval/gate-review-protocol.md` §3.5: SHOULD — at the real G5, not at rehearsals, one identical artifacts-only pass through a non-Anthropic model, attached as non-binding. Where the executing agent's model equals the reviewer's, that pass is REQUIRED rather than SHOULD, still non-binding, and both outputs accompany the owner-ack request; the invocation records the executing agent's model and the reviewer echoes it in its verdict | Additive → D-25 |
| 5 | §3: `.github/workflows/validate.yml` added as a scaffold-stage (non-`[P6]`) entry — both validators plus the HD-12 twin-parity diff on every pull request and every push to `main`, required on `main` by repository ruleset. This pulls the Phase-6 deliverable "CI running both validators on every PR" forward; §10 Phase 6 "CI green" is unchanged, and `ROADMAP.md` §2's foundation count is historical. It installs nothing on GitHub-hosted runners and makes no network call beyond the checkout, so it is not a new HR-6 or HR-7 exception | Additive |
| 6 | ADR amendment mechanism codified: when a spec PR amends an existing §12 cell, the mirroring ADR is amended **in place** — a dated `Amended` row in its field table plus dated italic notes at every changed passage, with `Status` staying `Accepted`. Superseding remains the route for reversing a decision. Recorded in `DECISIONS.md`, `CLAUDE.md` and `CONTRIBUTING.md` | Clarifying → D-16 |
| 7 | Editorial: §10 Phase 2 row marked complete; §12 rows re-sequenced so D-24 precedes D-25; §14 blocks re-ordered chronologically | Editorial |
| 8 | Bookkeeping: version pointers in `CLAUDE.md`, `CONTEXT.md`, `README.md`, `CONTRIBUTING.md`, `DECISIONS.md` and `eval/rubric.md`, and the verbatim exit-criteria quote in `ROADMAP.md` §7; validators re-bound — check D1 to the v2.5 version line, check S2 to require `.github/workflows/validate.yml` and `eval/gate-review-protocol.md`, check D2 unchanged at 25 ADRs. `DECISIONS.md` gains an ADR-025 Index row and "Next available" advances to ADR-026 | Additive |

Rationale of record: a reviewer is independent only if its inputs and its own definition are. v2.4 made the reviewer independent of the executing agent's reasoning; it still read a live checkout it could walk out of, and it was loaded from a file that nothing pinned. The clean room and the Step-0 digest close both gaps. The owner acknowledgement is the other half of the trade: delegation moved routine judgment off the owner's desk, and the one irreversible step — the commitment to build — returns to a human at the cost of a single comment.

Open items after v2.5: SPEC-GAP-001 (ADR-024) remains open — the official sub-agents reference documents an agent's `tools` as a comma-separated string while `templates/agent.md` standardizes the YAML list; resolve before any agent ships. HD-12 is closed by row 5, enforced now rather than honoured. `eval/triage-log.md` keeps its "human approval gate" wording because audit content is frozen, and ADR-009, ADR-021 and ADR-025's own Context keep the historical phrasing: they record what was true when they were written.

### v2.5 → v2.6 (2026-08-22) — Phase-4 scope covers ECC commands and agents (D-26); the Phase-3 rebuild design enters §3

| # | Change | Kind |
|---|---|---|
| 1 | §10 Phase 4: scope widened to include ECC `commands/` and `agents/`. Phase 3's read of ECC at the pinned commit established the gap — of the seven mining targets §8 ratifies, `sessions` / `save-session` / `resume-session`, `build-fix`, `code-review` and `project-init` exist **only** under `commands/` (94 files), and §4 names ECC's 68 `agents/` as `bankai`'s lineage and the sessions commands as `kaioken`'s. §10 Phase 3 is skills-only and Phase 4 named no ECC, so four of the seven ratified targets, and one plugin's primary source, had no phase that would ever audit them. Raised and landed at the G3 boundary, which is what `ROADMAP.md` §10 rule 4 exists for | Semantic → D-26 |
| 2 | §3: `eval/claude-mem-rebuild.md` added to the tree as a scaffold-stage (non-`[P6]`) entry — the Phase-3 file-based memory design for `rinnegan`. §10 Phase 3 already required the file *by path*; §3 did not list it, and a tree that omits a file the exit criteria name is an internal contradiction | Additive → D-26 |
| 3 | §12 decisions extended D-26; §3 comment updated to ADR-001…ADR-026 | Additive |
| 4 | Bookkeeping: version pointers in `CLAUDE.md`, `CONTEXT.md`, `README.md` and `DECISIONS.md`; validators re-bound — check D1 to the v2.6 version line, check D2 to exactly 26 ADR headings covering D-01…D-26, and check S2 to require `eval/claude-mem-rebuild.md`. That last item is explicit rather than incidental: `eval/gate-review-protocol.md` was a tracked §3 entry that S2 did not list until v2.5 §14 row 8 added it, and adding a §3 entry without adding it to S2 repeats that gap one version later. `DECISIONS.md` gains an ADR-026 Index row and "Next available" advances to ADR-027 | Additive |

Rationale of record: the widening is not new appetite, it is a hole Phase 3 measured. §8 ratified seven ECC mining targets in v2.0 and §10 then wrote Phase 3 as "270 ECC skills"; nobody noticed that four of the seven are commands until the tree was read at the pin. Phase 4 is the phase that sweeps up the remaining sources, and it is the phase that already annotates agent candidates with C-2 allowlists, so ECC's 68 agents belong beside wshobson's there rather than in a phase of their own. Phase 3 itself was executed exactly as ratified — skills only, 285 dispositioned, 40 deep-read — and the scope change lands at the gate afterwards, in the open, rather than being absorbed silently into the phase that found it.

### v2.6 → v2.7 (2026-08-22) — SPEC-GAP-001 resolved: an agent's `tools` is emitted as the documented string form (D-24)

| # | Change | Kind |
|---|---|---|
| 1 | §12 D-24 amended: **SPEC-GAP-001 is resolved.** Re-verified against the live official sub-agents reference on 2026-08-22 under the §0 re-verify rule, which D-7 binds to every phase gate. The reference documents an agent's `tools` **only** as a comma-separated string — every frontmatter example on the page is that form and no YAML list example appears — and states that `tools` omitted "Inherits every tool available to subagents", which is the premise C-2 rests on. The repo therefore **emits** the comma-separated string, the one documented form, and `schemas/agent.schema.json` and both validators keep **accepting either** form on read, as they already do. The list form's stated advantage was delimiter-unambiguity; for agents that is moot, because the documented delimiter is the comma and a reader must handle it regardless. Risk asymmetry decided the direction: an agent that fails to parse silently inherits the full tool set, which is a C-2 failure, whereas emitting the documented form costs three template lines | Semantic → D-24 (amended in place, ADR-024) |
| 2 | `templates/agent.md` converted to the string form at its three sites (slot frontmatter, worked example, and the Authoring Rules bullet); `CONTRIBUTING.md` rule 5 rewritten — the "resolved at G2" caveat is discharged. **No schema and no validator change**: `schemas/agent.schema.json`'s `anyOf` and the `tokens()` helper in both twins already accept both forms, and that acceptance is now the deliberate read-side rule rather than an incidental one | Clarifying → D-24 |
| 3 | **SPEC-GAP-002 opened** (see Open items). The same re-verification found a second undocumented assumption of the same kind: the repo expresses C-2 through parameterised grants such as `Bash(git ls-files:*)` **inside** an agent's `tools` field, but `Tool(specifier)` is documented as *permission-rule* syntax for `settings.json` allow/deny/ask rules, and the sub-agents reference documents a parenthesised form in `tools` only for `Agent(agent_type)`. Whether `tools` honours a `Bash` specifier is undocumented either way. It is recorded rather than guessed: unlike SPEC-GAP-001 it cannot be settled from documentation, so it is settled empirically at the Phase-6 gate, before any agent ships. Nothing changes today — the schema, both validators and the templates keep the parameterised form | Additive |
| 4 | Bookkeeping: version pointers in `CLAUDE.md`, `CONTEXT.md` and `README.md`; validator check D1 re-bound to the v2.7 version line in both twins. **Check D2 is untouched and the ADR count stays 26** — D-24's §12 cell already existed, so the SPEC v2.5 carve-out applies and ADR-024 is amended in place rather than superseded, which is what keeps D-16's §12↔ADR mapping 1:1 | Additive |

Rationale of record: the gap was opened by ADR-024 with the instruction "resolve before any agent ships", and Phase 4 is the phase that annotates every agent candidate with a C-2 allowlist — the first moment the question stops being theoretical. The direction was **not** predetermined: the plan of record recommended ratifying the list form, and the live fetch reversed it. That is the D48 pattern from Phase 3, where a fetch of the hooks reference overturned a design assumption, and it is why §0 requires re-verification at a gate rather than trusting a dated reading. The second residue was found by the same fetch and is deliberately left open rather than resolved by inference, because documentation silence is evidence of nothing.

Open items after v2.6: SPEC-GAP-001 (ADR-024) remains open — the official sub-agents reference documents an agent's `tools` as a comma-separated string while `templates/agent.md` standardizes the YAML list; resolve before any agent ships. `SPEC.md` §8's "~270 skills" figure for ECC is left as written: it is a dated role note from Phase 1, and `eval/triage-log.md` records the measured 897 / 285 split rather than restating it here. `eval/triage-log.md` keeps its "human approval gate" wording because audit content is frozen, and ADR-009, ADR-021 and ADR-025's own Context keep the historical phrasing: they record what was true when they were written.

### v2.7 → v2.8 (2026-08-25) — `eval/shortlist.md` enters the §3 tree (Phase-5 deliverable)

| # | Change | Kind |
|---|---|---|
| 1 | §3: `eval/shortlist.md` added to the tree as a scaffold-stage (non-`[P6]`) entry — the Phase-5 shortlist report, the per-plugin roster proposed for synthesis with lineage. `ROADMAP.md` §7 names it as a Phase-5 deliverable and §10 Phase 5 and `eval/gate-review-protocol.md` §3.4 make it a G5 input, but §3 admitted no file to hold it; a tree that omits a file the phase's exit path names is the same internal contradiction v2.6 row 2 corrected for `eval/claude-mem-rebuild.md`, and it is corrected the same way | Additive |
| 2 | Bookkeeping: version pointers in `CLAUDE.md`, `CONTEXT.md` and `README.md`; validators re-bound — check D1 to the v2.8 version line and check S2 to require `eval/shortlist.md`, in both twins, for the reason v2.6 row 4 records. **Check D2 is untouched and the ADR count stays 26**: no §12 cell changes at this version, so D-16's §12↔ADR mapping is unaffected and no ADR is written | Additive |

Rationale of record: this version adds a file and nothing else. The Phase-5 sign-off itself — the approved shortlist and build plan — lands as a §12 decision and its mirroring ADR only after the independent reviewer returns `APPROVED`, in the sign-off pull request D-25 names; writing that cell before the verdict would pre-decide the gate.

Open items after v2.8: unchanged from v2.7 — **SPEC-GAP-002 (ADR-024) is open**, settled empirically at the Phase-6 gate before any agent ships; §8's "~270 skills" figure and §10 Phase 3's missing `✅` marker are left as recorded below; `eval/triage-log.md` keeps its "human approval gate" wording because audit content is frozen.

Open items after v2.7: **SPEC-GAP-002 (ADR-024, opened v2.7) is open** — the repo expresses C-2 through parameterised grants such as `Bash(git ls-files:*)` inside an agent's `tools` field, but the official sub-agents reference documents a parenthesised form there only for `Agent(agent_type)`; `Tool(specifier)` is otherwise documented as permission-rule syntax for `settings.json`. Settle it empirically at the Phase-6 gate, before any agent ships. SPEC-GAP-001 is **closed** at v2.7. `SPEC.md` §8's "~270 skills" figure for ECC is left as written: it is a dated role note from Phase 1, and `eval/triage-log.md` records the measured 897 / 285 split rather than restating it here. §10 Phase 3's scope cell carries no `✅ Complete` marker although Phases 1 and 2 do; that inconsistency is recorded here rather than fixed outside a phase that touches §10. `eval/triage-log.md` keeps its "human approval gate" wording because audit content is frozen, and ADR-009, ADR-021 and ADR-025's own Context keep the historical phrasing: they record what was true when they were written.
