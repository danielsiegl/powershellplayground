# # Description: Tests for the Person class

# Describe "Person Class" {
#     BeforeAll {
#         . "$PSScriptRoot\..\Modules\person.ps1"
#     }
#     Context "When creating a new Person object" {
#         It "Should correctly assign properties" {
#             $person = [Person]::new("John", "Doe", 6.0, 4.5, 5.0, 0.0,
#                 [ordered]@{
#                     Monday    = [PSCustomObject]@{ Start = "08:00 AM"; End = "03:00 PM" }
#                     Tuesday   = [PSCustomObject]@{ Start = "08:00 AM"; End = "03:00 PM" }
#                     Wednesday = [PSCustomObject]@{ Start = "08:00 AM"; End = "03:00 PM" }
#                     Thursday  = [PSCustomObject]@{ Start = "08:00 AM"; End = "03:00 PM" }
#                 })
#             $person.FirstName | Should -BeExactly "John"
#             $person.LastName | Should -BeExactly "Doe"
#             $person.MorningCostPerHour | Should -BeExactly 6.0
#             $person.MorningGovSubsidyPerHour | Should -BeExactly 4.5
#             $person.AfternoonCostPerHour | Should -BeExactly 5.0
#             $person.AfternoonGovSubsidyPerHour | Should -BeExactly 0.0
#         }
#     }

#     Context "When loading a Person object from a file" {
#         It "Should correctly deserialize the JSON content" {
#             $json = '{"FirstName":"Alice","LastName":"Smith","MorningCostPerHour":6.0,"MorningGovSubsidyPerHour":4.5,"AfternoonCostPerHour":5.0,"AfternoonGovSubsidyPerHour":0.0}'
#             $filePath = "$PSScriptRoot/test_person.json"
#             Set-Content -Path $filePath -Value $json

#             $person = [Person]::LoadFromFile($filePath)
#             $person.FirstName | Should -BeExactly "Alice"
#             $person.LastName | Should -BeExactly "Smith"
#             $person.MorningCostPerHour | Should -BeExactly 6.0
#             $person.MorningGovSubsidyPerHour | Should -BeExactly 4.5
#             $person.AfternoonCostPerHour | Should -BeExactly 5.0
#             $person.AfternoonGovSubsidyPerHour | Should -BeExactly 0.0

#             Remove-Item -Path $filePath
#         }
#     }
# }
