# This script creates an empty genesis commit in the current git repository

# Check if inside a git repository
if (-not (Test-Path .git)) {
    Write-Error "Not inside a git repository. Please run this script from the root of a git repo."
    exit 1
}

# Check if a genesis commit already exists (by message and committer email only)
$committerName = "Genesis Committer"
$committerEmail = "noreply@linuxfoundation.org"
$genesisDate = "1970-01-01T00:00:00Z"

$existingGenesis = git log --all --pretty=format:"%H|%s|%ae" | ForEach-Object {
    $parts = $_ -split '\|'
    if ($parts.Length -eq 3 -and $parts[1] -eq 'genesis commit' -and $parts[2] -eq $committerEmail) {
        return $true
    }
} | Where-Object { $_ }

if ($existingGenesis) {
    Write-Output "Genesis commit already exists. No action taken."
    exit 0
}

# Create an empty genesis commit with the fixed genesis date, committer name, and email
try {
    git -c "user.name=$committerName" -c "user.email=$committerEmail" commit --allow-empty -m 'genesis commit' --date="$genesisDate"
    Write-Output "Genesis commit created successfully with date $genesisDate, committer $committerName <$committerEmail>."
} catch {
    Write-Error "Failed to create genesis commit: $_"
}
