class Person {
    [string]$FirstName
    [string]$LastName
    [int]$Age

    Person([string]$firstName, [string]$lastName, [int]$age) {
        $this.FirstName = $firstName
        $this.LastName = $lastName
        $this.Age = $age
    }

    [void] SaveToFile([string]$filePath) {
        $json = $this | ConvertTo-Json
        Set-Content -Path $filePath -Value $json
    }

    static [Person] LoadFromFile([string]$filePath) {
        $json = Get-Content -Path $filePath
        return $json | ConvertFrom-Json -AsHashtable | ForEach-Object {
            [Person]::new($_.FirstName, $_.LastName, $_.Age)
        }
    }
}