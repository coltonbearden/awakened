# `tests/` — Component test fixtures

`SPEC.md` §3 lists this directory as a `[P6]` entry: component test fixtures. The fixtures are **known-good and
known-bad samples of every component type the validators lint**, each paired with the check that must accept or
reject it. They are reference inputs for reviewers and for `claude plugin validate`; they are **not** shipped
components, and the validators' policy lint (checks P1–P3) deliberately walks `plugins/**` only, so nothing here can
pass as a component or trip the lint.

## Fixture table

| Fixture | Component type | Check | Expected |
|---|---|---|---|
| `fixtures/agents/good-scoped-agent.md` | agent frontmatter | C2, `schemas/agent.schema.json` | accept — one parameterised `Bash` grant |
| `fixtures/agents/bad-bare-bash-agent.md` | agent frontmatter | C2, `schemas/agent.schema.json` | reject — bare `Bash`, wildcard `Write(*)` (C-2) |
| `fixtures/skills/good-skill/SKILL.md` | skill frontmatter | C3, `schemas/skill.schema.json` | accept |
| `fixtures/skills/bad-skill/SKILL.md` | skill frontmatter | C3, `schemas/skill.schema.json` | reject — name ≠ directory, description < 40 chars (N-2) |
| `fixtures/hooks/good-hook.json` | hook config | H3 | accept — integer timeout within 1–10 s (C-1) |
| `fixtures/hooks/bad-hook-no-timeout.json` | hook config | H3 | reject — no `timeout` (C-1, D-22) |
| `fixtures/manifests/good-plugin.json` | plugin manifest | C4, `schemas/plugin.schema.json` | accept |
| `fixtures/manifests/bad-plugin-license.json` | plugin manifest | C4, `schemas/plugin.schema.json` | reject — license is not MIT (D-08) |
| `fixtures/palettes/good-palette.json` | aura palette preset | C5, `schemas/palette.schema.json` | accept — the twenty scheme keys, six-digit uppercase hex, `name` equals the file stem (D-29) |
| `fixtures/palettes/bad-palette-short-hex.json` | aura palette preset | C5, `schemas/palette.schema.json` | reject — three-digit `cyan`, missing `brightWhite`, stray `magenta` key (D-29) |

## How to exercise a fixture

Copy the fixture to the location the check walks, run both validators, and confirm the expected verdict; then delete
the copy. For example, on WSL2:

```bash
mkdir -p plugins/bankai/agents && cp tests/fixtures/agents/bad-bare-bash-agent.md plugins/bankai/agents/
bash scripts/validate.sh          # expect: ERROR [C2] ... bare or wildcard-equivalent grant
rm plugins/bankai/agents/bad-bare-bash-agent.md

cp tests/fixtures/palettes/bad-palette-short-hex.json plugins/aura/palettes/
bash scripts/validate.sh          # expect: ERROR [C5] ... is not a six-digit uppercase hex colour
rm plugins/aura/palettes/bad-palette-short-hex.json
```

The same sequence on Windows 11 uses `pwsh -File scripts/validate.ps1`. The verdict must be identical on both
platforms — a fixture that one twin accepts and the other rejects is a parity bug (`CLAUDE.md` §3.2).

## Limits, stated

No automated harness runs the fixture table yet: the twin validators (`scripts/validate.*`) do not read `tests/`, and
`.github/workflows/validate.yml` runs only the validators and the twin-parity diff. Wiring the table into a check is
recorded as Phase-6 follow-up work in `ROADMAP.md` §8, not implied by this file.
