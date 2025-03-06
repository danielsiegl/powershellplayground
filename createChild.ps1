# This script creates a child process and includes necessary modules for person, bank holidays, and workday functionalities.
# 
# Modules:
# - person.ps1: Contains functions and definitions related to person entities.
# - bankholidays.ps1: Provides functions to handle bank holidays.
# - workday.ps1: Includes functions to manage workday calculations and operations.
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

#define the rates
$morningRate = 6
$afternoonRate = 5
$morningGovSubsidy = 4.5
$afternoonGovSubsidy = 0

# Combine person and schedule into a single object using the Child class
$child = [Child]::new(
    [Person]::new("Daniel", "Siegl", $morningRate, $morningGovSubsidy, $afternoonRate, $afternoonGovSubsidy),   # Person object with hourly rates
    [ordered]@{
        Monday    = [PSCustomObject]@{ Start = "08:00 AM"; End = "03:00 PM" }   # Standard workday for Monday
        Tuesday   = [PSCustomObject]@{ Start = "08:00 AM"; End = "03:00 PM" }   # Standard workday for Tuesday
        Wednesday = [PSCustomObject]@{ Start = "08:00 AM"; End = "03:00 PM" }   # Standard workday for Wednesday
        Thursday  = [PSCustomObject]@{ Start = "08:00 AM"; End = "03:00 PM" }   # Standard workday for Thursday
    }
)

Write-Output "Child: $($child.Person.FirstName) $($child.Person.LastName)"
# Save the combined object to a JSON file
$child | ConvertTo-Json -Depth 3 | Set-Content -Path "child.json"

$restDateFormat = Get-RestDateFormat
$startDateString = $startDate.ToString($restDateFormat)
$endDateString = $endDate.ToString($restDateFormat)

$holidayArray = Get-AustrianBankHolidays -StartDate $startDateString -EndDate $endDateString
Write-Output "Start date: $startDateString - End date: $endDateString - Feiertage: $($holidayArray.Count)"

# Call the function to get workdays
$workdays = Get-Workdays-with-Cost-per-Child -startDate $startDate -endDate $endDate -holidayArray $holidayArray -child $child -morningRate $morningRate -afternoonRate $afternoonRate -morningGovSubsidy $morningGovSubsidy -afternoonGovSubsidy $afternoonGovSubsidy

# Group workdays by month and convert to JSON-friendly format
$workdaysByMonthForJson = $workdays |
    Group-Object { (Get-Date $_.Date).ToString('yyyy-MM') } |
    ForEach-Object {
        [PSCustomObject]@{
            Month = $_.Name
            Count = $_.Count
            TotalCost = ($_.Group | Measure-Object -Property TotalCost -Sum).Sum
            TotalSubsidy = ($_.Group | Measure-Object -Property TotalSubsidy -Sum).Sum
        }
    }

# Output the workdays per month
Write-Output "Workdays per month:"
$workdaysByMonthForJson | ForEach-Object {
    Write-Output ("Month: {0} - Count: {1} - TotalCost: €{2:F2} - TotalSubsidy: €{3:F2}" -f $_.Month, $_.Count, $_.TotalCost, $_.TotalSubsidy)
}

# Save the workdays per month to a JSON file
$workdaysByMonthForJson | ConvertTo-Json | Set-Content -Path "workdaysByMonth.json"
