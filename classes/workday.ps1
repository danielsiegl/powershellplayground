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