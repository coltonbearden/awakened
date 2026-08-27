# CLAUDE.md — Operating Rules for Claude Code Sessions in `awakened`

**Scope:** every Claude Code session working inside this repository.
**Governing document:** `SPEC.md` v2.13. On any conflict between this file and `SPEC.md`, `SPEC.md` wins and this file is corrected in the same commit.
**Repository:** `coltonbearden/awakened` — curated Claude Code plugin marketplace monorepo.

This file is **operational**. It does not restate `SPEC.md`'s normative content; it references it by rule ID (D-16). Where you need the rule itself, read `SPEC.md`.

---

## 0. Prime Directives

| # | Directive | Spec ref |
|---|---|---|
| PD-1 | `SPEC.md` is law. Read it before any structural, naming, or policy decision. Cite rule IDs, not prose. | §0 |
| PD-2 | Never violate a hard reject (HR-1…HR-8). There are no exceptions and no "just this once." | §6 |
| PD-3 | Synthesize, don't clone. Verbatim copying from upstream is prohibited; the sole exception is `poneglyph` ← `kepano/obsidian-skills`. | P-6, EXC-1 |
| PD-4 | Any deviation from `SPEC.md` or an Accepted ADR requires a new ADR in `DECISIONS.md` **before** merge. A spec change additionally requires a PR editing `SPEC.md` plus a §14 changelog row. | D-16, ADR-016 |
| PD-5 | Every script ships as a cross-platform pair — Windows 11 PowerShell 7 + WSL2 bash — with identical checks, messages, and exit codes. | C-1 |
| PD-6 | All changes pass the validation gate (§9) before commit. | E-2 |
| PD-7 | This repository contains zero secrets, zero telemetry, and zero runtime network calls. The sole sanctioned network use is repo-maintenance tooling: `scripts/pin-upstream.*` and `.github/workflows/upstream-watch.yml`. | HR-6 |

---

## 1. Document Precedence & Reading Order

Precedence on conflict (highest first):

1. `SPEC.md` — normative specification (v2.13)
2. `DECISIONS.md` — ADR-001…ADR-027; rationale and enforcement, mirroring SPEC §12 one-to-one
3. `CLAUDE.md` — this file; operational rules for sessions
4. `ROADMAP.md` — phase plan, verification criteria, approval gates
5. `CONTEXT.md` — descriptive orientation
6. `README.md` — public-facing summary

An ADR **MUST NOT** supersede, override, or reclassify a `SPEC.md` cell (ADR-016). Where it would need to, the change goes through the spec PR instead.

Reading order for a fresh session: `CONTEXT.md` → `SPEC.md` → this file → `ROADMAP.md` (current phase) → `DECISIONS.md` (as needed).

---

## 2. Repository Layout

The canonical tree is `SPEC.md` §3. Do not maintain a second copy of it here — read §3.

**Delivery stage of §3 entries.** Ratified — SPEC v2.2, D-19 (formerly open as A-GAP-001 / B-GAP-001): `SPEC.md` §3 now tags Phase-6 entries `[P6]`, and validators **MUST** treat `[P6]` entries as expected-absent by default and as required under `--release` / `-Release`. The table below mirrors those tags for quick reference — §3 is the authority, and `scripts/validate.*` check S3 implements it:

| §3 entry class | Stage | Present at scaffold |
|---|---|---|
| Root governance docs, `upstream.json`, `.gitattributes`, `eval/`, `schemas/`, `scripts/`, `templates/` | Foundation | Yes — validated |
| `.github/workflows/validate.yml` | Foundation (v2.5) | Yes — validated (S2) |
| `.claude-plugin/marketplace.json` | Phase 6 (§10) | No — expected absent |
| `plugins/<name>/` contents and manifests | Phase 6 (§10) | No — expected absent |
| `tests/` fixtures | Phase 6 (§10) | No — expected absent |
| `.github/workflows/upstream-watch.yml` | Phase 6 (§10) | No — expected absent |

