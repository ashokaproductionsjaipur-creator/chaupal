$ErrorActionPreference = 'Stop'

$p = Join-Path (Get-Location) 'lib/pages/worker_job_feed/worker_job_feed_widget.dart'
$s = Get-Content -Raw -Encoding UTF8 $p

$s = $s.Replace(
  'insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),',
  'insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),')
$s = $s.Replace(
  'constraints: const BoxConstraints(maxWidth: 520, maxHeight: 760),',
  'constraints: const BoxConstraints(maxWidth: 410, maxHeight: 560),')
s = $s.Replace(
  'borderRadius: BorderRadius.circular(28),',
  'borderRadius: BorderRadius.circular(20),')
s = $s.Replace(
  'boxShadow: const [BoxShadow(blurRadius: 28, spreadRadius: 3, offset: Offset(0, 10))],',
  'boxShadow: const [BoxShadow(blurRadius: 18, spreadRadius: 2, offset: Offset(0, 6))],')
s = $s.Replace(
  'padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),',
  'padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),')
s = $s.Replace(
  'fontSize: 30, fontWeight: FontWeight.w900',
  'fontSize: 23, fontWeight: FontWeight.w900')
s = $s.Replace(
  'padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),',
  'padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),')
s = $s.Replace(
  'fontSize: 21, fontWeight: FontWeight.w900',
  'fontSize: 16, fontWeight: FontWeight.w900')
s = $s.Replace(
  'height: 150,',
  'height: 82,')
s = $s.Replace(
  'height: 100,',
  'height: 58,')
s = $s.Replace(
  "const Text('🤝', style: TextStyle(fontSize: 70))",
  "const Text('🤝', style: TextStyle(fontSize: 40))")
s = $s.Replace(
  'fontSize: 19, fontWeight: FontWeight.w900',
  'fontSize: 14, fontWeight: FontWeight.w900')
s = $s.Replace(
  'padding: const EdgeInsets.all(15),',
  'padding: const EdgeInsets.all(9),')
s = $s.Replace(
  'fontSize: 18, height: 1.35, fontWeight: FontWeight.w800',
  'fontSize: 13, height: 1.2, fontWeight: FontWeight.w800')
s = $s.Replace(
  'height: 64,',
  'height: 50,')
s = $s.Replace(
  'borderRadius: BorderRadius.circular(34),',
  'borderRadius: BorderRadius.circular(26),')
s = $s.Replace(
  'size: 30',
  'size: 24')
s = $s.Replace(
  'fontSize: 21, fontWeight: FontWeight.w900',
  'fontSize: 17, fontWeight: FontWeight.w900')
s = $s.Replace(
  'fontSize: 14, fontWeight: FontWeight.w800',
  'fontSize: 11, fontWeight: FontWeight.w800')

Set-Content -Path $p -Value $s -Encoding UTF8
Write-Host 'Worker confirmation popup resized to compact job-card scale; it stays open until the worker presses the confirmation button.'
