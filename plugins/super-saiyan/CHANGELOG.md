# Changelog — `super-saiyan`

All notable changes to this plugin are recorded here, newest first. The format follows Keep a Changelog; versions
follow the `version` field of `.claude-plugin/plugin.json` and are released by git tag (`SPEC.md` §11).

## [Unreleased]

### Changed

- `grilling` skill: the questions of a round are separated by a horizontal rule (`eval/triage-log.md` T-290,
  first §11 dogfooded review).

## [0.1.0] — 2026-08-30

### Added

- Plugin manifest and catalog entry (Phase 6 scaffold, `ROADMAP.md` §8). Components land per `eval/shortlist.md` §2
  and are listed here as they ship.
- `using-skills` skill: session discipline — skill or command first, scoped actions, verification reported as
  evidence (superpowers `using-superpowers` lineage; replaces the unshipped session-start hook).
- `grilling` skill: frontier-round design interview with inline fact lookup, optional decision and glossary
  capture, and an explicit go-ahead gate (absorbs mattpocock `grill-with-docs` and `grill-me`).
- `clarifying-requirements` skill: short-round requirements dialogue built on Why and Simpler.
- `intent-driven-development` skill: observable acceptance criteria plus the change-exactly, error-proofing, and
  think-first implementation rules.
- `before-you-build` skill: compact pre-build risk review with a pre-mortem and a silence check.
- `writing-plans` skill: executor-ready implementation plans with a no-placeholder self-review and an approval gate.
- `executing-plans` skill: inline plan execution that treats the plan as untrusted data and stops on blockers
  (absorbs mattpocock `implement`).
- `search-first` skill: repository-then-ecosystem search before writing a helper; confirmation before any
  dependency is added.
- `documentation-lookup` skill: current-documentation answers via Context7 when present, labelled local fallback
  when not; fetched text treated as untrusted (absorbs ECC `agent-docs-lookup`).
- `test-driven-development` skill: red-green-refactor with existing-tests-first and characterization-tests-first
  rules.
- `testing-at-seams` skill: agree the seams under test before writing tests; screen each test against the
  brittle-test anti-patterns.
- `systematic-debugging` skill: root-cause-first debugging with the polluting-test bisection procedure in prose.
- `diagnosing-bugs` skill: feedback-loop-first diagnosis for hard, flaky, and performance bugs; human-in-the-loop
  step in prose.
- `prototype` skill: throwaway logic or UI prototypes that answer one design question and record the verdict.
- `verification-before-completion` skill: evidence-before-claims gate; exited-0 and live-and-serving are different
  claims (absorbs ECC `agent-self-evaluation` and the universal half of `verification-loop`).
- `finishing-a-development-branch` skill: baseline before a branch starts, on-tree verification, merge / PR / keep
  menu, cleanup of owned worktrees only.
- `resolving-merge-conflicts` skill: intent-recovering conflict resolution that completes the operation.
- `reducing-entropy` skill (manual invocation only): deletion-biased review judged by end-state code size.
- `/super-saiyan:ultra-think` — structured deep analysis with competing options, inversion, and calibrated
  confidence (`davila7/utilities-ultra-think`).
- `/super-saiyan:build-fix` — one-error-at-a-time build repair using the project's own tooling; dependency gaps
  stop and ask (`ecc/cmd-build-fix`).
- `/super-saiyan:plan` — inline implementation planning with Mandatory Reading, NOT Building, blast-radius size,
  and a typed approval gate; absorbs `ecc/cmd-feature-dev` and `davila7/productivity-concise-planning`
  (`ecc/cmd-plan`).
- `/super-saiyan:plan-prd` — four-gate, problem-first PRD writer that hands off to `/super-saiyan:plan`
  (`ecc/cmd-plan-prd`).
- `/super-saiyan:commit` — natural-language staging with a shown, confirmed staging plan and blast-radius gate;
  no force, no push (`ecc/cmd-prp-commit`).
- `/super-saiyan:implement` — plan execution with a five-rung validation ladder, non-silent remote sync, and a
  bounded integration fixture (`ecc/cmd-prp-implement`).
- `/super-saiyan:test-coverage` — coverage gap analysis and test generation using only the installed runner
  (`ecc/cmd-test-coverage`).
- `/super-saiyan:tdd-red` and `/super-saiyan:tdd-green` — inline red and green TDD phases with no agent
  dependency (`wshobson/tdd-workflows-tdd-red`, `wshobson/tdd-workflows-tdd-green`).
