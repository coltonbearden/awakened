#!/usr/bin/env bash
set -euo pipefail
# =============================================================================
# validate.sh - Awakened structure, frontmatter, naming, and policy validator.
# WSL2 / Linux twin of scripts/validate.ps1.
#
# PARITY RULE (CLAUDE.md 3.2): validate.ps1 implements this identical numbered
# check list, the identical message strings, and the identical exit contract.
# A change here that is not mirrored there in the same commit is a bug.
#
# DEPENDENCIES: bash 4.4+, coreutils, and python3 for JSON/CSV parsing. Both
# are standard on WSL2 Ubuntu. The PowerShell twin uses PS7's built-in JSON
# cmdlets and requires no Python. Nothing is ever auto-installed (HR-7); a
# missing interpreter is an environment error, not a violation.
#
# USAGE:
#   bash scripts/validate.sh              scaffold mode (default)
#   bash scripts/validate.sh --release    release mode: Phase-6 entries that
#                                         are expected-absent at scaffold
#                                         become errors
#   bash scripts/validate.sh --help
#
# EXIT CONTRACT (CLAUDE.md 3.3):
#   0  clean
#   1  violations - policy or structural; each failure line names its check ID
#   2  environment error (missing interpreter, unreadable tree, missing schemas)
#
# Ratified - SPEC v2.2, D-19 (formerly open as A-GAP-001 / B-GAP-001): SPEC
# section 3 tags Phase-6 entries [P6] and requires validators to treat them as
# expected-absent by default and as required under --release / -Release. Check
# S3 implements that staging: those entries report INFO when absent in scaffold
# mode and ERROR in release mode. This is normative spec text now, not a reading
# of section 3 against section 10.
#
# -----------------------------------------------------------------------------
# NUMBERED CHECK LIST - shared verbatim with scripts/validate.ps1
# -----------------------------------------------------------------------------
#   S1  Root foundation files present
#   S2  Foundation entries present (eval, schemas, scripts, templates, CI workflow)
#   S3  Phase-6 tree entries: expected-absent at scaffold, required at release
#   S4  No unexpected top-level entries against SPEC section 3
#   D1  SPEC.md present at root and carrying the governing version string
#   D2  DECISIONS.md has exactly 27 ADR headings covering D-01..D-27, no dupes
#   N1  Plugin directory names are drawn from the nine Tier-1 names
#   N3  Machine-facing names match ^[a-z0-9]+(-[a-z0-9]+)*$ (case-sensitive)
#   N4  No plugin, and no command namespace, named for the marketplace
#   N5  Tier-2 statusline preset IDs do not collide with Tier-1 plugin names
#   U1  upstream.json parses, holds exactly the ten SPEC section 8 repos, keys present
#   U2  upstream.json pin coherence: all commits null, or all pinned with pinned_at
#   R1  rubric.json matches Locked Format 4 and agrees with rubric.md text
#   M1  matrix.csv header is byte-equal to the SPEC section 9 normative header
#   M2  matrix.csv row lint: field count, axis ranges, enums, verdict coherence
#   C1  Every schemas/*.json parses and declares $schema and $id
#   C2  Agent tool allowlists carry no bare or wildcard-equivalent grant (C-2)
#   C3  Skill frontmatter: name matches its directory, description >= 40 chars
#   C4  plugin.json and marketplace.json cross-field rules
#   H1  At most one hook file per plugin (D-15)
#   H2  Hooks appear only in super-saiyan and rinnegan (D-15)
#   H3  Every hook entry declares a timeout (C-1)
#   P1  Hard-reject indicator scan over shipped components (HR-1..HR-7)
#   P2  Prompt-injection and secrets scan over shipped components (E-1)
#   P3  Hook write targets stay inside the D-18 scope (HR-8)
#   P4  No package.json at repository root (D-02, HR-7)
#   L1  No CR byte and no UTF-8 BOM in any tracked text file
# =============================================================================

ERRORS=0
WARNINGS=0
RELEASE=0

NINE_PLUGINS="super-saiyan sharingan rinnegan kaioken bankai domain instinct poneglyph aura"
HOOK_PLUGINS="super-saiyan rinnegan"
MARKETPLACE_NAME="awakened"
KEBAB='^[a-z0-9]+(-[a-z0-9]+)*$'
SPEC_VERSION_LINE='**Version:** 2.13'
MATRIX_HEADER='id,source_repo,component_path,component_type,target_plugin,value,bloat,risk,dependencies,user_scope_fit,hard_reject,verdict,rationale'

usage() {
  printf 'Usage: %s [--release] [--help]\n' "$(basename "$0")"
  printf '  --release  treat Phase-6 tree entries as required rather than expected-absent\n'
  printf '  --help     print this message and exit 0\n'
}

err()  { printf 'ERROR [%s] %s\n' "$1" "$2"; ERRORS=$((ERRORS + 1)); }
warn() { printf 'WARN  [%s] %s\n' "$1" "$2"; WARNINGS=$((WARNINGS + 1)); }
info() { printf 'INFO  [%s] %s\n' "$1" "$2"; }
ok()   { printf 'OK    [%s] %s\n' "$1" "$2"; }

env_fail() {
  printf 'ERROR [E0] %s\n' "$1" >&2
  printf 'VALIDATE: FAIL\n'
  exit 2
}

