# Changelog — `aura`

All notable changes to this plugin are recorded here, newest first. The format follows Keep a Changelog; versions
follow the `version` field of `.claude-plugin/plugin.json` and are released by git tag (`SPEC.md` §11).

## [0.2.0] — 2026-09-03

### Added

- Colour palettes as files: the six `SPEC.md` §5 presets — `ultra-instinct`, `final-flash`, `domain-expansion`,
  `gear-fifth`, `six-eyes`, `getsuga-tensho` — ship as `palettes/<id>.json`, each exactly a Windows Terminal colour
  scheme object (twenty six-digit hex slots) that pastes into a `schemes` array unchanged and maps 1:1 onto any
  emulator that takes sixteen ANSI colours plus foreground, background, cursor and selection (D-29). Every text slot
  measures at least 4.5:1 against its background and `brightBlack` at least 3:1 (WCAG 2.1; the table is in
  `brand/BRAND.md` §2.7). `getsuga-tensho` is the brand ink itself; `gear-fifth` is the proof-paper light set.
- `/aura:equip palette <id>` shows a palette block and where it goes. It reads only: a terminal's own settings file
  is outside the D-18 write scope, so the command never writes one.

### Changed

- `/aura:equip` with no argument or an unknown one now lists the six palettes beside the three statusline presets.

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
