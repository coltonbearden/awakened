#!/usr/bin/env bash
# aura statusline preset: transformation
# Renders the session's current mode as a transformation state.
#
# Reads from the Claude Code statusline JSON on stdin (fields only, nothing else):
#   model.display_name, workspace.current_dir, agent.name, cost.total_lines_added,
#   cost.total_lines_removed, context_window.total_input_tokens,
#   context_window.context_window_size, effort.level, thinking.enabled
# State rule (the stdin JSON carries no permission-mode field, so the state is
# inferred from what the session has observably done):
#   agent.name present                  -> kaioken-x20  (a delegated agent is driving)
#   lines added + removed > 0           -> super-saiyan (executing: files are changing)
#   otherwise                           -> base-form    (planning / reading, nothing changed yet)
#
# Dependencies: bash 4.4+ only. No jq, no python, no network, no writes.
# Exit contract: always exit 0 and always print one line, even on malformed or
# empty stdin, so the statusline never goes blank because of this script.
# Twin: transformation.ps1 (identical output for identical stdin).
set -euo pipefail
export LC_ALL=C

ESC=$'\033'
RESET="${ESC}[0m"
SILVER="${ESC}[38;5;250m"
GOLD="${ESC}[38;5;220m"
CRIMSON="${ESC}[38;5;160m"
BLUE="${ESC}[38;5;39m"
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
json_num() {
  local key="$1"
  if [[ "$INPUT" =~ \"${key}\"[[:space:]]*:[[:space:]]*(-?[0-9.]+|true|false|null) ]]; then
    printf '%s' "${BASH_REMATCH[1]}"
  fi
}
# json_obj_str OBJECT KEY -> "KEY" value when it is the first key inside "OBJECT": { ... }
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
base_name() {
  local p="$1"
  p="${p%/}"; p="${p%\\}"
  p="${p##*/}"; p="${p##*\\}"
  printf '%s' "$p"
}
to_int() { local n="${1%%.*}"; [[ "$n" =~ ^[0-9]+$ ]] && printf '%s' "$n" || printf '0'; }

main() {
  INPUT=""
  if [[ ! -t 0 ]]; then INPUT="$(cat)"; fi

  local model dir agent added removed used size level thinking pct
  model="$(json_str display_name)"; model="${model:-Claude}"
  dir="$(base_name "$(json_str current_dir)")"; dir="${dir:-?}"
  agent="$(json_obj_str agent name)"
  added="$(to_int "$(json_num total_lines_added)")"
  removed="$(to_int "$(json_num total_lines_removed)")"
  used="$(to_int "$(json_num total_input_tokens)")"
  size="$(to_int "$(json_num context_window_size)")"; (( size > 0 )) || size=200000
  level="$(json_str level)"
  thinking="$(json_num enabled)"
  pct=$(( used * 100 / size )); (( pct > 100 )) && pct=100

  local state color
  if [[ -n "$agent" ]]; then
    state="kaioken-x20"; color="$CRIMSON"
  elif (( added + removed > 0 )); then
    state="super-saiyan"; color="$GOLD"
  else
    state="base-form"; color="$SILVER"
  fi

  local extras=""
  [[ -n "$level" ]] && extras+=" ${DIM}effort:${level}${RESET}"
  [[ "$thinking" == "true" ]] && extras+=" ${BLUE}thinking${RESET}"
  [[ -n "$agent" ]] && extras+=" ${DIM}agent:${agent}${RESET}"

  printf '%s\n' "${BOLD}${color}[${state}]${RESET} ${model} | ${dir} | +${added}/-${removed} | ctx ${pct}%${extras}"
}

main || printf '%s\n' "[base-form]"
exit 0
