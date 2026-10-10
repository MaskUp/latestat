<#
.SYNOPSIS
  Shows the support status of the software you run, and exits 1 if anything has reached end of life.

.EXAMPLE
  .\Check-Eol.ps1 -Stack 'windows-server:2016','php:8.3.20','mysql:8.0'

.NOTES
  Works in Windows PowerShell 5.1 and PowerShell 7. Product names are the ones in
  latestat.com URLs (latestat.com/windows-server -> windows-server).
#>
param(
    [Parameter(Mandatory)]
    [string[]] $Stack
)

$report = Invoke-RestMethod -Uri ("https://latestat.com/api/stack.json?s=" + ($Stack -join ','))

$report.items |
    Select-Object @{ n = 'Product'; e = { $_.product } },
                  @{ n = 'Version'; e = { $_.version } },
                  @{ n = 'Status';  e = { $_.status } },
                  @{ n = 'Latest';  e = { $_.latest } },
                  @{ n = 'EOL';     e = { $_.eol } } |
    Format-Table -AutoSize

Write-Host "Grade: $($report.grade)  ->  $($report.url)"

if ($report.summary.eol -gt 0) {
    Write-Warning "$($report.summary.eol) item(s) have reached end of life."
    exit 1
}
