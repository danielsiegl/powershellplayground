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
$start = [DateTime]::Parse("2025-03-05 08:00")
$end = [DateTime]::Parse("2025-03-05 12:00")
$parentCostPerHour = 10.00
$governmentCostPerHour = 5.50

$window = [CostWindow]::new($start, $end, $parentCostPerHour, $governmentCostPerHour)

Write-Output "Total Parent Cost: $($window.GetTotalParentCost())"
Write-Output "Total Government Cost: $($window.GetTotalGovernmentCost())"
Write-Output "Total Cost: $($window.GetTotalCost())"
