---
description: Equip an aura statusline preset (power-level, transformation, barrier) — shows the exact statusLine block for the user's own settings.json, writes it only after explicit confirmation; `off` removes it. `palette <id>` shows one of the six colour palettes and where it goes, read-only.
argument-hint: "[power-level|transformation|barrier|off|palette <id>]"
allowed-tools: [Read, Glob, Edit, Write]
---

# Equip an aura preset

Interpret `$ARGUMENTS` as one of: a statusline preset id (`power-level`, `transformation`, `barrier`), `off`, or
`palette <id>` where `<id>` is one of the six palettes. If it is empty or none of those, list the three statusline
presets and the six palettes from the tables below, show which statusline (if any) the user's settings currently
point at, and stop.

| Statusline preset | What the statusline shows |
|---|---|
| `power-level` | Context-window usage as a rising power level: bar, percent, tokens, model, directory, session cost |
| `transformation` | Session state as a form: `base-form` (no edits), `super-saiyan` (editing), `kaioken-x20` (agent) |
| `barrier` | Which context layers are up: CLAUDE.md, rules, project settings, added dirs, worktree, output style |

| Palette | Look |
|---|---|
| `getsuga-tensho` | The brand ink: crimson on warm black — the base palette every other one transforms |
| `final-flash` | Gold energy on amber-black |
| `six-eyes` | Cyan and limitless blue on blue-black |
| `domain-expansion` | Deep void with violet and barrier-cyan accents |
| `ultra-instinct` | Silver base with electric-blue accents on graphite |
| `gear-fifth` | The light one: vivid ink on proof paper |

## Procedure — statusline preset or `off`

1. Resolve the plugin root: `${CLAUDE_PLUGIN_ROOT}` is the installed `aura` directory. Confirm with `Glob` that
   `statuslines/<preset>.sh` and `statuslines/<preset>.ps1` both exist there. If not, report that and stop.
2. Read the user's settings file at `~/.claude/settings.json` (the user's Claude configuration directory). If it does
   not exist, treat it as `{}`.
3. Build the block for the platform the session is running on, writing the plugin root as an absolute path with
   forward slashes (Claude Code does not expand environment variables inside the `command` string):
   - WSL, Linux, macOS: `"command": "<plugin-root>/statuslines/<preset>.sh"`
   - Windows: `"command": "pwsh -NoProfile -File <plugin-root>/statuslines/<preset>.ps1"`
   Show the user the complete block exactly as it will appear in their file:

   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "<plugin-root>/statuslines/<preset>.sh",
       "padding": 0
     }
   }
   ```

   For `off`, show the existing `statusLine` value and state that it will be removed.
4. Ask the user to confirm. Write nothing until they answer yes. On no, stop with the block still displayed so they can
   paste it themselves.
5. On yes, edit only `~/.claude/settings.json`: replace or add the `statusLine` key (or delete it for `off`), keep every
   other key untouched, keep 2-space indentation and a trailing newline. On WSL, also add `chmod +x` to the `.sh` twin
   if it is not already executable, and say so.
6. Report the change in one line and remind the user that the statusline appears on the next update trigger; nothing
   else needs restarting. Reversal is the same command with another preset or `off`.

## Procedure — `palette <id>`

1. Confirm with `Glob` that `palettes/<id>.json` exists under `${CLAUDE_PLUGIN_ROOT}`. If not, list the six ids and
   stop.
2. `Read` the file and show it whole. It is exactly a Windows Terminal colour scheme: `name`, `background`,
   `foreground`, `cursorColor`, `selectionBackground`, and the sixteen ANSI slots `black` … `brightWhite`.
3. Say where it goes, in two lines: Windows Terminal — paste the object into the `schemes` array of the terminal's
   own settings file and set `"colorScheme": "<id>"` on a profile; any other emulator — map the sixteen slots plus
   foreground, background, cursor and selection onto its scheme format by name.
4. Stop. This branch writes nothing: a terminal's settings file is outside the D-18 write scope, and the palette
   file itself is read-only.

Never write outside the user's own Claude configuration, never modify the preset scripts or palette files, and never
change any other setting in the file.
