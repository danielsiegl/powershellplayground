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
}

# Function to save a Person object to disk
function Save-PersonToFile {
    param (
        [Person]$Person,
        [string]$FilePath
    )

    $json = $Person | ConvertTo-Json
    # Function to load a Person object from disk
    
    Set-Content -Path $FilePath -Value $json
}

function Load-PersonFromFile {
    param (
        [string]$FilePath
    )

    $json = Get-Content -Path $FilePath -Raw
    $person = $json | ConvertFrom-Json
    return [Person]::new($person.FirstName, $person.LastName, $person.Age)
}
