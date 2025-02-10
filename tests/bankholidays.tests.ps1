# Load the function to be tested
.   "$PSScriptRoot/../bankholidays.ps1"
Describe "Get-AustrianBankHolidays" {
  
    Context "When called with valid dates" {
        It "Should return an array of holiday objects" {
            # Mock the Invoke-RestMethod to return a predefined response
            Mock -CommandName Invoke-RestMethod -MockWith {
                return @(
                    @{ startDate = "2023-01-01"; name = @{ text = "Neujahr" } },
                    @{ startDate = "2023-05-01"; name = @{ text = "Staatsfeiertag" } },
                    @{ startDate = "2023-12-25"; name = @{ text = "Weihnachten" } }
                )
            }

            $result = Get-AustrianBankHolidays -StartDate "2023-01-01" -EndDate "2023-12-31"
            $result | Should -BeOfType 'System.Object[]'
            $result.Count | Should -Be 3
            $result[0].Name | Should -Be "Neujahr"
            $result[1].Name | Should -Be "Staatsfeiertag"
            $result[2].Name | Should -Be "Weihnachten"
        }
    }

    Context "When API call fails" {
        It "Should write an error message and return nothing" {
            # Mock the Invoke-RestMethod to throw an exception
            Mock -CommandName Invoke-RestMethod -MockWith { throw "API call failed" }

            { Get-AustrianBankHolidays -StartDate "2023-01-01" -EndDate "2023-12-31" } | Should -Throw
        }
    }
}
