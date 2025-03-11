# classes/contract.Tests.ps1

Describe 'Contract Class' {
    BeforeAll {
        # Load the class definition
        . "$PSScriptRoot/../Classes/contract.ps1"
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
            $filePath = "$PSScriptRoot/../config/contract.json"
            $contract = [Contract]::LoadFromFile($filePath)
            $contract | Should -Not -BeNull
            $contract.FirstName | Should -Be "Daniel"
            $contract.LastName | Should -Be "Siegl"
            $contract.Year | Should -Be "2025"
        }
    }
}