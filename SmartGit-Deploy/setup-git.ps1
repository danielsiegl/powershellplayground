# Get the user's home directory
$homeDir = $env:USERPROFILE
$gitConfigPath = Join-Path $homeDir ".gitconfig"

# Get Windows user information
$windowsIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$displayName = $windowsIdentity.Name
$email = "$($windowsIdentity.Name.Split('\')[1])@localhost"

# Check if .gitconfig exists
if (-not (Test-Path $gitConfigPath)) {
    Write-Host "No .gitconfig found. Creating one..."
    
    # Create the .gitconfig content
    $gitConfigContent = @"
[user]
    name = $displayName
    email = $email
"@

    # Write the content to .gitconfig
    $gitConfigContent | Out-File -FilePath $gitConfigPath -Encoding utf8
    
    Write-Host "Created .gitconfig at $gitConfigPath"
    Write-Host "Set name to: $displayName"
    Write-Host "Set email to: $email"
} else {
    Write-Host ".gitconfig already exists at $gitConfigPath"
    Write-Host "Current user information:"
    Write-Host "Name: $displayName"
    Write-Host "Email: $email"
} 