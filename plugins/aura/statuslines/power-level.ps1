#Requires -Version 7
# aura statusline preset: power-level
# Renders context-window usage as a rising power level.
#
# Reads from the Claude Code statusline JSON on stdin (fields only, nothing else):
#   model.display_name, workspace.current_dir, context_window.total_input_tokens,
#   context_window.context_window_size, cost.total_cost_usd, exceeds_200k_tokens
# Percent is total_input_tokens * 100 / context_window_size, the same input-only
# formula Claude Code uses for used_percentage, so the value matches the built-in one.
#
# Dependencies: PowerShell 7 only (built-in ConvertFrom-Json). No modules, no network, no writes.
# Exit contract: always exit 0 and always print one line, even on malformed or
# empty stdin, so the statusline never goes blank because of this script.
# Twin: power-level.sh (identical output for identical stdin).
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Esc = [char]27
$Reset = "$Esc[0m"
$Gold = "$Esc[38;5;220m"
$Orange = "$Esc[38;5;208m"
$Red = "$Esc[38;5;196m"
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
function Format-Commas {
  param([long]$N)
  return $N.ToString('#,0', [System.Globalization.CultureInfo]::InvariantCulture)
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
  $used = Get-Field $data @('context_window', 'total_input_tokens')
  $used = if ($null -ne $used -and "$used" -match '^-?[0-9.]+$') { [long][Math]::Floor([double]$used) } else { 0 }
  if ($used -lt 0) { $used = 0 }
  $size = Get-Field $data @('context_window', 'context_window_size')
  $size = if ($null -ne $size -and "$size" -match '^[0-9.]+$' -and [double]$size -ge 1) {
    [long][Math]::Floor([double]$size)
  } else { 200000 }
  $cost = Get-Field $data @('cost', 'total_cost_usd')
  $cost = if ($null -ne $cost -and "$cost" -match '^[0-9.]+$') { [double]$cost } else { 0.0 }
  $exceeds = Get-Field $data @('exceeds_200k_tokens')
  $pct = [long][Math]::Floor(($used * 100) / $size); if ($pct -gt 100) { $pct = 100 }

  if ($pct -ge 90) { $color = $Red; $label = 'ASCENDED' }
  elseif ($pct -ge 60) { $color = $Orange; $label = 'RISING' }
  else { $color = $Gold; $label = 'CHARGING' }
  if ($exceeds -eq $true) { $label = 'LIMIT BREAK' }

  $filled = [long][Math]::Floor($pct / 10)
  $bar = ('#' * $filled) + ('-' * (10 - $filled))
  $costf = $cost.ToString('F2', [System.Globalization.CultureInfo]::InvariantCulture)

  $head = "$Bold${color}POWER LEVEL$Reset ${color}[$bar]$Reset $pct% $Dim$label$Reset"
  $tokens = "$(Format-Commas $used)/$(Format-Commas $size)"
  Write-Line "$head | $tokens | $model | $dir | `$$costf"
} catch {
  Write-Line 'POWER LEVEL [----------] 0%'
}
exit 0
