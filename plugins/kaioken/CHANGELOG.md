# Changelog — `kaioken`

All notable changes to this plugin are recorded here, newest first. The format follows Keep a Changelog; versions
follow the `version` field of `.claude-plugin/plugin.json` and are released by git tag (`SPEC.md` §11).

## [Unreleased]

### Changed

- `/kaioken:resume-session` — implicit selection (empty or date selector) now skips empty and placeholder session
  files and breaks ties deterministically; a slug, alias, or path is never substituted with another file
  (`eval/triage-log.md` T-290, first §11 dogfooded review).

## [0.1.0] — 2026-08-30

### Added

- Plugin manifest and catalog entry (Phase 6 scaffold, `ROADMAP.md` §8). Components land per `eval/shortlist.md` §2
  and are listed here as they ship.
- `/kaioken:aside` — answer a side question mid-task, read-only, and resume from the parked step
  (`eval/shortlist.md` §2.4, `ecc/cmd-aside`).
- `/kaioken:checkpoint` — named git-SHA checkpoints logged in the project, stash only after confirmation,
  tracer-slice planning (`ecc/cmd-checkpoint`; the dangling `/verify quick` reference is gone).
- `/kaioken:save-session` — reviewed-before-write handoff file under the plugin data directory,
  `<YYYY-MM-DD>--<slug>.md`, with session index, aliases, and branch/worktree metadata (`ecc/cmd-save-session`).
- `/kaioken:resume-session` — read-only briefing from a saved session file, do-not-retry list always shown
  (`ecc/cmd-resume-session`).
- `session-guard` skill — tool-call zone thresholds, rule recitation, and post-compaction re-anchoring
  (`wshobson/skill-forge-essentials-session-guard`).
