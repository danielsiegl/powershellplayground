# Load the functions and class to be tested
Import-Module ./person.psm1 -Verbose

Describe "Person Class" {
    Context "When creating a new Person object" {
        It "Should correctly assign properties" {
            $person = [Person]::new("John", "Doe", 30)
            $person.FirstName | Should -BeExactly "John"
            $person.LastName | Should -BeExactly "Doe"
            $person.Age | Should -BeExactly 30
        }
    }

    Context "When saving a Person object to a file" {
        It "Should create a file with the correct JSON content" {
            $person = [Person]::new("Jane", "Doe", 25)
            $filePath = "$PSScriptRoot/test_person.json"
            $person.SaveToFile($filePath)

            $json = Get-Content -Path $filePath -Raw
            $json | Should -Contain '"FirstName":"Jane"'
            $json | Should -Contain '"LastName":"Doe"'
            $json | Should -Contain '"Age":25'

            Remove-Item -Path $filePath
        }
    }

    Context "When loading a Person object from a file" {
        It "Should correctly deserialize the JSON content" {
            $json = '{"FirstName":"Alice","LastName":"Smith","Age":28}'
            $filePath = "$PSScriptRoot/test_person.json"
            Set-Content -Path $filePath -Value $json

            $person = [Person]::LoadFromFile($filePath)
            $person.FirstName | Should -BeExactly "Alice"
            $person.LastName | Should -BeExactly "Smith"
            $person.Age | Should -BeExactly 28

            Remove-Item -Path $filePath
        }
    }
}
