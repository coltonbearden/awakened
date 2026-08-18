# Triage Log

**Purpose.** The rejection and audit-history record for the evaluation harness. Every `eval/matrix.csv` row whose `verdict` is `reject` has an entry here citing the rule IDs that disqualified it — that is the `SPEC.md` §10 Phase-2 exit criterion, in this file, mechanically checkable via the trigger-ID field.

**Relationship to `eval/matrix.csv`.** The matrix records **effective state**: one row per component `id`, replaced in place on re-audit. This log is **append-only history**: entries are never edited or deleted, and a re-audit adds a new entry recording what changed and why. Together they answer "what is the current disposition" and "how did it get there" without either file having to do both jobs.

**This file ships empty of entries by design.** No component has been audited yet — Phase 2 has not begun (`ROADMAP.md` §1). Any entry appearing here before a phase has run is a fabrication, not a record. The first real entries are written during Phase 2.

---

## 1. Entry Template

Copy this block verbatim for each entry. Heading level is `###`, IDs are sequential from `T-001` and never reused.

```markdown
### T-NNN — <component-name>

- **Source:** <repo name exactly as it appears in `upstream.json`>
- **Path:** <path within the source repo at the pinned SHA>
- **HR/axis trigger IDs:** <comma-joined, e.g. `HR-4,HR-5` or `axis:user_scope_fit=1`>
- **Rationale:** <one or two sentences; cite the rule IDs and the deciding axis>
- **Date:** <YYYY-MM-DD>
```

### Field rules

| Field | Rule |
|---|---|
| Heading | `### T-NNN — <component-name>`, em-dash separator, `component-name` in kebab-case (N-3). The `T-NNN` matches nothing else in the repo and is the log's own ID space |
| Source | Must match a `repos[].name` value in `upstream.json` exactly; an unmatched source name is an audit-trail break |
| Path | Repo-relative, forward slashes, as it exists **at the pinned SHA** — not at branch HEAD |
| HR/axis trigger IDs | At least one ID. Hard rejects use the `HR-N` form; a rejection on an axis floor uses `axis:<column>=<score>`. This field is what `SPEC.md` §10 Phase 2 checks — prose in Rationale does not substitute for it |
| Rationale | Cites rule IDs, not adjectives. "Fails HR-5: bundles a native sqlite binary" is an entry; "too heavy" is not |
| Date | `YYYY-MM-DD`, the date the read happened |

---

## 2. Usage Rules

1. **One entry per rejected component.** Every `verdict = reject` row in `eval/matrix.csv` has exactly one entry here at the time the row is written — not batched at the end of a phase.
2. **Bulk rejects are logged as a class, once.** Where `SPEC.md` §10 Phase 3 authorizes disposing of a reject class without deep reads (ECC's 22 language packs, the 41KB hooks.json, dashboards, domain-niche skills), write one entry for the class: the component-name slot carries the class name, the Path slot carries the covering path prefix, and the Rationale states the count. Individual matrix rows are not written for bulk-rejected components.
3. **Re-pins that invalidate an audit get an entry.** When `scripts/pin-upstream.*` moves a SHA and a prior evaluation was read at the old one, append an entry recording the old and new SHAs and whether the evaluation still holds (`CLAUDE.md` §8).
4. **Re-audits get an entry, and the matrix row is replaced.** The entry records the previous scores and verdict, the new ones, and the reason. This is the only place a superseded score survives.
5. **Gap-scan findings are appended here.** §10 Phase 4's `hesreallyhim/awesome-claude-code` gap scan produces capability-gap findings, each mapped to one owning plugin or explicitly marked out of scope. Gap entries use the same template with `axis:` triggers or `n/a` where nothing was rejected.
6. **Never pre-decide.** This log records reads that happened. Writing an entry for a component that has not been read at a pinned SHA fabricates audit evidence and pre-empts the §10 Phase-5 human approval gate.
7. **No SHAs typed from memory.** Any SHA quoted in an entry is copied from `upstream.json` after `scripts/pin-upstream.*` wrote it (§8).

---

## 3. Entries

*None. Phase 2 has not begun.*

---

## 4. Statistics

Recomputed by hand at each gate from the entries in §3, so the table can be checked against the file rather than trusted.

| Metric | Count |
|---|---|
| Total entries | 0 |
| Hard-reject entries | 0 |
| Axis-floor entries | 0 |
| Bulk-reject classes | 0 |
| Gap-scan entries | 0 |
| Re-audit / re-pin entries | 0 |

The verdict vocabulary is `SPEC.md` §9 rule 3 — `shortlist`, `reject`, `merge`, `defer`. This log carries entries for `reject` (mandatory) and may carry them for `merge` and `defer` where the reasoning is worth preserving; `shortlist` rows need no entry.