# Routes "LEVEL<TAB>CHECK<TAB>message" lines from embedded python3 programs
# through the main-shell counters. Process substitution, never a pipe, so the
# counters live in this shell.
tally() {
  local line level check msg
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    level="${line%%	*}"; line="${line#*	}"
    check="${line%%	*}"; msg="${line#*	}"
    case "$level" in
      ERROR) err "$check" "$msg" ;;
      WARN)  warn "$check" "$msg" ;;
      OK)    ok "$check" "$msg" ;;
      *)     info "$check" "$msg" ;;
    esac
  done
}

for arg in "$@"; do
  case "$arg" in
    --release) RELEASE=1 ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'ERROR [E0] unknown argument: %s\n' "$arg" >&2; usage >&2; exit 2 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)" \
  || env_fail "cannot resolve the script directory"
ROOT="$(cd "$SCRIPT_DIR/.." >/dev/null 2>&1 && pwd)" \
  || env_fail "cannot resolve the repository root"
cd "$ROOT" || env_fail "cannot enter the repository root $ROOT"

command -v python3 >/dev/null 2>&1 \
  || env_fail "python3 not found on PATH; required for JSON and CSV checks (HR-7: nothing is auto-installed)"

[ -d schemas ] || env_fail "schemas/ directory not found; the tree is not an Awakened repository root"

if [ "$RELEASE" -eq 1 ]; then
  info "MODE" "release"
else
  info "MODE" "scaffold"
fi

# -----------------------------------------------------------------------------
# S1  Root foundation files present
# -----------------------------------------------------------------------------
S1_FILES="CLAUDE.md CONTEXT.md DECISIONS.md ROADMAP.md SPEC.md upstream.json SOURCES.md CONTRIBUTING.md README.md LICENSE NOTICE .gitattributes"
s1_missing=""
for f in $S1_FILES; do
  [ -f "$f" ] || s1_missing="$s1_missing $f"
done
if [ -n "$s1_missing" ]; then
  for f in $s1_missing; do err "S1" "root foundation file is missing: $f"; done
else
  ok "S1" "all 12 root foundation files present"
fi

# -----------------------------------------------------------------------------
# S2  Foundation directories present
# -----------------------------------------------------------------------------
s2_missing=""
for d in eval schemas scripts templates templates/plugin; do
  [ -d "$d" ] || s2_missing="$s2_missing $d"
done
for f in eval/rubric.md eval/rubric.json eval/matrix.csv eval/triage-log.md \
         eval/gate-review-protocol.md eval/claude-mem-rebuild.md eval/shortlist.md \
         schemas/marketplace.schema.json schemas/plugin.schema.json \
         schemas/skill.schema.json schemas/agent.schema.json \
         scripts/validate.sh scripts/validate.ps1 \
         scripts/pin-upstream.sh scripts/pin-upstream.ps1 \
         templates/plugin/plugin.json templates/skill.md templates/command.md \
         templates/agent.md templates/hook.json \
         .github/workflows/validate.yml; do
  [ -f "$f" ] || s2_missing="$s2_missing $f"
done
if [ -n "$s2_missing" ]; then
  for f in $s2_missing; do err "S2" "foundation entry is missing: $f"; done
else
  ok "S2" "eval, schemas, scripts, templates, and the CI workflow are complete"
fi

# -----------------------------------------------------------------------------
# S3  Phase-6 tree entries
# -----------------------------------------------------------------------------
s3_deferred=".claude-plugin/marketplace.json tests .github/workflows/upstream-watch.yml"
for entry in $s3_deferred; do
  if [ -e "$entry" ]; then
    ok "S3" "Phase-6 entry present: $entry"
  elif [ "$RELEASE" -eq 1 ]; then
    err "S3" "Phase-6 entry is missing in release mode: $entry (ROADMAP V6.1)"
  else
    info "S3" "Phase-6 entry absent by design at scaffold: $entry"
  fi
