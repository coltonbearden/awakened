# SOURCES.md — Lineage Register

Awakened is a synthesized Claude Code plugin marketplace (P-6). This register records the upstream repositories and concepts that inform each planned plugin and component family. It is a transparency record, not a claim that files were copied: except for **EXC-1**, components are independently authored after audit and must not be verbatim imports.

Attribution lives here and only here — no per-file headers anywhere in the tree (D-12). Apache-2.0 lineage additionally lives in `NOTICE`.

## Rules

- Add or materially revise a component only with a same-change update to this register (D-12).
- Cite the source repository and the pinned commit recorded in `upstream.json`; never a floating branch state (§8). Commits are `null` until `scripts/pin-upstream.*` has run, and no SHA is ever typed by hand.
- Record component path, owning plugin, source lineage, synthesis note, and license treatment once the component exists.
- License facts are those in `SPEC.md` §8. A discrepancy found at a pin is corrected by a spec PR under D-16, not by an entry here.
- A repository listed as discovery-only supplies no merge material unless a later audit row identifies a specific adopted concept.

## Planned Plugin Lineage

One row per Tier-1 plugin — nine rows, matching `SPEC.md` §4.

| Plugin | Planned component families | Primary lineage | Additional lineage | License treatment and boundary |
|---|---|---|---|---|
| `super-saiyan` | Planning, implementation discipline, test-driven development, debugging, verification, git workflow guidance, the pre-authorized SessionStart discipline hook | `obra/superpowers` | `mattpocock/skills`, `affaan-m/ECC` | MIT-informed synthesis (P-6). The only proposed hook is the D-15 pre-authorized SessionStart candidate; it must pass the C-1 checklist and write only within the D-18 scope. B-1: no dependency on agents, memory infrastructure, or project-specific tooling. |
| `sharingan` | Code review, architecture inspection, regression analysis, pattern detection, security-oriented review | `obra/superpowers`, `mattpocock/skills` | `affaan-m/ECC`, `wshobson/agents` | MIT-informed synthesis. B-2: analysis and review only; implementation stays outside this plugin. |
| `rinnegan` | File-based decision history, session context, searchable notes, recall, the optional memory-capture hook | `thedotmack/claude-mem` | `mattpocock/skills` | Apache-2.0 **conceptual** lineage, recorded in `NOTICE`. Rebuild only: no SQLite, workers, daemons, Docker, cloud sync, telemetry, or external services (HR-4, HR-5, HR-6). B-3: temporal context, file-based storage only. Its hook writes only within the D-18 scope. |
| `kaioken` | Save and resume, handoffs, focused execution plans, rapid iteration | `affaan-m/ECC` | `mattpocock/skills` | MIT-informed synthesis. B-5: session momentum only — it duplicates no planning, debugging, or review system. |
| `bankai` | General-purpose research, implementation, debugging, review, planning, and synthesis agents | `wshobson/agents` | `affaan-m/ECC`, `obra/superpowers` | MIT-informed synthesis. B-6: every agent carries a restricted allowlist — no bare or wildcard `Bash`, `Write`, `Edit`, `MultiEdit`, or `NotebookEdit` grant (C-2, enforced by `schemas/agent.schema.json`). |
| `domain` | Project maps, architecture context, conventions, rules, CLAUDE.md scaffolding, domain modeling | `mattpocock/skills` | `affaan-m/ECC`, `wshobson/agents` | MIT-informed synthesis. B-4: structural context only. Generates project-scoped artifacts on user invocation; it stores no history. |
| `instinct` | Skill creation, component auditing, validation, upstream evaluation, release checks | `anthropics/skills` | `obra/superpowers`, `vercel-labs/skills` | Apache-2.0 skill-pattern lineage recorded in `NOTICE` — upstream licenses per skill (no root license, §8/D-24); `skill-creator`, the named lineage, is Apache-2.0 and the four proprietary skills are excluded. Remaining lineage is MIT-informed. B-7: marketplace maintenance, not user workflow execution. |
| `poneglyph` | Obsidian Markdown, CLI, Bases, JSON Canvas, and Defuddle support | `kepano/obsidian-skills` | None | MIT. **EXC-1** — the sole permitted near-verbatim adaptation in the entire project, formalized under P-6 in `SPEC.md` §7 on the grounds that upstream is already minimal, high quality, MIT-licensed, and scoped exactly to this plugin's purpose. Applicable upstream attribution and license requirements are preserved. B-8: optional satellite, never a core dependency. |
| `aura` | Palettes, statusline presets (`power-level`, `transformation`, `barrier`), output styles, `/aura:equip` | Original Awakened work | None | No upstream component lineage planned — `SPEC.md` §4 records this plugin's lineage as original work. The `barrier` preset is the D-17 rename of the colliding `domain` preset (N-5, ADR-017). B-8: optional satellite, never a core dependency. |

## Discovery-Only Sources

| Source | Permitted role | Excluded material |
|---|---|---|
| `hesreallyhim/awesome-claude-code` | Gap scanning and catalog discovery (§8, §10 Phase 4) | Discovery-only; the audited-at-source rule is stated normatively in `SPEC.md` §8. |
| `davila7/claude-code-templates` | Candidate patterns from its `components` directory only (§8) | The npm CLI, analytics, and package-installation behaviour are hard rejects (HR-6, HR-7), as is anything outside `components`. |

## Component Entry Format

When Phase 6 adds a component, append a row using this exact structure:

| Component path | Owning plugin | Source repositories and pinned commits | Synthesized contribution | License and notice action |
|---|---|---|---|---|
| `plugins/<plugin-name>/skills/<skill-name>/SKILL.md` | `<plugin-name>` | `<owner>/<repository>@<pinned-sha-from-upstream.json>` | Independently authored workflow derived from audited ideas; no copied text | MIT lineage recorded here; add a `NOTICE` entry when Apache-2.0 material is closely adapted |

The row above defines the required record shape only. It is not a planned marketplace component, and the SHA slot is filled from `upstream.json` after `scripts/pin-upstream.*` has run — never by hand (§8).
