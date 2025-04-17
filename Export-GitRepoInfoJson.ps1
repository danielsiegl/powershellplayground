param (
    [string]$RepoPath = ".",
    [string]$OutputFile = "./git_repo_docs.json",
    [int]$CommitLimit = 1000
)

function Run-Git { param($args) ; git -C $RepoPath @args 2>&1 }
function Normalize-Path { param($p); return $p.Replace($RepoPath, "").Replace("\", "/").TrimStart("/") }
function Make-Doc { param($id, $text, $meta); return [pscustomobject]@{ id = $id; text = $text; metadata = $meta } }

if (-not (Test-Path "$RepoPath/.git")) {
    Write-Error "Not a Git repo."
    exit 1
}

$docs = @()

# --- Git metadata ---
$docs += Make-Doc "git_remotes" ((Run-Git "remote" "-v") -join "`n") @{ type = "git-meta"; section = "remotes" }
$docs += Make-Doc "git_branches" ((Run-Git "branch" "-a") -join "`n") @{ type = "git-meta"; section = "branches" }
$docs += Make-Doc "git_status" ((Run-Git "status") -join "`n") @{ type = "git-meta"; section = "status" }
$docs += Make-Doc "git_config" ((Run-Git "config" "--list") -join "`n") @{ type = "git-meta"; section = "config" }

# --- Enhanced Git log with changed files and tags ---
$logOutput = Run-Git "log" "--pretty=format:%h|%an|%ad|%s|%D" "--date=iso" "--name-only" -n $CommitLimit
$current = $null
$logEntries = @()
foreach ($line in $logOutput) {
    if ($line -match "^(?<hash>[a-f0-9]+)\|(?<author>[^|]+)\|(?<date>[^|]+)\|(?<subject>[^|]+)\|(?<refs>.*)$") {
        if ($null -ne $current) { $logEntries += $current }
        $current = @{
            hash = $matches.hash
            author = $matches.author
            date = $matches.date
            subject = $matches.subject
            refs = $matches.refs
            files = @()
        }
    } elseif ($line -and $null -ne $current) {
        $current["files"] += $line.ToString().Trim()
    }
}
if ($null -ne $current) { $logEntries += $current }

foreach ($entry in $logEntries) {
    $docId = "commit_" + $entry.hash
    $tags = @()
    if ($entry.subject -match "(?i)fix|bug") { $tags += "bugfix" }
    if ($entry.subject -match "(?i)feat|feature") { $tags += "feature" }
    if ($entry.subject -match "(?i)doc|readme") { $tags += "docs" }
    $text = "[$($entry.hash)] $($entry.subject) by $($entry.author) on $($entry.date)`nChanged files:`n$($entry.files -join "`n")"
    $docs += Make-Doc $docId $text @{ type = "commit"; author = $entry.author; date = $entry.date; tags = $tags; files = $entry.files; refs = $entry.refs }
}

# --- Committers summary ---
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

# --- File content extraction and chunking ---
$chunkSize = 1000
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
            $chunkCount = [math]::Ceiling($text.Length / $chunkSize)
            for ($i = 0; $i -lt $chunkCount; $i++) {
                $start = $i * $chunkSize
                $len = [Math]::Min($chunkSize, $text.Length - $start)
                $chunk = $text.Substring($start, $len)
                $docs += Make-Doc "file_${safeId}_chunk_$i" $chunk @{
                    type = $type; path = $relPath; extension = $ext;
                    chunkIndex = $i; totalChunks = $chunkCount
                }
            }

            # Optional: extract header comments as summary
            if ($ext -eq "ps1" -or $ext -eq "py") {
                $summary = ($text -split "`n" | Where-Object { $_ -match '^#' } | Select-Object -First 5) -join "`n"
                if ($summary) {
                    $docs += Make-Doc "summary_${safeId}" $summary @{ type = "summary"; path = $relPath }
                }
            }
        }
    } catch {
        Write-Warning "⚠️ Could not read: $relPath"
    }
}

# --- Export to JSON ---
$docs | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 -Path $OutputFile
Write-Host "`n✅ Enhanced RAG-friendly Git repo JSON saved to: $OutputFile"