done
if [ -d plugins ]; then
  for d in plugins/*/; do
    [ -d "$d" ] || continue
    name="$(basename "$d")"
    if [ -f "$d.claude-plugin/plugin.json" ]; then
      ok "S3" "plugin manifest present: $name"
    elif [ "$RELEASE" -eq 1 ]; then
      err "S3" "plugin manifest is missing in release mode: plugins/$name/.claude-plugin/plugin.json"
    else
      info "S3" "plugin not yet scaffolded, absent by design at scaffold: $name"
    fi
  done
fi

# -----------------------------------------------------------------------------
# S4  No unexpected top-level entries
# -----------------------------------------------------------------------------
S4_ALLOWED=".git .github .claude-plugin plugins schemas scripts eval templates tests .gitattributes CLAUDE.md CONTEXT.md DECISIONS.md ROADMAP.md SPEC.md upstream.json SOURCES.md CONTRIBUTING.md README.md LICENSE NOTICE"
for entry in * .[!.]*; do
  [ -e "$entry" ] || continue
  case " $S4_ALLOWED " in
    *" $entry "*) ;;
    *) warn "S4" "top-level entry is not in the SPEC section 3 tree: $entry" ;;
  esac
done
ok "S4" "top-level entries checked against SPEC section 3"

# -----------------------------------------------------------------------------
# D1  SPEC.md present and carrying the governing version string
# -----------------------------------------------------------------------------
if [ -f SPEC.md ]; then
  if grep -Fqx "$SPEC_VERSION_LINE" SPEC.md; then
    ok "D1" "SPEC.md carries the governing version string"
  else
    err "D1" "SPEC.md does not carry the governing version line: $SPEC_VERSION_LINE"
  fi
fi

# -----------------------------------------------------------------------------
# D2  DECISIONS.md ADR parity with SPEC section 12
# -----------------------------------------------------------------------------
if [ -f DECISIONS.md ]; then
  tally < <(python3 - DECISIONS.md <<'PY'
import re, sys
text = open(sys.argv[1], encoding='utf-8').read()
heads = re.findall(r'^## ADR-(\d{3})\b', text, re.M)
refs  = re.findall(r'^\|\s*Spec ref\s*\|\s*(D-\d{2})\s*\|', text, re.M)
if len(heads) != 27:
    print(f"ERROR\tD2\tDECISIONS.md has {len(heads)} ADR headings, expected exactly 27 (D-16)")
expected_adr = [f"{n:03d}" for n in range(1, 28)]
if sorted(heads) != expected_adr:
    print("ERROR\tD2\tADR headings are not exactly ADR-001..ADR-027")
expected_ref = [f"D-{n:02d}" for n in range(1, 28)]
if sorted(refs) != expected_ref:
    missing = sorted(set(expected_ref) - set(refs))
    dupes = sorted({r for r in refs if refs.count(r) > 1})
    if missing:
        print("ERROR\tD2\tSpec ref fields do not cover: " + ", ".join(missing))
    if dupes:
        print("ERROR\tD2\tSpec ref fields are duplicated: " + ", ".join(dupes))
    if not missing and not dupes:
        print("ERROR\tD2\tSpec ref fields do not map 1:1 onto D-01..D-27")
if len(heads) == 27 and sorted(heads) == expected_adr and sorted(refs) == expected_ref:
    print("OK\tD2\t27 ADRs mapping 1:1 onto D-01..D-27")
PY
)
fi

# -----------------------------------------------------------------------------
# N1  Plugin directory names
# N3  Kebab-case, case-sensitive
# N4  Marketplace name never used as a plugin or command namespace
# N5  Tier-2 statusline preset IDs
# -----------------------------------------------------------------------------
n1_bad=0
if [ -d plugins ]; then
  for d in plugins/*/; do
    [ -d "$d" ] || continue
    name="$(basename "$d")"
    case " $NINE_PLUGINS " in
      *" $name "*) ;;
      *) err "N1" "plugin directory is not one of the nine Tier-1 names: $name"; n1_bad=1 ;;
    esac
  done
fi
[ "$n1_bad" -eq 0 ] && ok "N1" "plugin directory names are within the Tier-1 set"

n3_bad=0
while IFS= read -r path; do
  base="$(basename "$path")"
  base="${base%.md}"; base="${base%.json}"
  # SKILL.md, .claude-plugin/ and CHANGELOG.md are fixed names the SPEC section 3
  # plugin layout mandates; they are not machine-facing component names (N-3).
  case "$base" in SKILL|.claude-plugin|CHANGELOG) continue ;; esac
  if ! printf '%s' "$base" | grep -Eq "$KEBAB"; then
    err "N3" "machine-facing name is not kebab-case: $path"
    n3_bad=1
  fi
done < <({ find plugins -mindepth 1 \( -name '*.md' -o -name '*.json' -o -type d \) 2>/dev/null || true; } | LC_ALL=C sort)
[ "$n3_bad" -eq 0 ] && ok "N3" "component names are lowercase kebab-case (N-3)"

n4_bad=0
if [ -d "plugins/$MARKETPLACE_NAME" ]; then
  err "N4" "a plugin named for the marketplace exists: plugins/$MARKETPLACE_NAME (N-4 prohibits the catch-all)"
  n4_bad=1
fi
while IFS= read -r cmd; do
  ns="$(printf '%s' "$cmd" | cut -d/ -f2)"
  if [ "$ns" = "$MARKETPLACE_NAME" ]; then
    err "N4" "command namespaces under the marketplace name: $cmd (N-4)"
    n4_bad=1
  fi
done < <(find plugins -mindepth 3 -path '*/commands/*.md' 2>/dev/null || true)
[ "$n4_bad" -eq 0 ] && ok "N4" "no marketplace-level plugin or command namespace (N-4)"

