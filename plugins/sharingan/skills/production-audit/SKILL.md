---
name: production-audit
description: Audit a repository for production readiness from local evidence only, covering security, data integrity, payments and webhooks, operations, user-facing failure states, secret exposure, an OWASP-style sweep, and modules that are shallower than their surface suggests. Use before a launch or rollout, after a merge, or whenever someone asks "is this ready to ship?" or "what breaks in prod?". Nothing is uploaded and no external scanner runs.
allowed-tools: [Read, Grep, Glob, "Bash(git status:*)", "Bash(git log:*)", "Bash(git diff:*)"]
---

# Production Audit

## Purpose

Answer "what will hurt us in production?" using only what the checkout, its history, and its configuration can
show. The audit ends with a banded verdict, the evidence behind it, and the one next action. It is engineering
triage, not a compliance certification, and it never sends source, secrets, or topology anywhere. The only shell
commands it runs are read-only `git status`, `git log`, and `git diff`.

## Trigger Conditions

Use when a launch, demo, customer rollout, or deploy is near; when a feature just merged and needs a risk pass;
or when CI is green but the user wants production risk rather than test status. Do not use it during active
implementation (line-level review belongs to `/sharingan:code-review`), for libraries or docs-only repositories
unless release packaging is the question, or when there is no repository to inspect. Fixes go to the
implementing workflow; this skill names them, it does not make them.

## Workflow

1. **Establish the release surface.** `git status --short --branch`, `git log --oneline -20`, and the diff stat
   against the release base. Locate package scripts, CI workflows, deployment manifests, environment
   documentation, migrations, and startup checks.
2. **Walk the boundaries that exist.** Only inspect what the repository actually has: routes and admin surfaces,
   auth middleware, background jobs, webhook handlers, payment flows, agent or model integrations, migrations.
3. **Sweep for exposed credentials.** Grep tracked files, examples, logs, fixtures, and client bundles for the
   pattern families in the table below. Any confirmed live credential is a blocker on its own.
4. **Run the OWASP-style sweep** in the table further down, then apply the false-positive checks before writing
   any finding up.
5. **Scan for shallow modules.** Note where understanding one concept means bouncing across many tiny files,
   where an interface is almost as complex as its implementation, and where the real bugs would hide in how
   extracted helpers are called rather than in the helpers. Report these as deepening opportunities with a
   strength of strong, worth exploring, or speculative; do not propose new interfaces here.
6. **Score, then report.** Apply the bands and caps, list evidence checked and evidence missing, and end with
   one concrete next action rather than an open question.

## Credential Pattern Families

Describe matches by file, line, and family. Never paste the matched value into the report.

| Family | What to look for |
|---|---|
| API credential patterns | long fixed-prefix random strings assigned to auth-like names |
| Cloud provider keys | provider-specific prefixed identifiers paired with a matching secret |
| Database URLs | connection strings carrying `user:password@host` |
| Signed tokens | three dot-separated base64url segments assigned or logged |
| Private keys | PEM header lines for RSA, EC, or OpenSSH keys inside tracked files |
| Hosting and OAuth tokens | source-forge personal, server, or OAuth tokens; OAuth client secrets |

## OWASP-Style Sweep

| Area | Questions |
|---|---|
| Injection | parameterised queries; user input never concatenated into commands, queries, or templates |
| Authentication | strong password hashing, validated session or token handling, no default credentials |
| Access control | authorisation on every route, admin separated from public, CORS deliberate |
| Sensitive data | secrets outside the client bundle and logs; personal data not written to plain logs |
| Configuration | debug modes off, security headers set, upload validation and rate limits present |
| Output handling | escaping or a framework that escapes; content security policy where rendering is dynamic |
| Deserialisation and parsers | untrusted input never deserialised into executable objects; XML entities disabled |
| Dependencies | lockfile present; known-vulnerable versions flagged from the lockfile, not from a network scan |
| Logging | security events recorded; logs redact credentials |
| Prompt and tool surfaces | untrusted content cannot reach privileged actions through a model or agent |

### Common False Positives

Verify context before flagging: placeholder values in example environment files, clearly marked test fixtures,
publishable client identifiers that are meant to be public, and hash functions used for checksums rather than
password storage. A false positive costs the reader trust in every real finding beside it.

## Risk Lenses

- **Data integrity:** migrations run forward and have a rollback or recovery path; destructive backfills are
  staged; retries on writes, jobs, and webhooks are idempotent.
- **Payments and webhooks:** signatures verified before trusting payload fields; duplicate, replayed, and
  out-of-order deliveries handled; test and live credentials separated.
- **Operations:** clean-checkout start using documented commands; required environment variables validated and
  fail fast; a health check that proves dependencies are reachable; deploy, rollback, and incident-owner paths
  written down.
- **User experience:** loading, empty, error, and permission-denied states explain what happened; the launch
  path works on mobile; a recovery route exists when a critical operation fails.

## Evidence Discipline

Never judge readiness from a dashboard screenshot, a status badge, or a script's stdout alone: dashboards
paginate and harness timing lies about asynchronous work. When logs, CI runs, or a deployed environment were not
inspected, say so before the first finding. Separate what was observed from what was inferred, and label the
inference as such; never present an inference as a fact.

## Scoring and Output

| Band | Score | Meaning |
|---|---|---|
| Blocked | 0-49 | do not ship until the blockers are fixed |
| Risky | 50-69 | ship only behind a small rollout |
| Launchable with caveats | 70-84 | ship if the owners accept the listed risks |
| Strong | 85-100 | no launch blocker visible in the evidence |

Cap at 69 when authorisation is missing on sensitive data, webhooks are not idempotent, a migration cannot run
safely, a credential is exposed, or a high-impact release has no rollback. Cap at 84 when CI is not green or the
launch-critical path was never exercised end to end.

Lead with one sentence: score, band, and the two risks to fix first. Then: **Blockers**, **High-value fixes**,
**Deepening opportunities**, **Evidence checked**, **Evidence missing**, **Next action**. Keep strengths short;
the user asked what remains at risk.
