# Define the Person class
# This class represents a person with properties for first name, last name, and age.
class Person {
    [string]$FirstName
    [string]$LastName
    [double]$MorningCostPerHour
    [double]$MorningGovSubsidyPerHour
    [double]$AfternoonCostPerHour
    [double]$AfternoonGovSubsidyPerHour

    Person([string]$firstName, [string]$lastName, [double]$morningCostPerHour, [double]$morningGovSubsidyPerHour,[double]$afternoonCostPerHour,[double]$afternoonGovSubsidyPerHour) {
        $this.FirstName = $firstName
        $this.LastName = $lastName
        $this.MorningCostPerHour = $morningCostPerHour
        $this.MorningGovSubsidyPerHour = $morningGovSubsidyPerHour
        $this.AfternoonCostPerHour = $afternoonCostPerHour
        $this.AfternoonGovSubsidyPerHour = $afternoonGovSubsidyPerHour
    }

    [void] SaveToFile([string]$filePath) {
        $json = $this | ConvertTo-Json -Depth 3
        Set-Content -Path $filePath -Value $json
    }

    static [Person] LoadFromFile([string]$filePath) {
        $json = Get-Content -Path $filePath
        return $json | ConvertFrom-Json -AsHashtable | ForEach-Object {
            [Person]::new($_.FirstName, $_.LastName, $_.MorningCostPerHour, $_.MorningGovSubsidyPerHour, $_.AfternoonCostPerHour, $_.AfternoonGovSubsidyPerHour)
        }
    }
}

# Define the Child class
# This class represents a child with properties for person and schedule.
class Child {
    [Person]$Person
    [hashtable]$Schedule

    Child([Person]$person, [hashtable]$schedule) {
        $this.Person = $person
        $this.Schedule = $schedule
    }
}