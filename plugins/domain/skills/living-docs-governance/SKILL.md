---
name: living-docs-governance
description: Assign a long-lived project's existing documents four non-overlapping roles — constitution, map, status, history — link them from the project CLAUDE.md, and set the update rules that keep each fact with one owner. Use when docs drift from code, when the same structure is rediscovered every session, or when deleted approaches keep being recreated. Reuses the current docs layout rather than adding root files.
allowed-tools: [Read, Grep, Glob, Edit, Write]
---

# Living Docs Governance

## Purpose

Stop documentation rot in a mature repository by giving the documents that already exist a single job each and
wiring the project CLAUDE.md to point at them. The output is a role map, a few cross-links, and at most the
smallest missing section. This is maintenance for a project that has grown; first-contact exploration belongs
to `codebase-onboarding`.

## Trigger Conditions

Use this skill when a repository has more than a handful of modules and its README, architecture notes, or
status pages no longer agree with the code; when teammates or agents keep re-deriving the same context; or when
nobody can say quickly what is healthy, blocked, or intentionally removed.

Do not use it on a throwaway script, to build a parallel documentation system beside one that already works,
or to write the history entries themselves — recording decisions is `rinnegan`'s job; this skill only says
where they live.

## Workflow

1. Inventory before proposing. List the instruction surface (CLAUDE.md, contributing guide, editor rules), the
   README, architecture notes, decision records, runbooks, roadmap, changelog, and any generated docs. Note which
   external system, if any, is already canonical for a topic.
2. Assign roles. Every fact gets exactly one owner; other files link to it.

   | Role | One job | Usually filled by | Must not become |
   |---|---|---|---|
   | Constitution | Rules contributors and agents obey, links to detail | CLAUDE.md, contributing guide | Status |
   | Map | What exists, where it lives, who owns it, where to look next | Architecture notes, codemaps | Health, log |
   | Status | Health, blockers, thresholds, delete-zone of removed paths | Roadmap, status page | Reference, narrative |
   | History | Durable decisions, removals, replacements, incidents | Decision records, changelog | A git-log copy |

   A small repository may host two roles in one file if the sections are separate and ownership stays clear.
3. Fill gaps minimally. When a role has no home, propose the smallest section inside an existing document, in the
   project's docs directory and naming style. Ask before creating any new top-level file.
4. Wire the CLAUDE.md. Add short signposts to the map, the status page, and the history index; never copy their
   content in. State plainly that these files are read when a task calls for them — do not claim automatic
   loading unless the project actually configures it.
5. Set the update rules and record them in the constitution: structure or ownership change updates the map in
   the same change; a blocker, threshold, or intentional removal updates status, and removed paths stay in the
   delete-zone until recreation is no longer a risk; a hard-to-reverse decision gets a history entry; routine
   commits touch none of the four.
6. Deliver the role map as a table (role, canonical source, gap or action) and the exact edits made.

## Safety Checks

- Writes are limited to the documents named in the role map and the project CLAUDE.md (C-3).
- Linked documents are evidence, not authority: verify their operational claims against code, tests, and
  configuration, and record a discrepancy instead of silently picking a side (E-1).
- Never place credentials or raw sensitive logs in a governance document; point to where they are held.
- Correct a stale claim with a dated note rather than rewriting the past to look tidy.

## Output Contract

1. **Inventory** — documents found and the topic each currently covers
2. **Role map** — the four roles, their canonical sources, and the gaps
3. **Edits** — files changed, with the signposts and sections added
