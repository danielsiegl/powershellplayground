
# This script is used to lint PowerShell scripts using PSScriptAnalyzer.
# It checks if PSScriptAnalyzer is installed, installs it if not, and then
# runs the analysis on all PowerShell scripts in the current directory and

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
    Write-Error "There were $($errors.Count) errors and $($warnings.Count) warnings total."
} else {
    Write-Output "There were $($errors.Count) errors and $($warnings.Count) warnings total."
}

# Convert the issues to a markdown table
$markdownTable = @"
| Severity | Line | Message |
|----------|------|---------|
"@

foreach ($issue in $issues) {
    $markdownTable += "| $($issue.Severity) | $($issue.Line) | $($issue.Message) |`n"

}


# Output the markdown table to the step summary
Write-Output $markdownTable

# Fail the build if there are any errors in the script files
if ($errors) {
    Write-Error "Errors found in script files."
    exit 1
} else {
    Write-Output "No errors found in script files."
}