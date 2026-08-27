#!/usr/bin/env bash
# aura statusline preset: power-level
# Renders context-window usage as a rising power level.
#
# Reads from the Claude Code statusline JSON on stdin (fields only, nothing else):
#   model.display_name, workspace.current_dir, context_window.total_input_tokens,
#   context_window.context_window_size, cost.total_cost_usd, exceeds_200k_tokens
# Percent is total_input_tokens * 100 / context_window_size, the same input-only
# formula Claude Code uses for used_percentage, so the value matches the built-in one.
#
# Dependencies: bash 4.4+ only. No jq, no python, no network, no writes.
# Exit contract: always exit 0 and always print one line, even on malformed or
# empty stdin, so the statusline never goes blank because of this script.
# Twin: power-level.ps1 (identical output for identical stdin).
set -euo pipefail
export LC_ALL=C

ESC=$'\033'
RESET="${ESC}[0m"
GOLD="${ESC}[38;5;220m"
ORANGE="${ESC}[38;5;208m"
RED="${ESC}[38;5;196m"
DIM="${ESC}[2m"
BOLD="${ESC}[1m"

# json_str KEY  -> value of the first "KEY": "..." pair, JSON escapes for \" \\ \/ decoded
json_str() {
  local key="$1"
  if [[ "$INPUT" =~ \"${key}\"[[:space:]]*:[[:space:]]*\"(([^\"\\]|\\.)*)\" ]]; then
    local v="${BASH_REMATCH[1]}"
    v="${v//\\\"/\"}"; v="${v//\\\//\/}"; v="${v//\\\\/\\}"
    printf '%s' "$v"
  fi
}
# json_num KEY  -> bare number/true/false/null after "KEY":, or empty
json_num() {
  local key="$1"
  if [[ "$INPUT" =~ \"${key}\"[[:space:]]*:[[:space:]]*(-?[0-9.]+|true|false|null) ]]; then
    printf '%s' "${BASH_REMATCH[1]}"
  fi
}
base_name() {
  local p="$1"
  p="${p%/}"; p="${p%\\}"
  p="${p##*/}"; p="${p##*\\}"
  printf '%s' "$p"
}
with_commas() {
  local n="$1" out=""
  while (( ${#n} > 3 )); do out=",${n: -3}${out}"; n="${n:0:${#n}-3}"; done
  printf '%s%s' "$n" "$out"
}

main() {
  INPUT=""
  if [[ ! -t 0 ]]; then INPUT="$(cat)"; fi

  local model dir used size cost exceeds pct
  model="$(json_str display_name)";      model="${model:-Claude}"
  dir="$(base_name "$(json_str current_dir)")"; dir="${dir:-?}"
  used="$(json_num total_input_tokens)"; used="${used%%.*}"; [[ "$used" =~ ^[0-9]+$ ]] || used=0
  size="$(json_num context_window_size)"; size="${size%%.*}"; [[ "$size" =~ ^[1-9][0-9]*$ ]] || size=200000
  cost="$(json_num total_cost_usd)"; [[ "$cost" =~ ^[0-9.]+$ ]] || cost=0
  exceeds="$(json_num exceeds_200k_tokens)"
  pct=$(( used * 100 / size )); (( pct > 100 )) && pct=100

  local color label
  if   (( pct >= 90 )); then color="$RED";    label="ASCENDED"
  elif (( pct >= 60 )); then color="$ORANGE"; label="RISING"
  else                       color="$GOLD";   label="CHARGING"; fi
  [[ "$exceeds" == "true" ]] && label="LIMIT BREAK"

  local filled=$(( pct / 10 )) bar="" i
  for (( i = 0; i < 10; i++ )); do
    if (( i < filled )); then bar+="#"; else bar+="-"; fi
  done

  local costf
  costf="$(printf '%.2f' "$cost")"
  local head tokens
  head="${BOLD}${color}POWER LEVEL${RESET} ${color}[${bar}]${RESET} ${pct}% ${DIM}${label}${RESET}"
  tokens="$(with_commas "$used")/$(with_commas "$size")"
  printf '%s\n' "${head} | ${tokens} | ${model} | ${dir} | \$${costf}"
}

main || printf '%s\n' "POWER LEVEL [----------] 0%"
exit 0
