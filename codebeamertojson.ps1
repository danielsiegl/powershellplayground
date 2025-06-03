param(
    [Parameter(Mandatory=$true)]
    [string]$TrackerId,
    [Parameter(Mandatory=$true)]
    [string]$Username,
    [Parameter(Mandatory=$true)]
    [string]$Password,
    [string]$BaseUrl = "https://training.codebeamer.com"
)

$secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ($Username, $secpasswd)

$url = "$BaseUrl/api/v3/trackers/$TrackerId/items"

try {
    $response = Invoke-RestMethod -Uri $url -Credential $creds -Method Get -Headers @{Accept="application/json"}
    $output = $response.items | Select-Object id, description | ConvertTo-Json
    Write-Output $output
} catch {
    Write-Error "Failed to retrieve tracker items: $_"
}