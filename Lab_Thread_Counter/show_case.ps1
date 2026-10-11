# Usage: powershell -ExecutionPolicy Bypass -File .\show_case.ps1 4
# Prints the thread-safe run and one unsynchronized run for test case 1-7.
# Take your screenshot of this window and save it as outputs\TC4.png (etc).

param([int]$Case = 1, [string]$Class = "Sumit_Thread")

$cases = @{
  1 = @(1, 1000);   2 = @(2, 10000);  3 = @(5, 10000); 4 = @(10, 50000)
  5 = @(20, 50000); 6 = @(50, 50000); 7 = @(100, 50000)
}
$n = $cases[$Case][0]
$m = $cases[$Case][1]

foreach ($mode in @("true", "false")) {
  Write-Host "===== TC${Case}: java $Class $n $m $mode ====="
  java $Class $n $m $mode
  Write-Host ""
}
