class Person {
    [string]$FirstName
    [string]$LastName
    [double]$MorningCostPerHour
    [double]$MorningGovSubsidyPerHour
    [double]$AfternoonCostPerHour
    [double]$AfternoonGovSubsidyPerHour
    [hashtable]$Schedule

    Person([string]$firstName, [string]$lastName, [double]$morningCostPerHour, [double]$morningGovSubsidyPerHour, [double]$afternoonCostPerHour, [double]$afternoonGovSubsidyPerHour, [hashtable]$schedule) {
        $this.FirstName = $firstName
        $this.LastName = $lastName
        $this.MorningCostPerHour = $morningCostPerHour
        $this.MorningGovSubsidyPerHour = $morningGovSubsidyPerHour
        $this.AfternoonCostPerHour = $afternoonCostPerHour
        $this.AfternoonGovSubsidyPerHour = $afternoonGovSubsidyPerHour
        $this.Schedule = $schedule
    }

    static [Person] LoadFromFile([string]$filePath) {
        if (-Not (Test-Path -Path $filePath)) {
            throw "File not found: $filePath"
        }
        $json = Get-Content -Path $filePath -Raw
        $data = $json | ConvertFrom-Json -AsHashtable
        $scheduleData = $data.Schedule
        [Person]$retval = [Person]::new($data.FirstName, $data.LastName, $data.MorningCostPerHour, $data.MorningGovSubsidyPerHour, $data.AfternoonCostPerHour, $data.AfternoonGovSubsidyPerHour, $scheduleData)
        return $retval
    }
}

function Set-Sample-Data {
    # Combine person and schedule into a single object using the Person class
    $person = [Person]::new("Daniel", "Siegl", 6.0, 4.5, 5.0, 0,  # Person object with hourly rates
    [ordered]@{
        Monday    = [PSCustomObject]@{ Start = "08:00 AM"; End = "03:00 PM" }   # Standard workday for Monday
        Tuesday   = [PSCustomObject]@{ Start = "08:00 AM"; End = "03:00 PM" }   # Standard workday for Tuesday
        Wednesday = [PSCustomObject]@{ Start = "08:00 AM"; End = "03:00 PM" }   # Standard workday for Wednesday
        Thursday  = [PSCustomObject]@{ Start = "08:00 AM"; End = "03:00 PM" }   # Standard workday for Thursday
    })

    # Save the combined object to a JSON file
    $person | ConvertTo-Json -Depth 5 | Set-Content -Path "config/person.json"
}
function Get-Sample-Data {
    # Load the person object from the JSON file
    $person = [Person]::LoadFromFile("config/person.json")
    return $person
}