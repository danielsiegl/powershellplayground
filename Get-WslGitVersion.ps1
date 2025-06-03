# This script runs 'git version' inside WSL and writes the output to Windows stdout

# Output the current directory
Write-Output "Current Directory: $(Get-Location)"

# Output the current directory inside WSL (using PWD environment variable for accuracy)
$wslPwd = wsl bash -c 'echo $PWD'
Write-Output "WSL Current Directory: $wslPwd"

$gitVersion = wsl git version
Write-Output "WSL Git Version: $gitVersion"


