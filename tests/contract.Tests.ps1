# classes/contract.Tests.ps1

Describe 'Contract Class' {
    BeforeAll {
        # Load the class definition
        # strange handling is required so it works in both environments
        # (VSCode and GitHub Actions)
        $paths = @(
            "$PSScriptRoot/classes/contract.ps1",
            "$PSScriptRoot/../classes/contract.ps1"
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
        It 'should create an instance of Contract with correct properties' {
            $schedule = @{
                Monday = @{ Start = "08:00 AM"; End = "04:00 PM" }
                Tuesday = @{ Start = "08:00 AM"; End = "04:00 PM" }
            }
            $contract = [Contract]::new("John", "Doe", "2023", 20.0, 5.0, 25.0, 10.0, $schedule)
            $contract | Should -Not -BeNull
            $contract.FirstName | Should -Be "John"
            $contract.LastName | Should -Be "Doe"
            $contract.Year | Should -Be "2023"
            $contract.MorningCostPerHour | Should -Be 20.0
            $contract.MorningGovSubsidyPerHour | Should -Be 5.0
            $contract.AfternoonCostPerHour | Should -Be 25.0
            $contract.AfternoonGovSubsidyPerHour | Should -Be 10.0
            $contract.Schedule | Should -Be $schedule
        }
    }

    Context 'Calculate Method' {
        It 'should calculate monthly costs correctly' {
            $schedule = @{
                Monday = @{ Start = "08:00 AM"; End = "04:00 PM" }
                Tuesday = @{ Start = "08:00 AM"; End = "04:00 PM" }
            }
            $contract = [Contract]::new("John", "Doe", "2023", 20.0, 5.0, 25.0, 10.0, $schedule)
            $monthlyCosts = $contract.Calculate()
            $monthlyCosts | Should -Not -BeNull
            $monthlyCosts.Count | Should -BeGreaterThan 0
        }
    }

    Context 'LoadFromFile Method' {
        It 'should load contract from file correctly' {

            # attention case sensitive on linux runner
            $paths = @(
                "$PSScriptRoot/config/contract.json",
                "$PSScriptRoot/../config/contract.json",
                "$PSScriptRoot/config/Contract.json",
                "$PSScriptRoot/../config/Contract.json"
            )

            $foundPath = $paths | Where-Object { Test-Path $_ } | Select-Object -First 1

            if ($foundPath) {
                $filePath = $foundPath
                Write-Output "File found: $filePath"
            }
            else {
                throw "File not found: $($paths -join ', ')"
            }
       
           # $filePath = "$PSScriptRoot/config/contract.json"
            $contract = [Contract]::LoadFromFile($filePath)
            $contract | Should -Not -BeNull
            $contract.FirstName | Should -Be "Daniel"
            $contract.LastName | Should -Be "Testuser"
            $contract.Year | Should -Be "2025"
        }
    }
}