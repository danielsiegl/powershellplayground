# Define the Person class
class Person {
    [string]$FirstName
    [string]$LastName
    [int]$Age

    Person([string]$firstName, [string]$lastName, [int]$age) {
        $this.FirstName = $firstName
        $this.LastName = $lastName
        $this.Age = $age
    }

    [void] SaveToFile([string]$FilePath) {
        $json = $this | ConvertTo-Json
        Set-Content -Path $FilePath -Value $json
    }

    static [Person] LoadFromFile([string]$FilePath) {
        $json = Get-Content -Path $FilePath -Raw
        $person = $json | ConvertFrom-Json
        return [Person]::new($person.FirstName, $person.LastName, $person.Age)
    }
}
