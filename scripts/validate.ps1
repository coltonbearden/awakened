# =============================================================================
# validate.ps1 - Awakened structure, frontmatter, naming, and policy validator.
# Windows 11 / PowerShell 7 twin of scripts/validate.sh.
#
# PARITY RULE (CLAUDE.md 3.2): validate.sh implements this identical numbered
# check list, the identical message strings, and the identical exit contract.
# A change here that is not mirrored there in the same commit is a bug.
#
# DEPENDENCIES: PowerShell 7 only. JSON parsing uses the built-in cmdlets, so
# unlike the bash twin this script needs no Python. Nothing is ever
# auto-installed (HR-7); a missing interpreter is an environment error.
#
# USAGE:
#   pwsh -File scripts/validate.ps1              scaffold mode (default)
#   pwsh -File scripts/validate.ps1 -Release     release mode: Phase-6 entries
#                                                that are expected-absent at
#                                                scaffold become errors
#   pwsh -File scripts/validate.ps1 -Help
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
# NUMBERED CHECK LIST - shared verbatim with scripts/validate.sh
# -----------------------------------------------------------------------------
#   S1  Root foundation files present
#   S2  Foundation entries present (eval, schemas, scripts, templates, CI workflow)
#   S3  Phase-6 tree entries: expected-absent at scaffold, required at release
#   S4  No unexpected top-level entries against SPEC section 3
#   D1  SPEC.md present at root and carrying the governing version string
#   D2  DECISIONS.md has exactly 29 ADR headings covering D-01..D-29, no dupes
#   N1  Plugin directory names are drawn from the nine Tier-1 names
#   N3  Machine-facing names match ^[a-z0-9]+(-[a-z0-9]+)*$ (case-sensitive)
#   N4  No plugin, and no command namespace, named for the marketplace
#   N5  Tier-2 preset IDs (statuslines, palettes) do not collide with Tier-1 plugin names
#   U1  upstream.json parses, holds exactly the ten SPEC section 8 repos, keys present
#   U2  upstream.json pin coherence: all commits null, or all pinned with pinned_at
#   R1  rubric.json matches Locked Format 4 and agrees with rubric.md text
#   M1  matrix.csv header is byte-equal to the SPEC section 9 normative header
#   M2  matrix.csv row lint: field count, axis ranges, enums, verdict coherence
#   C1  Every schemas/*.json parses and declares $schema and $id
#   C2  Agent tool allowlists carry no bare or wildcard-equivalent grant (C-2)
#   C3  Skill frontmatter: name matches its directory, description >= 40 chars
#   C4  plugin.json and marketplace.json cross-field rules
#   C5  aura palette files carry the twenty scheme keys as six-digit hex, name equals file stem (D-29)
#   H1  At most one hook file per plugin (D-15)
#   H2  Hooks appear only in super-saiyan and rinnegan (D-15)
#   H3  Every hook entry declares a timeout (C-1)
#   P1  Hard-reject indicator scan over shipped components (HR-1..HR-7)
#   P2  Prompt-injection and secrets scan over shipped components (E-1)
#   P3  Hook write targets stay inside the D-18 scope (HR-8)
#   P4  No package.json at repository root (D-02, HR-7)
#   L1  No CR byte and no UTF-8 BOM in any tracked text file
# =============================================================================

#Requires -Version 7
[CmdletBinding()]
param(
    [switch]$Release,
    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:Errors = 0
$script:Warnings = 0

$NinePlugins = @('super-saiyan', 'sharingan', 'rinnegan', 'kaioken', 'bankai',
                 'domain', 'instinct', 'poneglyph', 'aura')
$HookPlugins = @('super-saiyan', 'rinnegan')
$MarketplaceName = 'awakened'
$Kebab = '^[a-z0-9]+(-[a-z0-9]+)*$'
$SpecVersionLine = '**Version:** 2.20'
$MatrixHeader = 'id,source_repo,component_path,component_type,target_plugin,value,bloat,risk,dependencies,user_scope_fit,hard_reject,verdict,rationale'

function Write-Usage {
    Write-Host 'Usage: validate.ps1 [-Release] [-Help]'
    Write-Host '  -Release  treat Phase-6 tree entries as required rather than expected-absent'
    Write-Host '  -Help     print this message and exit 0'
}

function Add-Err  { param([string]$Check, [string]$Message) Write-Host ("ERROR [" + $Check + "] " + $Message); $script:Errors++ }
function Add-Warn { param([string]$Check, [string]$Message) Write-Host ("WARN  [" + $Check + "] " + $Message); $script:Warnings++ }
function Add-Info { param([string]$Check, [string]$Message) Write-Host ("INFO  [" + $Check + "] " + $Message) }
function Add-Ok   { param([string]$Check, [string]$Message) Write-Host ("OK    [" + $Check + "] " + $Message) }

function Exit-Env {
    param([string]$Message)
    [Console]::Error.WriteLine("ERROR [E0] " + $Message)
    Write-Host "VALIDATE: FAIL"
    exit 2
}

# Parses the restricted YAML subset: scalars, [flow, lists], and '- ' block lists.
# Mirrors the parser in the bash twin exactly.
function Get-Frontmatter {
    param([string]$Path)
    try { $text = Get-Content -LiteralPath $Path -Raw -Encoding utf8 } catch { return $null }
    if (-not $text.StartsWith('---')) { return $null }
    $text = $text -replace "`r`n", "`n"
    $end = $text.IndexOf("`n---", 3)
    if ($end -lt 0) { return $null }
    $body = $text.Substring($text.IndexOf("`n") + 1, $end - $text.IndexOf("`n") - 1)
    $data = @{}
    $key = $null
    foreach ($line in ($body -split "`n")) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        if ($line.TrimStart().StartsWith('#')) { continue }
        if ($line.TrimStart().StartsWith('- ') -and $null -ne $key) {
            if ($data[$key] -isnot [System.Collections.IList]) { $data[$key] = @() }
            $data[$key] += $line.TrimStart().Substring(2).Trim().Trim('"', "'")
            continue
        }
        $m = [regex]::Match($line, '^([A-Za-z0-9_-]+):\s*(.*)$')
        if (-not $m.Success) { continue }
        $key = $m.Groups[1].Value
        $val = $m.Groups[2].Value.Trim()
        if ($val.StartsWith('[') -and $val.EndsWith(']')) {
            $inner = $val.Substring(1, $val.Length - 2)
            $data[$key] = @($inner -split ',' | ForEach-Object { $_.Trim().Trim('"', "'") } | Where-Object { $_ -ne '' })
        }
        elseif ($val -eq '') { $data[$key] = @() }
        else { $data[$key] = $val.Trim('"', "'") }
    }
    return $data
}

function Get-ToolTokens {
    param($Value)
    if ($null -eq $Value) { return @() }
    if ($Value -is [System.Collections.IList]) { return @($Value | ForEach-Object { [string]$_ }) }
    return @([string]$Value -split ',')
}

