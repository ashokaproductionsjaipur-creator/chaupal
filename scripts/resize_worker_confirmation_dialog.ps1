$ErrorActionPreference = 'Stop'

$p = Join-Path (Get-Location) 'lib/pages/worker_job_feed/worker_job_feed_widget.dart'
$s = Get-Content -Raw -Encoding UTF8 $p

$start = $s.IndexOf('  Future<void> _showPendingConfirmation() async {')
$end = $s.IndexOf('  Widget _dealDetail(String icon, String label, String value) {', $start)
if ($start -lt 0 -or $end -lt 0) { throw 'Worker confirmation popup block not found.' }

$popup = $s.Substring($start, $end - $start)

$replacements = @{
  'insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),' = 'insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),'
  'constraints: const BoxConstraints(maxWidth: 520, maxHeight: 760),' = 'constraints: const BoxConstraints(maxWidth: 420, maxHeight: 590),'
  'borderRadius: BorderRadius.circular(28),' = 'borderRadius: BorderRadius.circular(22),'
  'boxShadow: const [BoxShadow(blurRadius: 28, spreadRadius: 3, offset: Offset(0, 10))],' = 'boxShadow: const [BoxShadow(blurRadius: 20, spreadRadius: 2, offset: Offset(0, 7))],'
  'padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),' = 'padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),'
  'fontSize: 30, fontWeight: FontWeight.w900' = 'fontSize: 24, fontWeight: FontWeight.w900'
  'padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),' = 'padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),'
  'height: 150,' = 'height: 90,'
  'height: 100,' = 'height: 70,'
  'const Text(\'🤝\', style: TextStyle(fontSize: 70))' = 'const Text(\'🤝\', style: TextStyle(fontSize: 42))'
  'fontSize: 19, fontWeight: FontWeight.w900' = 'fontSize: 15, fontWeight: FontWeight.w900'
  'padding: const EdgeInsets.all(15),' = 'padding: const EdgeInsets.all(10),'
  'fontSize: 18, height: 1.35, fontWeight: FontWeight.w800' = 'fontSize: 14, height: 1.25, fontWeight: FontWeight.w800'
  'height: 64,' = 'height: 52,'
  'borderRadius: BorderRadius.circular(34),' = 'borderRadius: BorderRadius.circular(28),'
  'size: 30' = 'size: 25'
  'fontSize: 21, fontWeight: FontWeight.w900' = 'fontSize: 18, fontWeight: FontWeight.w900'
  'fontSize: 14, fontWeight: FontWeight.w800' = 'fontSize: 12, fontWeight: FontWeight.w800'
}

foreach ($pair in $replacements.GetEnumerator()) {
  $popup = $popup.Replace($pair.Key, $pair.Value)
}

$s = $s.Substring(0, $start) + $popup + $s.Substring($end)
Set-Content -Path $p -Value $s -Encoding UTF8
Write-Host 'Worker confirmation popup resized only inside _showPendingConfirmation. Other job cards/posts are untouched. barrierDismissible remains false, so the popup stays until the worker presses the confirmation button.'