n5_bad=0
if [ -d plugins/aura/statuslines ]; then
  for p in plugins/aura/statuslines/*; do
    [ -e "$p" ] || continue
    preset="$(basename "$p")"; preset="${preset%.*}"
    case " $NINE_PLUGINS " in
      *" $preset "*)
        err "N5" "statusline preset ID collides with a Tier-1 plugin name: $preset (N-5, D-17)"
        n5_bad=1 ;;
    esac
  done
fi
[ "$n5_bad" -eq 0 ] && ok "N5" "no Tier-2 statusline preset collides with a Tier-1 plugin name"

# -----------------------------------------------------------------------------
# U1  upstream.json registry shape
# U2  upstream.json pin coherence
# -----------------------------------------------------------------------------
if [ -f upstream.json ]; then
  tally < <(python3 - upstream.json <<'PY'
import json, re, sys
EXPECTED = {
    "obra/superpowers", "mattpocock/skills", "affaan-m/ECC", "thedotmack/claude-mem",
    "wshobson/agents", "anthropics/skills", "kepano/obsidian-skills",
    "vercel-labs/skills", "hesreallyhim/awesome-claude-code",
    "davila7/claude-code-templates",
}
KEYS = ["name", "url", "license", "role", "commit", "notes"]
try:
    d = json.load(open(sys.argv[1], encoding='utf-8'))
except Exception as exc:
    print(f"ERROR\tU1\tupstream.json does not parse: {exc}")
    raise SystemExit(0)
repos = d.get("repos")
if not isinstance(repos, list):
    print("ERROR\tU1\tupstream.json has no repos array")
    raise SystemExit(0)
if len(repos) != 10:
    print(f"ERROR\tU1\tupstream.json holds {len(repos)} repos, expected exactly 10 (SPEC section 8)")
names = {r.get("name") for r in repos}
for miss in sorted(EXPECTED - names):
    print(f"ERROR\tU1\tupstream.json is missing a SPEC section 8 repository: {miss}")
for extra in sorted(names - EXPECTED):
    print(f"ERROR\tU1\tupstream.json holds a repository SPEC section 8 does not list: {extra}")
for r in repos:
    for k in KEYS:
        if k not in r:
            print(f"ERROR\tU1\tupstream.json repo {r.get('name')!r} is missing key: {k}")
if len(repos) == 10 and names == EXPECTED:
    print("OK\tU1\tupstream.json holds exactly the ten SPEC section 8 repositories")

commits = [r.get("commit") for r in repos]
pinned_at = d.get("pinned_at", "__absent__")
if pinned_at == "__absent__":
    print("ERROR\tU2\tupstream.json has no pinned_at key (Locked Format 3)")
elif all(c is None for c in commits):
    if pinned_at is None:
        print("OK\tU2\tall commits null and pinned_at null - scaffold state per SPEC section 8")
    else:
        print("ERROR\tU2\tpinned_at is set while every commit is null; run scripts/pin-upstream.*")
elif any(c is None for c in commits):
    print("ERROR\tU2\tupstream.json is partially pinned; pin-upstream writes all ten or none")
else:
    bad = [r.get("name") for r in repos
           if not re.fullmatch(r"[0-9a-f]{40}", str(r.get("commit")))]
    if bad:
        print("ERROR\tU2\tcommit is not a 40-character lowercase SHA for: " + ", ".join(map(str, bad)))
    elif pinned_at is None:
        print("ERROR\tU2\tall ten repos are pinned but pinned_at is null")
    else:
        print("OK\tU2\tall ten repos pinned with a pinned_at timestamp")
PY
)
fi

# -----------------------------------------------------------------------------
# R1  rubric.json shape and rubric.md agreement
# -----------------------------------------------------------------------------
if [ -f eval/rubric.json ] && [ -f eval/rubric.md ]; then
  tally < <(python3 - eval/rubric.json eval/rubric.md <<'PY'
import json, sys
try:
    r = json.load(open(sys.argv[1], encoding='utf-8'))
except Exception as exc:
    print(f"ERROR\tR1\teval/rubric.json does not parse: {exc}")
    raise SystemExit(0)
md = open(sys.argv[2], encoding='utf-8').read()
problems = []
if r.get("version") != "2.1":
    problems.append('version is not the string "2.1"')
axes = r.get("axes")
if not isinstance(axes, list) or len(axes) != 5:
    problems.append("axes is not a list of 5 objects")
    axes = []
th = r.get("thresholds")
if not isinstance(th, dict) or th.get("min_axis") != 3 \
        or th.get("hard_reject_overrides") is not True \
        or th.get("single_owner_required") is not True:
    problems.append("thresholds must be {min_axis:3, hard_reject_overrides:true, single_owner_required:true}")
if r.get("verdicts") != ["shortlist", "reject", "merge", "defer"]:
    problems.append("verdicts must be the SPEC section 9 rule 3 array")
if r.get("hard_rejects") != [f"HR-{n}" for n in range(1, 9)]:
    problems.append("hard_rejects must be the ID strings HR-1..HR-8")
for a in axes:
    for k in ("id", "name", "question", "anchors"):
        if k not in a:
            problems.append(f"axis {a.get('id', '?')} is missing key {k}")
    if a.get("question") and a["question"] not in md:
        problems.append(f"axis {a.get('id')} question text is absent from rubric.md")
    for lvl in ("1", "3", "5"):
        anchor = (a.get("anchors") or {}).get(lvl)
        if anchor is None:
            problems.append(f"axis {a.get('id')} is missing anchor {lvl}")
        elif anchor not in md:
            problems.append(f"axis {a.get('id')} anchor {lvl} is absent from rubric.md")
for p in problems:
    print(f"ERROR\tR1\t{p}")
if not problems:
    print("OK\tR1\trubric.json matches Locked Format 4 and agrees with rubric.md")
PY
)
fi

# -----------------------------------------------------------------------------
# M1  matrix.csv header
# M2  matrix.csv row lint
# -----------------------------------------------------------------------------
if [ -f eval/matrix.csv ]; then
  tally < <(MATRIX_HEADER="$MATRIX_HEADER" python3 - eval/matrix.csv <<'PY'
import csv, io, os, sys
raw = open(sys.argv[1], 'rb').read()
if raw.startswith(b'\xef\xbb\xbf'):
    print("ERROR\tM1\teval/matrix.csv carries a UTF-8 BOM; the header cannot be byte-equal")
    raw = raw[3:]
text = raw.decode('utf-8')
lines = text.split('\n')
expected = os.environ["MATRIX_HEADER"]
if not lines or lines[0] != expected:
    print("ERROR\tM1\teval/matrix.csv header is not byte-equal to the SPEC section 9 normative header")
else:
    print("OK\tM1\teval/matrix.csv header is byte-equal to the SPEC section 9 header")

TYPES = {"skill", "command", "agent", "hook", "template", "concept"}
VERDICTS = {"shortlist", "reject", "merge", "defer"}
AXES = (5, 6, 7, 8, 9)
data = [ln for ln in lines[1:] if ln.strip() and not ln.lstrip().startswith('#')]
bad = 0
seen = {}
for row in csv.reader(io.StringIO('\n'.join(data))):
    if len(row) != 13:
        print(f"ERROR\tM2\trow has {len(row)} fields, expected 13: {row[0] if row else '(empty)'}")
        bad += 1
        continue
    rid, verdict, hard = row[0], row[11], row[10]
    seen[rid] = seen.get(rid, 0) + 1
    for i in AXES:
        try:
            n = int(row[i])
            assert 1 <= n <= 5
        except Exception:
            print(f"ERROR\tM2\trow {rid}: axis field {i + 1} is not an integer 1-5: {row[i]!r}")
            bad += 1
    if row[3] not in TYPES:
        print(f"ERROR\tM2\trow {rid}: component_type {row[3]!r} is outside the SPEC section 9 enum")
        bad += 1
    if verdict not in VERDICTS:
        print(f"ERROR\tM2\trow {rid}: verdict {verdict!r} is outside the SPEC section 9 rule 3 enum")
        bad += 1
    if hard.strip() and verdict != "reject":
        print(f"ERROR\tM2\trow {rid}: hard_reject is set but verdict is {verdict!r}, not reject")
        bad += 1
    if verdict == "shortlist":
        if hard.strip():
            print(f"ERROR\tM2\trow {rid}: shortlist row carries a hard_reject value")
            bad += 1
        if not row[4].strip():
            print(f"ERROR\tM2\trow {rid}: shortlist row names no target_plugin")
            bad += 1
        if any(int(row[i]) < 3 for i in AXES if row[i].strip().isdigit()):
            print(f"ERROR\tM2\trow {rid}: shortlist row has an axis below the floor of 3")
            bad += 1
    if verdict in ("merge", "defer") and not row[12].strip():
        print(f"ERROR\tM2\trow {rid}: {verdict} row must name its target in rationale")
        bad += 1
for rid, n in seen.items():
    if n > 1:
        print(f"ERROR\tM2\tduplicate component id appears {n} times: {rid} (ROADMAP V5.2)")
        bad += 1
if not bad:
    print(f"OK\tM2\t{len(data)} matrix data row(s) pass the lint")
PY
)
fi

# -----------------------------------------------------------------------------
# C1  Schemas parse and declare $schema and $id
# -----------------------------------------------------------------------------
tally < <(python3 - schemas <<'PY'
import glob, json, os, sys
bad = 0
files = sorted(glob.glob(os.path.join(sys.argv[1], '*.schema.json')))
if len(files) != 4:
    print(f"ERROR\tC1\tschemas/ holds {len(files)} schema files, expected 4")
    bad += 1
for f in files:
    try:
        s = json.load(open(f, encoding='utf-8'))
    except Exception as exc:
        print(f"ERROR\tC1\t{f} does not parse: {exc}")
        bad += 1
        continue
    for key in ("$schema", "$id"):
        if key not in s:
            print(f"ERROR\tC1\t{f} does not declare {key}")
            bad += 1
if not bad:
    print("OK\tC1\tall four schemas parse and declare $schema and $id")
PY
)

# -----------------------------------------------------------------------------
# C2  Agent tool allowlists (C-2)
# C3  Skill frontmatter
# C4  plugin.json and marketplace.json cross-field rules
# -----------------------------------------------------------------------------
tally < <(python3 - "$MARKETPLACE_NAME" <<'PY'
import glob, json, os, re, sys

MARKETPLACE = sys.argv[1]
NINE = ["super-saiyan", "sharingan", "rinnegan", "kaioken", "bankai",
        "domain", "instinct", "poneglyph", "aura"]
KEBAB = re.compile(r'^[a-z0-9]+(-[a-z0-9]+)*$')
DANGER = (r"(?:[Bb][Aa][Ss][Hh]|[Ww][Rr][Ii][Tt][Ee]|[Ee][Dd][Ii][Tt]"
          r"|[Mm][Uu][Ll][Tt][Ii][Ee][Dd][Ii][Tt]"
          r"|[Nn][Oo][Tt][Ee][Bb][Oo][Oo][Kk][Ee][Dd][Ii][Tt])")
BAD_TOKEN = re.compile(r'^\s*["\']?\s*(?:\*|' + DANGER + r'\s*(?:\(\s*[*:.\s]*\s*\))?)\s*["\']?\s*$')


def frontmatter(path):
    """Parse the restricted YAML subset: scalars, [flow, lists], and '- ' block lists."""
    try:
        text = open(path, encoding='utf-8').read()
    except Exception:
        return None
    if not text.startswith('---'):
        return None
    end = text.find('\n---', 3)
    if end == -1:
        return None
    body = text[text.find('\n') + 1:end]
    data, key = {}, None
    for line in body.split('\n'):
        if not line.strip() or line.lstrip().startswith('#'):
            continue
        if line.lstrip().startswith('- ') and key is not None:
            data.setdefault(key, [])
            if isinstance(data[key], list):
                data[key].append(line.lstrip()[2:].strip().strip('"\''))
            continue
        m = re.match(r'^([A-Za-z0-9_-]+):\s*(.*)$', line)
        if not m:
            continue
        key, val = m.group(1), m.group(2).strip()
        if val.startswith('[') and val.endswith(']'):
            data[key] = [t.strip().strip('"\'') for t in val[1:-1].split(',') if t.strip()]
        elif val == '':
            data[key] = []
        else:
            data[key] = val.strip('"\'')
    return data


def tokens(value):
    if value is None:
        return []
    if isinstance(value, list):
        return [str(t) for t in value]
    return [t for t in str(value).split(',')]


bad_c2 = bad_c3 = bad_c4 = 0
agents = sorted(glob.glob('plugins/*/agents/*.md'))
for f in agents:
    fm = frontmatter(f)
    if fm is None:
        print(f"ERROR\tC2\t{f} has no parseable frontmatter")
        bad_c2 += 1
        continue
    if 'tools' not in fm:
        print(f"ERROR\tC2\t{f} declares no tools allowlist; C-2 makes it mandatory")
        bad_c2 += 1
        continue
    for tok in tokens(fm['tools']):
        if BAD_TOKEN.match(tok):
            print(f"ERROR\tC2\t{f} grants a bare or wildcard-equivalent tool: {tok.strip()!r} (C-2)")
            bad_c2 += 1
    if str(fm.get('permissionMode', '')) == 'bypassPermissions':
        print(f"ERROR\tC2\t{f} sets permissionMode: bypassPermissions (C-2)")
        bad_c2 += 1
if agents and not bad_c2:
    print(f"OK\tC2\t{len(agents)} agent allowlist(s) carry no bare or wildcard-equivalent grant")
elif not agents:
    print("INFO\tC2\tno agent files present; C-2 allowlist check not exercised")

skills = sorted(glob.glob('plugins/*/skills/*/SKILL.md'))
for f in skills:
    fm = frontmatter(f)
    if fm is None:
        print(f"ERROR\tC3\t{f} has no parseable frontmatter")
        bad_c3 += 1
        continue
    expected = os.path.basename(os.path.dirname(f))
    name = fm.get('name')
    if name != expected:
        print(f"ERROR\tC3\t{f} frontmatter name {name!r} does not match its directory {expected!r}")
        bad_c3 += 1
    if name and not KEBAB.match(str(name)):
        print(f"ERROR\tC3\t{f} name is not kebab-case: {name!r} (N-3)")
        bad_c3 += 1
    desc = str(fm.get('description', ''))
    if len(desc) < 40:
        print(f"ERROR\tC3\t{f} description is {len(desc)} characters; the floor is 40 (N-2)")
        bad_c3 += 1
if skills and not bad_c3:
    print(f"OK\tC3\t{len(skills)} skill frontmatter block(s) conform")
elif not skills:
    print("INFO\tC3\tno skill files present; frontmatter check not exercised")

for f in sorted(glob.glob('plugins/*/.claude-plugin/plugin.json')):
    plugin_dir = os.path.basename(os.path.dirname(os.path.dirname(f)))
    try:
        m = json.load(open(f, encoding='utf-8'))
    except Exception as exc:
        print(f"ERROR\tC4\t{f} does not parse: {exc}")
        bad_c4 += 1
        continue
    if m.get('name') != plugin_dir:
        print(f"ERROR\tC4\t{f} name {m.get('name')!r} does not match its directory {plugin_dir!r}")
        bad_c4 += 1
    if m.get('name') == MARKETPLACE:
        print(f"ERROR\tC4\t{f} is named for the marketplace (N-4)")
        bad_c4 += 1
    if m.get('license') != 'MIT':
        print(f"ERROR\tC4\t{f} license is {m.get('license')!r}; Awakened is MIT end to end (D-08)")
        bad_c4 += 1

