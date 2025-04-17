param (
    [string]$RepoPath = ".",
    [string]$OutputFile = "./git_repo_docs.json",
    [int]$CommitLimit = 50
)

# Helper functions
function Run-Git { param($args) ; git -C $RepoPath @args 2>&1 }
function Normalize-Path { param($p); return $p.Replace($RepoPath, "").Replace("\", "/").TrimStart("/") }
function Make-Doc { param($id, $text, $meta); return [pscustomobject]@{ id = $id; text = $text; metadata = $meta } }

# Validate repo
if (-not (Test-Path "$RepoPath/.git")) {
    Write-Error "Not a Git repo."
    exit 1
}

$docs = @()

# 🧠 1. Git metadata
$docs += Make-Doc "git_remotes" ((Run-Git "remote" "-v") -join "`n") @{ type = "git-meta"; section = "remotes" }
$docs += Make-Doc "git_branches" ((Run-Git "branch") -join "`n") @{ type = "git-meta"; section = "branches" }
$docs += Make-Doc "git_status" ((Run-Git "status") -join "`n") @{ type = "git-meta"; section = "status" }
$docs += Make-Doc "git_config" ((Run-Git "config" "--list") -join "`n") @{ type = "git-meta"; section = "config" }

# 🧠 2. Git log summary
$logLines = Run-Git "log" "-n" $CommitLimit "--pretty=format:%h|%an|%ad|%s" "--date=iso"
$logFormatted = @()
foreach ($line in $logLines) {
    $parts = $line -split "\|", 4
    if ($parts.Count -eq 4) {
        $logFormatted += "- [$($parts[0])] $($parts[3]) by $($parts[1]) on $($parts[2])"
    }
}
$docs += Make-Doc "git_log" ($logFormatted -join "`n") @{ type = "git-meta"; section = "log" }

# 🧠 2b. Committers summary
$committerRaw = Run-Git "shortlog" "-sne"
$committerLines = @()
foreach ($line in $committerRaw) {
    if ($line -match '^\s*(\d+)\s+(.+)\s+<(.+)>$') {
        $count = $matches[1]
        $name = $matches[2]
        $email = $matches[3]
        $committerLines += "$count commits – $name <$email>"
    }
}
$docs += Make-Doc "git_committers" ($committerLines -join "`n") @{ type = "git-meta"; section = "committers" }

# 🧠 3. File content extraction
$files = Get-ChildItem -Path $RepoPath -Recurse -File
foreach ($file in $files) {
    $relPath = Normalize-Path $file.FullName
    $ext = [IO.Path]::GetExtension($file.Name).TrimStart(".").ToLower()
    $type = switch ($ext) {
        "md" { "doc" }
        "rst" { "doc" }
        "ps1" { "code" }
        "py"  { "code" }
        "js"  { "code" }
        "ts"  { "code" }
        "sh"  { "code" }
        "java" { "code" }
        "cs" { "code" }
        "cpp" { "code" }
        "rb"  { "code" }
        "json" { "config" }
        default { "other" }
    }

    try {
        $text = Get-Content $file.FullName -Raw -ErrorAction Stop
        if ($text.Length -gt 0) {
            $safeId = $relPath.Replace("/", "_").Replace(".", "_")
            $docs += Make-Doc "file_$safeId" $text @{ type = $type; path = $relPath; extension = $ext }
        }
    } catch {
        Write-Warning "⚠️ Could not read: $relPath"
    }
}

# 🧠 4. Export to JSON
$docs | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 -Path $OutputFile
Write-Host "`n✅ Repo exported to RAG-friendly JSON at: $OutputFile"