if ($Help) { Write-Usage; exit 0 }

$ScriptDir = Split-Path -Parent $PSCommandPath
$Root = Split-Path -Parent $ScriptDir
try { Set-Location -LiteralPath $Root } catch { Exit-Env ("cannot enter the repository root " + $Root) }

if (-not (Test-Path -LiteralPath 'schemas' -PathType Container)) {
    Exit-Env "schemas/ directory not found; the tree is not an Awakened repository root"
}

if ($Release) { Add-Info 'MODE' 'release' } else { Add-Info 'MODE' 'scaffold' }

# -----------------------------------------------------------------------------
# S1  Root foundation files present
# -----------------------------------------------------------------------------
$S1Files = @('CLAUDE.md', 'CONTEXT.md', 'DECISIONS.md', 'ROADMAP.md', 'SPEC.md', 'upstream.json',
             'SOURCES.md', 'CONTRIBUTING.md', 'README.md', 'LICENSE', 'NOTICE', '.gitattributes')
$s1Missing = @($S1Files | Where-Object { -not (Test-Path -LiteralPath $_ -PathType Leaf) })
if ($s1Missing.Count -gt 0) {
    foreach ($f in $s1Missing) { Add-Err 'S1' ("root foundation file is missing: " + $f) }
} else {
    Add-Ok 'S1' 'all 12 root foundation files present'
}

# -----------------------------------------------------------------------------
# S2  Foundation directories present
# -----------------------------------------------------------------------------
$s2Missing = @()
foreach ($d in @('eval', 'schemas', 'scripts', 'templates', 'templates/plugin')) {
    if (-not (Test-Path -LiteralPath $d -PathType Container)) { $s2Missing += $d }
}
foreach ($f in @('eval/rubric.md', 'eval/rubric.json', 'eval/matrix.csv', 'eval/triage-log.md',
                 'eval/gate-review-protocol.md', 'eval/claude-mem-rebuild.md', 'eval/shortlist.md',
                 'schemas/marketplace.schema.json', 'schemas/plugin.schema.json',
                 'schemas/skill.schema.json', 'schemas/agent.schema.json',
                 'scripts/validate.sh', 'scripts/validate.ps1',
                 'scripts/pin-upstream.sh', 'scripts/pin-upstream.ps1',
                 'templates/plugin/plugin.json', 'templates/skill.md', 'templates/command.md',
                 'templates/agent.md', 'templates/hook.json',
                 '.github/workflows/validate.yml')) {
    if (-not (Test-Path -LiteralPath $f -PathType Leaf)) { $s2Missing += $f }
}
if ($s2Missing.Count -gt 0) {
    foreach ($f in $s2Missing) { Add-Err 'S2' ("foundation entry is missing: " + $f) }
} else {
    Add-Ok 'S2' 'eval, schemas, scripts, templates, and the CI workflow are complete'
}

# -----------------------------------------------------------------------------
# S3  Phase-6 tree entries
# -----------------------------------------------------------------------------
foreach ($entry in @('.claude-plugin/marketplace.json', 'tests', '.github/workflows/upstream-watch.yml')) {
    if (Test-Path -LiteralPath $entry) {
        Add-Ok 'S3' ("Phase-6 entry present: " + $entry)
    }
    elseif ($Release) {
        Add-Err 'S3' ("Phase-6 entry is missing in release mode: " + $entry + " (ROADMAP V6.1)")
    }
    else {
        Add-Info 'S3' ("Phase-6 entry absent by design at scaffold: " + $entry)
    }
}
if (Test-Path -LiteralPath 'plugins' -PathType Container) {
    foreach ($d in (Get-ChildItem -LiteralPath 'plugins' -Directory | Sort-Object Name)) {
        $manifest = Join-Path (Join-Path $d.FullName '.claude-plugin') 'plugin.json'
        if (Test-Path -LiteralPath $manifest -PathType Leaf) {
            Add-Ok 'S3' ("plugin manifest present: " + $d.Name)
        }
        elseif ($Release) {
            Add-Err 'S3' ("plugin manifest is missing in release mode: plugins/" + $d.Name + "/.claude-plugin/plugin.json")
        }
        else {
            Add-Info 'S3' ("plugin not yet scaffolded, absent by design at scaffold: " + $d.Name)
        }
    }
}

# -----------------------------------------------------------------------------
# S4  No unexpected top-level entries
# -----------------------------------------------------------------------------
$S4Allowed = @('.git', '.github', '.claude-plugin', 'plugins', 'schemas', 'scripts', 'eval',
               'templates', 'tests', 'brand', '.gitattributes', 'CLAUDE.md', 'CONTEXT.md', 'DECISIONS.md',
               'ROADMAP.md', 'SPEC.md', 'upstream.json', 'SOURCES.md', 'CONTRIBUTING.md',
               'README.md', 'LICENSE', 'NOTICE')
foreach ($item in (Get-ChildItem -Force | Sort-Object Name)) {
    if ($item.Name -cnotin $S4Allowed) {
        Add-Warn 'S4' ("top-level entry is not in the SPEC section 3 tree: " + $item.Name)
    }
}
Add-Ok 'S4' 'top-level entries checked against SPEC section 3'

# -----------------------------------------------------------------------------
# D1  SPEC.md present and carrying the governing version string
# -----------------------------------------------------------------------------
if (Test-Path -LiteralPath 'SPEC.md' -PathType Leaf) {
    $specLines = Get-Content -LiteralPath 'SPEC.md' -Encoding utf8
    if ($specLines -ccontains $SpecVersionLine) {
        Add-Ok 'D1' 'SPEC.md carries the governing version string'
    } else {
        Add-Err 'D1' ("SPEC.md does not carry the governing version line: " + $SpecVersionLine)
    }
}

