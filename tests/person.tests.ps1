# Load the functions and class to be tested
. ./../Modules/person.ps1

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
            $json | ConvertFrom-Json | ForEach-Object {
                $_.FirstName | Should -BeExactly "Jane"
                $_.LastName | Should -BeExactly "Doe"
                $_.Age | Should -BeExactly 25
            }
            
            $personAfterLoad = [Person]::LoadFromFile($filePath)
            $personAfterLoad.FirstName | Should -BeExactly "Jane"
            $personAfterLoad.LastName | Should -BeExactly "Doe" 
            $personAfterLoad.Age | Should -BeExactly 25

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
