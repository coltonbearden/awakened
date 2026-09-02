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
| `super-saiyan` | Core | Core workflow discipline: plan, TDD, debug, verify, git — 18 skills, 9 commands | `/super-saiyan:plan`, `/super-saiyan:implement`, `/super-saiyan:tdd-red`, `/super-saiyan:tdd-green`, `/super-saiyan:commit` |
| `sharingan` | Core | Code review and analysis — 7 skills | `/sharingan:code-review` |
| `rinnegan` | Core | Temporal memory — session recall and capture, **file-based**, no daemons, no sqlite | `/rinnegan:capture`, `/rinnegan:recall` |
| `kaioken` | Core | Session momentum: handoff and resume across sessions | `/kaioken:save-session`, `/kaioken:resume-session`, `/kaioken:checkpoint`, `/kaioken:aside` |
| `bankai` | Core | The subagent arsenal — every agent ships a restricted tool allowlist | 7 dispatch skills, 27 subagents; no commands |
| `domain` | Core | Structural context: maps the project, generates project `CLAUDE.md` and rules; never stores history — 7 skills | `/domain:update-codemaps`, `/domain:update-docs` |
| `instinct` | Core | Meta tooling: skill creation, audit, validation, upstream review — 6 skills | `/instinct:learn-eval`, `/instinct:skill-create` |
| `poneglyph` | Satellite (optional) | The Obsidian toolset: obsidian-markdown, obsidian-cli, obsidian-bases, json-canvas | opt in |
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

**Phase 6 complete (2026-08-27); v0.1.0 released 2026-08-30; v0.1.1 released and the repository made public 2026-09-02 — the marketplace is live.** Historically: Governance, the evaluation harness, JSON schemas, the twin validators (`scripts/validate.sh` and `scripts/validate.ps1`), the pin scripts, and the component templates were committed first. `upstream.json` shipped with every commit SHA `null` by policy (§8); the SHAs were resolved by `scripts/pin-upstream.*` on 2026-08-18 and re-pinned on 2026-09-02 (T-289). The audit closed at 322 matrix rows — 96 shortlist, 211 reject, 15 merge, 0 defer.

Plugin content shipped after those audits, the independent-reviewer approval gate (G5) and the owner's acknowledgement (D-25): 114 component files across nine plugins, zero hooks. The sequence, the verification criteria for each phase, and the gate log live in [`ROADMAP.md`](ROADMAP.md).

## Repository map

| Path | What it is |
|---|---|
| `.claude-plugin/marketplace.json` | The marketplace catalog — nine plugins, in-repo sources |
| `plugins/<name>/` | The nine plugins: manifest in `.claude-plugin/`, then `skills/`, `commands/`, `agents/` (bankai), `statuslines/` and `output-styles/` (aura), `CHANGELOG.md` |
| `SPEC.md` | The ratified specification (v2.18) — the authority, shipped verbatim |
| `CLAUDE.md` | Operating rules for Claude Code sessions working in this repository |
| `CONTEXT.md` | Five-minute orientation: mission, principles, lineup, non-goals |
| `DECISIONS.md` | ADR-001…ADR-028 — every resolved decision, mirroring `SPEC.md` §12 one to one |
| `ROADMAP.md` | Build phases, verification criteria, approval gates, gate log |
| `upstream.json` | The ten source repositories: URL, license, role, and the commit pin |
| `eval/` | Scoring rubric (Markdown and JSON), the evaluation matrix, the triage log, the G5 review protocol, the `rinnegan` memory design, and the Phase-5 shortlist report |
| `schemas/` | JSON Schemas for marketplace, plugin, skill, and agent files |
| `scripts/` | `validate.sh` / `validate.ps1` and `pin-upstream.sh` / `pin-upstream.ps1` twins |
| `templates/` | Slot-bearing starting points for every component type, each with a worked example |
| `.github/workflows/` | CI: `validate.yml` runs both validators and the HD-12 twin-parity diff on every PR and push to `main`; `upstream-watch.yml` diffs the pins monthly |
| `tests/` | Known-good and known-bad component fixtures mapped to the validator check each exercises |
| `CONTRIBUTING.md`, `LICENSE` | Contribution and acceptance criteria; MIT |
| `SOURCES.md`, `NOTICE` | Provenance ledger (one row per shipped component) and the Apache-2.0 / EXC-1 MIT attributions |

## Trademarks and artwork

The plugin names reference trademarked anime franchises (Shueisha, Bandai, and others). This is the standard fan-project convention: **names only**. This repository and this README contain no franchise artwork, logos, or copyrighted graphical assets, and none will be accepted (`SPEC.md` §7). `awakened` itself is a generic English word. Awakened is not affiliated with, endorsed by, or sponsored by any rights holder.

## Contributing

Proposals are scored, not merged on vibes — see [`CONTRIBUTING.md`](CONTRIBUTING.md) for the two paths, the rubric gate, and the PR checklist. Validation is one command from the repository root and behaves identically on WSL2 bash and Windows PowerShell 7.

## License

MIT © 2026 Colton Bearden. Upstream attributions: [`SOURCES.md`](SOURCES.md) and [`NOTICE`](NOTICE).
