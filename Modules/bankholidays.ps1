# this function retrieves Austrian bank holidays from openholidaysapi.org
# and returns them as an array of objects

# this function returns the date format used by the REST API
function Get-RestDateFormat {
    return "yyyy-MM-dd"
}

class HoliDayClass {
    [datetime]$Date
    [string]$Name

    HoliDayClass([datetime]$Date, [string]$Name) {
        $this.Date = $Date
        $this.Name = $Name
    }
}

# this function retrieves Austrian bank holidays from openholidaysapi.org
function Get-AustrianBankHolidays {
    # PSScriptAnalyzer rule suppression because it returns an array of objects
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', 'Get-AustrianBankHolidays')]
    param (
        [Parameter(Mandatory=$true)]
        [string]$StartDate,

        [Parameter(Mandatory=$true)]
        [string]$EndDate
    )

    Write-Output "Getting Austrian bank holidays from $StartDate to $EndDate from openholidaysapi.org"
    $url = "https://openholidaysapi.org/PublicHolidays?countryIsoCode=AT&languageIsoCode=DE&validFrom=$StartDate&validTo=$EndDate"
    Write-Output $url
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get
    } catch {
        Write-Error "Failed to retrieve data from API: $_"
        return
    }

    $dateFormat = Get-RestDateFormat
    $holidayArray = @()
    $response | ForEach-Object {

        $holidayObject = [HoliDayClass]::new([DateTime]::ParseExact($_.startDate, $dateFormat, $null), [string]$_.name.text)
        
            $holidayArray += $holidayObject
            Write-Debug "$($holidayObject.Date) - $($holidayObject.Name)"
        }
    
    return $holidayArray
}

function Get-AustrianBankHolidaysFromDateTime {
    param (
        [datetime]$startDate,
        [datetime]$endDate
    )

    $restDateFormat = Get-RestDateFormat
    $startDateString = $startDate.ToString($restDateFormat)
    $endDateString = $endDate.ToString($restDateFormat)

    return Get-AustrianBankHolidays -StartDate $startDateString -EndDate $endDateString
}