This classification is normative in `SPEC.md` §3 under D-19 (ADR-019); the table above only restates it operationally and is corrected from §3 on any difference.

Each plugin follows the official layout — manifest in `.claude-plugin/`, components at plugin root (`SPEC.md` §3, second tree).

---

## 3. Environment & Cross-Platform Rules

### 3.1 Target matrix

| Target | Shell | Minimum version | Notes |
|---|---|---|---|
| Windows 11 | PowerShell 7 (`pwsh`) | 7.0 | `#Requires -Version 7`. Windows PowerShell 5.1 is **not** a supported target. |
| WSL2 (Ubuntu) | bash | 4.4 | WSL2 Ubuntu ships bash 5.x; do not assume WSL-only paths |

PowerShell 7-only syntax is permitted. The 5.1 compatibility floor is withdrawn (C-1 and the cross-platform standard name PowerShell 7 explicitly).

### 3.2 Script pairing rule

Every executable script exists as a twin pair — `scripts/<name>.sh` and `scripts/<name>.ps1` — with identical inputs, outputs, side effects, numbered check lists, and exit codes. Behavioral drift between twins is a bug, not a variant.

### 3.3 Exit code convention (repo standard, all scripts)

| Code | Meaning |
|---|---|
| 0 | Clean |
| 1 | Violations — policy or structural; each failure line names its check ID and class |
| 2 | Environment error (missing interpreter, unreadable tree, missing schema files) |

### 3.4 Line endings and encoding

- **LF for every file, no exceptions** — `*.ps1` and `*.psm1` included. The PowerShell target is 7 (§3.1), which reads LF natively; no CRLF carve-out exists (`SPEC.md` §3, `.gitattributes`).
- UTF-8 **without** BOM everywhere, `*.ps1` included. Non-ASCII literals in scripts are avoided rather than BOM-enabled.
- Enforced two ways, both from the first commit: `.gitattributes` at repo root, and check L1 in `scripts/validate.*` — a CR byte or a BOM in any tracked text file is a violation (exit class 1).
- On Windows, set `git config core.autocrlf false` before cloning. `core.autocrlf=true` is the Windows default and would rewrite every `*.sh` to CRLF, making it unrunnable under WSL2.

### 3.5 Path discipline

- Forward slashes in all documentation, JSON, and frontmatter.
- Components reference intra-plugin files via `${CLAUDE_PLUGIN_ROOT}` — never relative guesses, never absolute machine paths.
- Never hardcode a user home path, a WSL mount path, or any machine-specific path in any shipped component.
- Hook and component write scope is governed by HR-8 as reconciled by D-18: writes are permitted **only** to (a) the active project directory or (b) the owning plugin's own data directory under the user's Claude configuration directory. Any other target is a hard reject. See ADR-018.

### 3.6 Network policy

- Shipped components make zero network calls of any kind (HR-6).
- The only sanctioned network activity in this repository is repo-maintenance tooling, never shipped to a user machine: `scripts/pin-upstream.sh` / `scripts/pin-upstream.ps1` (SHA resolution, §8) and `.github/workflows/upstream-watch.yml` (monthly diff, §11).

---

## 4. Naming Standards

All naming rules are N-1…N-6 in `SPEC.md` §5. Operationally:

- Lowercase kebab-case for every machine-facing name, matching `^[a-z0-9]+(-[a-z0-9]+)*$` (N-3).
- Tier 1 plugin names are fixed at the nine in `SPEC.md` §5 (N-1).
- Tier 2 dramatic technique names exist **only** as `aura` preset identifiers (N-1). Preset IDs must not duplicate a Tier 1 plugin name (N-5, D-17) — the statusline preset formerly called `domain` is `barrier` (ADR-017).
- Commands namespace under the **plugin** name: `/<plugin>:<verb>`. The marketplace-level namespace is prohibited — no catch-all plugin may exist (N-4).
- Skill and command names carry the **function**; plugin names carry the theme. A skill's frontmatter `description` drives auto-invocation: state concrete triggers and the observable outcome (N-2).
- New plugin names follow the Future Naming Logic in `SPEC.md` §5: scope and boundaries first, name second (N-6).