# -----------------------------------------------------------------------------
# D2  DECISIONS.md ADR parity with SPEC section 12
# -----------------------------------------------------------------------------
if (Test-Path -LiteralPath 'DECISIONS.md' -PathType Leaf) {
    $decisions = Get-Content -LiteralPath 'DECISIONS.md' -Raw -Encoding utf8
    $heads = @([regex]::Matches($decisions, '(?m)^## ADR-(\d{3})\b') | ForEach-Object { $_.Groups[1].Value })
    $refs  = @([regex]::Matches($decisions, '(?m)^\|\s*Spec ref\s*\|\s*(D-\d{2})\s*\|') | ForEach-Object { $_.Groups[1].Value })
    $expectedAdr = @(1..29 | ForEach-Object { '{0:d3}' -f $_ })
    $expectedRef = @(1..29 | ForEach-Object { 'D-{0:d2}' -f $_ })
    $d2Bad = $false
    if ($heads.Count -ne 29) {
        Add-Err 'D2' ("DECISIONS.md has " + $heads.Count + " ADR headings, expected exactly 29 (D-16)")
        $d2Bad = $true
    }
    if ((($heads | Sort-Object) -join ',') -cne ($expectedAdr -join ',')) {
        Add-Err 'D2' 'ADR headings are not exactly ADR-001..ADR-029'
        $d2Bad = $true
    }
    if ((($refs | Sort-Object) -join ',') -cne ($expectedRef -join ',')) {
        $missing = @($expectedRef | Where-Object { $_ -cnotin $refs })
        $dupes = @($refs | Group-Object | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name })
        if ($missing.Count -gt 0) { Add-Err 'D2' ("Spec ref fields do not cover: " + ($missing -join ', ')) }
        if ($dupes.Count -gt 0) { Add-Err 'D2' ("Spec ref fields are duplicated: " + ($dupes -join ', ')) }
        if ($missing.Count -eq 0 -and $dupes.Count -eq 0) {
            Add-Err 'D2' 'Spec ref fields do not map 1:1 onto D-01..D-29'
        }
        $d2Bad = $true
    }
    if (-not $d2Bad) { Add-Ok 'D2' '29 ADRs mapping 1:1 onto D-01..D-29' }
}

# -----------------------------------------------------------------------------
# N1 / N3 / N4 / N5  Naming
# -----------------------------------------------------------------------------
$n1Bad = $false
if (Test-Path -LiteralPath 'plugins' -PathType Container) {
    foreach ($d in (Get-ChildItem -LiteralPath 'plugins' -Directory)) {
        if ($d.Name -cnotin $NinePlugins) {
            Add-Err 'N1' ("plugin directory is not one of the nine Tier-1 names: " + $d.Name)
            $n1Bad = $true
        }
    }
}
if (-not $n1Bad) { Add-Ok 'N1' 'plugin directory names are within the Tier-1 set' }

$n3Bad = $false
if (Test-Path -LiteralPath 'plugins' -PathType Container) {
    $candidates = @(Get-ChildItem -LiteralPath 'plugins' -Recurse -Force |
        Where-Object { $_.PSIsContainer -or $_.Extension -cin @('.md', '.json') })
    foreach ($item in $candidates) {
        $base = $item.Name
        if (-not $item.PSIsContainer) { $base = [System.IO.Path]::GetFileNameWithoutExtension($base) }
        # SKILL.md, .claude-plugin/ and CHANGELOG.md are fixed names the SPEC section 3
        # plugin layout mandates; they are not machine-facing component names (N-3).
        if ($base -cin @('SKILL', '.claude-plugin', 'CHANGELOG')) { continue }
        if ($base -cnotmatch $Kebab) {
            $rel = [System.IO.Path]::GetRelativePath($Root, $item.FullName) -replace '\\', '/'
            Add-Err 'N3' ("machine-facing name is not kebab-case: " + $rel)
            $n3Bad = $true
        }
    }
}
if (-not $n3Bad) { Add-Ok 'N3' 'component names are lowercase kebab-case (N-3)' }

$n4Bad = $false
if (Test-Path -LiteralPath (Join-Path 'plugins' $MarketplaceName) -PathType Container) {
    Add-Err 'N4' ("a plugin named for the marketplace exists: plugins/" + $MarketplaceName + " (N-4 prohibits the catch-all)")
    $n4Bad = $true
}
if (Test-Path -LiteralPath 'plugins' -PathType Container) {
    foreach ($cmd in (Get-ChildItem -LiteralPath 'plugins' -Recurse -Force -Filter '*.md' -File |
                      Where-Object { $_.Directory.Name -ceq 'commands' })) {
        $rel = [System.IO.Path]::GetRelativePath($Root, $cmd.FullName) -replace '\\', '/'
        $ns = ($rel -split '/')[1]
        if ($ns -ceq $MarketplaceName) {
            Add-Err 'N4' ("command namespaces under the marketplace name: " + $rel + " (N-4)")
            $n4Bad = $true
        }
    }
}
if (-not $n4Bad) { Add-Ok 'N4' 'no marketplace-level plugin or command namespace (N-4)' }

$n5Bad = $false
foreach ($n5Dir in @('plugins/aura/statuslines', 'plugins/aura/palettes')) {
    if (-not (Test-Path -LiteralPath $n5Dir -PathType Container)) { continue }
    foreach ($p in (Get-ChildItem -LiteralPath $n5Dir -Force)) {
        $preset = [System.IO.Path]::GetFileNameWithoutExtension($p.Name)
        if ($preset -cin $NinePlugins) {
            Add-Err 'N5' ("preset ID collides with a Tier-1 plugin name: " + $preset + " (N-5, D-17, D-28)")
            $n5Bad = $true
        }
    }
}
if (-not $n5Bad) { Add-Ok 'N5' 'no Tier-2 preset ID collides with a Tier-1 plugin name' }

