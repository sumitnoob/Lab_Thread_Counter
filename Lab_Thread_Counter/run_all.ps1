# Usage (from the Lab_Thread_Counter folder):
#   powershell -ExecutionPolicy Bypass -File .\run_all.ps1
# Runs every test case: 1 thread-safe run + 5 unsynchronized runs.
# Saves raw output to outputs\output.txt and parsed numbers to outputs\results.csv

param([string]$Class = "Sumit_Thread")

javac "$Class.java"
if ($LASTEXITCODE -ne 0) { Write-Host "Compile failed"; exit 1 }

New-Item -ItemType Directory -Force -Path outputs | Out-Null
$log = "outputs\output.txt"
"" | Set-Content $log

$cases = @(
  @{tc="TC1"; n=1;   m=1000},
  @{tc="TC2"; n=2;   m=10000},
  @{tc="TC3"; n=5;   m=10000},
  @{tc="TC4"; n=10;  m=50000},
  @{tc="TC5"; n=20;  m=50000},
  @{tc="TC6"; n=50;  m=50000},
  @{tc="TC7"; n=100; m=50000}
)

function Get-Val($out, $pattern) {
  return ($out | Select-String $pattern).Matches[0].Groups[1].Value
}

$rows = @()
foreach ($c in $cases) {
  $runs = @(@{mode="true"; run=1})
  1..5 | ForEach-Object { $runs += @{mode="false"; run=$_} }

  foreach ($r in $runs) {
    $header = "===== $($c.tc): java $Class $($c.n) $($c.m) $($r.mode)  (run $($r.run)) ====="
    $out = java $Class $c.n $c.m $r.mode
    Write-Host $header
    $out | ForEach-Object { Write-Host $_ }
    Add-Content $log $header
    Add-Content $log ($out -join "`n")
    Add-Content $log ""

    $rows += [PSCustomObject]@{
      TC        = $c.tc
      Threads   = $c.n
      Increments= $c.m
      Safe      = $r.mode
      Run       = $r.run
      Expected  = [long](Get-Val $out 'Expected count\s*:\s*(\d+)')
      Static    = [long](Get-Val $out 'Static count\s*:\s*(\d+)')
      NonStatic = [long](Get-Val $out 'Non-static total\s*:\s*(\d+)')
      AbsDiff   = [long](Get-Val $out 'Absolute diff\s*:\s*(\d+)')
      DiffPct   = [double](Get-Val $out 'Difference \(%\)\s*:\s*([\d\.]+)')
    }
  }
}

$rows | Export-Csv -NoTypeInformation -Path "outputs\results.csv"
Write-Host "`nDone. See outputs\output.txt and outputs\results.csv"
