class CostWindow {
    [DateTime]$StartTime
    [DateTime]$EndTime
    [double]$MorningCostPerHour
    [double]$AfternoonCostPerHour
    [double]$MorningGovSubsidyPerHour
    [double]$AfternoonGovSubsidyPerHour
    [double]$TotalSubsidy
    
    CostWindow([DateTime]$start, [DateTime]$end, [double]$morningCost, [double]$afternoonCost, [double]$morningGovSubsidy, [double]$afternoonGovSubsidy) {
        if ($end -le $start) {
            throw "End time must be after start time."
        }
        $this.StartTime = $start
        $this.EndTime = $end
        $this.MorningCostPerHour = $morningCost
        $this.AfternoonCostPerHour = $afternoonCost
        $this.MorningGovSubsidyPerHour = $morningGovSubsidy
        $this.AfternoonGovSubsidyPerHour = $afternoonGovSubsidy
    }
    
    [double] GetTotalCost() {
        $totalCost = 0
        $totalSub = 0
        $current = $this.StartTime
        while ($current -lt $this.EndTime) {
            $nextHour = $current.AddHours(1)
            if ($current.Hour -ge 8 -and $current.Hour -lt 13) {
                # Morning pricing with optional government subsidy
                $cost = $this.MorningCostPerHour - $this.MorningGovSubsidyPerHour
                $totalCost += [math]::Min(($this.EndTime - $current).TotalHours, 1) * [math]::Max($cost, 0)
                $totalSub += [math]::Min(($this.EndTime - $current).TotalHours, 1) * $this.MorningGovSubsidyPerHour
            } elseif ($current.Hour -ge 13 -and $current.Hour -lt 15) {
                # Afternoon pricing with optional government subsidy
                $cost = $this.AfternoonCostPerHour - $this.AfternoonGovSubsidyPerHour
                $totalCost += [math]::Min(($this.EndTime - $current).TotalHours, 1) * [math]::Max($cost, 0)
                $totalSub += [math]::Min(($this.EndTime - $current).TotalHours, 1) * $this.AfternoonGovSubsidyPerHour
            }
            $current = $nextHour
        }
        $this.TotalSubsidy = [math]::Round($totalSub, 2)
        return [math]::Round($totalCost, 2)
    }
    
    [double] GetTotalSubsidy() {
        return $this.TotalSubsidy
    }
}

# Example usage:
$start = [DateTime]::Parse("2025-03-05 08:00")
$end = [DateTime]::Parse("2025-03-05 15:00")
$morningRate = 6
$afternoonRate = 5
$morningGovSubsidy = 4.5
$afternoonGovSubsidy = 0

$costWindow = [CostWindow]::new($start, $end, $morningRate, $afternoonRate, $morningGovSubsidy, $afternoonGovSubsidy)
Write-Output "Total Cost: $($costWindow.GetTotalCost())"
Write-Output "Total Government Subsidy: $($costWindow.GetTotalSubsidy())"