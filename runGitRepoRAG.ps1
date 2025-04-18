# ⚙️  Prerequisites
# 1. PowerShell 5+ (Windows) or pwsh (cross‑platform)
# 2. Your OpenAI API key in $env:OPENAI_API_KEY
# 3. git_repo_data.json in the same folder as the script (or adjust the path)

. ./functions/Get-ApiToken.ps1

# ---------- configuration ----------
$apiKey   = Get-ApiToken #$env:OPENAI_API_KEY   # or hard‑code: 'sk‑...'
$filePath = "git_repo_data.json"
$model    = "gpt-4.1"

# ---------- common headers ----------
$authHeaders = @{ 
    Authorization = "Bearer $apiKey"
    "Content-Type" = "application/json"
}

# ---------- 1) read the JSON file ----------
$jsonContent = Get-Content $filePath -Raw

# ---------- 2) create the chat completion request ----------
$requestBody = @{
    model = $model
    messages = @(
        @{
            role = "system"
            content = "You are a helpful assistant that analyzes JSON data with git repo data."
        },
        @{
            role = "user"
            content = "Here is the JSON data: $jsonContent. How many commits hapend on a monday?"
        }
    )
} | ConvertTo-Json -Depth 6

$response = Invoke-RestMethod `
    -Uri    "https://api.openai.com/v1/chat/completions" `
    -Method Post `
    -Headers $authHeaders `
    -Body   $requestBody

# ---------- 3) show the answer ----------
$response.choices[0].message.content
