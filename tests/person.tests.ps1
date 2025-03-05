# Description: Tests for the Person class

Describe "Person Class" {
    BeforeAll { 
        . "$PSScriptRoot\..\Modules\person.ps1"   
    }
    Context "When creating a new Person object" {
        It "Should correctly assign properties" {
            $person = [Person]::new("John", "Doe", 6.0, 4.5, 5.0, 0.0)
            $person.FirstName | Should -BeExactly "John"
            $person.LastName | Should -BeExactly "Doe"
            $person.MorningCostPerHour | Should -BeExactly 6.0
            $person.MorningGovSubsidyPerHour | Should -BeExactly 4.5
            $person.AfternoonCostPerHour | Should -BeExactly 5.0
            $person.AfternoonGovSubsidyPerHour | Should -BeExactly 0.0
        }
    }

    Context "When saving a Person object to a file" {
        It "Should create a file with the correct JSON content" {
            $person = [Person]::new("Jane", "Doe", 6.0, 4.5, 5.0, 0.0)
            $filePath = "$PSScriptRoot/test_person.json"
            $person.SaveToFile($filePath)
            
            $json = Get-Content -Path $filePath -Raw
            $json | ConvertFrom-Json | ForEach-Object {
                $_.FirstName | Should -BeExactly "Jane"
                $_.LastName | Should -BeExactly "Doe"
                $_.MorningCostPerHour | Should -BeExactly 6.0
                $_.MorningGovSubsidyPerHour | Should -BeExactly 4.5
                $_.AfternoonCostPerHour | Should -BeExactly 5.0
                $_.AfternoonGovSubsidyPerHour | Should -BeExactly 0.0
            }
            
            $personAfterLoad = [Person]::LoadFromFile($filePath)
            $personAfterLoad.FirstName | Should -BeExactly "Jane"
            $personAfterLoad.LastName | Should -BeExactly "Doe"
            $personAfterLoad.MorningCostPerHour | Should -BeExactly 6.0
            $personAfterLoad.MorningGovSubsidyPerHour | Should -BeExactly 4.5
            $personAfterLoad.AfternoonCostPerHour | Should -BeExactly 5.0
            $personAfterLoad.AfternoonGovSubsidyPerHour | Should -BeExactly 0.0

            Remove-Item -Path $filePath
        }
    }

    Context "When loading a Person object from a file" {
        It "Should correctly deserialize the JSON content" {
            $json = '{"FirstName":"Alice","LastName":"Smith","MorningCostPerHour":6.0,"MorningGovSubsidyPerHour":4.5,"AfternoonCostPerHour":5.0,"AfternoonGovSubsidyPerHour":0.0}'
            $filePath = "$PSScriptRoot/test_person.json"
            Set-Content -Path $filePath -Value $json

            $person = [Person]::LoadFromFile($filePath)
            $person.FirstName | Should -BeExactly "Alice"
            $person.LastName | Should -BeExactly "Smith"
            $person.MorningCostPerHour | Should -BeExactly 6.0
            $person.MorningGovSubsidyPerHour | Should -BeExactly 4.5
            $person.AfternoonCostPerHour | Should -BeExactly 5.0
            $person.AfternoonGovSubsidyPerHour | Should -BeExactly 0.0

            Remove-Item -Path $filePath
        }
    }
}
