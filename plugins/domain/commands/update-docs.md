---
description: Regenerate the generated sections of project documentation from declared sources of truth — build scripts, environment templates, route definitions or API specs, public exports, and container files — then flag docs that look stale. Use when scripts, variables, or endpoints changed and the docs did not, or before a release. Hand-written prose is never touched.
argument-hint: "[target: scripts|env|api|contributing|runbook|stale]"
allowed-tools: [Read, Grep, Glob, Edit, Write]
---

# Update Docs

Interpret `$ARGUMENTS` as the single documentation target to regenerate. If `$ARGUMENTS` is empty, run every
target whose source of truth exists in the project and report the ones with nothing to generate from.

## Procedure

1. Locate the sources of truth. Read only the files listed; do not infer from the wider tree.

   | Source | Generated content |
   |---|---|
   | `package.json` scripts, `Makefile`, `Cargo.toml`, `pyproject.toml`, `justfile` | Command reference table |
   | `.env.example`, `.env.template`, `.env.sample` | Variable table: name, required, purpose, example shape |
   | `openapi.*` or route registrations | Endpoint reference |
   | Public exports of the entry module | Public surface listing |
   | `Dockerfile`, `compose.*` | Local setup and service topology notes |

2. Find the destination. Prefer the file the project already uses for each topic (README section, `docs/`,
   `CONTRIBUTING.md`, `RUNBOOK.md`). Create a new file only when the user asks for it by name.
3. Regenerate inside marked regions only. Bound every generated block with visible Markdown lines:
   `> Generated from package.json by /domain:update-docs — edit the source, not this table.` on entry, and a
   matching closing line. Text outside the markers is hand-written and stays byte-identical.
4. Staleness pass. For each doc file, compare its modification time against the sources it describes. Flag a
   doc whose source changed after its last edit, and any doc untouched for 90 days whose subject is active.
   Flagging is a report line, not an edit.
5. Summarise in the conversation as a table: file, action (updated, skipped, flagged), one-line reason.

## Rules

- Generate from code; never hand-edit a generated block to match a doc.
- Environment tables show the variable's shape (`postgres://host/db`), never a real value; if the template
  contains one, name the key and say it needs redaction rather than copying it.
- Do not run scripts to discover what they do — read them.
- Writes stay inside the project directory; nothing is recorded outside the docs being regenerated.
