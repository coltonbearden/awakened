---
description: <What the command does in one sentence, then when to reach for it. Minimum 40 characters — this text is the trigger and help surface (N-2).>
argument-hint: "[<what-the-argument-means>]"
allowed-tools: [Read, Grep, Glob]
---

# <Command Title>

> **Schema:** commands share `schemas/skill.schema.json`'s frontmatter rules; there is no separate command schema in `SPEC.md` §3.
> **Destination:** `plugins/<plugin-name>/commands/<command-name>.md`.
> **The file name is the command.** `commands/review.md` inside the plugin `sharingan` becomes `/sharingan:review`. Namespacing comes from the owning plugin, never from the marketplace name — a marketplace-level namespace would imply the catch-all plugin that N-4 prohibits.

Interpret `$ARGUMENTS` as <what the argument means for this command>. If `$ARGUMENTS` is empty, <the explicit empty-argument behaviour>.

## Procedure

1. Restate the requested boundary in one sentence. If none was supplied, apply the documented empty-argument behaviour rather than guessing.
2. Read the smallest set of relevant files needed to understand intent, implementation, callers or consumers, tests, and configuration.
3. Identify only confirmed defects or material risks. Tie each to concrete evidence and name the failure mode.
4. Separate confirmed findings from uncertainties and from verification not performed.
5. Do not modify files, run unscoped shell commands, install dependencies, reach the network, or handle secrets (HR-6, HR-7, C-3).

## Response Format

### Scope

What was inspected, and what was outside the boundary.

### Findings

For each confirmed finding: severity, evidence, impact, and a concise corrective direction. If none are confirmed, say so plainly.

### Verification Gaps

Checks that remain necessary before acceptance, including anything runtime, platform, or test behaviour prevented observing.

---

## Worked Example

A complete, valid command header for `plugins/domain/commands/map.md`, which Claude Code exposes as `/domain:map`:

```yaml
---
description: Map the current repository into a one-screen orientation brief — layout, entry points, and the verbatim build and test commands. Use at the start of work in an unfamiliar repository.
argument-hint: "[focus-area]"
allowed-tools: [Read, Grep, Glob]
---
```

And a body short enough to be worth copying:

```markdown
Map this repository, focusing on: $ARGUMENTS

Follow the `structure-map` output contract: Layout, Entry points, Commands (verbatim),
Conventions, Unknowns. Read-only — write nothing. If $ARGUMENTS is empty, map the whole
repository at the top level.
```

## Authoring Rules

Delete this section after adapting the template.

- **Commands are the explicit, typed surface** (P-3): one command, one outcome, stated in the first sentence.
- **Do not set `name` or `paths`** in a command file. The file name is the command; extra identity fields are dead configuration.
- **Names carry the function, not the theme** (N-2): `plan`, `review`, `recall`, `handoff`, `map`, `validate` — never a themed joke.
- **`$ARGUMENTS` carries everything after the command name.** Handle the empty case explicitly.
- **Keep the body under about 30 lines.** Push depth into a skill and have the command reference it.
- **Quote bracketed hints** (`"[focus-area]"`), or they parse as a list rather than a string.
- After placing the file, run `bash scripts/validate.sh` (or `pwsh -File scripts/validate.ps1`) from the repository root and expect the final line `VALIDATE: PASS`.
