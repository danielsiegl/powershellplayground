. "$PSScriptRoot\..\classes\holiday.ps1"

function Get-RestDateFormat {
    return "yyyy-MM-dd"
}

# this function retrieves Austrian bank holidays from openholidaysapi.org
function Get-AustrianBankHolidays {
    # PSScriptAnalyzer rule suppression because it returns an array of objects
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', 'Get-AustrianBankHolidays')]
    param (
        [Parameter(Mandatory=$true)]
        [datetime]$StartDate,
        [Parameter(Mandatory=$true)]
        [datetime]$EndDate
    )

    $restDateFormat = Get-RestDateFormat
    $startDateString = $StartDate.ToString($restDateFormat)
    $endDateString = $EndDate.ToString($restDateFormat)

    Write-Output "Getting Austrian bank holidays from $startDateString to $endDateString from openholidaysapi.org"
    $url = "https://openholidaysapi.org/PublicHolidays?countryIsoCode=AT&languageIsoCode=DE&validFrom=$startDateString&validTo=$endDateString"
    Write-Output $url
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get
    } catch {
        Write-Error "Failed to retrieve data from API: $_"
        return
    }

    $holidayArray = @()
    $response | ForEach-Object {
        $holidayObject =[HoliDay]::new([datetime]$_.startDate, [string]$_.name.text)
        $holidayArray += $holidayObject
    }
    return $holidayArray
}

# Get-AustrianBankHolidays -StartDate (Get-Date -Year 2021 -Month 1 -Day 1) -EndDate (Get-Date -Year 2021 -Month 12 -Day 31)
