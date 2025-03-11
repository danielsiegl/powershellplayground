# classes/holiday.Tests.ps1

Describe 'HoliDay Class' {
    BeforeAll {
        # Load the class definition
        . "$PSScriptRoot/../Classes/holiday.ps1"
    }
    Context 'Constructor' {
        It 'should create an instance of HoliDay with correct properties' {
            $date = Get-Date -Year 2021 -Month 1 -Day 1
            $name = "New Year's Day"
            $holiday = [HoliDay]::new($date, $name)
            $holiday | Should -Not -BeNull
            $holiday.Date | Should -Be $date
            $holiday.Name | Should -Be $name
        }
    }

    Context 'Properties' {
        It 'should allow getting and setting Date property' {
            $holiday = [HoliDay]::new((Get-Date), "Test Holiday")
            $newDate = Get-Date -Year 2022 -Month 12 -Day 25
            $holiday.Date = $newDate

            $holiday.Date | Should -Be $newDate
        }

        It 'should allow getting and setting Name property' {
            $holiday = [HoliDay]::new((Get-Date), "Test Holiday")
            $newName = "Christmas"
            $holiday.Name = $newName

            $holiday.Name | Should -Be $newName
        }
    }
}