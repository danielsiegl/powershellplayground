# Load the function to be tested
using module "./../bankholidays.psm1"

Describe "Get-AustrianBankHolidays" {
    Context "When called with valid dates" {
        It "Should return an array of holiday objects" {
            # Mock the Invoke-RestMethod to return a predefined response
            # Mock -CommandName Invoke-RestMethod -MockWith {
            #     return @(
            #         @{ startDate = "2023-01-01"; Name = @{ text = "Neujahr" } },
            #         @{ startDate = "2023-05-01"; Name = @{ text = "Staatsfeiertag" } },
            #         @{ startDate = "2023-12-25"; Name = @{ text = "Weihnachten" } }
            #     )
            # }

            $result = Get-AustrianBankHolidays -StartDate "2023-01-01" -EndDate "2023-12-31"
            $result.Count | Should -Be 14
            # $result[0].Date | Should -Be "2023-01-01"
        }
    }

    Context "When API call fails" {
        It "Should write an error message and return nothing" {
            # Mock the Invoke-RestMethod to throw an exception
            # Mock -CommandName Invoke-RestMethod -MockWith { throw "API call failed" }

            { Get-AustrianBankHolidays -StartDate "XXX" -EndDate "2023-12-31" } | Should -Throw
        }
    }
}