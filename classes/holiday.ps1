class HoliDay {
    [datetime]$Date
    [string]$Name

    HoliDay([datetime]$Date, [string]$Name) {
        $this.Date = $Date
        $this.Name = $Name
    }
}

# [HoliDay] $holiday = [HoliDay]::new((Get-Date -Year 2021 -Month 1 -Day 1), "New Year's Day")
# Write-Output "$($holiday.Date) - $($holiday.Name)"