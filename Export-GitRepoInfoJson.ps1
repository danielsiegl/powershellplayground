# Export-GitRepoInfoJson.ps1
# This script exports comprehensive Git repository information to JSON format
# including commits, files, branches, and tags

param(
    [string]$OutputPath = "git_repo_data.json",
    [string]$RepoPath = "."
)

# Function to convert Git status codes to human-readable descriptions
function Convert-GitStatusToDescription {
    param(
        [string]$Status
    )
    
    $statusMap = @{
        'A' = 'Added'
        'M' = 'Modified'
        'D' = 'Deleted'
        'R' = 'Renamed'
        'C' = 'Copied'
        'U' = 'Unmerged'
        'T' = 'Type Changed'
        'X' = 'Unknown'
    }
    
    return $statusMap[$Status] ?? 'Unknown'
}

# Function to get detailed commit information
function Get-DetailedCommitInfo {
    param(
        [string]$CommitHash,
        [int]$CommitNumber,
        [int]$TotalCommits,
        [ref]$TotalFilesProcessed
    )
    
    Write-Progress -Activity "Processing Commits" -Status "Commit $CommitNumber of $TotalCommits" -PercentComplete (($CommitNumber / $TotalCommits) * 100)
    
    $commitInfo = git show --pretty=format:'%H|%an|%ae|%ad|%s' --date=iso --name-status $CommitHash
    $commitLines = $commitInfo -split "`n"
    
    $commitHeader = $commitLines[0] -split '\|'
    $files = @()
    
    for ($i = 1; $i -lt $commitLines.Count; $i++) {
        if ($commitLines[$i] -match '^([A-Z])\s+(.+)$') {
            $statusCode = $matches[1]
            $files += @{
                'status_code' = $statusCode
                'status' = Convert-GitStatusToDescription -Status $statusCode
                'path' = $matches[2]
            }
            $TotalFilesProcessed.Value++
        }
    }
    
    return @{
        'hash' = $commitHeader[0]
        'author' = @{
            'name' = $commitHeader[1]
            'email' = $commitHeader[2]
        }
        'date' = $commitHeader[3]
        'message' = $commitHeader[4]
        'files' = $files
    }
}

Write-Host "Starting Git repository export..."
Write-Host "Gathering repository information..."

# Get repository information
$repoInfo = @{
    'name' = (git rev-parse --show-toplevel | Split-Path -Leaf)
    'branches' = @()
    'tags' = @()
    'commits' = @()
    'statistics' = @{
        'total_commits' = 0
        'total_files' = 0
        'total_branches' = 0
        'total_tags' = 0
    }
}

Write-Host "Collecting branches..."
# Get all branches
$branches = git branch -a | ForEach-Object { $_.Trim() -replace '^\*?\s*' }
$repoInfo.branches = $branches
$repoInfo.statistics.total_branches = $branches.Count
Write-Host "Found $($branches.Count) branches"

Write-Host "Collecting tags..."
# Get all tags
$tags = git tag -l
$repoInfo.tags = $tags
$repoInfo.statistics.total_tags = $tags.Count
Write-Host "Found $($tags.Count) tags"

Write-Host "Collecting commits..."
# Get all commits
$commitHashes = git rev-list --all
$repoInfo.statistics.total_commits = $commitHashes.Count
Write-Host "Found $($commitHashes.Count) commits"

# Get total number of files to process
Write-Host "Counting total files to process..."
$totalFiles = 0
$commitCount = 0
$totalCommits = $commitHashes.Count

foreach ($commitHash in $commitHashes) {
    $commitCount++
    Write-Progress -Activity "Counting Files" -Status "Commit $commitCount of $totalCommits" -PercentComplete (($commitCount / $totalCommits) * 100)
    
    $fileChanges = git show --name-status $commitHash
    $fileCount = ($fileChanges -split "`n" | Where-Object { $_ -match '^[A-Z]\s+.+$' }).Count
    $totalFiles += $fileCount
    
    # Show progress every 100 commits
    if ($commitCount % 100 -eq 0) {
        Write-Host "Counted files in $commitCount of $totalCommits commits ($([math]::Round(($commitCount / $totalCommits) * 100))%)"
    }
}

# Clear the counting progress bar
Write-Progress -Activity "Counting Files" -Completed

Write-Host "Found $totalFiles file changes to process"

Write-Host "Processing commits and file changes..."
# Process each commit
$processedFiles = @{}
$commitNumber = 0
$filesProcessed = 0
foreach ($commitHash in $commitHashes) {
    $commitNumber++
    $commitInfo = Get-DetailedCommitInfo -CommitHash $commitHash -CommitNumber $commitNumber -TotalCommits $commitHashes.Count -TotalFilesProcessed ([ref]$filesProcessed)
    $repoInfo.commits += $commitInfo
    
    # Track unique files
    foreach ($file in $commitInfo.files) {
        $processedFiles[$file.path] = $true
    }
    
    # Show progress every 100 commits
    if ($commitNumber % 100 -eq 0) {
        Write-Host "Processed $commitNumber of $($commitHashes.Count) commits ($([math]::Round(($commitNumber / $commitHashes.Count) * 100))%)"
        Write-Host "Processed $filesProcessed of $totalFiles file changes ($([math]::Round(($filesProcessed / $totalFiles) * 100))%)"
    }
    
    # Update file progress bar
    Write-Progress -Activity "Processing Files" -Status "File $filesProcessed of $totalFiles" -PercentComplete (($filesProcessed / $totalFiles) * 100) -Id 1
}

# Clear the progress bars
Write-Progress -Activity "Processing Commits" -Completed
Write-Progress -Activity "Processing Files" -Completed -Id 1

$repoInfo.statistics.total_files = $processedFiles.Count

Write-Host "Exporting data to JSON..."
# Export to JSON
$repoInfo | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding utf8

Write-Host "`nRepository data export completed!"
Write-Host "Output saved to: $OutputPath"
Write-Host "`nStatistics:"
Write-Host "- Total Commits: $($repoInfo.statistics.total_commits)"
Write-Host "- Total Files: $($repoInfo.statistics.total_files)"
Write-Host "- Total Branches: $($repoInfo.statistics.total_branches)"
Write-Host "- Total Tags: $($repoInfo.statistics.total_tags)"