---

## 5. Coding Standards

### 5.1 Markdown

- One H1 per file; ATX headings; no skipped heading levels.
- Fenced code blocks always carry a language tag.
- Tables over prose for structured data. Soft line-length limit 120 characters.
- No HTML comments, no stub markers, no ellipsis stubs — every section is complete at commit time.

### 5.2 JSON

- 2-space indent, LF, trailing newline, no comments, keys in stable logical order.
- Every `marketplace.json`, `plugin.json`, hook config, and agent definition validates against its schema in `schemas/`.

### 5.3 Bash

```bash
#!/usr/bin/env bash
set -euo pipefail
```

- Quote all expansions; use arrays rather than word-split strings; no `eval`, no piping a download into a shell, no `sudo`.
- Use `trap` for temp-file cleanup; write temp files under `${TMPDIR:-/tmp}` only.
- Follow the §3.3 exit code convention; the final line of a validator prints `VALIDATE: PASS` or `VALIDATE: FAIL`.

### 5.4 PowerShell

```powershell
#Requires -Version 7
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
```

- No aliases in scripts (`Get-ChildItem`, not `gci`); `Join-Path` for all path construction; no `Invoke-Expression`; no execution-policy tampering.
- Comparisons that enforce a naming or policy rule use the **case-sensitive** operators (`-cmatch`, `-ceq`, `-cin`, `-ccontains`). PowerShell's default operators are case-insensitive and would let a name that bash rejects pass on Windows (N-3).
- Mirror the §3.3 exit code convention and the `VALIDATE: PASS|FAIL` final line exactly.

### 5.5 Component file types

Components are Markdown (`.md`) and JSON (`.json`). The one exception is `aura`, which `SPEC.md` §5 states "ships as statusline scripts with ANSI palettes" — those are `.sh`/`.ps1` twin pairs under `plugins/aura/statuslines/` (D-23, ADR-023), LF, zero dependencies (P-5), read-only outside the user's own configuration. No compiled code, no bundled binaries, no runtime package installation anywhere (HR-5, HR-7).

---

## 6. Component Authoring Rules

Component priority (D-04, ADR-004): **skills > commands > agents (curated) > hooks (minimal) > rules/templates.** Before authoring any lower-priority form, record in the PR description why the higher-priority forms cannot do the job.

Open the matching file in `templates/` and the matching schema in `schemas/` before writing any component.

### 6.1 Skills

- One `SKILL.md` per skill with frontmatter validating against `schemas/skill.schema.json`; optional resource files beside it.
- Size discipline is a scored rubric axis (§9 Bloat): instruction files stay as small as the job allows.
- No auto-invoked side effects: a skill instructs; it does not silently install, fetch, or persist outside the project (P-3).

### 6.2 Commands

- One command = one action, namespaced `/<plugin>:<verb>`; arguments documented in frontmatter.
- Commands are the visible surface (P-3).

### 6.3 Agents

- All subagents live in `bankai` (B-6).
- Explicit restricted tool allowlists only. Bare `Bash(*)` or unrestricted `Write(*)` are hard failures, enforced mechanically by `schemas/agent.schema.json` (C-2). Omit `Bash` unless the job needs a shell: the harness does not honour a `Bash(<command>:*)` specifier inside `tools` (SPEC-GAP-002, closed at v2.13) — it documents intent, and the agent body states the boundary.
- Every agent defines a handoff contract: expected inputs, produced outputs, stop conditions.

### 6.4 Hooks — budget and safety

Maximum one hook per plugin, load-bearing only (P-4, D-15, ADR-015). The complete budget:

| Plugin | Hook | Status |
|---|---|---|
| `super-saiyan` | Session-start skill-discipline injector (superpowers lineage) | Budgeted — **not shipped at v1**; ships as a skill (D-24 as amended v2.13) |
| `rinnegan` | Optional memory-capture, rebuilt lightweight — no workers, no daemons | Budgeted — **not shipped at v1**; ships as `/rinnegan:capture` (D-24 as amended v2.13) |
| All other plugins | — | Prohibited without a superseding ADR **and** a `SPEC.md` §6 amendment |

