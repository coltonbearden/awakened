# Changelog — `bankai`

All notable changes to this plugin are recorded here, newest first. The format follows Keep a Changelog; versions
follow the `version` field of `.claude-plugin/plugin.json` and are released by git tag (`SPEC.md` §11).

## [0.1.0] — 2026-08-30

### Added

- Plugin manifest and catalog entry (Phase 6 scaffold, `ROADMAP.md` §8). Components land per `eval/shortlist.md` §2
  and are listed here as they ship.
- `council` skill: four-voice decision council — session position first, Skeptic/Pragmatist/Critic subagents
  dispatched with minimal context, dissent kept visible in the verdict, no notes written outside the project.
- `iterative-retrieval` skill: three-cycle dispatch/evaluate/refine loop for building a subagent's context
  packet, expressed as steps and tables with nothing executable.
- `parallel-execution-optimizer` skill: lane matrix keyed on write-surface collisions; non-colliding lanes run
  together, every lane ends inside the turn, report is a verification table.
- `santa-method` skill: two context-isolated reviewer subagents, both must pass, fixes scoped to flagged
  issues, fresh reviewers per round, escalation to the user after three rounds; absorbs the santa-loop and
  gan-build command concepts.
- `research` skill: primary-source research delegated to a session-scoped subagent that writes one cited
  Markdown findings file inside the project; never a detached launch.
- `dispatching-parallel-agents` skill: one focused subagent per independent problem, dispatched in a single
  response, with conflict checks and a full-suite run before integration.
- `subagent-driven-development` skill: fresh implementer per plan task, task-scoped review, bounded fix loop,
  whole-branch final review, and a project-local `.bankai/sdd/` ledger that survives context loss.
- `agents/query-clarifier` — judges whether a research question is answerable as asked and returns the one to three
  questions that unblock it (`davila7/deep-research-team-query-clarifier`).
- `agents/research-synthesizer` — merges several research outputs into one attributed synthesis with contradictions
  and gaps kept visible; uses the harness's own `WebSearch`/`WebFetch` only to check a contested claim
  (`davila7/deep-research-team-research-synthesizer`).
- `agents/codebase-explorer` — read-only project orientation: stack, entry points, layers, data flow, conventions,
  gotchas (`davila7/development-tools-codebase-explorer`).
- `agents/codebase-pattern-finder` — catalogues existing implementations of a pattern with `path:line` references
  and never critiques (`davila7/development-tools-codebase-pattern-finder`).
- `agents/diagram-architect` — derives Mermaid, ASCII, or PlantUML diagram source from code and returns it for the
  caller to place (`davila7/documentation-diagram-architect`).
- `agents/commit-guardian` — read-only pre-commit verification report: branch, secret scan, static review, atomicity,
  Conventional Commits; the commit stays with the user (`davila7/git-commit-guardian`, narrowed per T-282).
- `agents/ai-agent-audit-specialist` — reviews or designs an AI coding agent's audit trail for reconstructability,
  tamper evidence, and control mapping (`davila7/security-ai-agent-audit-specialist`).
- `agents/llm-redteam-specialist` — plans adversarial evaluation of a model deployment and maps its injection surface
  without executing probes (`davila7/security-llm-redteam-specialist`).
- `agents/agent-evaluator` — scores another agent's output on five inlined axes with mandatory evidence
  (`ecc/agent-agent-evaluator`, axes from `ecc/agent-self-evaluation`).
- `agents/code-architect` — pattern-fitting feature blueprint with trade-off records and a dependency-ordered build
  sequence (`ecc/agent-code-architect`, absorbing `ecc/agent-architect`).
- `agents/code-explorer` — traces one feature end to end before it is extended (`ecc/agent-code-explorer`).
- `agents/code-reviewer` — independent diff review with a pre-report evidence gate, security sweep, false-positive
  filter, and an explicit clean verdict (`ecc/agent-code-reviewer`, stack-specific checklists dropped).
- `agents/code-simplifier` — behaviour-preserving simplification proposals triaged SAFE/CAREFUL/RISKY with
  dynamic-usage checks before any deletion (`ecc/agent-code-simplifier`).
- `agents/comment-analyzer` — tests comments as claims against the code and grades them inaccurate, stale,
  incomplete, or low-value (`ecc/agent-comment-analyzer`).
- `agents/planner` — dependency-ordered plan with file paths, per-step risk, testing strategy, and mergeable phases;
  the delegated path the `super-saiyan` plan command may name (`ecc/agent-planner`).
- `agents/pr-test-analyzer` — maps changed symbols to the tests that would fail on regression and rates the gaps
  (`ecc/agent-pr-test-analyzer`).
- `agents/silent-failure-hunter` — finds swallowed errors, masking defaults, lost causes, and unguarded I/O paths
  (`ecc/agent-silent-failure-hunter`).
- `agents/type-design-analyzer` — scores types on encapsulation, invariant expression, usefulness, and enforcement
  (`ecc/agent-type-design-analyzer`).
- `agents/docs-architect` — read-only codebase-to-technical-manual author (`wshobson/agents`, `eval/shortlist.md` §2.5).
- `agents/tutorial-engineer` — read-only step-by-step tutorial designer with progressive exercises (`wshobson/agents`).
- `agents/legacy-modernizer` — phased, rollback-safe modernisation planner; tests before refactor (`wshobson/agents`).
- `agents/debugger` — root-cause analyst for failures and stack traces; no shell, reports the verification command
  (`wshobson/agents`).
- `agents/error-detective` — symptom-to-cause log investigator with timeline and cascade analysis; no shell
  (`wshobson/agents`).
- `agents/code-review-preshipment` — ten-section pre-ship review over a commit range ending in a SHIP verdict;
  `Bash(git diff:*)` documented with the C-2 harness note (`wshobson/agents`).
- `agents/session-end` — session finaliser returning verified, targeted state-document edits; skips cleanly
  (`wshobson/agents`).
- `agents/session-start` — session briefer that reconciles the state document against the working tree and flags
  mismatches first (`wshobson/agents`).
- `agents/eval-judge` — four-dimension anchored scorer with an F1 triggering-accuracy test, cited by `instinct`'s
  component linting (`wshobson/agents`).
