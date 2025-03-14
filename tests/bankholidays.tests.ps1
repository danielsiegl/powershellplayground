# # Modules/bankholidays.Tests.ps1

# Describe "Get-RestDateFormat" {
#     BeforeAll {
#         . "$PSScriptRoot\..\Modules\bankholidays.ps1"
#     }
#     It "should return the correct date format" {
#         $result = Get-RestDateFormat
#         $result | Should -Be "yyyy-MM-dd"
#     }
# }

# Describe "HoliDayClass" {
#     BeforeAll {
#         . "$PSScriptRoot\..\Modules\bankholidays.ps1"
#     }
#     It "should create an object with the correct properties" {
#         $date = [datetime]"2023-12-25"
#         $name = "Christmas Day"
#         $holiday = [HoliDayClass]::new($date, $name)

#         $holiday.Date | Should -Be $date
#         $holiday.Name | Should -Be $name
#     }
# }

# Describe "Get-AustrianBankHolidays" {
#     BeforeAll {
#         . "$PSScriptRoot\..\Modules\bankholidays.ps1"
#     }
#     Context "When called with valid dates" {
#         It "Should return an array of holiday objects" {
#             $result = Get-AustrianBankHolidays -StartDate "2023-01-01" -EndDate "2023-12-31"
#             $result.Count | Should -Be 15
#         }
#     }

#     Context "When API call fails" {
#         It "Should write an error message and return nothing" {
#             { Get-AustrianBankHolidays -StartDate "XXX" -EndDate "2023-12-31" } | Should -Throw
#         }
#     }
# }