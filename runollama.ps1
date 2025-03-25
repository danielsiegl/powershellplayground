# $uri = "http://localhost:11434/api/chat"
# $body = @{
#     model    = "qwen2.5-coder:7b"
#     messages = @(
#         @{
#             role    = "user"
#             content = "why is the sky blue?"
#         }
#     )
#     stream   = $false
# } | ConvertTo-Json

# $response = Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
# Write-Output $response

$uri = "http://localhost:11434/v1/chat/completions"
$body = @{
    model    = "phi4-mini:latest"
    messages = @(
        @{
            role    = "system"
            content = "You are a helpful assistant."
        },
        @{
            role    = "user"
            content = "What is the capital of France?"
        }
    )
    stream   = $false
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
Write-Output $response