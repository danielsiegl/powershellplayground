# This function sends a chat completion request to the OpenAI API.
# It takes a prompt, API key, base URL, and model as parameters.
    function Invoke-ChatCompletion {
    param (
        [string]$Prompt,
        [string]$ApiKey,
        [string]$BaseUrl,
        [string]$Model = "o3-mini"
    )

    # No manual escaping is needed when using ConvertTo-Json,
    # just trim the prompt to remove any leading or trailing whitespace.
    $Prompt = ConvertTo-Json $Prompt.Trim()


    # Define the request payload
    $Body = @{
        messages = @(
            @{ role = "system"; content = "" },
            @{ role = "user"; content = $Prompt }
        )
        model = $Model
    } | ConvertTo-Json -Depth 10

    # Define headers
    $Headers = @{
        "Authorization" = "Bearer $ApiKey"
        "Content-Type" = "application/json"
    }

    # Make the API request
    try {
        $url = "$BaseUrl/chat/completions"
        Write-Output "Request URL: $url"
        $Response = Invoke-RestMethod -Uri $url  -Method Post -Headers $Headers -Body $Body

        return $Response.choices[0].message.content
    } catch {
        Write-Error "The sample encountered an error: $_"
        Write-Error "with the following parameters:"
        Write-Error "Prompt: $Prompt"
        Write-Error "BaseUrl: $BaseUrl"
        throw
    }
}