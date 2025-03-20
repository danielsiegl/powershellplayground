# check for pwsh
if ($PSVersionTable.PSEdition -ne "Core") {
    throw  "This script is intended to be run in PowerShell Core (pwsh)."
}

# Install the required module if not installed
# Install-Module -Name Microsoft.PowerShell.Utility -Force
. .\functions\Get-ApiToken.ps1
. .\functions\Invoke-ChatCompletion.ps1

$baseUrl = "http://localhost:11434/"  #"https://models.inference.ai.azure.com"
$apiKey = "" # Get-ApiToken  # Ensure you have set this environment variable
$model = "llama3:latest" #"4o-mini" #"gpt-4o"  # Specify the model you want to use

$prompt = "What is the {  capital '`" of France?"

# Example usage
$ResponseMessage = Invoke-ChatCompletion -Prompt $prompt -ApiKey $apiKey -BaseUrl $baseUrl -Model $model
Write-Output $ResponseMessage
