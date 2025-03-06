# generateWorkdaysReport.ps1

. ./Modules/workday.ps1

$workdaysByMonth = Get-Content -Path "data/workdaysByMonth.json" | ConvertFrom-Json

$output = "| Month       | Workdays |\n|-------------|----------|\n"
foreach ($month in $workdaysByMonth) {
    $output += "| $($month.Month) | $($month.Count) |\n"
}

$output | Set-Content -Path "output.md"