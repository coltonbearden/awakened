# Awakened

**A curated Claude Code plugin marketplace: the best of the open-source ecosystem, synthesized — with the bloat and the risk engineered out.**

Nine plugins. Zero daemons, zero databases, zero API keys, zero telemetry. Everything installs at user scope and works in any project, any language, any stack. Every component is scored against a published rubric, screened against a published safety policy, and rebuilt to one standard — provenance for all of it lives in [`SOURCES.md`](SOURCES.md).

## Install

```bash
claude plugin marketplace add coltonbearden/awakened
```

Then install plugins individually — each one installs, tests, and removes independently:

```text
/plugin install super-saiyan@awakened
```

Requires [Claude Code](https://claude.com/claude-code).

## The lineup

| Plugin | Category | What it does | Surface |
|---|---|---|---|
| `super-saiyan` | Core | Core workflow discipline: plan, TDD, debug, verify, git | `/super-saiyan:plan` |
| `sharingan` | Core | Code review and analysis | `/sharingan:review` |
| `rinnegan` | Core | Temporal memory — session recall and record, **file-based**, no daemons, no sqlite | `/rinnegan:recall`, `/rinnegan:record` |
| `kaioken` | Core | Session momentum: handoff and resume across sessions | `/kaioken:handoff`, `/kaioken:resume` |
| `bankai` | Core | The subagent arsenal — every agent ships a restricted tool allowlist | `/bankai:dispatch`, `/bankai:research` |
| `domain` | Core | Structural context: maps the project, generates project `CLAUDE.md` and rules; never stores history | `/domain:map`, `/domain:context` |
| `instinct` | Core | Meta tooling: skill creation, audit, validation, upstream review | `/instinct:validate`, `/instinct:audit` |
| `poneglyph` | Satellite (optional) | The Obsidian toolset: obsidian-markdown, obsidian-cli, obsidian-bases, json-canvas, defuddle | opt in |
| `aura` | Satellite (optional) | Palettes, statusline presets, and output styles — the fun lives here | `/aura:equip` |

Commands are namespaced per plugin. There is deliberately no marketplace-level catch-all namespace (N-4), and satellites are never dependencies of core (B-8).

## Design principles

The normative statements are `SPEC.md` §1, P-1 through P-6. In brief:

| ID | Principle |
|---|---|
| P-1 | Every plugin installs, tests, and removes independently |
| P-2 | Lightweight means user-scope safe: nothing project-, language-, or LSP-specific at user level |
| P-3 | Prefer skills and commands — explicit surfaces — over hidden automation |
| P-4 | Hooks are exceptional: at most one per plugin, only where load-bearing; the entire marketplace budgets **two** |
| P-5 | No third-party tooling, services, keys, daemons, or databases. Allowed exceptions: Obsidian, Context7, Claude Code |
| P-6 | Synthesize, don't clone: components are rebuilt to one standard, never bulk-imported |

## What is never in this marketplace

Third-party API keys or accounts · MCP servers beyond Obsidian, Context7 and Claude Code · LSP or language-specific tooling at user scope · background daemons, workers, or watchers · sqlite or native binaries · telemetry, analytics, or network calls in any shipped component · auto-installing packages · hooks that write outside the project directory or the owning plugin's own data directory.

The full policy with trigger IDs is `SPEC.md` §6, indexed for audit use in [`eval/rubric.md`](eval/rubric.md) §3. Every component also passes static review and `scripts/validate.*` before merge (E-1, E-2).

The one sanctioned network use in the whole repository is maintenance tooling that never ships to a user: `scripts/pin-upstream.*`, which resolves upstream commit SHAs, and the monthly upstream-watch workflow.

## Status

**Foundation complete, plugin content not yet built.** Governance, the evaluation harness, JSON schemas, the twin validators (`scripts/validate.sh` and `scripts/validate.ps1`), the pin scripts, and the component templates are committed. `upstream.json` shipped with every commit SHA `null` by policy (§8); the SHAs were resolved by `scripts/pin-upstream.*` on 2026-08-18. The Phase-2 Tier-1 audit has since scored 55 components — 27 shortlist, 25 reject, 3 merge.

Plugin content lands after those audits, after the independent-reviewer approval gate, and after the project owner acknowledges that approval (D-25). The sequence, the verification criteria for each phase, and the gate log live in [`ROADMAP.md`](ROADMAP.md).

## Repository map

| Path | What it is |
|---|---|
| `SPEC.md` | The ratified specification (v2.11) — the authority, shipped verbatim |
| `CLAUDE.md` | Operating rules for Claude Code sessions working in this repository |
| `CONTEXT.md` | Five-minute orientation: mission, principles, lineup, non-goals |
| `DECISIONS.md` | ADR-001…ADR-027 — every resolved decision, mirroring `SPEC.md` §12 one to one |
| `ROADMAP.md` | Build phases, verification criteria, approval gates, gate log |
| `upstream.json` | The ten source repositories: URL, license, role, and the commit pin |
| `eval/` | Scoring rubric (Markdown and JSON), the evaluation matrix, the triage log, the G5 review protocol, the `rinnegan` memory design, and the Phase-5 shortlist report |
| `schemas/` | JSON Schemas for marketplace, plugin, skill, and agent files |
| `scripts/` | `validate.sh` / `validate.ps1` and `pin-upstream.sh` / `pin-upstream.ps1` twins |
| `templates/` | Slot-bearing starting points for every component type, each with a worked example |
| `.github/workflows/` | CI: `validate.yml` runs both validators and the HD-12 twin-parity diff on every PR and push to `main` |
| `SOURCES.md`, `NOTICE` | Provenance ledger and Apache-2.0 attributions |

## Trademarks and artwork

The plugin names reference trademarked anime franchises (Shueisha, Bandai, and others). This is the standard fan-project convention: **names only**. This repository and this README contain no franchise artwork, logos, or copyrighted graphical assets, and none will be accepted (`SPEC.md` §7). `awakened` itself is a generic English word. Awakened is not affiliated with, endorsed by, or sponsored by any rights holder.

## Contributing

Proposals are scored, not merged on vibes — see [`CONTRIBUTING.md`](CONTRIBUTING.md) for the two paths, the rubric gate, and the PR checklist. Validation is one command from the repository root and behaves identically on WSL2 bash and Windows PowerShell 7.

## License

MIT © 2026 Colton Bearden. Upstream attributions: [`SOURCES.md`](SOURCES.md) and [`NOTICE`](NOTICE).
