# Changelog — `instinct`

All notable changes to this plugin are recorded here, newest first. The format follows Keep a Changelog; versions
follow the `version` field of `.claude-plugin/plugin.json` and are released by git tag (`SPEC.md` §11).

## [Unreleased]

### Added

- Plugin manifest and catalog entry (Phase 6 scaffold, `ROADMAP.md` §8). Components land per `eval/shortlist.md` §2
  and are listed here as they ship.
- `context-budget` skill: read-only estimate of always-loaded context cost across agents, skills, rules, MCP tool
  schemas and the `CLAUDE.md` chain, with ranked savings (`ecc/context-budget`).
- `skill-scout` skill: search local, marketplace and — when available — GitHub and web sources before writing a
  skill; vets every external candidate; remote channels degrade to local-only (`ecc/skill-scout`).
- `writing-for-agents` skill: prose-level levers for any agent-facing document — hierarchy, pointers, completion
  criteria, positive phrasing, pruning (`mattpocock/writing-for-agents`).
- `writing-skills` skill: test-first authoring of a `SKILL.md` in the shape of `templates/skill.md`; no scripts
  or sibling files (`superpowers/writing-skills`).
- `/instinct:learn-eval` command: extract one session pattern, gate it with an overlap check and a
  Save / Improve / Absorb / Drop verdict, choose project or user scope, write on confirmation; absorbs the
  upstream `/learn` (`ecc/cmd-learn-eval`, `ecc/cmd-learn`).
- `/instinct:skill-create` command: derive a project-conventions skill from local git history, git-only, written
  to `.claude/skills/` on confirmation (`ecc/cmd-skill-create`).
- `auditing-components` skill: bill-of-materials-then-scan safety audit of a skill, command, agent or hook
  against HR-1…HR-8, C-1…C-3 and E-1, fail-closed (original work, `SPEC.md` §4).
- `linting-components` skill: fixed pass/fail scorecard for frontmatter, naming, Markdown and template
  conformance, used as tallied, plus a separate trigger-description judgement (original work, `SPEC.md` §4).
