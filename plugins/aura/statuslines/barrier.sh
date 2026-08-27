#!/usr/bin/env bash
# aura statusline preset: barrier
# Shows which project context layers are up around the session: CLAUDE.md, rule
# files, project settings, added directories, worktree, and the active output style.
#
# Reads from the Claude Code statusline JSON on stdin (fields only, nothing else):
#   model.display_name, workspace.project_dir, workspace.current_dir,
#   workspace.added_dirs, workspace.git_worktree, output_style.name
# Filesystem access is READ-ONLY existence checks under the project directory:
#   <project>/CLAUDE.md, <project>/.claude/rules/*.md, <project>/.claude/settings.json,
#   <project>/.claude/settings.local.json
#
# Dependencies: bash 4.4+ only. No jq, no python, no network, no writes.
# Exit contract: always exit 0 and always print one line, even on malformed or
# empty stdin, so the statusline never goes blank because of this script.
# Twin: barrier.ps1 (identical output for identical stdin and filesystem).
set -euo pipefail
export LC_ALL=C

ESC=$'\033'
RESET="${ESC}[0m"
VOID="${ESC}[38;5;93m"
ACCENT="${ESC}[38;5;51m"
DIM="${ESC}[2m"
BOLD="${ESC}[1m"

json_str() {
  local key="$1"
  if [[ "$INPUT" =~ \"${key}\"[[:space:]]*:[[:space:]]*\"(([^\"\\]|\\.)*)\" ]]; then
    local v="${BASH_REMATCH[1]}"
    v="${v//\\\"/\"}"; v="${v//\\\//\/}"; v="${v//\\\\/\\}"
    printf '%s' "$v"
  fi
}
json_obj_str() {
  local obj="$1" key="$2"
  local re="\"${obj}\"[[:space:]]*:[[:space:]]*\{[[:space:]]*"
  re+="\"${key}\"[[:space:]]*:[[:space:]]*\"(([^\"\\\\]|\\\\.)*)\""
  if [[ "$INPUT" =~ $re ]]; then
    local v="${BASH_REMATCH[1]}"
    v="${v//\\\"/\"}"; v="${v//\\\//\/}"; v="${v//\\\\/\\}"
    printf '%s' "$v"
  fi
}
# json_arr_count KEY -> number of string items in the "KEY": [ ... ] array
json_arr_count() {
  local key="$1" body n=0
  if [[ "$INPUT" =~ \"${key}\"[[:space:]]*:[[:space:]]*\[([^]]*)\] ]]; then
    body="${BASH_REMATCH[1]}"
    while [[ "$body" =~ \"(([^\"\\]|\\.)*)\"(.*) ]]; do n=$(( n + 1 )); body="${BASH_REMATCH[3]}"; done
  fi
  printf '%s' "$n"
}
base_name() {
  local p="$1"
  p="${p%/}"; p="${p%\\}"
  p="${p##*/}"; p="${p##*\\}"
  printf '%s' "$p"
}
layer() { # layer LABEL PRESENT(0/1) [DETAIL]
  if [[ "$2" == "1" ]]; then printf '%s' "${ACCENT}${1}${3:+ $3}${RESET}"; else printf '%s' "${DIM}${1} --${RESET}"; fi
}

main() {
  INPUT=""
  if [[ ! -t 0 ]]; then INPUT="$(cat)"; fi

  local model project dir style worktree dirs
  model="$(json_str display_name)"; model="${model:-Claude}"
  project="$(json_str project_dir)"
  dir="$(json_str current_dir)"
  [[ -n "$project" ]] || project="$dir"
  style="$(json_obj_str output_style name)"
  worktree="$(json_str git_worktree)"
  dirs="$(json_arr_count added_dirs)"

  local has_claude=0 has_settings=0 rules=0 f
  if [[ -n "$project" && -d "$project" ]]; then
    [[ -f "$project/CLAUDE.md" ]] && has_claude=1
    { [[ -f "$project/.claude/settings.json" ]] || [[ -f "$project/.claude/settings.local.json" ]]; } && has_settings=1
    if [[ -d "$project/.claude/rules" ]]; then
      for f in "$project"/.claude/rules/*.md; do [[ -f "$f" ]] && rules=$(( rules + 1 )); done
    fi
  fi

  local rules_on=0 dirs_on=0 wt_on=0 style_on=0
  (( rules > 0 )) && rules_on=1
  (( dirs > 0 )) && dirs_on=1
  [[ -n "$worktree" ]] && wt_on=1
  [[ -n "$style" && "$style" != "default" ]] && style_on=1

  local name; name="$(base_name "$dir")"; name="${name:-?}"
  local line
  line="${BOLD}${VOID}[BARRIER]${RESET} ${name}"
  line+=" | $(layer CLAUDE.md "$has_claude") | $(layer rules "$rules_on" "$rules")"
  line+=" | $(layer settings "$has_settings") | $(layer dirs "$dirs_on" "+${dirs}")"
  line+=" | $(layer worktree "$wt_on" "$worktree") | $(layer style "$style_on" "$style") | ${model}"
  printf '%s\n' "$line"
}

main || printf '%s\n' "[BARRIER] down"
exit 0
