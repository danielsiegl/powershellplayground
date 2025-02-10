
# This script is used to lint PowerShell scripts using PSScriptAnalyzer.

# Check if PSScriptAnalyzer is installed, if not install it.
if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
    Set-PSRepository PSGallery -InstallationPolicy Trusted
    Install-Module PSScriptAnalyzer -ErrorAction Stop
}

# Lint the PowerShell scripts.
Invoke-ScriptAnalyzer -Path *.ps1 -Recurse -Outvariable issues

$errors   = $issues.Where({$_.Severity -eq 'Error'})
$warnings = $issues.Where({$_.Severity -eq 'Warning'})
if ($errors) {
    Write-Error "There were $($errors.Count) errors and $($warnings.Count) warnings total." -ErrorAction Stop
} else {
    Write-Output "There were $($errors.Count) errors and $($warnings.Count) warnings total."
}