class MonthlyCost {
    [string]$Month
    [int] $Days
    [double] $TotalCost
    [double] $TotalSubsidy

    MonthlyCost([string]$month, [int]$days, [double]$totalCost, [double]$totalSubsidy) {
        $this.Month = $month
        $this.Days = $days
        $this.TotalCost = $totalCost
        $this.TotalSubsidy = $totalSubsidy
    }
}