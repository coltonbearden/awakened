# Shortlist Report — Phase 5 Consolidation

**Status:** Phase-5 deliverable (`ROADMAP.md` §7), the per-plugin roster proposed for synthesis at Phase 6. Derived
from `eval/matrix.csv` at the state recorded in `ROADMAP.md` §7; every row named here is a `verdict = shortlist`
row there, and no component appears here that the matrix did not shortlist (`eval/gate-review-protocol.md` §3.4).
Lineage is `source_repo` at the `upstream.json` pinned commit; scores are
`value,bloat,risk,dependencies,user_scope_fit`.

This file proposes; it does not approve. Approval is Gate G5's, adjudicated by the independent reviewer under
`eval/gate-review-protocol.md` and acknowledged by the project owner (D-25). Nothing in it is built before that.

## 1. Totals

| Plugin | Tier | Shortlisted | Skills | Commands | Agents | Concepts |
|---|---|---|---|---|---|---|
| `super-saiyan` | core | **28** | 19 | 9 | 0 | 0 |
| `sharingan` | core | **8** | 7 | 1 | 0 | 0 |
| `rinnegan` | core | **3** | 2 | 0 | 0 | 1 |
| `kaioken` | core | **6** | 2 | 4 | 0 | 0 |
| `bankai` | core | **36** | 7 | 0 | 29 | 0 |
| `domain` | core | **9** | 7 | 2 | 0 | 0 |
| `instinct` | core | **6** | 4 | 2 | 0 | 0 |
| `poneglyph` | optional satellite (B-8) | **4** | 4 | 0 | 0 | 0 |
| `aura` | optional satellite (B-8) | **0** | 0 | 0 | 0 | 0 |
| **Total** | | **100** | 52 | 18 | 29 | 1 |

Matrix state this report was derived from: 322 rows — 100 `shortlist` / 207 `reject` / 15 `merge` / 0 `defer`.
**There are zero `defer` rows**, so the enumeration of open
defers that `SPEC.md` §9 rule 3 requires of the Phase-5 sign-off ADR is empty, and is stated as empty rather than
left to inference.