Every hook must satisfy C-1 in full — idempotent, read-only by default, timeout-bounded, and, where it executes shell commands, cross-platform — plus the D-18 write scope in §3.5. Repo standard timeout: ≤ 10 seconds wall clock, declared explicitly in the hook manifest. Ratified — SPEC v2.2, D-22 (formerly open as A-GAP-005): C-1 binds **every** hook regardless of handler type, so a prompt-only hook still declares a timeout; the cross-platform clause is the one part that stays specific to shell-command handlers. See ADR-022.

A failing hook logs a warning and must never corrupt state or block the user's session.

---

## 7. Safety Policy Enforcement

The policy itself is `SPEC.md` §6. This section says how it is enforced here, not what it says.

- **Hard rejects HR-1…HR-8** — automatic failure, overriding every score. HR-8 carries the D-18 carve-out (§3.5); any restatement of HR-8 that omits the carve-out is a policy bug, because it re-creates the contradiction D-18 resolved and would reject `rinnegan`'s budgeted hook.
- **Conditionals C-1…C-3** — audited; kept only if every check passes. C-2 is enforced mechanically by `schemas/agent.schema.json`; C-1 and C-3 are enforced by `scripts/validate.*` plus PR review.
- **Every component E-1/E-2** — static review for prompt-injection patterns, secrets handling, and obfuscation; and a passing `scripts/validate.*` run before merge.

Static review checklist for every PR:

- Prompt-injection patterns — instructions to act without asking, to bypass confirmation, or to ignore prior policy.
- Secrets handling — nothing reads, echoes, or persists credentials; the repo itself contains no secrets or tokens.
- Obfuscation — encoded payloads, base64 blobs, minified logic, or misleading names.
- Scope creep — the component belongs to exactly one owning plugin under B-1…B-8.

---

## 8. Git & Change Control

- **Conventional Commits.** Types: `feat` `fix` `docs` `refactor` `test` `chore` `build` `ci`. Scope = plugin or area: `feat(rinnegan): add recall command`.
- **Squash-merge only.** Linear history on the default branch `main`.
- **No force flags.** `--force` and `--force-with-lease` are prohibited in every context.
- **Branch naming.** `feat/<area>-<slug>`, `fix/<area>-<slug>`, `docs/<slug>`.
- **ADR discipline.** Accepted ADRs are immutable — supersede with a new ADR, never edit. The one carve-out (SPEC v2.5): a spec PR that amends an existing `SPEC.md` §12 cell amends the mirroring ADR **in place** — dated `Amended` field row plus dated italic notes at each changed passage, `Status` unchanged — because D-16 requires the 1:1 mapping to hold. Architectural deviations get their ADR before merge (PD-4).
- **`upstream.json` discipline.** Commit SHAs are `null` at scaffold and are written **only** by `scripts/pin-upstream.*` (§8: "No SHA may ever be typed from memory"). Re-pins that affect a prior evaluation get an entry in `eval/triage-log.md`.
- **Attribution.** Update `SOURCES.md` in the same commit that adds or materially revises a synthesized component. No per-file headers (D-12).
- **Releases.** Versioned via git tags; per-plugin `CHANGELOG.md` (§11).

---

## 9. Verification Gates (run from repo root, both platforms)

| Gate | WSL2 command | Windows 11 command | Expected |
|---|---|---|---|
| Structure, naming, policy, encoding | `bash scripts/validate.sh` | `pwsh -File scripts/validate.ps1` | Exit 0; final line `VALIDATE: PASS` |
| Release readiness | `bash scripts/validate.sh --release` | `pwsh -File scripts/validate.ps1 -Release` | Exit 0 once the Phase-6 tree entries exist |
| CI — both validators plus HD-12 parity | runs on GitHub Actions | runs on GitHub Actions | `.github/workflows/validate.yml` green; required check on `main` |

