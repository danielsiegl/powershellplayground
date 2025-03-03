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

# Define the start and end dates for the year
$startDate = Get-Date -Year 2025 -Month 1 -Day 1
$endDate = Get-Date -Year 2025 -Month 12 -Day 31


# Combine person and schedule into a single object using the Child class
$child = [Child]::new(
    [Person]::new("John", "Doe", 2),
    [ordered]@{
        Monday    = [PSCustomObject]@{ Start = "09:00 AM"; End = "05:00 PM" }   # Standard workday for Monday
        Tuesday   = [PSCustomObject]@{ Start = "09:00 AM"; End = "05:00 PM" }   # Standard workday for Tuesday
        Wednesday = [PSCustomObject]@{ Start = "09:00 AM"; End = "05:00 PM" }   # Standard workday for Wednesday
        Thursday  = [PSCustomObject]@{ Start = "09:00 AM"; End = "05:00 PM" }   # Standard workday for Thursday
    }
)

Write-Output "Child object created with name: $($child.Person.FirstName) $($child.Person.LastName)"
# Save the combined object to a JSON file
$child | ConvertTo-Json -Depth 3 | Set-Content -Path "child.json"

$restDateFormat = Get-RestDateFormat
$startDateString = $startDate.ToString($restDateFormat)
$endDateString = $endDate.ToString($restDateFormat)

Write-Output "Start date: $startDateString - End date: $endDateString with format: $restDateFormat"

$holidayArray = Get-AustrianBankHolidays -StartDate $startDateString -EndDate $endDateString

Write-Output "Feiertage $($holidayArray.Count)"

# Initialize an array to hold workdays
[Workday[]]$workdays = @()

# Loop through each day in the year
$currentDate = $startDate
while ($currentDate -le $endDate) {
    # Get the day of the week
    $dayOfWeek = $currentDate.DayOfWeek

    # Check if the current day is a holiday
    $isHoliday = $false

    foreach ($holiday in $holidayArray) {
        if ($currentDate.Date -eq $holiday.Date.Date) {
            $isHoliday = $true
            $holidayName = $holiday.Name
            break
        }
    }

    # Check if the day is in the schedule and is not a holiday
    if ($Child.Schedule.Contains("$dayOfWeek") -and -not $isHoliday) {
        # Create a Workday object for the workday
        $workday = [Workday]::new(
            $currentDate.ToString('yyyy-MM-dd'),
            $dayOfWeek.ToString(),
            $child.Schedule[$dayOfWeek.ToString()].Start,
            $child.Schedule[$dayOfWeek.ToString()].End
        )
        # Add the workday to the array
        $workdays += $workday
    }

    # Move to the next day
    $currentDate = $currentDate.AddDays(1)
}

# Group workdays by month and convert to JSON-friendly format
$workdaysByMonthForJson = $workdays |
    Group-Object { (Get-Date $_.Date).ToString('yyyy-MM') } |
    ForEach-Object {
        [PSCustomObject]@{
            Month = $_.Name
            Count = $_.Count
        }
    }

# Output the workdays per month
Write-Output "Workdays per month:"
$workdaysByMonthForJson | ForEach-Object {
    Write-Output "Month: $($_.Month) - Count: $($_.Count)"
}

# Save the workdays per month to a JSON file
$workdaysByMonthForJson | ConvertTo-Json | Set-Content -Path "workdaysByMonth.json"
