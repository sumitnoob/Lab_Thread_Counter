# Usage: powershell -ExecutionPolicy Bypass -File .\make_tables.ps1
# Reads outputs\results.csv and writes outputs\tables.md (paste into README section 5)

$d = Import-Csv "outputs\results.csv"
$f = { param($x) '{0:N0}' -f [long]$x }
$p = { param($x) '{0:N2}' -f [double]$x }

$md = @()
$md += "### Thread-safe (AtomicLong)"
$md += ""
$md += "| Threads | Increments/thread | Expected | Static | Non-static | Abs diff | Diff % |"
$md += "| --- | --- | --- | --- | --- | --- | --- |"
foreach ($r in $d | Where-Object { $_.Safe -eq "true" }) {
  $md += "| $($r.Threads) | $(& $f $r.Increments) | $(& $f $r.Expected) | $(& $f $r.Static) | $(& $f $r.NonStatic) | $(& $f $r.AbsDiff) | $(& $p $r.DiffPct) |"
}

$md += ""
$md += "### Unsynchronized (5 runs each)"
$md += ""
$md += "| Threads | Run | Expected | Static (unsafe) | Non-static | Abs diff | Diff % |"
$md += "| --- | --- | --- | --- | --- | --- | --- |"
foreach ($r in $d | Where-Object { $_.Safe -eq "false" }) {
  $md += "| $($r.Threads) | $($r.Run) | $(& $f $r.Expected) | $(& $f $r.Static) | $(& $f $r.NonStatic) | $(& $f $r.AbsDiff) | $(& $p $r.DiffPct) |"
}

$md += ""
$md += "### Average of 5 unsynchronized runs"
$md += ""
$md += "| Threads | Avg static | Avg abs diff | Avg Diff % | Min % | Max % |"
$md += "| --- | --- | --- | --- | --- | --- |"
$unsafe = $d | Where-Object { $_.Safe -eq "false" }
foreach ($g in $unsafe | Group-Object { [int]$_.Threads } | Sort-Object { [int]$_.Name }) {
  $st  = ($g.Group | ForEach-Object { [double]$_.Static }  | Measure-Object -Average).Average
  $ad  = ($g.Group | ForEach-Object { [double]$_.AbsDiff } | Measure-Object -Average).Average
  $pc  = $g.Group | ForEach-Object { [double]$_.DiffPct } | Measure-Object -Average -Minimum -Maximum
  $md += "| $($g.Name) | $(& $f $st) | $(& $f $ad) | $(& $p $pc.Average) | $(& $p $pc.Minimum) | $(& $p $pc.Maximum) |"
}

$md | Set-Content "outputs\tables.md" -Encoding UTF8
Write-Host "Wrote outputs\tables.md"
