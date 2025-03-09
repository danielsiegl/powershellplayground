. "classes\workday.ps1"
. "classes\dailycost.ps1"
. "classes\monthlycost.ps1"
. "functions\bankholidays.ps1"

class Contract {
    [string]$FirstName
    [string]$LastName
    [string]$Year
    [double]$MorningCostPerHour
    [double]$MorningGovSubsidyPerHour
    [double]$AfternoonCostPerHour
    [double]$AfternoonGovSubsidyPerHour
    [hashtable]$Schedule

    Contract([string]$firstName, [string]$lastName, [string]$year, [double]$morningCostPerHour, [double]$morningGovSubsidyPerHour, [double]$afternoonCostPerHour, [double]$afternoonGovSubsidyPerHour, [hashtable]$schedule) {
        $this.FirstName = $firstName
        $this.LastName = $lastName
        $this.Year = $year
        $this.MorningCostPerHour = $morningCostPerHour
        $this.MorningGovSubsidyPerHour = $morningGovSubsidyPerHour
        $this.AfternoonCostPerHour = $afternoonCostPerHour
        $this.AfternoonGovSubsidyPerHour = $afternoonGovSubsidyPerHour
        $this.Schedule = $schedule
    }

    [System.Collections.Generic.List[MonthlyCost]] Calculate() {
        # Function body goes here
        # Define the start and end dates for the year
        [datetime]$startDateContract = Get-Date -Year $this.Year -Month 1 -Day 1
        [datetime]$endDateContract = Get-Date -Year $this.Year -Month 12 -Day 31
        [double]$morningRate = $this.MorningCostPerHour
        [double]$afternoonRate = $this.AfternoonCostPerHour
        [double]$morningGovSubsidy = $this.MorningGovSubsidyPerHour
        [double]$afternoonGovSubsidy = $this.AfternoonGovSubsidyPerHour

        $holidayArray = Get-AustrianBankHolidays -StartDate $startDateContract -EndDate $endDateContract

        # Initialize an array to hold workdays
        #[Workday[]]$workdays = @()
        [System.Collections.Generic.List[Workday]] $workdays = [System.Collections.Generic.List[Workday]]::new()

        # Loop through each day in the year
        $currentDate = $startDateContract
        while ($currentDate -le $endDateContract) {
            $holiday = $holidayArray | Where-Object { $_.Date.Date -eq $currentDate.Date }
            if ($holiday) {
                $isHoliday = $true
            } else {
                $isHoliday = $false
            }

            # Get the day of the week
            $dayOfWeek = $currentDate.DayOfWeek

            # Check if the day is in the schedule and is not a holiday
            if ($this.Schedule.Contains("$dayOfWeek") -and -not $isHoliday) {

                # combine the schedule and person information to calculate the cost
                $dailySchedule = $this.Schedule[$dayOfWeek.ToString()]
                $start = [DateTime]::ParseExact("$($currentDate.ToString('yyyy-MM-dd')) $($dailySchedule.Start)", 'yyyy-MM-dd hh:mm tt', $null)
                $end = [DateTime]::ParseExact("$($currentDate.ToString('yyyy-MM-dd')) $($dailySchedule.End)", 'yyyy-MM-dd hh:mm tt', $null)

                # Create a CostWindow object to calculate the cost for each workday - bit of an overkill - but the best way to show the usage of the class
                $costWindow = [DailyCost]::new($start, $end, $morningRate, $afternoonRate, $morningGovSubsidy, $afternoonGovSubsidy)
                # Create a Workday object
                $workday = [Workday]::new(
                    $currentDate.ToString('yyyy-MM-dd'),
                    $dayOfWeek.ToString(),
                    $this.Schedule[$dayOfWeek.ToString()].Start,
                    $this.Schedule[$dayOfWeek.ToString()].End,
                    $costWindow.GetTotalCost(),
                    $costWindow.GetTotalSubsidy()
                )
                # Add the workday to the array
                $workdays += $workday
            }

            # Move to the next day
            $currentDate = $currentDate.AddDays(1)
        }

        Write-Debug $workdays.Count

        $yearlyCosts = $workdays |
            Group-Object { (Get-Date $_.Date).ToString('yyyy-MM') } |
            ForEach-Object {
                [MonthlyCost]::new(
                    $_.Name,
                    $_.Count,
                    ($_.Group | Measure-Object -Property TotalCost -Sum).Sum,
                    ($_.Group | Measure-Object -Property TotalSubsidy -Sum).Sum
                )
            }
        return $yearlyCosts
    }

    static [Contract] LoadFromFile([string]$filePath) {
        if (-Not (Test-Path -Path $filePath)) {
            throw "File not found: $filePath"
        }
        $json = Get-Content -Path $filePath -Raw
        $data = $json | ConvertFrom-Json -AsHashtable
        $scheduleData = $data.Schedule
        [Contract]$retval = [Contract]::new($data.FirstName, $data.LastName, $data.Year,$data.MorningCostPerHour, $data.MorningGovSubsidyPerHour, $data.AfternoonCostPerHour, $data.AfternoonGovSubsidyPerHour, $scheduleData)
        return $retval
    }
}