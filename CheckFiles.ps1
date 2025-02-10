Import-Module Pester
Get-ChildItem -Path . -Recurse 
Test-Path ./person.ps1 | Should -Be $true
Test-Path ./tests/person.tests.ps1 | Should -Be $true
Test-Path ./bankholidays.ps1 | Should -Be $true
Test-Path ./tests/bankholidays.tests.ps1 | Should -Be $true