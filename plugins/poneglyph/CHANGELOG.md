# Changelog — `poneglyph`

All notable changes to this plugin are recorded here, newest first. The format follows Keep a Changelog; versions
follow the `version` field of `.claude-plugin/plugin.json` and are released by git tag (`SPEC.md` §11).

## [0.1.0] — 2026-08-30

### Added

- Plugin manifest and catalog entry (Phase 6 scaffold, `ROADMAP.md` §8). Components land per `eval/shortlist.md` §2
  and are listed here as they ship.
- `skills/json-canvas` — JSON Canvas (`.canvas`) authoring and validation with a `references/EXAMPLES.md` sibling.
  Adopted near-verbatim from `kepano/obsidian-skills` under EXC-1 (`SOURCES.md`).
- `skills/obsidian-bases` — Obsidian Bases (`.base`) authoring with filters, formulas, views, and a
  `references/FUNCTIONS_REFERENCE.md` sibling. Adopted near-verbatim under EXC-1.
- `skills/obsidian-cli` — vault operations through the `obsidian` CLI (read, create, append, search, daily notes,
  tasks, properties, tags, backlinks). Adopted under EXC-1 with the developer surface (`eval`, `dev:*`, CDP/debugger)
  intentionally omitted.
- `skills/obsidian-markdown` — Obsidian Flavored Markdown (wikilinks, embeds, callouts, properties, tags) with
  `references/PROPERTIES.md`, `EMBEDS.md`, and `CALLOUTS.md` siblings. Adopted near-verbatim under EXC-1.
