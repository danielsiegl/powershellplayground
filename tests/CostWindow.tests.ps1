# # Description: This file contains the tests for the CostWindow class

# Describe "CostWindow Class" {
#     BeforeAll {
#         . "$PSScriptRoot\..\Modules\CostWindow.ps1"
#     }
#     # Test for constructor
#     It "should return 17.5 when start is 2025-03-05 08:00 and end is 2025-03-05 15:00" {
#         $start = [DateTime]::Parse("2025-03-05 08:00")
#         $end = [DateTime]::Parse("2025-03-05 15:00")
#         $morningRate = 6
#         $afternoonRate = 5
#         $morningGovSubsidy = 4.5
#         $afternoonGovSubsidy = 0

#         $costWindow = [CostWindow]::new($start, $end, $morningRate, $afternoonRate, $morningGovSubsidy, $afternoonGovSubsidy)
#         $costWindow.GetTotalCost() | Should -Be 17.5
#         $costWindow.GetTotalSubsidy() | Should -Be 22.5
#     }
# }