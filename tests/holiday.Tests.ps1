# classes/holiday.Tests.ps1

Describe 'HoliDay Class' {
    BeforeAll {
        # Load the class definition
        # strange handling is required so it works in both environments
        # (VSCode and GitHub Actions)
        $paths = @(
            "$PSScriptRoot/classes/holiday.ps1",
            "$PSScriptRoot/../classes/holiday.ps1"
        )

        $foundPath = $paths | Where-Object { Test-Path $_ } | Select-Object -First 1

        if ($foundPath) {
            . $foundPath
        }
        else {
            throw "File not found: $($paths -join ', ')"
        }
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