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

# Define the start and end dates for the year
$startDate = Get-Date -Year 2025 -Month 1 -Day 1
$endDate = Get-Date -Year 2025 -Month 12 -Day 31


# Combine person and schedule into a single object using the Child class
$child = [Child]::new(
    [Person]::new("Daniel", "Siegl", 6.00, 4.50, 5.00, 0),   # Person object with hourly rates
    [ordered]@{
        Monday    = [PSCustomObject]@{ Start = "08:00 AM"; End = "03:00 PM" }   # Standard workday for Monday
        Tuesday   = [PSCustomObject]@{ Start = "08:00 AM"; End = "03:00 PM" }   # Standard workday for Tuesday
        Wednesday = [PSCustomObject]@{ Start = "08:00 AM"; End = "03:00 PM" }   # Standard workday for Wednesday
        Thursday  = [PSCustomObject]@{ Start = "08:00 AM"; End = "03:00 PM" }   # Standard workday for Thursday
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

        $dailySchedule = $child.Schedule[$dayOfWeek.ToString()]
        $start = [DateTime]::ParseExact("$($currentDate.ToString('yyyy-MM-dd')) $($dailySchedule.Start)", 'yyyy-MM-dd hh:mm tt', $null)
        $end = [DateTime]::ParseExact("$($currentDate.ToString('yyyy-MM-dd')) $($dailySchedule.End)", 'yyyy-MM-dd hh:mm tt', $null)

        Write-Output "Start: $start - End: $end"

       
        $morningRate = 6
        $afternoonRate = 5
        $morningGovSubsidy = 4.5
        $afternoonGovSubsidy = 0

        $costWindow = [CostWindow]::new($start, $end, $morningRate, $afternoonRate, $morningGovSubsidy, $afternoonGovSubsidy)


        $workday = [Workday]::new(
            $currentDate.ToString('yyyy-MM-dd'),
            $dayOfWeek.ToString(),
            $child.Schedule[$dayOfWeek.ToString()].Start,
            $child.Schedule[$dayOfWeek.ToString()].End,
            $costWindow.GetTotalCost(),
            $costWindow.GetTotalSubsidy()

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
            TotalCost = ($_.Group | Measure-Object -Property TotalCost -Sum).Sum
            TotalSubsidy = ($_.Group | Measure-Object -Property TotalSubsidy -Sum).Sum
        }
    }

# Output the workdays per month
Write-Output "Workdays per month:"
$workdaysByMonthForJson | ForEach-Object {
    Write-Output "Month: $($_.Month) - Count: $($_.Count)"
}

# Save the workdays per month to a JSON file
$workdaysByMonthForJson | ConvertTo-Json | Set-Content -Path "workdaysByMonth.json"
