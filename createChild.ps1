# This script creates a child process and includes necessary modules for person, bank holidays, and workday functionalities.
# 
# Usage:
# 1. Ensure the script is executed in the correct directory.    
# 2. Run the script to create a child object and calculate workdays for the year 2025.

# Check if the execution directory is the script directory
if ($PSScriptRoot -ne (Get-Location)) {
    Write-Error "The execution directory is not the script directory. Please change to the script directory. $PSScriptRoot"
    Exit 1
}

. ./Modules/person.ps1
. ./Modules/bankholidays.ps1
. ./Modules/workday.ps1
. ./Modules/CostWindow.ps1
. ./Modules/workdaycost.ps1

# Define the start and end dates for the year
$startDate = Get-Date -Year 2025 -Month 1 -Day 1
$endDate = Get-Date -Year 2025 -Month 12 -Day 31

# Load the combined object from the JSON file
$person = [Person]::LoadFromFile("config/person.json")

$holidayArray = Get-AustrianBankHolidaysFromDateTime -startDate $startDate -endDate $endDate
Write-Output "Start date: $startDate - End date: $endDate - Feiertage: $($holidayArray.Count)"

# Call the function to get workdays
$workdays = Get-Workdays-with-Cost-per-Child -startDate $startDate -endDate $endDate -holidayArray $holidayArray -person $person 

# Call the function to get workdays cost per month
$workdaysByMonthForJson = Get-Workdays-Cost-per-Month -workdays $workdays

# Output the workdays per month
Write-Output "Workdays per month:"
$workdaysByMonthForJson | ForEach-Object {
    Write-Output ("Month: {0} - Count: {1} - TotalCost: €{2:F2} - TotalSubsidy: €{3:F2}" -f $_.Month, $_.Count, $_.TotalCost, $_.TotalSubsidy)
}

# Save the workdays per month to a JSON file
$workdaysByMonthForJson | ConvertTo-Json | Set-Content -Path "data/workdaysByMonth.json"
