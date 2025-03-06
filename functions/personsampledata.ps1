. "$PSScriptRoot\classes\contract.ps1"
function Set-Sample-Data {
    [CmdletBinding(SupportsShouldProcess)]
    # Combine person and schedule into a single object using the Person class
    $person = [Contract]::new("Daniel", "Siegl","2005", 6.0, 4.5, 5.0, 0,  # Person object with hourly rates
    [ordered]@{
        Monday    = [PSCustomObject]@{ Start = "08:00 AM"; End = "03:00 PM" }   # Standard workday for Monday
        Tuesday   = [PSCustomObject]@{ Start = "08:00 AM"; End = "03:00 PM" }   # Standard workday for Tuesday
        Wednesday = [PSCustomObject]@{ Start = "08:00 AM"; End = "03:00 PM" }   # Standard workday for Wednesday
        Thursday  = [PSCustomObject]@{ Start = "08:00 AM"; End = "03:00 PM" }   # Standard workday for Thursday
    })

    # Save the combined object to a JSON file
    $person | ConvertTo-Json -Depth 5 | Set-Content -Path "config/Contract.json"
}
function Get-Sample-Data {
    # Load the person object from the JSON file
    $person = [Contract]::LoadFromFile("config/Contract.json")
    return $person
}

# Get-Sample-Data