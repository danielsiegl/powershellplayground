# This script creates an empty genesis commit in the current git repository

# Check if inside a git repository
if (-not (Test-Path .git)) {
    Write-Error "Not inside a git repository. Please run this script from the root of a git repo."
    exit 1
}

# Set a fixed committer name and email for the genesis commit
$committerName = "Genesis Committer"
$committerEmail = "noreply@linuxfoundation.org"
$genesisDate = "1970-01-01T00:00:00Z"

# Create an empty genesis commit with the fixed genesis date, committer name, and email
$commitCommand = "git -c user.name=""$committerName"" -c user.email=""$committerEmail"" commit --allow-empty -m 'genesis commit' --date=""$genesisDate"" "

try {
    Invoke-Expression $commitCommand
    Write-Output "Genesis commit created successfully with date $genesisDate, committer $committerName <$committerEmail>."
} catch {
    Write-Error "Failed to create genesis commit: $_"
}
