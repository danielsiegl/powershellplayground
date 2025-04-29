<#
.SYNOPSIS
  Export commit metadata, file lists, and diff hunks in one pass.

.DESCRIPTION
  Runs `git log --name-status --patch` with a JSON header per commit,
  NUL-terminates each block (`-z`), and optionally detects renames/copies
  (`-M -C`).  The raw stream is written byte-for-byte so the NUL
  separators are preserved.

.PARAMETER RepoPath
  Path to the Git repository (defaults to the current directory).

.PARAMETER OutputFile
  Destination file for the NUL-terminated NDJSON stream.

.PARAMETER Since
  Optional --since value (e.g. "2025-01-01" or "2 weeks ago")  
  for incremental exports.

.PARAMETER DetectRenames
  Switch: include -M -C flags to detect renames and copies.

.EXAMPLE
  ./export-git-history.ps1 -RepoPath C:\src\myapp -Since "2025-01-01" `
                           -DetectRenames -OutputFile history.ndjsonz
#>

param(
    [string]$RepoPath   = ".",
    [string]$OutputFile = "repo.ndjsonz",
    [string]$Since      = "",
    [switch]$DetectRenames
)

#---- Sanity checks ----------------------------------------------------------
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "❌  'git' executable not found in PATH."
    exit 1
}
if (-not (Test-Path $RepoPath)) {
    Write-Error "❌  RepoPath '$RepoPath' does not exist."
    exit 1
}

Push-Location $RepoPath

#---- JSON header format -----------------------------------------------------
$format = @'
{{
  "commit": "%H",
  "parents": "%P",
  "author": {{ "name": %Q%an%Q, "email": %Q%ae%Q }},
  "date": "%ad",
  "subject": %Q%s%Q
}}
'@

#---- Build git log arguments ------------------------------------------------
$logArgs = @(
    "log", "--all",
    "-z",                 # NUL-terminate each commit block
    "--name-status",
    "--patch",
    "--pretty=$format"
)

if ($Since)       { $logArgs += "--since=$Since" }
if ($DetectRenames) { $logArgs += "-M"; $logArgs += "-C" }

#---- Run git and capture raw bytes -----------------------------------------
try {
    git @logArgs | Set-Content -Encoding utf8 -Path $OutputFile
    Write-Host "✅  Wrote Git history to '$OutputFile'"
} finally {
    Pop-Location
}
