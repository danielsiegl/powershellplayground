<#
.SYNOPSIS
    Compare one or more “master-data” cells (by address) between two Excel
    workbooks stored in OneDrive / Office 365 and report the differences.

.DESCRIPTION

    INstall this required PowerShell modules before running the script:

    ```powershell
    Install-Module ImportExcel -Scope CurrentUser
    Install-Module Microsoft.Graph -Scope CurrentUser    # only if you’ll use Option B
    ```
    1.  Option A – local OneDrive sync folder
        If the files are already synced to the local PC (the usual “C:\Users\<you>\OneDrive – <Org>” path),
        the script opens them directly.

    2.  Option B – Microsoft Graph download
        If you only have the HTTPS links, the script signs in (interactive,
        or device-code for unattended use), downloads each workbook to a
        temporary file, and then proceeds exactly the same way.

    In both cases the script uses Doug Finke’s ImportExcel module, so it
    **does not require Excel to be installed** on the machine running it.

.PARAMETERS
    -File1            Path or HTTPS link to the first workbook
    -File2            Path or HTTPS link to the second workbook
    -Worksheet        Name of the worksheet that contains the master data
    -Cells            One or more cell addresses to compare (e.g. 'A2','B3')
    -GraphUser        (If using Microsoft Graph) UPN of the account that owns
                      or can read the files; default is the signed-in account.
    -DownloadFolder   Local folder to hold temporary copies when downloading;
                      defaults to $env:TEMP

.OUTPUTS
    Console output + a timestamped CSV called
    Differences_<yyyy-MM-dd_HH-mm-ss>.csv in the current directory.

.EXAMPLE
    .\Compare-ExcelCells.ps1 `
        -File1 "C:\Users\Alex\OneDrive – Fabricam\MasterData\MD_2025-Q1.xlsx" `
        -File2 "C:\Users\Alex\OneDrive – Fabricam\MasterData\MD_2025-Q2.xlsx" `
        -Worksheet "MasterData" `
        -Cells "A2","B2","C2","D2"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$File1,

    [Parameter(Mandatory)]
    [string]$File2,

    [Parameter(Mandatory)]
    [string]$Worksheet,

    [Parameter(Mandatory)]
    [string[]]$Cells,

    [string]$GraphUser = $null,
    [string]$DownloadFolder = $env:TEMP
)

#----- Helper: Download an Office file from OneDrive via Microsoft Graph and
#           return the local path. Requires Microsoft.Graph module ≥2.x.
function Get-ODFile {
    param (
        [string]$Url,            # fully-qualified HTTPS link
        [string]$OutFolder,
        [string]$UserId
    )

    # Connect if not already connected
    if (-not (Get-MgContext)) {
        Write-Verbose "Connecting to Microsoft Graph…"
        Connect-MgGraph -Scopes "Files.Read.All","User.Read" | Out-Null
    }

    if (-not $UserId) { $UserId = (Get-MgContext).Account }

    # Resolve sharing link → driveItem
    $driveItem = Invoke-MgGraphRequest -Method POST `
        -Uri "https://graph.microsoft.com/v1.0/shares/u!$([Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Url)).Replace('/','_').Replace('+','-'))/driveItem"

    $downloadUrl = $driveItem.'@microsoft.graph.downloadUrl'
    if (-not $downloadUrl) { throw "Cannot obtain download URL for $Url" }

    $localPath = Join-Path $OutFolder ([IO.Path]::GetRandomFileName() + ".xlsx")
    Invoke-WebRequest -Uri $downloadUrl -OutFile $localPath
    Write-Verbose "Downloaded to $localPath"
    return $localPath
}

Write-Host "[1/5] Preparing…"

# ImportExcel is on the PowerShell Gallery
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Write-Host "Installing ImportExcel module (requires admin for system-wide)…"
    Install-Module ImportExcel -Scope CurrentUser -Force
}
Import-Module ImportExcel

# Decide whether we need to download either file
$tempFiles = @()
foreach ($ref in @("File1","File2")) {
    $val = Get-Variable -Name $ref -ValueOnly
    if ($val -match '^https://') {
        Write-Host "[2/5] Downloading $ref from OneDrive/SharePoint…"
        $local = Get-ODFile -Url $val -OutFolder $DownloadFolder -UserId $GraphUser
        Set-Variable -Name $ref -Value $local -Scope Script
        $tempFiles += $local
    }
}

#----- Open each workbook; Open-ExcelPackage returns a package object
Write-Host "[3/5] Opening workbooks…"
$wb1 = Open-ExcelPackage -Path $File1
$wb2 = Open-ExcelPackage -Path $File2

$ws1 = $wb1.Workbook.Worksheets[$Worksheet]
$ws2 = $wb2.Workbook.Worksheets[$Worksheet]

if (-not $ws1 -or -not $ws2) {
    throw "Worksheet '$Worksheet' not found in one or both workbooks."
}

#----- Compare cells
Write-Host "[4/5] Comparing cells…"
$results = foreach ($address in $Cells) {
    $v1 = ($ws1.Cells[$address]).Text
    $v2 = ($ws2.Cells[$address]).Text
    if ($v1 -ne $v2) {
        [pscustomobject]@{
            CellAddress = $address
            File1_Value = $v1
            File2_Value = $v2
        }
    }
}

if ($results) {
    $stamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
    $csv   = "Differences_$stamp.csv"
    $results | Tee-Object -Variable diffs | Export-Csv -NoTypeInformation -Path $csv
    Write-Host "[5/5] Done:"
    $diffs | Format-Table -AutoSize
    Write-Host ""
    Write-Host "Differences exported to .\${csv}"
} else {
    Write-Host "[5/5] No differences found in the specified cells ✔️"
}

#----- Clean up temp downloads
if ($tempFiles) {
    $tempFiles | ForEach-Object {
        if (Test-Path $_) { Remove-Item $_ -Force }
    }
}