cat = '.claude-plugin/marketplace.json'
if os.path.isfile(cat):
    try:
        c = json.load(open(cat, encoding='utf-8'))
    except Exception as exc:
        print(f"ERROR\tC4\t{cat} does not parse: {exc}")
        bad_c4 += 1
        c = None
    if c is not None:
        if c.get('name') != MARKETPLACE:
            print(f"ERROR\tC4\t{cat} name is {c.get('name')!r}, expected {MARKETPLACE!r} (D-03)")
            bad_c4 += 1
        owner = (c.get('owner') or {}).get('name')
        if owner != 'coltonbearden':
            print(f"ERROR\tC4\t{cat} owner.name is {owner!r}; SPEC section 2 fixes it to 'coltonbearden'")
            bad_c4 += 1
        entries = c.get('plugins') or []
        listed = []
        for e in entries:
            n, src = e.get('name'), e.get('source')
            listed.append(n)
            if n == MARKETPLACE:
                print(f"ERROR\tC4\t{cat} lists a plugin named for the marketplace (N-4)")
                bad_c4 += 1
            if isinstance(src, str) and os.path.basename(src.rstrip('/')) != n:
                print(f"ERROR\tC4\t{cat} entry {n!r} source basename does not equal its name: {src!r}")
                bad_c4 += 1
        if len(entries) != 9:
            print(f"ERROR\tC4\t{cat} lists {len(entries)} plugins, expected exactly 9 (ROADMAP V6.4)")
            bad_c4 += 1
        if sorted(x for x in listed if x) != sorted(NINE):
            print(f"ERROR\tC4\t{cat} entries do not match the nine Tier-1 plugin names")
            bad_c4 += 1
        on_disk = sorted(os.path.basename(p.rstrip('/'))
                         for p in glob.glob('plugins/*') if os.path.isdir(p))
        for d in on_disk:
            if d not in listed:
                print(f"ERROR\tC4\tplugins/{d} exists on disk but is absent from {cat}")
                bad_c4 += 1
    if not bad_c4:
        print("OK\tC4\tmarketplace catalog and plugin manifests are internally consistent")