# -----------------------------------------------------------------------------
# U1 / U2  upstream registry
# -----------------------------------------------------------------------------
if (Test-Path -LiteralPath 'upstream.json' -PathType Leaf) {
    $expectedRepos = @('obra/superpowers', 'mattpocock/skills', 'affaan-m/ECC', 'thedotmack/claude-mem',
                       'wshobson/agents', 'anthropics/skills', 'kepano/obsidian-skills',
                       'vercel-labs/skills', 'hesreallyhim/awesome-claude-code',
                       'davila7/claude-code-templates')
    $upstream = $null
    try { $upstream = Get-Content -LiteralPath 'upstream.json' -Raw -Encoding utf8 | ConvertFrom-Json }
    catch { Add-Err 'U1' ("upstream.json does not parse: " + $_.Exception.Message) }
    if ($null -ne $upstream) {
        $repos = @($upstream.repos)
        if ($repos.Count -ne 10) {
            Add-Err 'U1' ("upstream.json holds " + $repos.Count + " repos, expected exactly 10 (SPEC section 8)")
        }
        $names = @($repos | ForEach-Object { $_.name })
        foreach ($miss in ($expectedRepos | Where-Object { $_ -cnotin $names } | Sort-Object)) {
            Add-Err 'U1' ("upstream.json is missing a SPEC section 8 repository: " + $miss)
        }
        foreach ($extra in ($names | Where-Object { $_ -cnotin $expectedRepos } | Sort-Object)) {
            Add-Err 'U1' ("upstream.json holds a repository SPEC section 8 does not list: " + $extra)
        }
        foreach ($r in $repos) {
            foreach ($k in @('name', 'url', 'license', 'role', 'commit', 'notes')) {
                if ($k -cnotin $r.PSObject.Properties.Name) {
                    Add-Err 'U1' ("upstream.json repo '" + $r.name + "' is missing key: " + $k)
                }
            }
        }
        if ($repos.Count -eq 10 -and @($names | Where-Object { $_ -cnotin $expectedRepos }).Count -eq 0 `
            -and @($expectedRepos | Where-Object { $_ -cnotin $names }).Count -eq 0) {
            Add-Ok 'U1' 'upstream.json holds exactly the ten SPEC section 8 repositories'
        }

        $commits = @($repos | ForEach-Object { $_.commit })
        $hasPinnedAt = 'pinned_at' -cin $upstream.PSObject.Properties.Name
        $nullCount = @($commits | Where-Object { $null -eq $_ }).Count
        if (-not $hasPinnedAt) {
            Add-Err 'U2' 'upstream.json has no pinned_at key (Locked Format 3)'
        }
        elseif ($nullCount -eq $commits.Count) {
            if ($null -eq $upstream.pinned_at) {
                Add-Ok 'U2' 'all commits null and pinned_at null - scaffold state per SPEC section 8'
            } else {
                Add-Err 'U2' 'pinned_at is set while every commit is null; run scripts/pin-upstream.*'
            }
        }
        elseif ($nullCount -gt 0) {
            Add-Err 'U2' 'upstream.json is partially pinned; pin-upstream writes all ten or none'
        }
        else {
            $bad = @($repos | Where-Object { [string]$_.commit -cnotmatch '^[0-9a-f]{40}$' } | ForEach-Object { $_.name })
            if ($bad.Count -gt 0) {
                Add-Err 'U2' ("commit is not a 40-character lowercase SHA for: " + ($bad -join ', '))
            }
            elseif ($null -eq $upstream.pinned_at) {
                Add-Err 'U2' 'all ten repos are pinned but pinned_at is null'
            }
            else {
                Add-Ok 'U2' 'all ten repos pinned with a pinned_at timestamp'
            }
        }
    }
}

# -----------------------------------------------------------------------------
# R1  rubric.json shape and rubric.md agreement
# -----------------------------------------------------------------------------
if ((Test-Path -LiteralPath 'eval/rubric.json' -PathType Leaf) -and
    (Test-Path -LiteralPath 'eval/rubric.md' -PathType Leaf)) {
    $rubric = $null
    try { $rubric = Get-Content -LiteralPath 'eval/rubric.json' -Raw -Encoding utf8 | ConvertFrom-Json }
    catch { Add-Err 'R1' ("eval/rubric.json does not parse: " + $_.Exception.Message) }
    if ($null -ne $rubric) {
        $md = Get-Content -LiteralPath 'eval/rubric.md' -Raw -Encoding utf8
        $problems = @()
        if ($rubric.version -cne '2.1') { $problems += 'version is not the string "2.1"' }
        $axes = @()
        if ('axes' -cin $rubric.PSObject.Properties.Name) { $axes = @($rubric.axes) }
        if ($axes.Count -ne 5) { $problems += 'axes is not a list of 5 objects'; $axes = @() }
        if ('thresholds' -cnotin $rubric.PSObject.Properties.Name -or
            $rubric.thresholds.min_axis -ne 3 -or
            $rubric.thresholds.hard_reject_overrides -ne $true -or
            $rubric.thresholds.single_owner_required -ne $true) {
            $problems += 'thresholds must be {min_axis:3, hard_reject_overrides:true, single_owner_required:true}'
        }
        if ((@($rubric.verdicts) -join ',') -cne 'shortlist,reject,merge,defer') {
            $problems += 'verdicts must be the SPEC section 9 rule 3 array'
        }
        if ((@($rubric.hard_rejects) -join ',') -cne (@(1..8 | ForEach-Object { "HR-$_" }) -join ',')) {
            $problems += 'hard_rejects must be the ID strings HR-1..HR-8'
        }
        foreach ($a in $axes) {
            foreach ($k in @('id', 'name', 'question', 'anchors')) {
                if ($k -cnotin $a.PSObject.Properties.Name) { $problems += ("axis " + $a.id + " is missing key " + $k) }
            }
            if (('question' -cin $a.PSObject.Properties.Name) -and -not $md.Contains([string]$a.question)) {
                $problems += ("axis " + $a.id + " question text is absent from rubric.md")
            }
            foreach ($lvl in @('1', '3', '5')) {
                $anchor = $null
                if ('anchors' -cin $a.PSObject.Properties.Name -and $lvl -cin $a.anchors.PSObject.Properties.Name) {
                    $anchor = [string]$a.anchors.$lvl
                }
                if ($null -eq $anchor) { $problems += ("axis " + $a.id + " is missing anchor " + $lvl) }
                elseif (-not $md.Contains($anchor)) { $problems += ("axis " + $a.id + " anchor " + $lvl + " is absent from rubric.md") }
            }
        }
        foreach ($p in $problems) { Add-Err 'R1' $p }
        if ($problems.Count -eq 0) { Add-Ok 'R1' 'rubric.json matches Locked Format 4 and agrees with rubric.md' }
    }
}

# -----------------------------------------------------------------------------
# M1 / M2  matrix.csv
# -----------------------------------------------------------------------------
if (Test-Path -LiteralPath 'eval/matrix.csv' -PathType Leaf) {
    $bytes = [System.IO.File]::ReadAllBytes((Join-Path $Root 'eval/matrix.csv'))
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        Add-Err 'M1' 'eval/matrix.csv carries a UTF-8 BOM; the header cannot be byte-equal'
        $bytes = $bytes[3..($bytes.Length - 1)]
    }
    $matrixText = [System.Text.Encoding]::UTF8.GetString($bytes)
    $matrixLines = $matrixText -split "`n"
    if ($matrixLines.Count -lt 1 -or $matrixLines[0] -cne $MatrixHeader) {
        Add-Err 'M1' 'eval/matrix.csv header is not byte-equal to the SPEC section 9 normative header'
    } else {
        Add-Ok 'M1' 'eval/matrix.csv header is byte-equal to the SPEC section 9 header'
    }

    $types = @('skill', 'command', 'agent', 'hook', 'template', 'concept')
    $verdicts = @('shortlist', 'reject', 'merge', 'defer')
    $axisIdx = @(5, 6, 7, 8, 9)
    $dataLines = @($matrixLines | Select-Object -Skip 1 |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and -not $_.TrimStart().StartsWith('#') })
    $m2Bad = 0
    $seen = @{}
    foreach ($line in $dataLines) {
        $row = @($line | ConvertFrom-Csv -Header (0..12 | ForEach-Object { "c$_" }) |
            ForEach-Object { $r = $_; 0..12 | ForEach-Object { $r."c$_" } })
        $present = @($row | Where-Object { $null -ne $_ }).Count
        if ($present -ne 13) {
            Add-Err 'M2' ("row has " + $present + " fields, expected 13: " + $row[0])
            $m2Bad++
            continue
        }
        $rid = $row[0]; $verdict = $row[11]; $hard = $row[10]
        if ($seen.ContainsKey($rid)) { $seen[$rid]++ } else { $seen[$rid] = 1 }
        foreach ($i in $axisIdx) {
            $n = 0
            if (-not [int]::TryParse($row[$i], [ref]$n) -or $n -lt 1 -or $n -gt 5) {
                Add-Err 'M2' ("row " + $rid + ": axis field " + ($i + 1) + " is not an integer 1-5: '" + $row[$i] + "'")
                $m2Bad++
            }
        }
        if ($row[3] -cnotin $types) {
            Add-Err 'M2' ("row " + $rid + ": component_type '" + $row[3] + "' is outside the SPEC section 9 enum")
            $m2Bad++
        }
        if ($verdict -cnotin $verdicts) {
            Add-Err 'M2' ("row " + $rid + ": verdict '" + $verdict + "' is outside the SPEC section 9 rule 3 enum")
            $m2Bad++
        }
        if (-not [string]::IsNullOrWhiteSpace($hard) -and $verdict -cne 'reject') {
            Add-Err 'M2' ("row " + $rid + ": hard_reject is set but verdict is '" + $verdict + "', not reject")
            $m2Bad++
        }
        if ($verdict -ceq 'shortlist') {
            if (-not [string]::IsNullOrWhiteSpace($hard)) {
                Add-Err 'M2' ("row " + $rid + ": shortlist row carries a hard_reject value"); $m2Bad++
            }
            if ([string]::IsNullOrWhiteSpace($row[4])) {
                Add-Err 'M2' ("row " + $rid + ": shortlist row names no target_plugin"); $m2Bad++
            }
            $low = $false
            foreach ($i in $axisIdx) {
                $n = 0
                if ([int]::TryParse($row[$i], [ref]$n) -and $n -lt 3) { $low = $true }
            }
            if ($low) { Add-Err 'M2' ("row " + $rid + ": shortlist row has an axis below the floor of 3"); $m2Bad++ }
        }
        if ($verdict -cin @('merge', 'defer') -and [string]::IsNullOrWhiteSpace($row[12])) {
            Add-Err 'M2' ("row " + $rid + ": " + $verdict + " row must name its target in rationale")
            $m2Bad++
        }
    }
    foreach ($rid in $seen.Keys) {
        if ($seen[$rid] -gt 1) {
            Add-Err 'M2' ("duplicate component id appears " + $seen[$rid] + " times: " + $rid + " (ROADMAP V5.2)")
            $m2Bad++
        }
    }
    if ($m2Bad -eq 0) { Add-Ok 'M2' ($dataLines.Count.ToString() + " matrix data row(s) pass the lint") }
}

# -----------------------------------------------------------------------------
# C1  Schemas parse and declare $schema and $id
# -----------------------------------------------------------------------------
$c1Bad = 0
$schemaFiles = @(Get-ChildItem -LiteralPath 'schemas' -Filter '*.schema.json' -File | Sort-Object Name)
if ($schemaFiles.Count -ne 5) {
    Add-Err 'C1' ("schemas/ holds " + $schemaFiles.Count + " schema files, expected 5")
    $c1Bad++
}
foreach ($f in $schemaFiles) {
    $s = $null
    try { $s = Get-Content -LiteralPath $f.FullName -Raw -Encoding utf8 | ConvertFrom-Json }
    catch { Add-Err 'C1' ("schemas/" + $f.Name + " does not parse: " + $_.Exception.Message); $c1Bad++; continue }
    foreach ($key in @('$schema', '$id')) {
        if ($key -cnotin $s.PSObject.Properties.Name) {
            Add-Err 'C1' ("schemas/" + $f.Name + " does not declare " + $key)
            $c1Bad++
        }
    }
}
if ($c1Bad -eq 0) { Add-Ok 'C1' 'all five schemas parse and declare $schema and $id' }

# -----------------------------------------------------------------------------
# C2 / C3 / C4  Components and manifests
# -----------------------------------------------------------------------------
$danger = '(?:[Bb][Aa][Ss][Hh]|[Ww][Rr][Ii][Tt][Ee]|[Ee][Dd][Ii][Tt]' +
          '|[Mm][Uu][Ll][Tt][Ii][Ee][Dd][Ii][Tt]' +
          '|[Nn][Oo][Tt][Ee][Bb][Oo][Oo][Kk][Ee][Dd][Ii][Tt])'
$badToken = '^\s*["'']?\s*(?:\*|' + $danger + '\s*(?:\(\s*[*:.\s]*\s*\))?)\s*["'']?\s*$'

$c2Bad = 0; $c3Bad = 0; $c4Bad = 0
$agentFiles = @()
$skillFiles = @()
if (Test-Path -LiteralPath 'plugins' -PathType Container) {
    $agentFiles = @(Get-ChildItem -LiteralPath 'plugins' -Recurse -Force -Filter '*.md' -File |
        Where-Object { $_.Directory.Name -ceq 'agents' } | Sort-Object FullName)
    $skillFiles = @(Get-ChildItem -LiteralPath 'plugins' -Recurse -Force -Filter 'SKILL.md' -File | Sort-Object FullName)
}

foreach ($f in $agentFiles) {
    $rel = [System.IO.Path]::GetRelativePath($Root, $f.FullName) -replace '\\', '/'
    $fm = Get-Frontmatter -Path $f.FullName
    if ($null -eq $fm) { Add-Err 'C2' ($rel + " has no parseable frontmatter"); $c2Bad++; continue }
    if (-not $fm.ContainsKey('tools')) {
        Add-Err 'C2' ($rel + " declares no tools allowlist; C-2 makes it mandatory"); $c2Bad++; continue
    }
    foreach ($tok in (Get-ToolTokens $fm['tools'])) {
        if ($tok -cmatch $badToken) {
            Add-Err 'C2' ($rel + " grants a bare or wildcard-equivalent tool: '" + $tok.Trim() + "' (C-2)")
            $c2Bad++
        }
    }
    if ($fm.ContainsKey('permissionMode') -and [string]$fm['permissionMode'] -ceq 'bypassPermissions') {
        Add-Err 'C2' ($rel + " sets permissionMode: bypassPermissions (C-2)"); $c2Bad++
    }
}
if ($agentFiles.Count -gt 0 -and $c2Bad -eq 0) {
    Add-Ok 'C2' ($agentFiles.Count.ToString() + " agent allowlist(s) carry no bare or wildcard-equivalent grant")
} elseif ($agentFiles.Count -eq 0) {
    Add-Info 'C2' 'no agent files present; C-2 allowlist check not exercised'
}

foreach ($f in $skillFiles) {
    $rel = [System.IO.Path]::GetRelativePath($Root, $f.FullName) -replace '\\', '/'
    $fm = Get-Frontmatter -Path $f.FullName
    if ($null -eq $fm) { Add-Err 'C3' ($rel + " has no parseable frontmatter"); $c3Bad++; continue }
    $expected = $f.Directory.Name
    $name = if ($fm.ContainsKey('name')) { [string]$fm['name'] } else { $null }
    if ($name -cne $expected) {
        Add-Err 'C3' ($rel + " frontmatter name '" + $name + "' does not match its directory '" + $expected + "'")
        $c3Bad++
    }
    if ($null -ne $name -and $name -cnotmatch $Kebab) {
        Add-Err 'C3' ($rel + " name is not kebab-case: '" + $name + "' (N-3)"); $c3Bad++
    }
    $desc = if ($fm.ContainsKey('description')) { [string]$fm['description'] } else { '' }
    if ($desc.Length -lt 40) {
        Add-Err 'C3' ($rel + " description is " + $desc.Length + " characters; the floor is 40 (N-2)")
        $c3Bad++
    }
}
if ($skillFiles.Count -gt 0 -and $c3Bad -eq 0) {
    Add-Ok 'C3' ($skillFiles.Count.ToString() + " skill frontmatter block(s) conform")
} elseif ($skillFiles.Count -eq 0) {
    Add-Info 'C3' 'no skill files present; frontmatter check not exercised'
}

if (Test-Path -LiteralPath 'plugins' -PathType Container) {
    foreach ($f in (Get-ChildItem -LiteralPath 'plugins' -Recurse -Force -Filter 'plugin.json' -File |
                    Where-Object { $_.Directory.Name -ceq '.claude-plugin' } | Sort-Object FullName)) {
        $rel = [System.IO.Path]::GetRelativePath($Root, $f.FullName) -replace '\\', '/'
        $pluginDir = $f.Directory.Parent.Name
        $m = $null
        try { $m = Get-Content -LiteralPath $f.FullName -Raw -Encoding utf8 | ConvertFrom-Json }
        catch { Add-Err 'C4' ($rel + " does not parse: " + $_.Exception.Message); $c4Bad++; continue }
        if ($m.name -cne $pluginDir) {
            Add-Err 'C4' ($rel + " name '" + $m.name + "' does not match its directory '" + $pluginDir + "'")
            $c4Bad++
        }
        if ($m.name -ceq $MarketplaceName) { Add-Err 'C4' ($rel + " is named for the marketplace (N-4)"); $c4Bad++ }
        if ($m.license -cne 'MIT') {
            Add-Err 'C4' ($rel + " license is '" + $m.license + "'; Awakened is MIT end to end (D-08)")
            $c4Bad++
        }
    }
}

$catalog = '.claude-plugin/marketplace.json'
if (Test-Path -LiteralPath $catalog -PathType Leaf) {
    $c = $null
    try { $c = Get-Content -LiteralPath $catalog -Raw -Encoding utf8 | ConvertFrom-Json }
    catch { Add-Err 'C4' ($catalog + " does not parse: " + $_.Exception.Message); $c4Bad++ }
    if ($null -ne $c) {
        if ($c.name -cne $MarketplaceName) {
            Add-Err 'C4' ($catalog + " name is '" + $c.name + "', expected '" + $MarketplaceName + "' (D-03)")
            $c4Bad++
        }
        $owner = $null
        if ('owner' -cin $c.PSObject.Properties.Name) { $owner = $c.owner.name }
        if ($owner -cne 'coltonbearden') {
            Add-Err 'C4' ($catalog + " owner.name is '" + $owner + "'; SPEC section 2 fixes it to 'coltonbearden'")
            $c4Bad++
        }
        $entries = @($c.plugins)
        $listed = @()
        foreach ($e in $entries) {
            $listed += $e.name
            if ($e.name -ceq $MarketplaceName) {
                Add-Err 'C4' ($catalog + " lists a plugin named for the marketplace (N-4)"); $c4Bad++
            }
            if ($e.source -is [string]) {
                $basename = ($e.source.TrimEnd('/') -split '/')[-1]
                if ($basename -cne $e.name) {
                    Add-Err 'C4' ($catalog + " entry '" + $e.name + "' source basename does not equal its name: '" + $e.source + "'")
                    $c4Bad++
                }
            }
        }
        if ($entries.Count -ne 9) {
            Add-Err 'C4' ($catalog + " lists " + $entries.Count + " plugins, expected exactly 9 (ROADMAP V6.4)")
            $c4Bad++
        }
        if ((($listed | Sort-Object) -join ',') -cne (($NinePlugins | Sort-Object) -join ',')) {
            Add-Err 'C4' ($catalog + " entries do not match the nine Tier-1 plugin names"); $c4Bad++
        }
        if (Test-Path -LiteralPath 'plugins' -PathType Container) {
            foreach ($d in (Get-ChildItem -LiteralPath 'plugins' -Directory | Sort-Object Name)) {
                if ($d.Name -cnotin $listed) {
                    Add-Err 'C4' ("plugins/" + $d.Name + " exists on disk but is absent from " + $catalog)
                    $c4Bad++
                }
            }
        }
    }
    if ($c4Bad -eq 0) { Add-Ok 'C4' 'marketplace catalog and plugin manifests are internally consistent' }
} else {
    Add-Info 'C4' 'no marketplace catalog present; catalog cross-checks not exercised (Phase 6)'
}

# -----------------------------------------------------------------------------
# C5  aura palette files: twenty scheme keys, six-digit uppercase hex, name = file stem (D-29)
# -----------------------------------------------------------------------------
if (Test-Path -LiteralPath (Join-Path 'plugins' 'aura' 'palettes') -PathType Container) {
    $paletteKeys = @('name', 'background', 'foreground', 'cursorColor', 'selectionBackground',
                     'black', 'red', 'green', 'yellow', 'blue', 'purple', 'cyan', 'white',
                     'brightBlack', 'brightRed', 'brightGreen', 'brightYellow', 'brightBlue',
                     'brightPurple', 'brightCyan', 'brightWhite')
    $paletteFiles = @(Get-ChildItem -LiteralPath (Join-Path 'plugins' 'aura' 'palettes') -Filter '*.json' -File | Sort-Object Name)
    $c5Bad = 0
    foreach ($f in $paletteFiles) {
        $rel = 'plugins/aura/palettes/' + $f.Name
        $stem = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
        $pal = $null
        try { $pal = Get-Content -LiteralPath $f.FullName -Raw -Encoding utf8 | ConvertFrom-Json }
        catch { Add-Err 'C5' ($rel + " does not parse: " + $_.Exception.Message); $c5Bad++; continue }
        if ($null -eq $pal -or $pal -isnot [System.Management.Automation.PSCustomObject]) {
            Add-Err 'C5' ($rel + " is not a JSON object"); $c5Bad++; continue
        }
        $present = @($pal.PSObject.Properties.Name)
        $missing = @($paletteKeys | Where-Object { $_ -cnotin $present })
        $extra = @($present | Where-Object { $_ -cnotin $paletteKeys } | Sort-Object)
        if ($missing.Count -gt 0) { Add-Err 'C5' ($rel + " is missing scheme keys: " + ($missing -join ', ')); $c5Bad++ }
        if ($extra.Count -gt 0) { Add-Err 'C5' ($rel + " carries keys outside the scheme shape: " + ($extra -join ', ')); $c5Bad++ }
        $nameVal = if ('name' -cin $present) { $pal.name } else { $null }
        if ($nameVal -cne $stem) {
            $shown = if ($null -eq $nameVal) { 'None' } else { "'" + $nameVal + "'" }
            Add-Err 'C5' ($rel + " name " + $shown + " does not equal the file stem '" + $stem + "'"); $c5Bad++
        }
        foreach ($k in $paletteKeys[1..($paletteKeys.Count - 1)]) {
            if ($k -cin $present) {
                $v = $pal.$k
                if (-not ($v -is [string] -and $v -cmatch '^#[0-9A-F]{6}$')) {
                    $shown = if ($null -eq $v) { 'None' } else { "'" + [string]$v + "'" }
                    Add-Err 'C5' ($rel + " " + $k + " is not a six-digit uppercase hex colour: " + $shown); $c5Bad++
                }
            }
        }
    }
    if ($paletteFiles.Count -eq 0) {
        Add-Info 'C5' 'no palette files present under plugins/aura/palettes'
    } elseif ($c5Bad -eq 0) {
        Add-Ok 'C5' ("" + $paletteFiles.Count + " aura palette file(s) carry the scheme shape with six-digit hex colours")
    }
} else {
    Add-Info 'C5' 'plugins/aura/palettes absent; palette shape check not exercised'
}

# -----------------------------------------------------------------------------
# H1 / H2 / H3  Hook budget, ownership, timeout
# -----------------------------------------------------------------------------
$hookFound = 0
$hBad = 0
$hookFiles = @()
if (Test-Path -LiteralPath 'plugins' -PathType Container) {
    foreach ($d in (Get-ChildItem -LiteralPath 'plugins' -Directory | Sort-Object Name)) {
        $hookDir = Join-Path $d.FullName 'hooks'
        if (-not (Test-Path -LiteralPath $hookDir -PathType Container)) { continue }
        $hooks = @(Get-ChildItem -LiteralPath $hookDir -Filter '*.json' -File | Sort-Object Name)
        if ($hooks.Count -eq 0) { continue }
        $hookFiles += $hooks
        $hookFound += $hooks.Count
        if ($hooks.Count -gt 1) {
            Add-Err 'H1' ($d.Name + " declares " + $hooks.Count + " hook files; the budget is 1 (D-15)")
            $hBad++
        }
        if ($d.Name -cnotin $HookPlugins) {
            Add-Err 'H2' ($d.Name + " ships a hook; only super-saiyan and rinnegan are budgeted (D-15)")
            $hBad++
        }
        foreach ($h in $hooks) {
            $rel = [System.IO.Path]::GetRelativePath($Root, $h.FullName) -replace '\\', '/'
            $cfg = $null
            try { $cfg = Get-Content -LiteralPath $h.FullName -Raw -Encoding utf8 | ConvertFrom-Json }
            catch { Add-Err 'H3' ($rel + " does not parse: " + $_.Exception.Message); $hBad++; continue }
            $entries = @()
            if ('hooks' -cin $cfg.PSObject.Properties.Name) {
                foreach ($event in $cfg.hooks.PSObject.Properties) {
                    foreach ($matcher in @($event.Value)) {
                        if ('hooks' -cin $matcher.PSObject.Properties.Name) { $entries += @($matcher.hooks) }
                    }
                }
            }
            if ($entries.Count -eq 0) { Add-Err 'H3' ($rel + " declares no hook entries"); $hBad++ }
            foreach ($e in $entries) {
                if ('timeout' -cnotin $e.PSObject.Properties.Name) {
                    Add-Err 'H3' ($rel + " has a hook entry with no timeout (C-1)"); $hBad++
                }
                elseif ($e.timeout -isnot [int] -or $e.timeout -lt 1 -or $e.timeout -gt 10) {
                    Add-Err 'H3' ($rel + " timeout '" + $e.timeout + "' is outside the repo standard of 1-10 seconds")
                    $hBad++
                }
            }
        }
    }
}
if ($hookFound -eq 0) {
    Add-Info 'H1' 'no hook files present; the D-15 budget is trivially satisfied'
} elseif ($hBad -eq 0) {
    Add-Ok 'H1' ($hookFound.ToString() + " hook file(s) within the D-15 budget, owned and timeout-bounded")
}

# -----------------------------------------------------------------------------
# P1 / P2  Policy lint over shipped components
# P3       Hook write targets
# P4       No package.json at repository root
# -----------------------------------------------------------------------------
# The policy lint runs over SHIPPED COMPONENTS only - plugins/**. Governance
# documents describe the policy and legitimately contain the words the lint
# looks for, so scanning them would flag Awakened's own safety documentation
# as a violation of itself.
$components = @()
if (Test-Path -LiteralPath 'plugins' -PathType Container) {
    # -Force: on Linux PowerShell hides dot-directories such as .claude-plugin/ without it;
    # on Windows it does not. The twins must scan the same files on every platform (HD-12).
    $components = @(Get-ChildItem -LiteralPath 'plugins' -Recurse -Force -File |
        Where-Object { $_.Extension -cin @('.md', '.json', '.sh', '.ps1') } | Sort-Object FullName)
}
$hrPatterns = @(
    @{ Id = 'HR-1'; Pattern = '\b(api[_ -]?key|secret[_ -]?key|access[_ -]?token|bearer\s+[A-Za-z0-9._-]{16,})\b' },
    @{ Id = 'HR-2'; Pattern = '"mcpServers"\s*:\s*\{' },
    @{ Id = 'HR-3'; Pattern = '\b(lspServers|language[- ]server-protocol)\b' },
    @{ Id = 'HR-4'; Pattern = '\b(nohup|systemd|launchd|crontab|setInterval|while\s+true\s*;\s*do)\b' },
    @{ Id = 'HR-5'; Pattern = '\b(sqlite3?|better-sqlite3|node-gyp|\.node\b)' },
    @{ Id = 'HR-6'; Pattern = '\b(curl\s+http|wget\s+http|fetch\(|https?://[^\s)"'']+/(v\d|api)/)' },
    @{ Id = 'HR-7'; Pattern = '\b(npm\s+i(nstall)?\b|pip\s+install\b|apt(-get)?\s+install\b|winget\s+install\b|cargo\s+install\b)' }
)
$injection = @(
    'ignore\s+(all\s+)?previous\s+instructions',
    'without\s+(asking|confirmation|prompting)',
    'do\s+not\s+ask\s+the\s+user',
    '\bbypass(ing)?\s+(the\s+)?(confirmation|permission|approval)',
    'base64\s*(-d|--decode|\.b64decode)'
)
$p1 = 0; $p2 = 0
foreach ($f in $components) {
    $rel = [System.IO.Path]::GetRelativePath($Root, $f.FullName) -replace '\\', '/'
    $text = ''
    try { $text = Get-Content -LiteralPath $f.FullName -Raw -Encoding utf8 } catch { continue }
    if ($null -eq $text) { continue }
    foreach ($hr in $hrPatterns) {
        foreach ($m in [regex]::Matches($text, $hr.Pattern, 'IgnoreCase')) {
            $line = ($text.Substring(0, $m.Index) -split "`n").Count
            $snippet = $m.Value; if ($snippet.Length -gt 60) { $snippet = $snippet.Substring(0, 60) }
            Add-Err 'P1' ($rel + ":" + $line + " matches a " + $hr.Id + " indicator: '" + $snippet + "'")
            $p1++
        }
    }
    foreach ($pat in $injection) {
        foreach ($m in [regex]::Matches($text, $pat, 'IgnoreCase')) {
            $line = ($text.Substring(0, $m.Index) -split "`n").Count
            $snippet = $m.Value; if ($snippet.Length -gt 60) { $snippet = $snippet.Substring(0, 60) }
            Add-Err 'P2' ($rel + ":" + $line + " matches a prompt-injection or obfuscation pattern: '" + $snippet + "' (E-1)")
            $p2++
        }
    }
}
if ($components.Count -eq 0) {
    Add-Info 'P1' 'no shipped components present; the HR indicator scan is not exercised'
    Add-Info 'P2' 'no shipped components present; the E-1 injection scan is not exercised'
} else {
    if ($p1 -eq 0) { Add-Ok 'P1' ($components.Count.ToString() + " component file(s) carry no HR-1..HR-7 indicator") }
    if ($p2 -eq 0) { Add-Ok 'P2' ($components.Count.ToString() + " component file(s) carry no injection or obfuscation pattern") }
}

# P3 - hook write targets. Permitted prefixes are the D-18 scope: the project
# directory and the owning plugin's own data directory.
# Every pattern is anchored: the allow-list gates a PREFIX, never a substring.
# The anchors are load-bearing here because -cmatch searches anywhere in the
# string; the bash twin holds this same array verbatim.
$allowedTargets = @('^\$\{?CLAUDE_PROJECT_DIR\}?', '^\$\{?CLAUDE_PLUGIN_DATA(_DIR)?\}?',
                    '^\$\{?CLAUDE_PLUGIN_ROOT\}?', '^\./', '^[A-Za-z0-9_.-]+/')
# A prefix allow-list alone cannot hold HR-8: '.' is inside the character class
# above, so '../' matches it, and 'logs/../../etc/passwd' matches even anchored.
# Any '..' path segment is therefore denied outright, before the allow-list runs.
$traversalRe = '(^|[/\\])\.\.([/\\]|$)'
$writeRe = '(?:>>?|tee\s+|Out-File\s+|Set-Content\s+|cp\s+\S+\s+|mv\s+\S+\s+)\s*([^\s;|&"]+)'
$p3 = 0
foreach ($h in $hookFiles) {
    $rel = [System.IO.Path]::GetRelativePath($Root, $h.FullName) -replace '\\', '/'
    # Both twins scan the same compact JSON round-trip, never the raw file text.
    # -Depth is load-bearing: the default of 2 stringifies the nested hooks[]
    # level and the scan would silently find nothing. Parse failure fails closed.
    $blob = ''
    try {
        $cfg = Get-Content -LiteralPath $h.FullName -Raw -Encoding utf8 | ConvertFrom-Json
        $blob = $cfg | ConvertTo-Json -Depth 100 -Compress
    } catch {
        Add-Err 'P3' ($rel + " is not parseable JSON; the HR-8 write-scope scan cannot run")
        $p3++
        continue
    }
    foreach ($m in [regex]::Matches($blob, $writeRe)) {
        $target = $m.Groups[1].Value.Trim('"', '\')
        if ($target -cmatch $traversalRe) {
            Add-Err 'P3' ($rel + " writes to a target containing a '..' path segment: '" + $target + "' (HR-8)")
            $p3++
            continue
        }
        $okTarget = $false
        foreach ($a in $allowedTargets) { if ($target -cmatch $a) { $okTarget = $true } }
        if (-not $okTarget) {
            Add-Err 'P3' ($rel + " writes to a target outside the D-18 scope: '" + $target + "' (HR-8)")
            $p3++
        }
    }
}
if ($hookFiles.Count -eq 0) {
    Add-Info 'P3' 'no hook files present; the HR-8 write-scope scan is not exercised'
} elseif ($p3 -eq 0) {
    Add-Ok 'P3' ($hookFiles.Count.ToString() + " hook file(s) write only inside the D-18 scope")
}

if (Test-Path -LiteralPath 'package.json' -PathType Leaf) {
    Add-Err 'P4' 'package.json exists at repository root; distribution is the GitHub repo only (D-02, HR-7)'
} else {
    Add-Ok 'P4' 'no package.json at repository root'
}

# -----------------------------------------------------------------------------
# L1  Line endings and byte-order marks
# -----------------------------------------------------------------------------
$textExt = @('.sh', '.ps1', '.psm1', '.json', '.md', '.csv', '.yml', '.yaml', '.py', '.txt')
$namedFiles = @('LICENSE', 'NOTICE', '.gitattributes')
$l1Bad = 0
$l1Count = 0
foreach ($f in (Get-ChildItem -Recurse -File -Force |
                Where-Object { $_.FullName -cnotmatch '[\\/](\.git|node_modules|__pycache__)[\\/]' })) {
    if ($f.Extension -cnotin $textExt -and $f.Name -cnotin $namedFiles) { continue }
    $l1Count++
    $rel = [System.IO.Path]::GetRelativePath($Root, $f.FullName) -replace '\\', '/'
    $data = [System.IO.File]::ReadAllBytes($f.FullName)
    if ($data.Length -ge 3 -and $data[0] -eq 0xEF -and $data[1] -eq 0xBB -and $data[2] -eq 0xBF) {
        Add-Err 'L1' ($rel + " carries a UTF-8 BOM; the policy is UTF-8 without BOM"); $l1Bad++
    }
    if ($data -contains 0x0D) {
        Add-Err 'L1' ($rel + " contains a CR byte; the policy is LF everywhere"); $l1Bad++
    }
}
if ($l1Bad -eq 0) { Add-Ok 'L1' ($l1Count.ToString() + " text file(s) are LF with no BOM") }

# -----------------------------------------------------------------------------
Write-Host ("Validation complete: " + $script:Errors + " error(s), " + $script:Warnings + " warning(s)")
if ($script:Errors -gt 0) {
    Write-Host "VALIDATE: FAIL"
    exit 1
}
Write-Host "VALIDATE: PASS"
exit 0
