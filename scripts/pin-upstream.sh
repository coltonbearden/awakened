#!/usr/bin/env bash
set -euo pipefail
# =============================================================================
# pin-upstream.sh - Awakened upstream pin resolver (WSL2/Linux twin of
# scripts/pin-upstream.ps1).
#
# Resolves each repository in upstream.json to its default-branch HEAD SHA via
# `git ls-remote` and writes the SHAs plus a UTC pinned_at timestamp back.
#
# This script is the ONLY sanctioned source of upstream.json commit values.
# SPEC section 8: "No SHA may ever be typed from memory." Its network use is
# the sanctioned repo-maintenance exception under HR-6 - it is not a shipped
# plugin component and never runs on a user's machine as part of a plugin.
#
# PARITY RULE (CLAUDE.md 3.2): scripts/pin-upstream.ps1 implements the identical
# check list, the identical write-back semantics, and the identical exit
# contract. A change here that is not mirrored there in the same commit is a bug.
#
# USAGE:   bash scripts/pin-upstream.sh [path/to/upstream.json]   (default: ./upstream.json)
#
# EXIT CONTRACT (CLAUDE.md 3.3):
#   0  all ten repositories resolved and written
#   1  one or more unresolved; upstream.json left unchanged
#   2  environment error (missing git or python3, unreadable manifest)
#
# DEPENDENCIES: git, python3 >= 3.8 (stdlib only). Nothing is auto-installed
# (HR-7); a missing dependency is an environment error, not a violation.
#
# ATOMICITY: all ten repositories resolve, or upstream.json is not touched.
# A partial pin can never masquerade as a complete one, which is what the
# SPEC section 10 Phase-2 exit criterion is scored against.
# =============================================================================

env_fail() {
  printf '[FAIL][E0] %s\n' "$1" >&2
  printf 'PIN: FAIL\n'
  exit 2
}

command -v git >/dev/null 2>&1 || env_fail "git not found on PATH"
command -v python3 >/dev/null 2>&1 || env_fail "python3 not found on PATH"
python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 8) else 1)' \
  || env_fail "python3 3.8 or newer is required"

manifest="${1:-./upstream.json}"
[ -f "$manifest" ] || env_fail "upstream.json not found at ${manifest}"

# Emit "name<TAB>url" for every repo, failing loudly on malformed JSON.
mapfile -t rows < <(python3 - "$manifest" <<'PY'
import json, sys
with open(sys.argv[1], encoding="utf-8") as fh:
    data = json.load(fh)
for repo in data["repos"]:
    print(f"{repo['name']}\t{repo['url']}")
PY
)

[ "${#rows[@]}" -eq 10 ] || env_fail "expected 10 repos per SPEC section 8; found ${#rows[@]}"

declare -a resolved_names=()
declare -a resolved_shas=()
unresolved=0

for row in "${rows[@]}"; do
  name="${row%%	*}"
  url="${row#*	}"
  # ls-remote reads HEAD from the remote without cloning anything.
  sha="$(git ls-remote --exit-code "$url" HEAD 2>/dev/null | awk 'NR==1{print $1}')" || sha=""
  if [ -z "$sha" ]; then
    printf '[FAIL][P1] %s: could not resolve HEAD from %s\n' "$name" "$url" >&2
    unresolved=$((unresolved + 1))
    continue
  fi
  printf '[ OK ] %s %s\n' "$name" "${sha:0:7}"
  resolved_names+=("$name")
  resolved_shas+=("$sha")
done

if [ "$unresolved" -gt 0 ]; then
  printf 'PIN: FAIL (%d unresolved; upstream.json left unchanged)\n' "$unresolved"
  exit 1
fi

# Write back only once all ten have resolved.
tmpdir="${TMPDIR:-/tmp}"
names_file="$tmpdir/awakened-pin-names.$$"
shas_file="$tmpdir/awakened-pin-shas.$$"
trap 'rm -f "$names_file" "$shas_file"' EXIT

printf '%s\n' "${resolved_names[@]}" > "$names_file"
printf '%s\n' "${resolved_shas[@]}" > "$shas_file"

python3 - "$manifest" "$names_file" "$shas_file" <<'PY'
import datetime, json, sys

manifest, names_path, shas_path = sys.argv[1], sys.argv[2], sys.argv[3]
with open(names_path, encoding="utf-8") as fh:
    names = [line.rstrip("\n") for line in fh]
with open(shas_path, encoding="utf-8") as fh:
    shas = [line.rstrip("\n") for line in fh]
pins = dict(zip(names, shas))

with open(manifest, encoding="utf-8") as fh:
    data = json.load(fh)
for repo in data["repos"]:
    repo["commit"] = pins[repo["name"]]
data["pinned_at"] = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

# LF line endings, UTF-8 without BOM (CLAUDE.md 3.4).
with open(manifest, "w", encoding="utf-8", newline="\n") as fh:
    json.dump(data, fh, indent=2, ensure_ascii=False)
    fh.write("\n")
PY

printf 'PIN: PASS (10/10 resolved)\n'
exit 0