else:
    print("INFO\tC4\tno marketplace catalog present; catalog cross-checks not exercised (Phase 6)")
PY
)

# -----------------------------------------------------------------------------
# H1  Hook budget per plugin
# H2  Hook ownership
# H3  Hook timeout
# -----------------------------------------------------------------------------
tally < <(python3 <<'PY'
import glob, json, os
BUDGETED = {"super-saiyan", "rinnegan"}
found = 0
bad = 0
for d in sorted(glob.glob('plugins/*/')):
    plugin = os.path.basename(d.rstrip('/'))
    hooks = sorted(glob.glob(os.path.join(d, 'hooks', '*.json')))
    if not hooks:
        continue
    found += len(hooks)
    if len(hooks) > 1:
        print(f"ERROR\tH1\t{plugin} declares {len(hooks)} hook files; the budget is 1 (D-15)")
        bad += 1
    if plugin not in BUDGETED:
        print(f"ERROR\tH2\t{plugin} ships a hook; only super-saiyan and rinnegan are budgeted (D-15)")
        bad += 1
    for h in hooks:
        try:
            cfg = json.load(open(h, encoding='utf-8'))
        except Exception as exc:
            print(f"ERROR\tH3\t{h} does not parse: {exc}")
            bad += 1
            continue
        entries = []
        for events in (cfg.get('hooks') or {}).values():
            for matcher in events if isinstance(events, list) else []:
                entries.extend(matcher.get('hooks') or [])
        if not entries:
            print(f"ERROR\tH3\t{h} declares no hook entries")
            bad += 1
        for e in entries:
            if 'timeout' not in e:
                print(f"ERROR\tH3\t{h} has a hook entry with no timeout (C-1)")
                bad += 1
            elif not isinstance(e['timeout'], int) or not 1 <= e['timeout'] <= 10:
                print(f"ERROR\tH3\t{h} timeout {e['timeout']!r} is outside the repo standard of 1-10 seconds")
                bad += 1
if not found:
    print("INFO\tH1\tno hook files present; the D-15 budget is trivially satisfied")
elif not bad:
    print(f"OK\tH1\t{found} hook file(s) within the D-15 budget, owned and timeout-bounded")
PY
)

