. "classes\contract.ps1"
. "functions\bankholidays.ps1"

# Check if the execution directory is the script directory
if ($PSScriptRoot -ne (Get-Location)) {
    Write-Error "The execution directory is not the script directory. Please change to the script directory. $PSScriptRoot"
    Exit 1
}

# Check for PowerShell version 7 or higher
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Error "This script requires PowerShell 7 or higher. Please upgrade your PowerShell version."
    Exit 1
}

# Load the combined object from the JSON file
$contract = [Contract]::LoadFromFile("config/Contract.json")
$contractResult = $contract.Calculate()

# loop throug contractresult to find the highest and lowewst month
$highestMonth = $contractResult | Sort-Object -Property TotalCost -Descending | Select-Object -First 1
$lowestMonth = $contractResult | Sort-Object -Property TotalCost | Select-Object -First 1

Write-Output "Highest month: $($highestMonth.Month) - TotalCost: €$($highestMonth.TotalCost) - TotalSubsidy: €$($highestMonth.TotalSubsidy)"
Write-Output "Lowest month: $($lowestMonth.Month) - TotalCost: €$($lowestMonth.TotalCost) - TotalSubsidy: €$($lowestMonth.TotalSubsidy)"

Write-Output "Contract loaded: $($contract.FirstName) $($contract.LastName) - Year: $($contract.Year)"
Write-Output "Morning cost per hour: €$($contract.MorningCostPerHour) - Morning subsidy per hour: €$($contract.MorningGovSubsidyPerHour)"

# Output the workdays per month
Write-Output "Workdays per month:"
$contractResult | ForEach-Object {
    Write-Output ("Month: {0} - Count: {1} - TotalCost: €{2:F2} - TotalSubsidy: €{3:F2}" -f $_.Month, $_.Days, $_.TotalCost, $_.TotalSubsidy)
}

# Save the workdays per month to a JSON file
$contractResult | ConvertTo-Json | Set-Content -Path "data/contractResult.json"