# Modules/bankholidays.Tests.ps1

Describe "Get-RestDateFormat" {
    BeforeAll { 
        . "$PSScriptRoot\..\Modules\bankholidays.ps1"   
    }
    It "should return the correct date format" {
        $result = Get-RestDateFormat
        $result | Should -Be "yyyy-MM-dd"
    }
}

Describe "HoliDayClass" {
    BeforeAll { 
        . "$PSScriptRoot\..\Modules\bankholidays.ps1"   
    }
    It "should create an object with the correct properties" {
        $date = [datetime]"2023-12-25"
        $name = "Christmas Day"
        $holiday = [HoliDayClass]::new($date, $name)

        $holiday.Date | Should -Be $date
        $holiday.Name | Should -Be $name
    }
}

Describe "Get-AustrianBankHolidays" {
    BeforeAll { 
        . "$PSScriptRoot\..\Modules\bankholidays.ps1"   
    }
    Context "When called with valid dates" {
        It "Should return an array of holiday objects" {
           
            $result = Get-AustrianBankHolidays -StartDate "2023-01-01" -EndDate "2023-12-31"
            $result.Count | Should -Be 15

            # $result[0] | Should -BeOfType HoliDayClass
            # $result[0].Date | Should -Be "2023-01-01"
            # [HoliDayClass]$result[0] | Should -BeOfType HoliDayClass
            # $result[0].Date | Should -Be "2023-01-01"
        }
    }

    Context "When API call fails" {
        It "Should write an error message and return nothing" {
           
            { Get-AustrianBankHolidays -StartDate "XXX" -EndDate "2023-12-31" } | Should -Throw
        }
    }
}

Describe "Get-AustrianBankHolidays" {
    BeforeAll { 
        . "$PSScriptRoot\..\Modules\bankholidays.ps1"   
    }
    Mock -CommandName Invoke-RestMethod -MockWith {
        return @(
            @{ startDate = "2023-12-25"; name = @{ text = "Christmas Day" } },
            @{ startDate = "2023-01-01"; name = @{ text = "New Year's Day" } }
        )
    }

    It "should retrieve and parse holidays correctly" {
        $startDate = "2023-01-01"
        $endDate = "2023-12-31"
        $holidays = Get-AustrianBankHolidays -StartDate $startDate -EndDate $endDate

        $holidays.Count | Should -Be 2

        $holidays[0].Date | Should -Be ([datetime]"2023-12-25")
        $holidays[0].Name | Should -Be "Christmas Day"

        $holidays[1].Date | Should -Be ([datetime]"2023-01-01")
        $holidays[1].Name | Should -Be "New Year's Day"
    }

    It "should handle API errors gracefully" {
        Mock -CommandName Invoke-RestMethod -MockWith { throw "API error" }

        { Get-AustrianBankHolidays -StartDate "2023-01-01" -EndDate "2023-12-31" } | Should -Throw
    }
}