# -----------------------------------------------------------------------------
# P1  Hard-reject indicator scan over shipped components
# P2  Prompt-injection and secrets scan over shipped components
# P3  Hook write targets (HR-8 with the D-18 carve-out)
# P4  No package.json at repository root
# -----------------------------------------------------------------------------
tally < <(python3 <<'PY'
import glob, json, os, re

# The policy lint runs over SHIPPED COMPONENTS only - plugins/**. Governance
# documents describe the policy and legitimately contain the words the lint
# looks for, so scanning them would flag Awakened's own safety documentation
# as a violation of itself.
# os.walk rather than glob: glob skips dot-directories, and .claude-plugin/plugin.json
# is a shipped file the scan must cover (parity with the PowerShell twin's -Force walk).
COMPONENTS = sorted(os.path.join(root, f)
                    for root, _dirs, files in os.walk('plugins')
                    for f in files
                    if f.rsplit('.', 1)[-1] in ('md', 'json', 'sh', 'ps1'))

HR_PATTERNS = [
    ("HR-1", r'\b(api[_ -]?key|secret[_ -]?key|access[_ -]?token|bearer\s+[A-Za-z0-9._-]{16,})\b'),
    ("HR-2", r'"mcpServers"\s*:\s*\{'),
    ("HR-3", r'\b(lspServers|language[- ]server-protocol)\b'),
    ("HR-4", r'\b(nohup|systemd|launchd|crontab|setInterval|while\s+true\s*;\s*do)\b'),
    ("HR-5", r'\b(sqlite3?|better-sqlite3|node-gyp|\.node\b)'),
    ("HR-6", r'\b(curl\s+http|wget\s+http|fetch\(|https?://[^\s)"\']+/(v\d|api)/)'),
    ("HR-7", r'\b(npm\s+i(nstall)?\b|pip\s+install\b|apt(-get)?\s+install\b|winget\s+install\b|cargo\s+install\b)'),
]
INJECTION = [
    r'ignore\s+(all\s+)?previous\s+instructions',
    r'without\s+(asking|confirmation|prompting)',
    r'do\s+not\s+ask\s+the\s+user',
    r'\bbypass(ing)?\s+(the\s+)?(confirmation|permission|approval)',
    r'base64\s*(-d|--decode|\.b64decode)',
]

p1 = p2 = 0
for f in COMPONENTS:
    try:
        text = open(f, encoding='utf-8').read()
    except Exception:
        continue
    for hr, pat in HR_PATTERNS:
        for m in re.finditer(pat, text, re.I):
            line = text[:m.start()].count('\n') + 1
            print(f"ERROR\tP1\t{f}:{line} matches a {hr} indicator: {m.group(0)[:60]!r}")
            p1 += 1
    for pat in INJECTION:
        for m in re.finditer(pat, text, re.I):
            line = text[:m.start()].count('\n') + 1
            print(f"ERROR\tP2\t{f}:{line} matches a prompt-injection or obfuscation pattern: {m.group(0)[:60]!r} (E-1)")
            p2 += 1
if not COMPONENTS:
    print("INFO\tP1\tno shipped components present; the HR indicator scan is not exercised")
    print("INFO\tP2\tno shipped components present; the E-1 injection scan is not exercised")
else:
    if not p1:
        print(f"OK\tP1\t{len(COMPONENTS)} component file(s) carry no HR-1..HR-7 indicator")
    if not p2:
        print(f"OK\tP2\t{len(COMPONENTS)} component file(s) carry no injection or obfuscation pattern")

# P3 - hook write targets. Permitted prefixes are the D-18 scope: the project
# directory and the owning plugin's own data directory.
# Every pattern is anchored: the allow-list gates a PREFIX, never a substring.
# The PowerShell twin holds this same array verbatim, where the anchors are
# load-bearing because -cmatch searches anywhere in the string.
ALLOWED = (r'^\$\{?CLAUDE_PROJECT_DIR\}?', r'^\$\{?CLAUDE_PLUGIN_DATA(_DIR)?\}?',
           r'^\$\{?CLAUDE_PLUGIN_ROOT\}?', r'^\./', r'^[A-Za-z0-9_.-]+/')
# A prefix allow-list alone cannot hold HR-8: '.' is inside the character class
# above, so '../' matches it, and 'logs/../../etc/passwd' matches even anchored.
# Any '..' path segment is therefore denied outright, before the allow-list runs.
TRAVERSAL = re.compile(r'(^|[/\\])\.\.([/\\]|$)')
WRITE = re.compile(r'(?:>>?|tee\s+|Out-File\s+|Set-Content\s+|cp\s+\S+\s+|mv\s+\S+\s+)\s*([^\s;|&\"]+)')
p3 = 0
hookfiles = sorted(glob.glob('plugins/*/hooks/*.json'))
for h in hookfiles:
    # Both twins scan the same compact JSON round-trip, never the raw file text.
    # An unparseable hook file fails closed: a security lint may not skip silently.
    try:
        cfg = json.load(open(h, encoding='utf-8'))
    except Exception:
        print(f"ERROR\tP3\t{h} is not parseable JSON; the HR-8 write-scope scan cannot run")
        p3 += 1
        continue
    blob = json.dumps(cfg, separators=(',', ':'))
    for m in WRITE.finditer(blob):
        target = m.group(1).strip('"\\')
        if TRAVERSAL.search(target):
            print(f"ERROR\tP3\t{h} writes to a target containing a '..' path segment: {target!r} (HR-8)")
            p3 += 1
        elif not any(re.match(a, target) for a in ALLOWED):
            print(f"ERROR\tP3\t{h} writes to a target outside the D-18 scope: {target!r} (HR-8)")
            p3 += 1
if not hookfiles:
    print("INFO\tP3\tno hook files present; the HR-8 write-scope scan is not exercised")
elif not p3:
    print(f"OK\tP3\t{len(hookfiles)} hook file(s) write only inside the D-18 scope")

if os.path.isfile('package.json'):
    print("ERROR\tP4\tpackage.json exists at repository root; distribution is the GitHub repo only (D-02, HR-7)")
else:
    print("OK\tP4\tno package.json at repository root")
PY
)

