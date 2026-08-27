# Changelog — `sharingan`

All notable changes to this plugin are recorded here, newest first. The format follows Keep a Changelog; versions
follow the `version` field of `.claude-plugin/plugin.json` and are released by git tag (`SPEC.md` §11).

## [Unreleased]

### Added

- Plugin manifest and catalog entry (Phase 6 scaffold, `ROADMAP.md` §8). Components land per `eval/shortlist.md` §2
  and are listed here as they ship.
- `/sharingan:code-review` command: local or PR review across seven categories with a fail-closed decision and
  strict target validation; `gh` optional, falls back to local-only review (`eval/shortlist.md` §2.2,
  absorbs `ecc/cmd-review-pr`).
- `code-review` skill: two-axis Standards/Spec review of a range since a fixed point, inline sequential
  fallback, no tracker dependency.
- `production-audit` skill: local-evidence readiness audit with credential pattern families, an OWASP-style
  sweep, false-positive checks, a shallow-module scan, and evidence discipline.
- `discernment-nudge` skill: once-per-conversation follow-up questions chosen by evidence-evaluation criteria.
- `receiving-code-review` skill: verify each review item against the codebase before responding; no
  performative agreement.
- `requesting-code-review` skill: self-contained review brief and severity-triaged review before the next task.
- `avoid-ai-writing` skill: detect, rewrite, or edit-list prose audit without adding voice or facts; absorbs
  `davila7/productivity-humanizer`.
- `ai-debt-detector` skill: audit generated code for swallowed errors, orphans, edge inputs, hallucinated
  dependencies, and drift, filed under a technical-debt taxonomy.
