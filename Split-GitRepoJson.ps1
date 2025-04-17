# Split-GitRepoJson.ps1
# This script splits a large Git repository JSON file into 4 smaller files

param(
    [string]$InputFile = "git_repo_data.json",
    [string]$OutputPrefix = "git_repo_data_part"
)

# Function to create a new JSON file with a subset of commits
function New-GitRepoJsonFile {
    param(
        [string]$OutputFile,
        [array]$Commits,
        [object]$BaseData,
        [int]$FileNumber,
        [int]$TotalFiles
    )
    
    Write-Progress -Activity "Creating Output Files" -Status "File $FileNumber of $TotalFiles" -PercentComplete (($FileNumber / $TotalFiles) * 100)
    
    $outputData = @{
        'name' = $BaseData.name
        'branches' = $BaseData.branches
        'tags' = $BaseData.tags
        'commits' = $Commits
        'statistics' = @{
            'total_commits' = $Commits.Count
            'total_files' = $BaseData.statistics.total_files
            'total_branches' = $BaseData.statistics.total_branches
            'total_tags' = $BaseData.statistics.total_tags
        }
    }
    
    $outputData | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputFile -Encoding utf8
}

try {
    $inputFullPath = (Get-Item $InputFile).FullName
    Write-Host "Reading input file: $inputFullPath"
    Write-Progress -Activity "Reading Input File" -Status "Reading JSON data..." -PercentComplete 0

    # Read the input file with progress
    $fileSize = (Get-Item $inputFullPath).Length
    $bytesRead = 0
    $stream = [System.IO.File]::OpenRead($inputFullPath)
    $reader = [System.IO.StreamReader]::new($stream)

    $jsonContent = ""
    while (-not $reader.EndOfStream) {
        $line = $reader.ReadLine()
        $jsonContent += $line
        $bytesRead += $line.Length
        $percentComplete = ($bytesRead / $fileSize) * 100
        Write-Progress -Activity "Reading Input File" -Status "Reading JSON data..." -PercentComplete $percentComplete
    }

    $reader.Close()
    $stream.Close()
    Write-Progress -Activity "Reading Input File" -Completed

    $jsonData = $jsonContent | ConvertFrom-Json

    # Calculate the number of commits per file
    $totalCommits = $jsonData.commits.Count
    $commitsPerFile = [math]::Ceiling($totalCommits / 4)

    Write-Host "Total commits: $totalCommits"
    Write-Host "Commits per file: $commitsPerFile"

    # Split the commits into 4 parts
    $commitParts = @()
    for ($i = 0; $i -lt 4; $i++) {
        $startIndex = $i * $commitsPerFile
        $endIndex = [math]::Min(($startIndex + $commitsPerFile - 1), ($totalCommits - 1))
        $commitParts += $jsonData.commits[$startIndex..$endIndex]
    }

    # Create the output files
    for ($i = 0; $i -lt 4; $i++) {
        $outputFile = "$OutputPrefix$($i + 1).json"
        Write-Host "Creating file: $outputFile with $($commitParts[$i].Count) commits"
        New-GitRepoJsonFile -OutputFile $outputFile -Commits $commitParts[$i] -BaseData $jsonData -FileNumber ($i + 1) -TotalFiles 4
    }

    Write-Host "`nSplit complete! Created 4 files:"
    Write-Host "- $OutputPrefix`1.json ($($commitParts[0].Count) commits)"
    Write-Host "- $OutputPrefix`2.json ($($commitParts[1].Count) commits)"
    Write-Host "- $OutputPrefix`3.json ($($commitParts[2].Count) commits)"
    Write-Host "- $OutputPrefix`4.json ($($commitParts[3].Count) commits)"
}
finally {
    # Ensure progress bars are cleared even if an error occurs
    Write-Progress -Activity "Reading Input File" -Completed
    Write-Progress -Activity "Creating Output Files" -Completed
} 