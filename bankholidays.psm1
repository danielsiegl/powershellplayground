# this function retrieves Austrian bank holidays from openholidaysapi.org
# and returns them as an array of objects

# PSScriptAnalyzer rule suppression
# pragma warning disable PSUseSingularNouns
function Get-AustrianBankHolidays {
    param (
        [Parameter(Mandatory=$true)]
        [string]$StartDate,

        [Parameter(Mandatory=$true)]
        [string]$EndDate
    )

    Write-Output "Getting Austrian bank holidays from $StartDate to $EndDate from openholidaysapi.org"
    $url = "https://openholidaysapi.org/PublicHolidays?countryIsoCode=AT&languageIsoCode=DE&validFrom=$StartDate&validTo=$EndDate"
    Write-Debug $url
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get
    } catch {
        Write-Error "Failed to retrieve data from API: $_"
        return
    }

    $holidayArray = @()
    $response | ForEach-Object {
        $holidayObject = [PSCustomObject]@{
            Date = [DateTime]::ParseExact($_.startDate, "yyyy-MM-dd", $null)
            Name      = $_.name.text
        }
        $holidayArray += $holidayObject
        Write-Debug "$($_.Date) - $($_.name.text)"
    }
    return $holidayArray
}