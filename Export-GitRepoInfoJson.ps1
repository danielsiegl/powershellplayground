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
        [string]$CommitHash
    )
    
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

# Get all branches
$branches = git branch -a | ForEach-Object { $_.Trim() -replace '^\*?\s*' }
$repoInfo.branches = $branches
$repoInfo.statistics.total_branches = $branches.Count

# Get all tags
$tags = git tag -l
$repoInfo.tags = $tags
$repoInfo.statistics.total_tags = $tags.Count

# Get all commits
$commitHashes = git rev-list --all
$repoInfo.statistics.total_commits = $commitHashes.Count

# Process each commit
$processedFiles = @{}
foreach ($commitHash in $commitHashes) {
    $commitInfo = Get-DetailedCommitInfo -CommitHash $commitHash
    $repoInfo.commits += $commitInfo
    
    # Track unique files
    foreach ($file in $commitInfo.files) {
        $processedFiles[$file.path] = $true
    }
}

$repoInfo.statistics.total_files = $processedFiles.Count

# Export to JSON
$repoInfo | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding utf8

Write-Host "Repository data exported to $OutputPath"
Write-Host "Statistics:"
Write-Host "- Total Commits: $($repoInfo.statistics.total_commits)"
Write-Host "- Total Files: $($repoInfo.statistics.total_files)"
Write-Host "- Total Branches: $($repoInfo.statistics.total_branches)"
Write-Host "- Total Tags: $($repoInfo.statistics.total_tags)"
