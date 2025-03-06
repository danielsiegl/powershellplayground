. ./Modules/person.ps1
. ./Modules/workday.ps1
. ./Modules/CostWindow.ps1

# Function to get workdays with cost per child
function Get-Workdays-with-Cost-per-Child {
    param (
        [datetime]$startDate,
        [datetime]$endDate,
        [array]$holidayArray,
        [person]$person
    )

    [double]$morningRate = $person.MorningCostPerHour
    [double]$afternoonRate = $person.AfternoonCostPerHour
    [double]$morningGovSubsidy = $person.MorningGovSubsidyPerHour
    [double]$afternoonGovSubsidy = $person.AfternoonGovSubsidyPerHour

    # Initialize an array to hold workdays
    [Workday[]]$workdays = @()

    # Loop through each day in the year
    $currentDate = $startDate
    while ($currentDate -le $endDate) {
        # Get the day of the week
        $dayOfWeek = $currentDate.DayOfWeek

        # Check if the current day is a holiday
        $isHoliday = $holidayArray.Date -contains $currentDate.Date

        # Check if the day is in the schedule and is not a holiday
        if ($person.Schedule.Contains("$dayOfWeek") -and -not $isHoliday) {
            # Create a Workday object for the workday

            # combine the schedule and person information to calculate the cost
            $dailySchedule = $person.Schedule[$dayOfWeek.ToString()]
            $start = [DateTime]::ParseExact("$($currentDate.ToString('yyyy-MM-dd')) $($dailySchedule.Start)", 'yyyy-MM-dd hh:mm tt', $null)
            $end = [DateTime]::ParseExact("$($currentDate.ToString('yyyy-MM-dd')) $($dailySchedule.End)", 'yyyy-MM-dd hh:mm tt', $null)

            # Create a CostWindow object to calculate the cost for each workday - bit of an overkill - but the best way to show the usage of the class
            $costWindow = [CostWindow]::new($start, $end, $morningRate, $afternoonRate, $morningGovSubsidy, $afternoonGovSubsidy)
            
            # Create a Workday object
            $workday = [Workday]::new(
                $currentDate.ToString('yyyy-MM-dd'),
                $dayOfWeek.ToString(),
                $person.Schedule[$dayOfWeek.ToString()].Start,
                $person.Schedule[$dayOfWeek.ToString()].End,
                $costWindow.GetTotalCost(),
                $costWindow.GetTotalSubsidy()
            )
            # Add the workday to the array
            $workdays += $workday
        }

        # Move to the next day
        $currentDate = $currentDate.AddDays(1)
    }

    return $workdays
}

# Function to get workdays cost per month
function Get-Workdays-Cost-per-Month {
    param (
        [Parameter(Mandatory=$true)]
        [array]$workdays
    )

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

    return $workdaysByMonthForJson
}