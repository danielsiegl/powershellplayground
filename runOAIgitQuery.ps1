param (
    [Parameter(Mandatory = $true)]
    [string]$prompt

)

# check for pwsh
if ($PSVersionTable.PSEdition -ne "Core") {
    throw  "This script is intended to be run in PowerShell Core (pwsh)."
}

# Install the required module if not installed
# Install-Module -Name Microsoft.PowerShell.Utility -Force
if (Test-Path "$PSScriptRoot\functions\Get-ApiToken.ps1") {
    . "$PSScriptRoot\functions\Get-ApiToken.ps1"
} else {
    throw "The file Get-ApiToken.ps1 was not found in the functions folder."
}

if (Test-Path "$PSScriptRoot\functions\Invoke-ChatCompletion.ps1") {
    . "$PSScriptRoot\functions\Invoke-ChatCompletion.ps1"
} else {
    throw "The file Invoke-ChatCompletion.ps1 was not found in the functions folder."
}

$baseUrl = "https://api.openai.com/v1"  #"https://models.inference.ai.azure.com"
$apiKey = Get-ApiToken  # Ensure you have set this environment variable
$model = "gpt-4o" #"o3-mini" #"4o-mini" #"gpt-4o"  # Specify the model you want to use

$instructions = "You are a Git expert you answer just with the git command in a nothing else that answers this query: "

$fullPrompt = "$instructions`n$prompt"

# Example usage
Write-Output "Prompt: $fullPrompt"
$ResponseMessage = Invoke-ChatCompletion -Prompt $fullPrompt -ApiKey $apiKey -BaseUrl $baseUrl -Model $model
Write-Output "$($ResponseMessage[0])"
Write-Output "Raw Response: $($ResponseMessage[1])"
$gitCommand = $ResponseMessage[1]  -replace '```bash', '' -replace '```', ''  -replace '^\s*', '' -replace '\s*$', '' # Trim whitespace
Write-Output "Git Command: $gitCommand"

# Extract the actual git command from the markdown-formatted response if necessary
if (-not [string]::IsNullOrWhiteSpace($gitCommand)) {
    try {
        #check if the $gitCommand starts with "git "
        if (-not $gitCommand.StartsWith('git ', 'InvariantCultureIgnoreCase')) {
            throw "The command must start with 'git '."
        }
        
        $gitOutput = bash -c "$gitCommand" 2>&1 | Out-String # Capture both stdout and stderr as a string
    } catch {
        Write-Error "Error executing git command: $_"
    }
} else {
    throw "The git command is empty or invalid."  
}

# if output is empty show a nice message    
if (-not $gitOutput) {
    Write-Output "The git command executed successfully but returned no output."
} else {
    Write-Output "Git command executed successfully."
    Write-Output "Git Output: $gitOutput"
}

# Output the result
