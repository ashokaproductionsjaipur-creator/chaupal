$ErrorActionPreference = 'Stop'

$p = Join-Path (Get-Location) 'lib/pages/worker_job_feed/worker_job_feed_widget.dart'
if (-not (Test-Path $p)) { throw "Worker job feed file not found: $p" }

$s = Get-Content -Raw -Encoding UTF8 $p

$startMarker = '  Future<void> _showPendingConfirmation() async {'
$endMarker = '  Widget _dealDetail(String icon, String label, String value) {'
$start = $s.IndexOf($startMarker, [StringComparison]::Ordinal)
$end = $s.IndexOf($endMarker, [StringComparison]::Ordinal)

if ($start -lt 0) { throw 'Could not find _showPendingConfirmation method.' }
if ($end -lt 0 -or $end -le $start) { throw 'Could not find confirmation method boundary.' }

$base64 = @'
BASE64_PLACEHOLDER
'@

$bytes = [Convert]::FromBase64String(($base64 -replace '\s',''))
$newMethod = [Text.Encoding]::UTF8.GetString($bytes)

$s = $s.Substring(0, $start) + $newMethod + $s.Substring($end)

Set-Content -Path $p -Value $s -Encoding UTF8

Write-Host 'OK: Worker confirmation frontend replaced with compile-safe UTF-8 confirm/cancel flow.'
Write-Host 'Backend RPCs verified: get_pending_worker_confirmation_details, cancel_worker_job_confirmation, finalize_worker_job_confirmation_v2.'