# -----------------------------------------------------------------------------
# L1  Line endings and byte-order marks
# -----------------------------------------------------------------------------
tally < <(python3 <<'PY'
import os
SKIP_DIRS = {'.git', 'node_modules', '__pycache__'}
TEXT_EXT = {'.sh', '.ps1', '.psm1', '.json', '.md', '.csv', '.yml', '.yaml', '.py', '.txt'}
NAMED = {'LICENSE', 'NOTICE', '.gitattributes'}
bad = 0
count = 0
for dirpath, dirnames, filenames in os.walk('.'):
    dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
    for fn in filenames:
        path = os.path.join(dirpath, fn)
        if os.path.splitext(fn)[1] not in TEXT_EXT and fn not in NAMED:
            continue
        count += 1
        with open(path, 'rb') as fh:
            data = fh.read()
        rel = os.path.relpath(path, '.')
        if data.startswith(b'\xef\xbb\xbf'):
            print(f"ERROR\tL1\t{rel} carries a UTF-8 BOM; the policy is UTF-8 without BOM")
            bad += 1
        if b'\r' in data:
            print(f"ERROR\tL1\t{rel} contains a CR byte; the policy is LF everywhere")
            bad += 1
if not bad:
    print(f"OK\tL1\t{count} text file(s) are LF with no BOM")
PY
)

# -----------------------------------------------------------------------------
printf 'Validation complete: %d error(s), %d warning(s)\n' "$ERRORS" "$WARNINGS"
if [ "$ERRORS" -gt 0 ]; then
  printf 'VALIDATE: FAIL\n'
  exit 1
fi
printf 'VALIDATE: PASS\n'
exit 0
