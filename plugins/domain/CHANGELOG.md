# Changelog — `domain`

All notable changes to this plugin are recorded here, newest first. The format follows Keep a Changelog; versions
follow the `version` field of `.claude-plugin/plugin.json` and are released by git tag (`SPEC.md` §11).

## [Unreleased]

### Added

- Plugin manifest and catalog entry (Phase 6 scaffold, `ROADMAP.md` §8). Components land per `eval/shortlist.md` §2
  and are listed here as they ship.
- `/domain:update-codemaps` — token-lean architecture maps under `docs/CODEMAPS/` with a freshness line and a
  30-percent diff gate before any overwrite (`eval/shortlist.md` §2.6, `ecc/cmd-update-codemaps`).
- `/domain:update-docs` — regenerates marked documentation regions from build scripts, environment templates,
  route or API specs, exports, and container files, then flags stale docs (`ecc/cmd-update-docs`).
- `crafting-readmes` skill — README creation, extension, refresh, and review matched to reader and project type
  (`davila7/productivity-crafting-effective-readmes`).
- `codebase-onboarding` skill — repository survey to onboarding guide plus approval-gated project CLAUDE.md
  (`ecc/codebase-onboarding`).
- `inherit-legacy-style` skill — extracts a legacy project's conventions into `.ai-style-rules.md`; no hook
  offered (`ecc/inherit-legacy-style`, D-15).
- `living-docs-governance` skill — constitution, map, status, history roles over existing docs, wired from
  CLAUDE.md (`ecc/living-docs-governance`).
- `codebase-design` skill — deep-module vocabulary, seam and dependency method, inline design-it-twice
  (`mattpocock/codebase-design`).
- `domain-modeling` skill — active glossary curation into CONTEXT.md with an explicit do-not-use list and a
  viability check (`mattpocock/domain-modeling`, §8 T-269 concept).
- `ai-readable-docs` skill — HADS-style tagged-block documentation for human and model readers
  (`wshobson/documentation-standards-hads`).
