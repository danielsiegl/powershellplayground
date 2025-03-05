# Description: Pester tests for the bankholidays module

Describe "Get-AustrianBankHolidays" {
    BeforeAll { 
        . "$PSScriptRoot\..\Modules\bankholidays.ps1"   
    }
    Context "When called with valid dates" {
        It "Should return an array of holiday objects" {
           
            $result = Get-AustrianBankHolidays -StartDate "2023-01-01" -EndDate "2023-12-31"
            $result.Count | Should -Be 15
            $result[0].Date | Should -Be "2023-01-01"
        }
    }

    Context "When API call fails" {
        It "Should write an error message and return nothing" {
           
            { Get-AustrianBankHolidays -StartDate "XXX" -EndDate "2023-12-31" } | Should -Throw
        }
    }
}