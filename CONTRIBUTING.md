# Contributing to Awakened

Awakened is a **curated** marketplace, not a collection. Every component that ships was scored against a rubric, screened against a safety policy, and synthesized to one standard — contributions go through the same gate. Read `CONTEXT.md` first (five minutes), then `SPEC.md` for anything you intend to touch. `SPEC.md` is the authority; this file is the process.

## The two contribution paths

| Path | What it is | Where it starts |
|---|---|---|
| **Component proposal** | A new skill, command, or agent, or an upstream component worth synthesizing | An issue containing a filled evaluation row (below) — not a PR |
| **Fix or hardening** | Corrections to existing components, docs, schemas, or validators | A PR directly, small and focused |

New plugins are out of scope: the nine-plugin lineup is fixed by `SPEC.md` §4 and D-14, and changes only by a superseding ADR.

### Proposing a component

Open an issue titled `proposal: <plugin>/<component-name>` containing every `eval/matrix.csv` column for your candidate, self-scored against `eval/rubric.md` — axes and anchors in §2, policy trigger IDs in §3. The maintainer audits at the pinned SHA in `upstream.json` (for upstream material) or against the rubric directly (for original work), records the official row, and applies the §4 verdict rules: `shortlist` requires no hard-reject hit, every axis ≥ 3, and exactly one owning plugin.

Shortlisted is not accepted. Inclusion happens only at the `SPEC.md` §10 Phase-5 gate, which is adjudicated by an independent reviewer against `eval/gate-review-protocol.md` (D-25). The sign-off is recorded as an ADR in `DECISIONS.md` (`ROADMAP.md` G5), and the reviewer's `APPROVED` is provisional until the project owner acknowledges it on the sign-off PR.

### What gets rejected without discussion

Any hard-reject trigger. The definitions are `SPEC.md` §6; `eval/rubric.md` §3 is the audit-time index. Note HR-8's D-18 carve-out — it is what makes `rinnegan`'s memory hook legal, and omitting it re-creates the contradiction D-18 resolved:

| ID | Trigger |
|---|---|
| HR-1 | Third-party API keys, external services, or accounts |
| HR-2 | MCP servers beyond Obsidian, Context7, and Claude Code |
| HR-3 | LSP servers or language-specific tooling at user scope |
| HR-4 | Background daemons, workers, watchers, or services |
| HR-5 | sqlite/native binary dependencies |
| HR-6 | Telemetry, analytics, or network calls of any kind. Sole exception: `scripts/pin-upstream.*` and `.github/workflows/upstream-watch.yml`, which are repo-maintenance tooling, not shipped components |
| HR-7 | Auto-installing packages or runtime dependency fetching |
| HR-8 | Hooks that write outside (a) the project directory or (b) the owning plugin's own data directory under the user's Claude config dir (**D-18**) |

Also closed by standing decision: new hooks beyond the D-15 budget (`super-saiyan` session-start and `rinnegan` memory-capture are the entire automatic-execution surface); verbatim clones (P-6, with EXC-1 the sole named exception); and anything language- or stack-specific at user scope (P-2, D-11).

## Naming rules

Every machine-facing name is governed by `SPEC.md` §5. Contributors most often trip on N-4 and N-5:

| ID | Rule as it applies to a contribution |
|---|---|
| N-1 | Two tiers. Tier 1 is the nine short plugin names, typed constantly. Tier 2 is the full dramatic technique names, which exist **only** as `aura` preset identifiers and are never typed as commands |
| N-2 | Plugin names carry the theme; **skill and command names carry the function**. A skill auto-invokes on its frontmatter `description`, so a clever name with a vague description never fires |
| N-3 | Every machine-facing name is lowercase kebab-case, matching `^[a-z0-9]+(-[a-z0-9]+)*$`. The validator checks this case-sensitively, so `Super-Saiyan` fails on both platforms rather than passing on one |
| N-4 | Commands namespace under the **plugin** name, never the marketplace name. A marketplace-level namespace would imply a catch-all plugin, which is prohibited |
| N-5 | A Tier-2 preset identifier must not duplicate a Tier-1 plugin name (D-17). This is why the statusline preset is `barrier` and not `domain` — see ADR-017 |
| N-6 | Reject names that are too vague to communicate purpose, too long to type (Tier 1), tied to a temporary implementation, or overlapping an existing plugin |

