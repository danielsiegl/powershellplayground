# ⚙️  Prerequisites
# 1. PowerShell 5+ (Windows) or pwsh (cross‑platform)
# 2. Your OpenAI API key in $env:OPENAI_API_KEY
# 3. git_repo_data.json in the same folder as the script (or adjust the path)

. ./functions/Get-ApiToken.ps1

# ---------- configuration ----------
$apiKey = Get-ApiToken
$filePath = "git_repo_data.json"
$model = "gpt-4-turbo-preview"

# ---------- common headers ----------
$authHeaders = @{ 
    Authorization = "Bearer $apiKey"
    "Content-Type" = "application/json"
}

function Invoke-OpenAIRequest {
    param (
        [string]$Question,
        [string]$JsonData
    )

    $requestBody = @{
        model = $SCRIPT:model
        messages = @(
            @{
                role = "system"
                content = "You are a helpful assistant that provides concise, direct answers to questions about git repository data. Focus on answering the specific question asked without additional explanation or code examples unless explicitly requested."
            },
            @{
                role = "user"
                content = "Here is the git repository data: $JsonData"
            },
            @{
                role = "user"
                content = $Question
            }
        )
        temperature = 0.7
        max_tokens = 150
    } | ConvertTo-Json -Depth 10

    try {
        $response = Invoke-RestMethod `
            -Uri "https://api.openai.com/v1/chat/completions" `
            -Method Post `
            -Headers $SCRIPT:authHeaders `
            -Body $requestBody

        return $response.choices[0].message.content.Trim()
    }
    catch {
        if ($_.Exception.Response) {
            $errorDetails = $_.ErrorDetails.Message | ConvertFrom-Json
            if ($errorDetails.error.code -eq "rate_limit_exceeded") {
                $retryAfter = [int]($errorDetails.error.message -replace '.*try again in (\d+).*', '$1')
                Write-Host "Rate limit reached. Waiting $retryAfter seconds..."
                Start-Sleep -Seconds $retryAfter
                return Invoke-OpenAIRequest -Question $Question -JsonData $JsonData
            }
        }
        Write-Error "Error querying OpenAI: $_"
        return $null
    }
}

try {
    # Read the JSON file content
    $fileContent = Get-Content -Path $filePath -Raw

    # Example queries
    $queries = @(
        "How many commits happened on a Monday? Just answer with a number.",
        "What is the most active day of the week for commits?",
        "Who are the top 3 contributors by number of commits?"
    )

    foreach ($query in $queries) {
        Write-Host "`nQuestion: $query"
        $answer = Invoke-OpenAIRequest -Question $query -JsonData $fileContent
        Write-Host "Answer: $answer"
        
        # Add a small delay between requests to avoid rate limits
        Start-Sleep -Seconds 2
    }

} catch {
    Write-Error "An error occurred: $_"
    if ($_.Exception.Response) {
        $errorDetails = $_.ErrorDetails.Message
        Write-Error "Response body: $errorDetails"
    }
}
