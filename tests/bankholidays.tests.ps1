# Modules/bankholidays.Tests.ps1

Describe "Get-RestDateFormat" {
    BeforeAll {
         # Load the class definition
        # strange handling is required so it works in both environments
        # (VSCode and GitHub Actions)
        $paths = @(
            "$PSScriptRoot/functions\bankholidays.ps1",
            "$PSScriptRoot/../functions\bankholidays.ps1"
        )

        $foundPath = $paths | Where-Object { Test-Path $_ } | Select-Object -First 1

        if ($foundPath) {
            . $foundPath
        }
        else {
            throw "File not found: $($paths -join ', ')"
        }
    }
    It "should return the correct date format" {
        $result = Get-RestDateFormat
        $result | Should -Be "yyyy-MM-dd"
    }
}

Describe "Get-AustrianBankHolidays" {
    BeforeAll {
        . "$PSScriptRoot\..\functions\bankholidays.ps1"
    }
    Context "When called with valid dates" {
        It "Should return an array of holiday objects" {
            $result = Get-AustrianBankHolidays -StartDate "2023-01-01" -EndDate "2023-12-31"
            $result.Count | Should -Be 15
        }
    }

    Context "When API call fails" {
        It "Should write an error message and return nothing" {
            { Get-AustrianBankHolidays -StartDate "XXX" -EndDate "2023-12-31" } | Should -Throw
        }
    }
}