class CostWindow {
    [DateTime]$StartTime
    [DateTime]$EndTime
    [double]$ParentCostPerHour
    [double]$GovernmentCostPerHour
    
    CostWindow([DateTime]$start, [DateTime]$end, [double]$parentCost, [double]$govCost) {
        if ($end -le $start) {
            throw "End time must be after start time."
        }
        $this.StartTime = $start
        $this.EndTime = $end
        $this.ParentCostPerHour = $parentCost
        $this.GovernmentCostPerHour = $govCost
    }
    
    [double] GetTotalParentCost() {
        $duration = ($this.EndTime - $this.StartTime).TotalHours
        return [math]::Round($duration * $this.ParentCostPerHour, 2)
    }
    
    [double] GetTotalGovernmentCost() {
        $duration = ($this.EndTime - $this.StartTime).TotalHours
        return [math]::Round($duration * $this.GovernmentCostPerHour, 2)
    }
    
    [double] GetTotalCost() {
        return $this.GetTotalParentCost() + $this.GetTotalGovernmentCost()
    }
}

# Example usage:
#morning cost
$start = [DateTime]::Parse("2025-03-05 08:00")
$end = [DateTime]::Parse("2025-03-05 13:00")
$parentCostPerHour = 1.50
$governmentCostPerHour = 4.50
$MorningCost = [CostWindow]::new($start, $end, $parentCostPerHour, $governmentCostPerHour)

#afternoon cost
$start = [DateTime]::Parse("2025-03-05 13:00")
$end = [DateTime]::Parse("2025-03-05 15:00")
$parentCostPerHour = 5.00
$governmentCostPerHour = 0.00
$AfternoonCost = [CostWindow]::new($start, $end, $parentCostPerHour, $governmentCostPerHour)

$overallParentCost = $MorningCost.GetTotalParentCost() + $AfternoonCost.GetTotalParentCost()
$overallGovernmentCost = $MorningCost.GetTotalGovernmentCost() + $AfternoonCost.GetTotalGovernmentCost()
$overallTotalCost = $MorningCost.GetTotalCost() + $AfternoonCost.GetTotalCost()

Write-Output "Morning Parent Cost: $($MorningCost.GetTotalParentCost())"
Write-Output "Morning Government Cost: $($MorningCost.GetTotalGovernmentCost())"
Write-Output "Afternoon Parent Cost: $($AfternoonCost.GetTotalParentCost())"
Write-Output "*************************************************************"
Write-Output "Overall Parent Cost: $overallParentCost"
Write-Output "Overall Government Cost: $overallGovernmentCost"
Write-Output "Overall Total Cost: $overallTotalCost"