Both twins publish the same numbered check list in their header comment (S1–S4, D1–D2, N1/N3/N4/N5, U1–U2, R1, M1–M2, C1–C4, H1–H3, P1–P4, L1) and emit the same message strings. That list is the contract; the header is where a reviewer checks parity.

**What the validators do and do not enforce.** They check tree structure, ADR/spec parity, naming, the `upstream.json` and rubric shapes, the matrix header and row lint, hook budget and timeouts, the C-2 allowlist rule, the policy lint over shipped components, and line endings. They **parse** every file in `schemas/` and assert it declares `$schema` and `$id`, but they do not run a full JSON Schema evaluation — that would need a validator library, and HR-7 forbids installing one. Schema conformance is enforced at review time and in CI, where a JSON Schema tool may be used; the C-2 rule is the one schema constraint the validators reimplement directly, so it holds even when no schema evaluator is available.

Invoke with the interpreter named explicitly (`bash …`, `pwsh -File …`) rather than relying on the executable bit or a file association; the repository does not depend on POSIX permission bits surviving a Windows checkout.

**Windows first run.** If `pwsh -File scripts/validate.ps1` fails before printing anything, the machine's execution policy is blocking the script. Run it for the current process only — `pwsh -ExecutionPolicy Bypass -File scripts/validate.ps1` — or set `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` once. Scripts in this repository never change execution policy themselves.

The validators depend on tools guaranteed present on their platform: bash plus `python3` on WSL2 for JSON parsing, and PowerShell 7's built-in JSON cmdlets on Windows. Nothing is auto-installed (HR-7); a missing interpreter is an environment error (exit 2), not a violation.

Run before every commit. `.github/workflows/validate.yml` (SPEC v2.5) re-runs both validators on every pull request and every push to `main`, and adds the HD-12 twin-parity check: the two legs' output, CRLF-normalized, must be byte-identical. It is a **required check on `main` by repository ruleset**, so a red run blocks the merge and direct pushes to `main` are blocked with it. It installs nothing on GitHub-hosted runners — they ship PowerShell 7 and Python 3 — and makes no network call beyond the checkout, so it is not a new HR-6 or HR-7 exception. A green local run is a required precondition, not a substitute.

---

## 10. Prohibited Actions for Sessions in This Repo

- Adding any dependency, package manager step, lockfile, or runtime fetch (HR-7).
- Adding MCP server configuration beyond Obsidian, Context7, and Claude Code (HR-2).
- Creating a marketplace-namespaced command or any catch-all plugin (N-4).
- Copying upstream files verbatim outside EXC-1 (P-6); record lineage in `SOURCES.md`.
- Adding franchise artwork, logos, or media assets — names only (§7).
- Committing secrets, tokens, or machine-specific configuration.
- Editing an Accepted ADR outside the in-place amendment carve-out in §8 (a spec PR amending the §12 cell it mirrors, with the dated `Amended` row and dated notes), rewriting `SPEC.md` normative content outside the D-16 PR flow, or renaming Tier 1 plugins without a superseding ADR.
- Writing a commit SHA into `upstream.json` by hand (§8).
- Writing hooks, scripts, or components that touch paths outside the D-18 write scope.

---

## 11. Standard Session Loop

1. **Orient** — read the precedence docs (§1) and the current `ROADMAP.md` phase; do not perform work gated behind an approval that has not been recorded.
2. **Plan** — for any multi-file change, state the plan and the affected boundaries (B-1…B-8) before editing.
3. **Implement** — within the naming, coding, and component rules (§4–§6), from the matching template and schema.
4. **Validate** — run both platform gates (§9); fix to green.
5. **Record** — deviations become ADRs; evaluation outcomes land in `eval/matrix.csv` and `eval/triage-log.md` the same session.
6. **Commit** — Conventional Commit, squash-merge, no force flags, `SOURCES.md` updated in the same commit.