`aura` holds zero shortlisted rows **by design**: `SPEC.md` §4 records its Source Lineage as *Original work*, and
T-235 records that two upstream candidates (`anthropics/theme-factory`, davila7's statusline family) were rejected on
exactly that ground. Its recorded plan is §5 below, which is what V5.7 asks for.

## 2. Per-plugin rosters

The **Synthesis constraints** column carries what the matrix rationale requires synthesis to change or preserve.
Two rules apply to every row and are not repeated per row: (a) P-6 — synthesize, never clone, except `poneglyph`
under EXC-1; (b) `CLAUDE.md` §5.5 — components are Markdown and JSON only, so any sibling script named in a
rationale is folded into prose or dropped, never shipped. Every `agent` row additionally ships the **proposed
allowlist** its rationale names, which was replayed against `schemas/agent.schema.json` (C-2); the SPEC-GAP-002
question — whether `tools` honours `Bash(<cmd>:*)` — is settled empirically at the Phase-6 gate before any agent ships.

### 2.1 `super-saiyan` — 28 components

| id | type | lineage | upstream path | scores | synthesis constraints |
|---|---|---|---|---|---|
| `davila7/utilities-ultra-think` | command | `davila7/claude-code-templates` @ `8546d44fdec5` | `cli-tool/components/commands/utilities/ultra-think.md` | 4,4,5,5,5 | — |
| `ecc/cmd-build-fix` | command | `affaan-m/ECC` @ `06c5e118c4d3` | `commands/build-fix.md` | 4,5,4,4,4 | Detection table runs the project's own tooling only; the `need npm install` guardrail must stay a stop-and-ask, never an install (HR-7) |
| `ecc/cmd-plan` | command | `affaan-m/ECC` @ `06c5e118c4d3` | `commands/plan.md` | 4,3,5,5,5 | **Knowingly contested — re-examined at T-275.** Drop the `/plan-canvas` confirmation-gate coupling: that surface is an HR-4 reject (T-050). Keep the inline, no-subagent path primary so B-1 holds |
| `ecc/cmd-plan-prd` | command | `affaan-m/ECC` @ `06c5e118c4d3` | `commands/plan-prd.md` | 4,4,5,5,5 | — |
| `ecc/cmd-prp-commit` | command | `affaan-m/ECC` @ `06c5e118c4d3` | `commands/prp-commit.md` | 3,5,4,4,5 | Show the staging plan before committing; no `--force`, no push |
| `ecc/cmd-prp-implement` | command | `affaan-m/ECC` @ `06c5e118c4d3` | `commands/prp-implement.md` | 4,3,4,4,4 | Kept beside `superpowers/executing-plans`: this row carries the validation ladder and package-manager detection, that one carries plan execution. The `&`…`kill`/`wait` dev-server fixture stays bounded to one script (HR-4 cleared on that ground) |
| `ecc/cmd-test-coverage` | command | `affaan-m/ECC` @ `06c5e118c4d3` | `commands/test-coverage.md` | 4,5,4,4,4 | Detection table runs the project's own installed runner; no `npx` fetch of a tool (HR-7) |
| `wshobson/tdd-workflows-tdd-green` | command | `wshobson/agents` @ `367cb6a4a182` | `plugins/tdd-workflows/commands/tdd-green.md` | 4,4,4,5,4 | Keep the five behavioural rules; the subagent clause must not create an agent dependency for `super-saiyan` (B-1) — inline only |
| `wshobson/tdd-workflows-tdd-red` | command | `wshobson/agents` @ `367cb6a4a182` | `plugins/tdd-workflows/commands/tdd-red.md` | 4,4,4,5,4 | As for `tdd-green`: inline only, no agent dependency (B-1) |
| `davila7/development-clean-code` | skill | `davila7/claude-code-templates` @ `8546d44fdec5` | `cli-tool/components/skills/development/clean-code/SKILL.md` | 4,4,5,5,5 | — |
| `davila7/productivity-reducing-entropy` | skill | `davila7/claude-code-templates` @ `8546d44fdec5` | `cli-tool/components/skills/productivity/reducing-entropy/SKILL.md` | 5,5,5,5,5 | — |
| `davila7/productivity-requirements-clarity` | skill | `davila7/claude-code-templates` @ `8546d44fdec5` | `cli-tool/components/skills/productivity/requirements-clarity/SKILL.md` | 4,3,5,5,5 | — |
| `ecc/documentation-lookup` | skill | `affaan-m/ECC` @ `06c5e118c4d3` | `skills/documentation-lookup/SKILL.md` | 4,5,5,3,4 | Must degrade gracefully when Context7 is absent (P-5 exception); keep the three-call cap and secret redaction |
| `ecc/intent-driven-development` | skill | `affaan-m/ECC` @ `06c5e118c4d3` | `skills/intent-driven-development/SKILL.md` | 4,3,5,5,5 | — |
| `ecc/search-first` | skill | `affaan-m/ECC` @ `06c5e118c4d3` | `skills/search-first/SKILL.md` | 4,4,4,5,4 | Strip step 5's Configure-MCP branch and the Quick-Mode MCP check (`CLAUDE.md` §10 bars a shipped component from adding MCP configuration); inline path stays primary |
| `mattpocock/diagnosing-bugs` | skill | `mattpocock/skills` @ `9c9f36ccd399` | `skills/engineering/diagnosing-bugs/SKILL.md` | 5,4,4,5,5 | `scripts/hitl-loop.template.sh` cannot ship (`CLAUDE.md` §5.5) — fold the human-in-the-loop prompt into prose; drop `agents/openai.yaml` (display metadata) |
| `mattpocock/grilling` | skill | `mattpocock/skills` @ `9c9f36ccd399` | `skills/productivity/grilling/SKILL.md` | 4,5,5,5,5 | — |
| `mattpocock/prototype` | skill | `mattpocock/skills` @ `9c9f36ccd399` | `skills/engineering/prototype/SKILL.md` | 4,5,4,5,5 | — |
| `mattpocock/resolving-merge-conflicts` | skill | `mattpocock/skills` @ `9c9f36ccd399` | `skills/engineering/resolving-merge-conflicts/SKILL.md` | 4,5,5,5,5 | — |
| `mattpocock/tdd` | skill | `mattpocock/skills` @ `9c9f36ccd399` | `skills/engineering/tdd/SKILL.md` | 5,5,5,5,5 | — |
| `superpowers/executing-plans` | skill | `obra/superpowers` @ `b36e0829c6d0` | `skills/executing-plans/SKILL.md` | 4,5,5,5,5 | — |
| `superpowers/finishing-a-development-branch` | skill | `obra/superpowers` @ `b36e0829c6d0` | `skills/finishing-a-development-branch/SKILL.md` | 4,4,4,5,5 | — |
| `superpowers/systematic-debugging` | skill | `obra/superpowers` @ `b36e0829c6d0` | `skills/systematic-debugging/SKILL.md` | 5,3,4,5,5 | `find-polluter.sh` cannot ship as a sibling: components are Markdown and JSON only (`CLAUDE.md` §5.5). Fold the bisection procedure into prose |
| `superpowers/test-driven-development` | skill | `obra/superpowers` @ `b36e0829c6d0` | `skills/test-driven-development/SKILL.md` | 5,4,5,5,5 | — |
| `superpowers/using-superpowers` | skill | `obra/superpowers` @ `b36e0829c6d0` | `skills/using-superpowers/SKILL.md` | 3,3,5,5,4 | This is the `super-saiyan` session-start hook lineage budgeted by `SPEC.md` §6 (D-15) — the one hook `super-saiyan` may ship. Drop the five harness-specific reference files |
| `superpowers/verification-before-completion` | skill | `obra/superpowers` @ `b36e0829c6d0` | `skills/verification-before-completion/SKILL.md` | 5,5,5,5,5 | Absorbs `ecc/agent-self-evaluation` and the universal half of `ecc/verification-loop`; carry the T-164 rule — `exited 0` and `live and serving` are different claims |
| `superpowers/writing-plans` | skill | `obra/superpowers` @ `b36e0829c6d0` | `skills/writing-plans/SKILL.md` | 5,4,5,5,5 | — |
| `wshobson/before-you-build-before-you-build` | skill | `wshobson/agents` @ `367cb6a4a182` | `plugins/before-you-build/skills/before-you-build/SKILL.md` | 4,5,5,5,4 | — |

### 2.2 `sharingan` — 8 components

| id | type | lineage | upstream path | scores | synthesis constraints |
|---|---|---|---|---|---|
| `ecc/cmd-code-review` | command | `affaan-m/ECC` @ `06c5e118c4d3` | `commands/code-review.md` | 4,3,4,4,4 | Keep the explicit `No gh CLI: fall back to local-only review` path — the `gh` channel must stay optional |
| `anthropics/discernment-nudge` | skill | `anthropics/skills` @ `0a64e398ec6b` | `skills/discernment-nudge/SKILL.md` | 4,4,5,5,5 | — |
| `ecc/production-audit` | skill | `affaan-m/ECC` @ `06c5e118c4d3` | `skills/production-audit/SKILL.md` | 4,4,5,5,4 | — |
| `mattpocock/code-review` | skill | `mattpocock/skills` @ `9c9f36ccd399` | `skills/engineering/code-review/SKILL.md` | 5,4,5,3,5 | **Knowingly contested — re-examined at T-274.** Drop the line-13 `/setup-matt-pocock-skills` coupling (the command is an HR-1 reject, T-005); the Spec axis degrades to asking the user or skipping |
| `superpowers/receiving-code-review` | skill | `obra/superpowers` @ `b36e0829c6d0` | `skills/receiving-code-review/SKILL.md` | 4,4,5,5,5 | — |
| `superpowers/requesting-code-review` | skill | `obra/superpowers` @ `b36e0829c6d0` | `skills/requesting-code-review/SKILL.md` | 4,5,5,5,5 | — |
| `wshobson/avoid-ai-writing-avoid-ai-writing` | skill | `wshobson/agents` @ `367cb6a4a182` | `plugins/avoid-ai-writing/skills/avoid-ai-writing/SKILL.md` | 4,4,5,5,5 | — |
| `wshobson/skill-forge-essentials-ai-debt-detector` | skill | `wshobson/agents` @ `367cb6a4a182` | `plugins/skill-forge-essentials/skills/ai-debt-detector/SKILL.md` | 5,5,5,5,5 | — |

### 2.3 `rinnegan` — 3 components

| id | type | lineage | upstream path | scores | synthesis constraints |
|---|---|---|---|---|---|
| `claude-mem/session-memory` | concept | `thedotmack/claude-mem` @ `fae697a45d10` | `docs/architecture-overview.md` | 5,4,3,5,5 | Built from `eval/claude-mem-rebuild.md` as designed: one prompt-handler hook, declared 10s timeout, writes only to `rinnegan`'s plugin data directory (D-15, D-18, D-24). This is `rinnegan`'s one budgeted hook |
| `ecc/architecture-decision-records` | skill | `affaan-m/ECC` @ `06c5e118c4d3` | `skills/architecture-decision-records/SKILL.md` | 4,4,3,5,5 | — |
| `ecc/growth-log` | skill | `affaan-m/ECC` @ `06c5e118c4d3` | `skills/growth-log/SKILL.md` | 4,4,5,5,5 | — |

### 2.4 `kaioken` — 6 components

| id | type | lineage | upstream path | scores | synthesis constraints |
|---|---|---|---|---|---|
| `ecc/cmd-aside` | command | `affaan-m/ECC` @ `06c5e118c4d3` | `commands/aside.md` | 4,4,5,5,5 | — |
| `ecc/cmd-checkpoint` | command | `affaan-m/ECC` @ `06c5e118c4d3` | `commands/checkpoint.md` | 3,5,4,4,4 | Fix the dangling `/verify quick` reference (no such command exists) and add an explicit confirmation before any stash or commit |
| `ecc/cmd-resume-session` | command | `affaan-m/ECC` @ `06c5e118c4d3` | `commands/resume-session.md` | 4,4,5,5,5 | — |
| `ecc/cmd-save-session` | command | `affaan-m/ECC` @ `06c5e118c4d3` | `commands/save-session.md` | 4,4,4,5,5 | The write target must be D-18-compliant at synthesis — `kaioken`'s own plugin data directory or the project, never a bare `~/.claude/` path |
| `mattpocock/claude-handoff` | skill | `mattpocock/skills` @ `9c9f36ccd399` | `skills/in-progress/claude-handoff/SKILL.md` | 4,5,4,5,5 | — |
| `wshobson/skill-forge-essentials-session-guard` | skill | `wshobson/agents` @ `367cb6a4a182` | `plugins/skill-forge-essentials/skills/session-guard/SKILL.md` | 5,5,5,5,5 | — |

### 2.5 `bankai` — 36 components

| id | type | lineage | upstream path | scores | synthesis constraints |
|---|---|---|---|---|---|
| `davila7/deep-research-team-query-clarifier` | agent | `davila7/claude-code-templates` @ `8546d44fdec5` | `cli-tool/components/agents/deep-research-team/query-clarifier.md` | 4,5,5,5,5 | — |
| `davila7/deep-research-team-research-synthesizer` | agent | `davila7/claude-code-templates` @ `8546d44fdec5` | `cli-tool/components/agents/deep-research-team/research-synthesizer.md` | 4,4,5,5,4 | `WebSearch`/`WebFetch` are the harness's own tools — no component-shipped endpoint may be added (HR-6) |
| `davila7/development-tools-codebase-explorer` | agent | `davila7/claude-code-templates` @ `8546d44fdec5` | `cli-tool/components/agents/development-tools/codebase-explorer.md` | 4,4,4,5,4 | — |
| `davila7/development-tools-codebase-pattern-finder` | agent | `davila7/claude-code-templates` @ `8546d44fdec5` | `cli-tool/components/agents/development-tools/codebase-pattern-finder.md` | 5,4,5,5,5 | — |
| `davila7/development-tools-unused-code-cleaner` | agent | `davila7/claude-code-templates` @ `8546d44fdec5` | `cli-tool/components/agents/development-tools/unused-code-cleaner.md` | 4,4,4,5,4 | — |
| `davila7/documentation-diagram-architect` | agent | `davila7/claude-code-templates` @ `8546d44fdec5` | `cli-tool/components/agents/documentation/diagram-architect.md` | 3,4,4,5,4 | — |
| `davila7/git-commit-guardian` | agent | `davila7/claude-code-templates` @ `8546d44fdec5` | `cli-tool/components/agents/git/commit-guardian.md` | 4,4,5,5,5 | — |
| `davila7/security-ai-agent-audit-specialist` | agent | `davila7/claude-code-templates` @ `8546d44fdec5` | `cli-tool/components/agents/security/ai-agent-audit-specialist.md` | 4,4,5,5,4 | — |
| `davila7/security-llm-redteam-specialist` | agent | `davila7/claude-code-templates` @ `8546d44fdec5` | `cli-tool/components/agents/security/llm-redteam-specialist.md` | 4,4,4,5,4 | — |
| `ecc/agent-agent-evaluator` | agent | `affaan-m/ECC` @ `06c5e118c4d3` | `agents/agent-evaluator.md` | 4,3,5,5,4 | — |
| `ecc/agent-code-architect` | agent | `affaan-m/ECC` @ `06c5e118c4d3` | `agents/code-architect.md` | 4,5,5,5,5 | — |
| `ecc/agent-code-explorer` | agent | `affaan-m/ECC` @ `06c5e118c4d3` | `agents/code-explorer.md` | 4,5,5,5,5 | — |
| `ecc/agent-code-reviewer` | agent | `affaan-m/ECC` @ `06c5e118c4d3` | `agents/code-reviewer.md` | 5,3,4,4,3 | Drop the two React/Next.js and Node.js checklist sections (user_scope_fit 3); apply the proposed allowlist |
| `ecc/agent-code-simplifier` | agent | `affaan-m/ECC` @ `06c5e118c4d3` | `agents/code-simplifier.md` | 3,5,3,5,4 | — |
| `ecc/agent-comment-analyzer` | agent | `affaan-m/ECC` @ `06c5e118c4d3` | `agents/comment-analyzer.md` | 3,5,5,5,5 | — |
| `ecc/agent-planner` | agent | `affaan-m/ECC` @ `06c5e118c4d3` | `agents/planner.md` | 4,3,5,5,5 | — |
| `ecc/agent-pr-test-analyzer` | agent | `affaan-m/ECC` @ `06c5e118c4d3` | `agents/pr-test-analyzer.md` | 4,5,4,5,5 | — |
| `ecc/agent-security-reviewer` | agent | `affaan-m/ECC` @ `06c5e118c4d3` | `agents/security-reviewer.md` | 4,4,4,4,3 | The `npm audit` step is npm-only — make it a conditional branch with a stated skip for other stacks; apply the proposed allowlist |
| `ecc/agent-silent-failure-hunter` | agent | `affaan-m/ECC` @ `06c5e118c4d3` | `agents/silent-failure-hunter.md` | 4,5,4,5,5 | — |
| `ecc/agent-type-design-analyzer` | agent | `affaan-m/ECC` @ `06c5e118c4d3` | `agents/type-design-analyzer.md` | 3,5,5,5,4 | — |
| `wshobson/code-documentation-docs-architect` | agent | `wshobson/agents` @ `367cb6a4a182` | `plugins/code-documentation/agents/docs-architect.md` | 3,4,5,5,4 | — |
| `wshobson/code-documentation-tutorial-engineer` | agent | `wshobson/agents` @ `367cb6a4a182` | `plugins/code-documentation/agents/tutorial-engineer.md` | 3,4,5,5,4 | — |
| `wshobson/code-refactoring-legacy-modernizer` | agent | `wshobson/agents` @ `367cb6a4a182` | `plugins/code-refactoring/agents/legacy-modernizer.md` | 4,5,4,5,4 | — |
| `wshobson/debugging-toolkit-debugger` | agent | `wshobson/agents` @ `367cb6a4a182` | `plugins/debugging-toolkit/agents/debugger.md` | 4,5,4,5,5 | — |
| `wshobson/error-debugging-error-detective` | agent | `wshobson/agents` @ `367cb6a4a182` | `plugins/error-debugging/agents/error-detective.md` | 4,5,5,5,4 | — |
| `wshobson/operating-kit-code-review-preshipment` | agent | `wshobson/agents` @ `367cb6a4a182` | `plugins/operating-kit/agents/code-review-preshipment.md` | 5,4,4,5,4 | — |
| `wshobson/operating-kit-session-end` | agent | `wshobson/agents` @ `367cb6a4a182` | `plugins/operating-kit/agents/session-end.md` | 4,5,4,5,4 | Placeholders substituted per project; apply the proposed allowlist |
| `wshobson/operating-kit-session-start` | agent | `wshobson/agents` @ `367cb6a4a182` | `plugins/operating-kit/agents/session-start.md` | 4,5,4,5,4 | As for `session-end` |
| `wshobson/plugin-eval-eval-judge` | agent | `wshobson/agents` @ `367cb6a4a182` | `plugins/plugin-eval/agents/eval-judge.md` | 4,4,5,5,4 | — |
| `ecc/council` | skill | `affaan-m/ECC` @ `06c5e118c4d3` | `skills/council/SKILL.md` | 4,4,5,5,5 | Keep the ban on shadow writes to `~/.claude/notes` |
| `ecc/iterative-retrieval` | skill | `affaan-m/ECC` @ `06c5e118c4d3` | `skills/iterative-retrieval/SKILL.md` | 3,3,5,5,4 | The JavaScript is pseudocode; nothing executable ships |
| `ecc/parallel-execution-optimizer` | skill | `affaan-m/ECC` @ `06c5e118c4d3` | `skills/parallel-execution-optimizer/SKILL.md` | 4,5,4,5,5 | Keep the rule that no background process outlives the turn (HR-4 boundary) |
| `ecc/santa-method` | skill | `affaan-m/ECC` @ `06c5e118c4d3` | `skills/santa-method/SKILL.md` | 4,3,5,5,4 | The Python is illustrative and stays illustrative — no shipped script (`CLAUDE.md` §5.5) |
| `mattpocock/research` | skill | `mattpocock/skills` @ `9c9f36ccd399` | `skills/engineering/research/SKILL.md` | 4,5,4,5,5 | — |
| `superpowers/dispatching-parallel-agents` | skill | `obra/superpowers` @ `b36e0829c6d0` | `skills/dispatching-parallel-agents/SKILL.md` | 4,4,5,5,5 | — |
| `superpowers/subagent-driven-development` | skill | `obra/superpowers` @ `b36e0829c6d0` | `skills/subagent-driven-development/SKILL.md` | 4,3,4,5,5 | Slim from 32KB; the three bash helpers cannot ship (`CLAUDE.md` §5.5) — express the `.superpowers/sdd/` state handling in prose or drop it |

### 2.6 `domain` — 9 components

| id | type | lineage | upstream path | scores | synthesis constraints |
|---|---|---|---|---|---|
| `ecc/cmd-update-codemaps` | command | `affaan-m/ECC` @ `06c5e118c4d3` | `commands/update-codemaps.md` | 4,4,5,5,4 | Keep the diff gate — changes over 30 percent require approval before overwriting |
| `ecc/cmd-update-docs` | command | `affaan-m/ECC` @ `06c5e118c4d3` | `commands/update-docs.md` | 4,4,5,5,4 | — |
| `davila7/productivity-crafting-effective-readmes` | skill | `davila7/claude-code-templates` @ `8546d44fdec5` | `cli-tool/components/skills/productivity/crafting-effective-readmes/SKILL.md` | 4,5,5,5,5 | — |
| `ecc/codebase-onboarding` | skill | `affaan-m/ECC` @ `06c5e118c4d3` | `skills/codebase-onboarding/SKILL.md` | 5,4,3,5,5 | The `npx prisma migrate dev` line is template example text; it must stay example text |
| `ecc/inherit-legacy-style` | skill | `affaan-m/ECC` @ `06c5e118c4d3` | `skills/inherit-legacy-style/SKILL.md` | 4,4,3,4,5 | Drop the optional hard hook — D-15 budgets none for `domain` |
| `ecc/living-docs-governance` | skill | `affaan-m/ECC` @ `06c5e118c4d3` | `skills/living-docs-governance/SKILL.md` | 4,4,3,5,5 | — |
| `mattpocock/codebase-design` | skill | `mattpocock/skills` @ `9c9f36ccd399` | `skills/engineering/codebase-design/SKILL.md` | 4,4,5,5,4 | — |
| `mattpocock/domain-modeling` | skill | `mattpocock/skills` @ `9c9f36ccd399` | `skills/engineering/domain-modeling/SKILL.md` | 4,5,5,5,4 | — |
| `wshobson/documentation-standards-hads` | skill | `wshobson/agents` @ `367cb6a4a182` | `plugins/documentation-standards/skills/hads/SKILL.md` | 3,4,5,5,4 | — |

### 2.7 `instinct` — 6 components

| id | type | lineage | upstream path | scores | synthesis constraints |
|---|---|---|---|---|---|
| `ecc/cmd-learn-eval` | command | `affaan-m/ECC` @ `06c5e118c4d3` | `commands/learn-eval.md` | 4,3,4,5,5 | — |
| `ecc/cmd-skill-create` | command | `affaan-m/ECC` @ `06c5e118c4d3` | `commands/skill-create.md` | 3,3,4,4,4 | Drop the GitHub App link (an advanced alternative, not a requirement); git-only |
| `ecc/context-budget` | skill | `affaan-m/ECC` @ `06c5e118c4d3` | `skills/context-budget/SKILL.md` | 4,5,5,5,5 | — |
| `ecc/skill-scout` | skill | `affaan-m/ECC` @ `06c5e118c4d3` | `skills/skill-scout/SKILL.md` | 4,5,4,4,5 | `gh` and web channels stay conditional and degrade; keep the vet step for installs, shell and network in any candidate |
| `mattpocock/writing-for-agents` | skill | `mattpocock/skills` @ `9c9f36ccd399` | `skills/productivity/writing-for-agents/SKILL.md` | 5,3,5,5,5 | Tighten against `superpowers/writing-skills` (bloat 3 at 11KB) |
| `superpowers/writing-skills` | skill | `obra/superpowers` @ `b36e0829c6d0` | `skills/writing-skills/SKILL.md` | 5,3,4,3,5 | Slim from 26KB plus six siblings; `render-graphs.js` cannot ship (`CLAUDE.md` §5.5) and its node/graphviz need is dropped with it |

### 2.8 `poneglyph` — 4 components

| id | type | lineage | upstream path | scores | synthesis constraints |
|---|---|---|---|---|---|
| `kepano/json-canvas` | skill | `kepano/obsidian-skills` @ `a1dc48e68138` | `skills/json-canvas/SKILL.md` | 4,4,5,5,3 | — |
| `kepano/obsidian-bases` | skill | `kepano/obsidian-skills` @ `a1dc48e68138` | `skills/obsidian-bases/SKILL.md` | 4,3,5,4,3 | — |
| `kepano/obsidian-cli` | skill | `kepano/obsidian-skills` @ `a1dc48e68138` | `skills/obsidian-cli/SKILL.md` | 4,5,3,3,3 | EXC-1 near-verbatim adoption, **minus** the developer surface: `obsidian eval code=...`, `dev:screenshot`, `dev:dom` and the CDP/debugger controls are dropped at adoption |
| `kepano/obsidian-markdown` | skill | `kepano/obsidian-skills` @ `a1dc48e68138` | `skills/obsidian-markdown/SKILL.md` | 5,4,5,5,3 | — |

### 2.9 `aura` — 0 components

No shortlisted rows — see §5 for the recorded original-work plan and its in-repo basis.

## 3. Merge absorptions

Fifteen `merge` rows fold into a shortlisted absorber. Each absorber is itself shortlisted (checked mechanically at
G4 and again for this report); the residue worth carrying is in the merged row's own rationale in `eval/matrix.csv`.

| merged id | absorbed by | absorber's plugin |
|---|---|---|
| `mattpocock/grill-with-docs` | `mattpocock/grilling` | `super-saiyan` |
| `mattpocock/implement` | `superpowers/executing-plans` | `super-saiyan` |
| `mattpocock/grill-me` | `mattpocock/grilling` | `super-saiyan` |
| `ecc/agent-self-evaluation` | `superpowers/verification-before-completion` | `super-saiyan` |
| `ecc/verification-loop` | `superpowers/verification-before-completion` | `super-saiyan` |
| `ecc/cmd-feature-dev` | `ecc/cmd-plan` | `super-saiyan` |
| `ecc/cmd-review-pr` | `ecc/cmd-code-review` | `sharingan` |
| `ecc/cmd-santa-loop` | `ecc/santa-method` | `bankai` |
| `ecc/cmd-gan-build` | `ecc/santa-method` | `bankai` |
| `ecc/cmd-learn` | `ecc/cmd-learn-eval` | `instinct` |
| `ecc/agent-architect` | `ecc/agent-code-architect` | `bankai` |
| `ecc/agent-docs-lookup` | `ecc/documentation-lookup` | `super-saiyan` |
| `davila7/productivity-concise-planning` | `ecc/cmd-plan` | `super-saiyan` |
| `davila7/productivity-think-tank` | `ecc/council` | `bankai` |
| `davila7/productivity-humanizer` | `wshobson/avoid-ai-writing-avoid-ai-writing` | `sharingan` |

## 4. Hook budget preview (V5.6)

`SPEC.md` §6 budgets exactly two hooks (D-15): `super-saiyan`'s session-start skill-discipline injector and
`rinnegan`'s optional memory-capture hook. The shortlist implies exactly those two and no others:

- `super-saiyan` — lineage `superpowers/using-superpowers` (the only shortlisted row whose rationale names the §6
  session-start budget). One hook.
- `rinnegan` — lineage `claude-mem/session-memory`, designed in `eval/claude-mem-rebuild.md`: one prompt-handler
  hook, declared timeout, D-18 write scope. One hook.
- Every other plugin — zero. The one `component_type = hook` row in the matrix (`claude-mem/memory-hooks`) is a
  `reject`. `ecc/inherit-legacy-style` (`domain`) mentions an optional hard hook that synthesis drops (§2.6).

## 5. Recorded plans for original work (V5.7)

V5.7 requires every core plugin to hold at least one shortlisted component **or a recorded plan for original work**.
All seven core plugins and `poneglyph` hold shortlisted rows (§1). The plans below close the gaps the Phase-4 gap
scan carried out of G4 (`ROADMAP.md` §6), and `aura`'s roster; each names its in-repo basis.

| Plugin | Gap | Basis | Plan for Phase 6 |
|---|---|---|---|
| `aura` | Statusline presets, palettes, output styles, `/aura:equip` — the whole plugin | `SPEC.md` §4 (*Original work*), §5 preset tables, D-23; T-235 | Authored, not sourced: `.sh`/`.ps1` statusline twin pairs under `plugins/aura/statuslines/` (D-23), zero dependencies (P-5), preset ids per N-5. No upstream row may be added to close this — T-235 records the two rejections on that ground |
| `instinct` | Component-safety auditing — a shipped component that audits skills, agents and hooks for unsafe patterns | T-223; B-7 | Authored from the policy that already exists in-repo: `SPEC.md` §6 HR-1…HR-8 / C-1…C-3 and the `scripts/validate.*` P-group checks, expressed as a skill with no tooling dependency. Two shortlisted rows are adjacent inputs, not owners: `davila7/security-ai-agent-audit-specialist` (`bankai`, an audit-trail agent) and `ecc/agent-agent-evaluator` (`bankai`, whose Bash constraints are a worked example of C-2 hygiene) |
| `instinct` | Component linting — conventions, structure and description quality of an authored component | T-232; B-7 | Authored beside the safety audit as one family: the structural rules are `schemas/*.schema.json`, `templates/*` and N-2's trigger-description rule; `wshobson/plugin-eval-eval-judge` (`bankai`) supplies the triggering-accuracy scoring shape |

## 6. Knowingly contested rows

Two shortlisted rows were self-marked *knowingly contested — re-examine at G5* when they were scored. Phase 5
re-read both at the pinned commit before this report went to the gate; the re-audits are T-274 and T-275 in
`eval/triage-log.md`, and the reviewer's own spot-check (`eval/gate-review-protocol.md` §3.2) is expected to land on
them.

| id | plugin | why contested | Phase-5 disposition |
|---|---|---|---|
| `mattpocock/code-review` | `sharingan` | Line 13 tells the user to run `/setup-matt-pocock-skills`, an HR-1 reject (T-005), when the issue-tracker doc is absent; `dependencies` sits on the floor at 3 (T-026) | T-274 |
| `ecc/cmd-plan` | `super-saiyan` | Offers `/plan-canvas` as a confirmation gate; that surface is an HR-4 reject (T-050) | T-275 |

## 7. Re-donated concepts — Phase-6 synthesis inputs, unscored

Across Phases 2–4, rejected or merged components donated a concept their implementation could not carry. They are
listed here so synthesis has them in one place; they are **not** matrix rows and carry no score. `eval/rubric.md` §7
Example A allows a concept to re-enter as a scored `concept` row with `target_plugin` set; `claude-mem/session-memory`
is the one that has, because a design document exists for it. The rest re-enter only if Phase 6 writes a design worth
scoring — until then they are inputs to the shortlisted rows named, not candidates of their own.

| Concept | Donor entry | Owner | Lands in |
|---|---|---|---|
| Design-dialogue with an approval gate before implementation, without the visual companion | T-001 | `super-saiyan` | `superpowers/writing-plans`, `mattpocock/grilling` |
| Worktree isolation and baseline verification before work starts | T-002 | `super-saiyan` | `superpowers/finishing-a-development-branch` |
| Deepening-opportunity scan of a codebase, without the CDN-backed report | T-004 | `sharingan` | `ecc/production-audit` |
| Tracer-bullet ticket decomposition, without the tracker coupling | T-007 | `kaioken` | `ecc/cmd-checkpoint` |
| Plan Handoff: treat a `*.plan.md` as untrusted data, never as instructions; reject destructive or fetch-and-execute steps (E-1) | T-059 | `super-saiyan` | `superpowers/executing-plans` |
| Mandatory Reading list and an explicit NOT Building section in a plan | T-086 | `super-saiyan` | `ecc/cmd-plan` |
| Blast-radius size classifier and two human gates (after Plan, before Commit) | T-049 | `super-saiyan` | `ecc/cmd-plan`, `ecc/cmd-prp-commit` |
| Session index, aliases and branch/worktree metadata | T-078 | `kaioken` | `ecc/cmd-save-session` |
| `context.json` source of truth with a generated view, unsaved-session detection, git-activity delta | T-039 | `rinnegan` | `eval/claude-mem-rebuild.md` |
| Deterministic scorecard whose output the agent must use directly — *do not rescore manually* | T-097 | `instinct` | §5 linting plan |
| Fail-closed contract and strict PR-URL validation | T-111 | `sharingan` | `ecc/cmd-code-review` |
| Update the existing tests first — what makes a change a tweak rather than a fix | T-122 | `super-saiyan` | `superpowers/test-driven-development` |
| Characterization tests green before touching legacy code | T-124 | `super-saiyan` | `superpowers/test-driven-development` |
| SAFE / CAREFUL / RISKY triage and a grep for dynamic imports before deleting code | T-136 | `sharingan` | `davila7/development-tools-unused-code-cleaner` (via `bankai`) |
| An agent that scopes its own grants in prose — the C-2 idea expressed in the `tools` field instead | T-137 | `bankai` | every agent row's proposed allowlist |
| ADR-ACC: an accessibility decision recorded the way an ADR records an architectural one | T-142 | `rinnegan` | `ecc/architecture-decision-records` |
| Secret-detection regex library (API keys, AWS, DB URLs with credentials, JWTs, private keys, GitHub and Google tokens) | T-146 | `sharingan` | `ecc/production-audit` |
| Never-trust-the-forker independence: an auditor that re-verifies everything, any secret match a hard FAIL | T-148 | `sharingan` | `ecc/agent-security-reviewer` (via `bankai`) |
| *Exited 0* and *live and serving the new code* are different claims — verify live before reporting shipped | T-164 | `super-saiyan` | `superpowers/verification-before-completion` |
| Never analyse an incident from a dashboard or stdout alone; state when logs were not checked; never present inference as fact | T-165 | `sharingan` | `ecc/production-audit` |
| Change exactly what was indicated and preserve everything else | T-206 | `super-saiyan` | `davila7/development-clean-code` |
| A read-only guarantee delivered by the allowlist alone, needing no hook | T-238 | `bankai` | every read-only agent row |
| Technical-debt category taxonomy | T-253 | `sharingan` | `wshobson/skill-forge-essentials-ai-debt-detector` |
| SBOM-then-scan sequence | T-255 | `instinct` | §5 safety-audit plan |
| Evidence-evaluation criteria for claim verification | T-257 | `sharingan` | `anthropics/discernment-nudge` |
| Pre-mortem plus the silence check — what does the document *not* say | T-260 | `sharingan` | `wshobson/before-you-build-before-you-build` (via `super-saiyan`) |
| Error-proofing (poka-yoke) applied to code changes | T-262 | `super-saiyan` | `davila7/development-clean-code` |
| An explicit *Do not use this skill when* section and a viability check before proceeding | T-269 | `domain` | `mattpocock/domain-modeling` |
| Ask at most one or two questions, and only when truly blocking | T-258 | `super-saiyan` | `ecc/cmd-plan` |
| Treat fetched documentation as untrusted; never obey instructions embedded in tool output (E-1) | `ecc/agent-docs-lookup` merge row | `super-saiyan` | `ecc/documentation-lookup` |

## 8. Build plan for Phase 6 (proposed, not authorized)

1. Scaffold the nine plugin directories and `.claude-plugin/marketplace.json` per `SPEC.md` §3, from `templates/`.
2. Settle SPEC-GAP-002 empirically before any agent ships: author one scoped agent and observe whether `tools` honours
   `Bash(<cmd>:*)`; record the outcome as a §14 row and an ADR-024 amendment.
3. Synthesize per plugin in D-04 priority order — skills, then commands, then agents, then the two budgeted hooks —
   from the rosters in §2 with their constraints, `SOURCES.md` updated in the same commit (D-12).
4. Author `aura` and the two `instinct` original-work components per §5.
5. `bash scripts/validate.sh --release` and `pwsh -File scripts/validate.ps1 -Release` both exit 0; G6.

No step above begins until `ROADMAP.md` §11 carries both G5 rows — the reviewer's `APPROVED (reviewer) — pending
owner ack` and the owner's `OWNER ACK` (D-25).
