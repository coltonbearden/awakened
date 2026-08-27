# CONTEXT.md — Awakened System Overview

**Purpose of this file:** orient a new session or contributor in under five minutes. This file is **descriptive**; `SPEC.md` v2.13 is normative and wins every conflict. Nothing here restates a spec rule — rules are referenced by ID (D-16).

---

## 1. What Awakened Is

Awakened is a curated Claude Code plugin marketplace: a "best-of" synthesis of the strongest open-source Claude Code repositories, rebuilt from scratch with the bloat, risk, and friction of the originals engineered out. It ships as a single GitHub monorepo (`coltonbearden/awakened`) containing nine independently installable plugins behind one marketplace catalog.

Core promise: **curated, lightweight, safe, modular upgrades for Claude Code.**

## 2. How It Works

1. A user runs `claude plugin marketplace add coltonbearden/awakened` once.
2. The user installs only the plugins they want — each is independently installable, testable, and removable (P-1).
3. Plugins deliver capability primarily through **skills** (auto-invoked via description matching) and **commands** (`/<plugin>:<verb>`), with a small curated set of restricted subagents and at most one load-bearing hook per plugin (P-3, P-4).
4. Every shipped component is a new implementation synthesized from the best logic of ten vetted upstream repositories — never a verbatim copy (P-6). The single recorded exception is `poneglyph` (EXC-1).

## 3. Design Principles

The six governing principles are **P-1 … P-6** in `SPEC.md` §1. They are not reproduced here — read §1 and cite the IDs. In one line each, so you know which ID to look up:

| ID | Concerns |
|---|---|
| P-1 | Independent installability |
| P-2 | Lightweight means user-scope safe |
| P-3 | Skills and commands over hidden automation |
| P-4 | Hooks are exceptional |
| P-5 | No third-party tooling, services, keys, daemons, or databases |
| P-6 | Synthesize, don't clone |

Universal component requirements are **E-1** (static review) and **E-2** (validators pass before merge). Conditional requirements are **C-1 … C-3**. Hard rejects are **HR-1 … HR-8**, with HR-8 read together with **D-18** (see ADR-018).

## 4. User Profile

**Target user.** Any Claude Code user, on any platform, language, or stack, who wants stronger workflows without importing an ecosystem: no accounts, no API keys, no daemons, no databases, no telemetry, nothing to babysit. Components install at user scope and must earn their place on every project (P-2, D-11).

**Maintainer.** Solo developer (GitHub: `coltonbearden`). Daily environments: Windows 11 with PowerShell 7 and WSL2 Ubuntu with bash — which is why cross-platform script parity is a repo-level invariant, not an aspiration (C-1). Distribution is GitHub-only; there is no CLI installer, registry, or website (D-02).

## 5. Plugin Lineup at a Glance

Responsibilities and boundaries are normative in `SPEC.md` §4 (B-1…B-8). This table is the orientation index only.

| Plugin | One-liner | Tier |
|---|---|---|
| `super-saiyan` | Core engineering workflow: plan, implement, TDD, debug, verify, git discipline | Core |
| `sharingan` | Code review & analysis: review, inspect, regressions, patterns, security-oriented review | Core |
| `rinnegan` | Persistent **temporal** memory: decisions, session context, recall — file-based only | Core |
| `kaioken` | Session momentum: save/resume, handoffs, focused execution | Core |
| `bankai` | Curated specialist subagents with restricted tool allowlists | Core |
| `domain` | **Structural** project context: maps, conventions, rules, CLAUDE.md scaffolding | Core |
| `instinct` | Marketplace meta tooling: skill creation, auditing, validation, upstream review | Core |
| `poneglyph` | Obsidian knowledge-vault integration | Optional satellite |
| `aura` | Personalization: palettes, statusline presets, output styles, `/aura:equip` | Optional satellite |

## 6. Ownership Boundaries (the arbiter for scope disputes)

Normative text is `SPEC.md` §4, B-1…B-8. The practical shape of it:

- **Temporal context** (what happened, what was decided) → `rinnegan` (B-3). **Structural context** (what the system is now) → `domain` (B-4). The two never blur.
- **All subagents** and their tool permissions → `bankai` (B-6).
- **Baseline workflow** → `super-saiyan` (B-1); it depends on no agents, no memory infrastructure, no project-specific tooling.
- **Analysis and review** → `sharingan` (B-2); it never becomes the execution plugin.
- **Session momentum** → `kaioken` (B-5); it duplicates no planning, debugging, or review systems.
- **Marketplace maintenance, validation, quality gates** → `instinct` (B-7).
- `poneglyph` and `aura` are satellites — never dependencies of a core plugin (B-8).

Every accepted component has exactly one owning plugin. A component with no clear owner, or two plausible owners, is not shortlistable.

## 7. Component Priority

**skills > commands > agents (curated) > hooks (minimal) > rules/templates** (D-04, ADR-004). Authoring a lower-priority form requires justifying why the higher forms cannot do the job.

## 8. Explicit Architectural Non-Goals

Awakened is deliberately **not**:

- A per-language toolkit — no language packs, no LSP servers, no language-specific tooling at user scope (HR-3, P-2).
- An automation daemon — no background workers, watchers, services, or scheduled processes on user machines (HR-4).
- A data platform — no sqlite, no native binaries, no databases, no cloud sync (HR-5); `rinnegan` is plain files (B-3).
- A connected product — no telemetry, no analytics, no network calls, no accounts, no third-party API keys (HR-1, HR-6); MCP surface limited to Obsidian, Context7, and Claude Code (HR-2). The sanctioned exception is repo-maintenance tooling only: `scripts/pin-upstream.*` and `.github/workflows/upstream-watch.yml`.
- A package manager — no auto-installed packages, no runtime dependency fetching, no npm CLI installer (HR-7).
- A mirror — not a fork or re-host of the ten upstream repos; components are synthesized (P-6) and upstreams are pinned in `upstream.json` for evaluation only.
- A catch-all — no plugin named for the marketplace and no marketplace-level command namespace (N-4); every component has exactly one owning plugin.
- A fan-art project — anime names only; franchise artwork and logos never enter the repo or README (§7).

## 9. Current State

- **Spec:** v2.13 governing (`SPEC.md`), dated 2026-08-27. It ships verbatim at repository root and is never regenerated (D-16).
- **Phase 1 (structural inventory):** complete per `SPEC.md` §10 — all ten source repos crawled, structure, counts, and licenses mapped into §8.
- **Phase 2 (Tier-1 deep audit):** complete 2026-08-18 — 55 scored `eval/matrix.csv` rows, 27 shortlist / 25 reject / 3 merge, triage T-001…T-028; gate G2 approved.
- **Foundation suite:** governance, evaluation harness, schemas, validation scripts, templates, the legal framework, and the CI workflow (`.github/workflows/validate.yml`, v2.5) are committed. See `ROADMAP.md` §2.
- **Upstream pins:** resolved 2026-08-18 by `scripts/pin-upstream.sh` — ten non-null commits, non-null `pinned_at` (§8).
- **Next milestone:** Phase 3 — ECC triage against the §9 rubric, plus the claude-mem concept extraction written to `eval/claude-mem-rebuild.md` (`ROADMAP.md` §5).

## 10. Reading Order

1. This file — orientation.
2. `SPEC.md` — the governing specification (§0–§14).
3. `CLAUDE.md` — operating rules for sessions working in this repo.
4. `ROADMAP.md` — current phase, deliverables, verification gates.
5. `DECISIONS.md` — ADR-001…ADR-027 when rationale or enforcement detail is needed.
