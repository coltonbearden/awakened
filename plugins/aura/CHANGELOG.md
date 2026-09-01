# Changelog — `aura`

All notable changes to this plugin are recorded here, newest first. The format follows Keep a Changelog; versions
follow the `version` field of `.claude-plugin/plugin.json` and are released by git tag (`SPEC.md` §11).

## [0.1.0] — 2026-08-30

### Added

- Plugin manifest and catalog entry (Phase 6 scaffold, `ROADMAP.md` §8). Components land per `eval/shortlist.md` §2
  and are listed here as they ship.
- Statusline presets `power-level`, `transformation`, `barrier` as `.sh`/`.ps1` twin pairs under `statuslines/`
  (D-23): pure-bash and built-in `ConvertFrom-Json` parsing, no dependencies (P-5), read-only, always exit 0.
- `/aura:equip <preset>` command: shows the exact `statusLine` block and writes only the user's own `settings.json`
  after confirmation; `off` removes it (D-18).
- Output styles `saiyan-focus` (terse, verification-first) and `sensei` (explanatory); manifest declares
  `"outputStyles": "./output-styles/"`.
