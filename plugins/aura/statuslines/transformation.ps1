#Requires -Version 7
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
# Dependencies: PowerShell 7 only (built-in ConvertFrom-Json). No modules, no network, no writes.
# Exit contract: always exit 0 and always print one line, even on malformed or
# empty stdin, so the statusline never goes blank because of this script.
# Twin: transformation.sh (identical output for identical stdin).
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Esc = [char]27
$Reset = "$Esc[0m"
$Silver = "$Esc[38;5;250m"
$Gold = "$Esc[38;5;220m"
$Crimson = "$Esc[38;5;160m"
$Blue = "$Esc[38;5;39m"
$Dim = "$Esc[2m"
$Bold = "$Esc[1m"

function Get-Field {
  param($Object, [string[]]$Path)
  $cur = $Object
  foreach ($p in $Path) {
    if ($null -eq $cur) { return $null }
    $prop = $cur.PSObject.Properties[$p]
    if ($null -eq $prop) { return $null }
    $cur = $prop.Value
  }
  return $cur
}
function Get-BaseName {
  param([string]$P)
  $P = $P.TrimEnd('/', '\')
  $i = [Math]::Max($P.LastIndexOf('/'), $P.LastIndexOf('\'))
  if ($i -ge 0) { return $P.Substring($i + 1) }
  return $P
}
function ConvertTo-Int {
  param($V)
  if ($null -ne $V -and "$V" -match '^[0-9]+(\.[0-9]+)?$') { return [long][Math]::Floor([double]$V) }
  return [long]0
}
function Write-Line {
  param([string]$Text)
  $stdout = [Console]::OpenStandardOutput()
  $bytes = [System.Text.UTF8Encoding]::new($false).GetBytes($Text + "`n")
  $stdout.Write($bytes, 0, $bytes.Length)
  $stdout.Flush()
}

try {
  $raw = [Console]::In.ReadToEnd()
  $data = $null
  if (-not [string]::IsNullOrWhiteSpace($raw)) {
    try { $data = $raw | ConvertFrom-Json } catch { $data = $null }
  }

  $model = Get-Field $data @('model', 'display_name'); if (-not $model) { $model = 'Claude' }
  $dir = Get-BaseName ([string](Get-Field $data @('workspace', 'current_dir'))); if (-not $dir) { $dir = '?' }
  $agent = [string](Get-Field $data @('agent', 'name'))
  $added = ConvertTo-Int (Get-Field $data @('cost', 'total_lines_added'))
  $removed = ConvertTo-Int (Get-Field $data @('cost', 'total_lines_removed'))
  $used = ConvertTo-Int (Get-Field $data @('context_window', 'total_input_tokens'))
  $size = ConvertTo-Int (Get-Field $data @('context_window', 'context_window_size'))
  if ($size -le 0) { $size = 200000 }
  $level = [string](Get-Field $data @('effort', 'level'))
  $thinking = Get-Field $data @('thinking', 'enabled')
  $pct = [long][Math]::Floor(($used * 100) / $size); if ($pct -gt 100) { $pct = 100 }

  if ($agent) { $state = 'kaioken-x20'; $color = $Crimson }
  elseif (($added + $removed) -gt 0) { $state = 'super-saiyan'; $color = $Gold }
  else { $state = 'base-form'; $color = $Silver }

  $extras = ''
  if ($level) { $extras += " ${Dim}effort:$level$Reset" }
  if ($thinking -eq $true) { $extras += " ${Blue}thinking$Reset" }
  if ($agent) { $extras += " ${Dim}agent:$agent$Reset" }

  Write-Line "$Bold${color}[$state]$Reset $model | $dir | +$added/-$removed | ctx $pct%$extras"
} catch {
  Write-Line '[base-form]'
}
exit 0
