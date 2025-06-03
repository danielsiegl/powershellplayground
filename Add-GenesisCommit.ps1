# This script creates an empty genesis commit in the current git repository

# Check if inside a git repository
if (-not (Test-Path .git)) {
    Write-Error "Not inside a git repository. Please run this script from the root of a git repo."
    exit 1
}

# Check if the repo is empty (no commits)
$commitCount = git rev-list --all --count
if ($commitCount -gt 0) {
    Write-Output "Repository already has commits. Genesis commit not created."
    exit 0
}

# Create the empty genesis commit with fixed author/committer and date using git -c and --author
$committerName = "Genesis Committer"
$committerEmail = "noreply@linuxfoundation.org"
$genesisDate = "1970-01-01T00:00:00Z"
$author = "$committerName <$committerEmail>"

try {
    git -c user.name="$committerName" -c user.email="$committerEmail" commit --allow-empty -m 'genesis commit' --date="$genesisDate" --author="$author <$committerEmail>"
    Write-Output "Genesis commit created successfully with fixed metadata for identical commit ID across repos."
} catch {
    Write-Error "Failed to create genesis commit: $_"
}
