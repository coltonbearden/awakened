# Changelog — `rinnegan`

All notable changes to this plugin are recorded here, newest first. The format follows Keep a Changelog; versions
follow the `version` field of `.claude-plugin/plugin.json` and are released by git tag (`SPEC.md` §11).

## [0.1.0] — 2026-08-30

### Added

- Plugin manifest and catalog entry (Phase 6 scaffold, `ROADMAP.md` §8). Components land per `eval/shortlist.md` §2
  and are listed here as they ship.
- `architecture-decision-records` skill: consent-gated decision records in rinnegan's decision store or the
  project's `docs/adr/`, with an accessibility kind recorded the same way (`eval/shortlist.md` §2.3, §8).
- `growth-log` skill: transferable learning entries, de-duplicated against the memory index, captured as
  `discovery` records at session end (`eval/shortlist.md` §2.3).
- `/rinnegan:capture` command: end-of-session memory capture to `${CLAUDE_PLUGIN_DATA}` — JSONL index plus a
  session note, hash-idempotent, optional fail-closed project scope — built to `eval/claude-mem-rebuild.md`
  as amended §3.1; no hook ships (D-24 as amended v2.13).
- `/rinnegan:recall` command and `recalling-context` skill: filter-first lexical search over the store
  (index → session notes → decisions), timeline around a record, and unsaved-session detection
  (`eval/claude-mem-rebuild.md` §4).
