#Requires -Version 7
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
# Dependencies: PowerShell 7 only (built-in ConvertFrom-Json). No modules, no network, no writes.
# Exit contract: always exit 0 and always print one line, even on malformed or
# empty stdin, so the statusline never goes blank because of this script.
# Twin: barrier.sh (identical output for identical stdin and filesystem).
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Esc = [char]27
$Reset = "$Esc[0m"
$Void = "$Esc[38;5;93m"
$Accent = "$Esc[38;5;51m"
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
function Format-Layer {
  param([string]$Label, [bool]$Present, [string]$Detail = '')
  if ($Present) {
    $d = if ($Detail) { " $Detail" } else { '' }
    return "$Accent$Label$d$Reset"
  }
  return "$Dim$Label --$Reset"
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
  $project = [string](Get-Field $data @('workspace', 'project_dir'))
  $dir = [string](Get-Field $data @('workspace', 'current_dir'))
  if (-not $project) { $project = $dir }
  $style = [string](Get-Field $data @('output_style', 'name'))
  $worktree = [string](Get-Field $data @('workspace', 'git_worktree'))
  $added = Get-Field $data @('workspace', 'added_dirs')
  $dirs = if ($null -ne $added) { @($added).Count } else { 0 }

  $hasClaude = $false; $hasSettings = $false; $rules = 0
  if ($project -and (Test-Path -LiteralPath $project -PathType Container)) {
    $hasClaude = Test-Path -LiteralPath (Join-Path $project 'CLAUDE.md') -PathType Leaf
    $claudeDir = Join-Path $project '.claude'
    $hasSettings = (Test-Path -LiteralPath (Join-Path $claudeDir 'settings.json') -PathType Leaf) -or
      (Test-Path -LiteralPath (Join-Path $claudeDir 'settings.local.json') -PathType Leaf)
    $rulesDir = Join-Path $claudeDir 'rules'
    if (Test-Path -LiteralPath $rulesDir -PathType Container) {
      $rules = @(Get-ChildItem -LiteralPath $rulesDir -File -Filter '*.md').Count
    }
  }

  $name = Get-BaseName $dir; if (-not $name) { $name = '?' }
  $line = "$Bold${Void}[BARRIER]$Reset $name | " +
    (Format-Layer 'CLAUDE.md' $hasClaude) + ' | ' +
    (Format-Layer 'rules' ($rules -gt 0) "$rules") + ' | ' +
    (Format-Layer 'settings' $hasSettings) + ' | ' +
    (Format-Layer 'dirs' ($dirs -gt 0) "+$dirs") + ' | ' +
    (Format-Layer 'worktree' ([bool]$worktree) $worktree) + ' | ' +
    (Format-Layer 'style' ([bool]$style -and $style -ne 'default') $style) + " | $model"
  Write-Line $line
} catch {
  Write-Line '[BARRIER] down'
}
exit 0
