. ./person.ps1
. ./bankholidays.ps1

# Example usage
$person = [Person]::new("John", "Doe", 30)
Save-PersonToFile -Person $person -FilePath "person.json"
$loadedPerson = Load-PersonFromFile -FilePath "person.json"
Write-Output $loadedPerson.FirstName

$startDate = Get-Date -Year 2025 -Month 1 -Day 1
$endDate = Get-Date -Year 2025 -Month 12 -Day 31
$startDateString = $startDate.ToString("yyyy-MM-dd")
$endDateString = $endDate.ToString("yyyy-MM-dd")   

$holidayArray = Get-AustrianBankHolidays $startDateString, $endDateString

# Output the array to verify
# $holidayArray

Write-Output "Holidays in 2025:"
# Get all days of 2025


$currentDate = $startDate
while ($currentDate -le $endDate) {
    $isHoliday = $false
    $holidayName = ""

    foreach ($holiday in $holidayArray) {
        # Write-Output "$currentDate - $holiday.StartDate"
        if ($currentDate.Date -eq $holiday.StartDate.Date) {
            $isHoliday = $true
            $holidayName = $holiday.Name
            break
        }
    }

    $dayOfWeek = $currentDate.DayOfWeek
    if ($isHoliday) {
        Write-Output "$($currentDate.ToString('yyyy-MM-dd')) - $dayOfWeek - Holiday: $holidayName"
    } else {
        Write-Output "$($currentDate.ToString('yyyy-MM-dd')) - $dayOfWeek - Regular day"
    }

    $currentDate = $currentDate.AddDays(1)
}

exit 0

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
    Write-Host "$day : $($loadedSchedule.$day.Start) - $($loadedSchedule.$day.End)"
}

# # Display the schedule
# $Schedule.GetEnumerator() | Sort-Object Name | ForEach-Object {
#     Write-Host "$($_.Key): $($_.Value.Start) - $($_.Value.End)"
# }

foreach ($day in $Schedule.Keys) {
    Write-Host "$day : $($Schedule[$day].Start) - $($Schedule[$day].End)"
}
