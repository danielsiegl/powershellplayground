# Define the Workday class
# This class represents a workday with properties for date, day of the week, start time, and end time.
class Workday {
    [string]$Date
    [string]$DayOfWeek
    [string]$StartTime
    [string]$EndTime
    [double]$TotalCost
    [double]$TotalSubsidy

    Workday([string]$date, [string]$dayOfWeek, [string]$startTime, [string]$endTime, [double]$totalCost, [double]$totalSubsidy) {
        $this.Date = $date
        $this.DayOfWeek = $dayOfWeek
        $this.StartTime = $startTime
        $this.EndTime = $endTime
        $this.TotalCost = $totalCost
        $this.TotalSubsidy = $totalSubsidy
    }
}

# Define the Get-DaysInfo function
# This function retrieves information about each day in a given date range, including holidays.
function Get-DaysInfo {
    param (
        [datetime]$startDate,
        [datetime]$endDate,
        [array]$holidayArray
    )

    $daysArray = @()
    $currentDate = $startDate
    while ($currentDate -le $endDate) {
        $isHoliday = $false
        $holidayName = ""

        foreach ($holiday in $holidayArray) {
            if ($currentDate.Date -eq $holiday.Date.Date) {
                $isHoliday = $true
                $holidayName = $holiday.Name
                break
            }
        }

        $dayOfWeek = $currentDate.DayOfWeek
        $dayInfo = @{
            Date = $currentDate.ToString('yyyy-MM-dd')
            DayOfWeek = $dayOfWeek
            IsHoliday = $isHoliday
            HolidayName = $holidayName
        }

        # Add the day's information to the array
        $daysArray += $dayInfo

        $currentDate = $currentDate.AddDays(1)
    }

    return $daysArray
}