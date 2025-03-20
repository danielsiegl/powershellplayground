# check for pwsh
if ($PSVersionTable.PSEdition -ne "Core") {
    throw  "This script is intended to be run in PowerShell Core (pwsh)."
}

# Install the required module if not installed
# Install-Module -Name Microsoft.PowerShell.Utility -Force
. .\functions\Get-ApiToken.ps1
. .\functions\Invoke-ChatCompletion.ps1

$baseUrl = "https://api.openai.com/v1/"  #"https://models.inference.ai.azure.com"
$apiKey = Get-ApiToken  # Ensure you have set this environment variable
$model = "o3-mini" #"4o-mini" #"gpt-4o"  # Specify the model you want to use

$prompt = "List all the keywords of the SysML V2 textual syntax"

# Example usage
Write-Output "Prompt: $prompt"
$ResponseMessage = Invoke-ChatCompletion -Prompt $prompt -ApiKey $apiKey -BaseUrl $baseUrl -Model $model
Write-Output "$($ResponseMessage[0])"
Write-Output "Response: $($ResponseMessage[1])"
