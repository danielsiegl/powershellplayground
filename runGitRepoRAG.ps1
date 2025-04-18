# ⚙️  Prerequisites
# 1. PowerShell 5+ (Windows) or pwsh (cross‑platform)
# 2. Your OpenAI API key in $env:OPENAI_API_KEY
# 3. git_repo_data.json in the same folder as the script (or adjust the path)

. ./functions/Get-ApiToken.ps1

# ---------- configuration ----------
$apiKey   = Get-ApiToken
$filePath = "git_repo_data.json"
$model    = "gpt-4-1106-preview"

# ---------- common headers ----------
$authHeaders = @{ 
    Authorization = "Bearer $apiKey"
    "Content-Type" = "application/json"
}

try {
    # Read the JSON file content
    $fileContent = Get-Content -Path $filePath -Raw

    # Prepare the chat completion request
    $chatBody = @{
        model = $model
        messages = @(
            @{
                role = "system"
                content = "You are a helpful assistant that analyzes git repository data. You will be given JSON data about a git repository and should analyze it to answer questions about commit patterns and repository activity."
            },
            @{
                role = "user"
                content = "Here is the git repository data: $fileContent"
            },
            @{
                role = "user"
                content = "How many commits happened on a Monday? just answer with a number"
            }
        )
        temperature = 0.7
    } | ConvertTo-Json -Depth 10

    # Make the API call
    Write-Host "Sending request to OpenAI..."
    $response = Invoke-RestMethod `
        -Uri "https://api.openai.com/v1/chat/completions" `
        -Method Post `
        -Headers $authHeaders `
        -Body $chatBody

    # Display the response
    Write-Host "`nAnswer:"
    $response.choices[0].message.content

} catch {
    Write-Error "An error occurred: $_"
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        Write-Error "Response body: $($reader.ReadToEnd())"
    }
}
