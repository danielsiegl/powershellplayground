function Get-AustrianBankHolidays {
    param (
        [Parameter(Mandatory=$true)]
        [string]$StartDate,

        [Parameter(Mandatory=$true)]
        [string]$EndDate
    )

    Write-Output "Getting Austrian bank holidays from $StartDate to $EndDate"
    $url = "https://openholidaysapi.org/PublicHolidays?countryIsoCode=AT&languageIsoCode=DE&validFrom=$StartDate&validTo=$EndDate"
    Write-Output $url
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get
    } catch {
        Write-Error "Failed to retrieve data from API: $_"
        return
    }
    
    $holidayArray = @()
    $response | ForEach-Object {
        $holidayObject = [PSCustomObject]@{
            StartDate = [DateTime]::ParseExact($_.startDate, "yyyy-MM-dd", $null)
            EndDate   = [DateTime]::ParseExact($_.endDate, "yyyy-MM-dd", $null)
            Name      = $_.name.text
        }
        $holidayArray += $holidayObject
        Write-Output "$($_.startDate) - $($_.endDate) - $($_.name.text)"
    }
    return $holidayArray
}