## Development environment

| Requirement | Notes |
|---|---|
| Windows 11 with PowerShell 7, or WSL2 with bash, or both | Everything ships cross-platform; test on what you have and state what you did not test |
| bash 4.4 or newer (WSL2) | `scripts/*.sh` |
| PowerShell 7 or newer (`pwsh`) | `scripts/*.ps1`. Windows PowerShell 5.1 is not a supported target |
| python3 3.8 or newer on PATH, WSL2 only | Used by the bash validator and the bash pin script for JSON and CSV parsing. Standard on WSL2 Ubuntu; nothing is installed for you (HR-7). The PowerShell twins need no Python |
| git, with Conventional Commits | See commit discipline below |

Set `git config core.autocrlf false` before cloning on Windows. `.gitattributes` forces LF, and the validator's check L1 fails on a CR byte or a UTF-8 BOM.

## The authoring loop

1. **Start from `templates/`.** Every template names its schema, carries angle-bracket slot markers, and embeds one worked example that passes that schema verbatim. Adapt the example; keep the shape. Slot markers are the template's product, not placeholders to leave behind.
2. **Validate after every placement or edit**, from the repository root:
   - WSL2: `bash scripts/validate.sh`
   - Windows: `pwsh -File scripts/validate.ps1`

   Expected: final line `VALIDATE: PASS`, exit 0. The contract is **0 clean, 1 violations, 2 environment error**; each failure line names its check ID. Invoke with the interpreter named explicitly rather than relying on the executable bit, which does not survive every checkout.
3. **For agents**, `tools` is mandatory and restricted. Omit `Bash` unless the job needs a shell; where it is needed, write the parameterised form — `"Bash(git status:*)"` — because bare `Bash`, bare `Write`, `Bash(*)`, `Bash(*:*)` and `*` are all rejected by `schemas/agent.schema.json` and by validator check C2 (C-2). The parameterised form is documented intent, not a harness boundary (rule 5).
4. **For skills**, the `description` is the entire auto-invocation surface and has a 40-character floor. Write the triggering situation, not a slogan (N-2).
5. **Tool lists follow the form the official reference documents for each field** (D-24, as amended at SPEC v2.7). Agents' `tools` is written as a **comma-separated string** — `tools: Read, Grep, Glob` — because that is the only form the sub-agents reference documents. Skills' and commands' `allowed-tools` keeps the **list** form, which is documented alongside the string there and is delimiter-unambiguous. `schemas/agent.schema.json` and both validators accept either form on read, so an inherited component written the other way still validates; what the rule fixes is what this repo *emits*. SPEC-GAP-001 is closed. **SPEC-GAP-002 is closed (SPEC v2.13):** `tools` does **not** honour a parameterised grant such as `Bash(git ls-files:*)` — the harness grants the whole `Bash` tool, and that syntax binds only as a `settings.json` permission rule. Omit `Bash` unless the agent needs a shell; where it appears, the parameterised form documents intent and the agent body states the harness boundary (`SPEC.md` §6, C-2 note).

### JSON template authoring rules

`templates/plugin/plugin.json` and `templates/hook.json` cannot carry inline comments, so their authoring rules live here.

**`templates/plugin/plugin.json`** — the shipped file is a complete worked example that validates against `schemas/plugin.schema.json`. When adapting it:

- `name` must equal the plugin's directory name and be one of the nine Tier-1 names (N-1, N-3).
- `version` is an explicit semantic version, so a release is never identified by a bare commit SHA.
- `description` has a 40-character floor and should state the plugin's responsibility **and** its boundary (B-1…B-8).
- `license` is `MIT` and `repository` is the canonical repository URL (D-08, D-03).
- Do **not** add `skills`, `commands`, `agents`, or `workflows` path fields: `SPEC.md` §3 fixes the per-plugin layout, and redirecting discovery would put components outside the tree the validator walks. The schema rejects them.
- `hooks` may be declared only by `super-saiyan` and `rinnegan`, only as `./hooks/<kebab-case>.json`, and only one file (D-15). `outputStyles` may be declared only by `aura` (§4).
- `mcpServers`, if present at all, is the inline object form restricted to `obsidian` and `context7`. The path-string form is rejected because a referenced file cannot be constrained by the schema (HR-2).

