if (Test-Path "./person.ps1") {
    . ./person.ps1
} else {
    Write-Error "The file 'person.ps1' was not found."
    exit 1
}

if (Test-Path "./bankholidays.ps1") {
    . ./bankholidays.ps1
} else {
    Write-Error "The file 'bankholidays.ps1' was not found."
    exit 1
}

# Example usage
$person = [Person]::new("John", "Doe", 30)
Save-PersonToFile -Person $person -FilePath "person.json"
$loadedPerson = Load-PersonFromFile -FilePath "person.json"
Write-Output $loadedPerson.FirstName

$startDate = Get-Date -Year 2025 -Month 1 -Day 1
$endDate = Get-Date -Year 2025 -Month 12 -Day 31
$startDateString = $startDate.ToString("yyyy-MM-dd")
$endDateString = $endDate.ToString("yyyy-MM-dd")

$holidayArray = Get-AustrianBankHolidays -StartDate $startDateString -EndDate $endDateString

# Output the array to verify
Write-Output "Holidays in 2025:"
Write-Output $holidayArray



# Define an array to hold the data
$daysArray = @()

# Get all days of 2025
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

    if ($isHoliday) {
        Write-Debug "$($currentDate.ToString('yyyy-MM-dd')) - $dayOfWeek - Holiday: $holidayName"
    } else {
        Write-Debug "$($currentDate.ToString('yyyy-MM-dd')) - $dayOfWeek - Regular day"
    }

    $currentDate = $currentDate.AddDays(1)
}

# Output the array to verify
$daysArray | ForEach-Object {
    Write-Output "$($_.Date) - $($_.DayOfWeek) - Holiday: $($_.HolidayName)"
}

# Save the array to a JSON file
$daysArray | ConvertTo-Json | Set-Content -Path "daysArray.json"

# Load the array from the JSON file
$loadedDaysArray = Get-Content -Path "daysArray.json" | ConvertFrom-Json

# Display the loaded array
foreach ($day in $loadedDaysArray) {
    Write-Output  "$($day.Date) : $($day.DayOfWeek) - Holiday: $($day.HolidayName)"
}

$Schedule = [ordered]@{
    Monday    = [PSCustomObject]@{ Start = "09:00 AM"; End = "05:00 PM" }
    Tuesday   = [PSCustomObject]@{ Start = "09:00 AM"; End = "05:00 PM" }
    Wednesday = [PSCustomObject]@{ Start = "09:00 AM"; End = "05:00 PM" }
    Thursday  = [PSCustomObject]@{ Start = "09:00 AM"; End = "05:00 PM" }
    Friday    = [PSCustomObject]@{ Start = "09:00 AM"; End = "04:00 PM" }
}

# Save the schedule to a JSON file
$Schedule | ConvertTo-Json | Set-Content -Path "schedule.json"

# Load the schedule from the JSON file
$loadedSchedule = Get-Content -Path "schedule.json" | ConvertFrom-Json

# Display the loaded schedule
foreach ($day in $loadedSchedule.PSObject.Properties.Name) {
    Write-Output "$day : $($loadedSchedule.$day.Start) - $($loadedSchedule.$day.End)"
}

foreach ($day in $Schedule.Keys) {
    Write-Output "$day : $($Schedule[$day].Start) - $($Schedule[$day].End)"
}
