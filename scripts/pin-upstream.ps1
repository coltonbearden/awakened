# =============================================================================
# pin-upstream.ps1 - Awakened upstream pin resolver (PowerShell 7 twin of
# scripts/pin-upstream.sh).
#
# Resolves each repository in upstream.json to its default-branch HEAD SHA via
# `git ls-remote` and writes the SHAs plus a UTC pinned_at timestamp back.
#
# This script is the ONLY sanctioned source of upstream.json commit values.
# SPEC section 8: "No SHA may ever be typed from memory." Its network use is
# the sanctioned repo-maintenance exception under HR-6 - it is not a shipped
# plugin component and never runs on a user's machine as part of a plugin.
#
# PARITY RULE (CLAUDE.md 3.2): scripts/pin-upstream.sh implements the identical
# check list, the identical write-back semantics, and the identical exit
# contract. A change here that is not mirrored there in the same commit is a bug.
#
# USAGE:   pwsh -File scripts/pin-upstream.ps1 [-Manifest <path>]   (default: .\upstream.json)
#
# EXIT CONTRACT (CLAUDE.md 3.3):
#   0  all ten repositories resolved and written
#   1  one or more unresolved; upstream.json left unchanged
#   2  environment error (missing git, unreadable manifest)
#
# DEPENDENCIES: git. Nothing is auto-installed (HR-7); a missing dependency is
# an environment error, not a violation. Unlike the bash twin this script needs
# no Python - PowerShell 7's built-in JSON cmdlets do the parsing.
#
# ATOMICITY: all ten repositories resolve, or upstream.json is not touched.
# =============================================================================

#Requires -Version 7
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Manifest = (Join-Path (Get-Location).Path 'upstream.json')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Exit-Env {
    param([string]$Message)
    [Console]::Error.WriteLine("[FAIL][E0] " + $Message)
    Write-Host "PIN: FAIL"
    exit 2
}

if ($null -eq (Get-Command git -ErrorAction SilentlyContinue)) {
    Exit-Env "git not found on PATH"
}
if (-not (Test-Path -LiteralPath $Manifest -PathType Leaf)) {
    Exit-Env ("upstream.json not found at " + $Manifest)
}

try {
    $data = Get-Content -LiteralPath $Manifest -Raw -Encoding utf8 | ConvertFrom-Json
}
catch {
    Exit-Env ("upstream.json is not valid JSON: " + $_.Exception.Message)
}

if ($data.repos.Count -ne 10) {
    Exit-Env ("expected 10 repos per SPEC section 8; found " + $data.repos.Count)
}

$pins = @{}
$unresolved = 0

foreach ($repo in $data.repos) {
    $line = & git ls-remote --exit-code $repo.url HEAD 2>$null | Select-Object -First 1
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($line)) {
        [Console]::Error.WriteLine("[FAIL][P1] " + $repo.name + ": could not resolve HEAD from " + $repo.url)
        $unresolved = $unresolved + 1
        continue
    }
    $sha = ($line -split "\s+")[0]
    Write-Host ("[ OK ] " + $repo.name + " " + $sha.Substring(0, 7))
    $pins[$repo.name] = $sha
}

if ($unresolved -gt 0) {
    Write-Host ("PIN: FAIL (" + $unresolved + " unresolved; upstream.json left unchanged)")
    exit 1
}

foreach ($repo in $data.repos) {
    $repo.commit = $pins[$repo.name]
}
$data.pinned_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

$json = $data | ConvertTo-Json -Depth 12
# LF line endings, UTF-8 without BOM (CLAUDE.md 3.4).
[System.IO.File]::WriteAllText(
    $Manifest,
    (($json -replace "`r`n", "`n") + "`n"),
    (New-Object System.Text.UTF8Encoding($false))
)

Write-Host "PIN: PASS (10/10 resolved)"
exit 0