**`templates/hook.json`** — the shipped file is a `Stop`-event `prompt` handler, the form the harness supports. **Neither budgeted hook ships at v1** (SPEC v2.13, D-24 as amended): the harness rejects `prompt`/`agent` handlers on `SessionStart` and does not run `agent` handlers on `SessionEnd`, so the `super-saiyan` discipline injector is a skill and `rinnegan`'s capture is `/rinnegan:capture`. The template exists for the budgeted slots should a supported form appear; it is not a component in the tree.

- `timeout` is **mandatory on every hook entry**, and the repository standard is 1–10 seconds (C-1, validator check H3).
- The worked example uses a `prompt` handler deliberately. **Ratified — SPEC v2.3, D-24 (formerly open as B-GAP-002):** hooks satisfy C-1's cross-platform clause shell-free — `prompt` or `agent` handler types. A `command` handler requires a superseding decision, and then only the exec form with a P-5-sanctioned interpreter available on both platforms; none is sanctioned today. See `SPEC.md` §6 Hook Dispatch (ADR-024).
- A hook writes only within the D-18 scope: the active project directory, or the owning plugin's own data directory. Validator check P3 scans the whole serialized configuration for write targets, so a target hidden in an unusual field is still caught.
- A failing hook logs and never blocks the session.

## Commit and PR discipline

| Rule | Value |
|---|---|
| Commit format | Conventional Commits: `feat\|fix\|docs\|refactor\|test\|chore\|build\|ci(scope): subject` |
| Merge strategy | Squash-merge; the PR title becomes the commit subject. Linear history on `main` |
| Force pushes | Never — `--force` and `--force-with-lease` alike |
| Branch names | `feat/<area>-<slug>`, `fix/<area>-<slug>`, `docs/<slug>` |
| PR gate | `scripts/validate.*` exits 0 on the tree; `.github/workflows/validate.yml` runs both twins plus the HD-12 parity diff on every PR and is a required check on `main` |
| History | ADRs are immutable — a policy change requires a superseding ADR in the same PR. Carve-out: a spec PR amending an existing `SPEC.md` §12 cell amends the mirroring ADR in place, with a dated `Amended` row and dated notes |

### PR checklist

- [ ] `bash scripts/validate.sh` and/or `pwsh -File scripts/validate.ps1` exit 0, with the platform you did not run stated in the PR body.
- [ ] Every new or materially revised component has a `SOURCES.md` row in the **same** commit (D-12).
- [ ] Apache-2.0 material adapted closely also has a `NOTICE` entry.
- [ ] Any agent added or changed carries a restricted, parameterised `tools` allowlist (C-2).
- [ ] Any hook added or changed is within the D-15 budget, declares a timeout, and writes only within the D-18 scope.
- [ ] **A change that touches `SPEC.md` includes a §14 changelog row in the same PR and a matching ADR in `DECISIONS.md`** (D-16) — a new ADR for a new §12 cell, or an in-place amendment (dated `Amended` row plus dated notes, `Status` unchanged) for a cell that already has one. An ADR must not supersede, override, or reclassify a `SPEC.md` cell — if it would need to, the change belongs in the spec PR instead.
- [ ] No commit SHA was typed into `upstream.json` by hand; pins come only from `scripts/pin-upstream.*` (§8).
- [ ] No franchise artwork, logos, or media assets were added (§7).

## Licensing of contributions

Inbound equals outbound: contributions are accepted under the repository's MIT license (`LICENSE`). A contribution that synthesizes from an upstream source must trace to a repository registered in `upstream.json`, and its provenance lands in `SOURCES.md`; Apache-2.0-derived material additionally lands in `NOTICE`. Never draw from a source outside the registry — propose a registry addition first, which is an `upstream.json` change plus an ADR.

## Reporting problems

- **Validator false positive or negative:** an issue titled `validate: <check-id> <one-line>`, with the failing file inline.
- **Security or policy concern in a shipped component:** an issue titled `policy: <plugin>/<component>` citing the HR or C trigger ID. These take priority over everything else.
