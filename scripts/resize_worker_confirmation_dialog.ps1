$ErrorActionPreference = 'Stop'

$p = Join-Path (Get-Location) 'lib/pages/worker_job_feed/worker_job_feed_widget.dart'
$s = Get-Content -Raw -Encoding UTF8 $p

# Compact dialog: approximately one worker job-card size.
$s = $s.Replace('insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),', 'insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),')
$s = $s.Replace('constraints: const BoxConstraints(maxWidth: 520, maxHeight: 760),', 'constraints: const BoxConstraints(maxWidth: 390, maxHeight: 540),')
$s = $s.Replace('borderRadius: BorderRadius.circular(28),', 'borderRadius: BorderRadius.circular(18),')
$s = $s.Replace('boxShadow: const [BoxShadow(blurRadius: 28, spreadRadius: 3, offset: Offset(0, 10))],', 'boxShadow: const [BoxShadow(blurRadius: 18, spreadRadius: 2, offset: Offset(0, 6))],')
$s = $s.Replace('padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),', 'padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),')
$s = $s.Replace('fontSize: 30, fontWeight: FontWeight.w900', 'fontSize: 24, fontWeight: FontWeight.w900')
$s = $s.Replace('fontSize: 21, fontWeight: FontWeight.w900', 'fontSize: 18, fontWeight: FontWeight.w900')
$s = $s.Replace('padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),', 'padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),')
$s = $s.Replace('height: 150,', 'height: 90,')
$s = $s.Replace('height: 100,', 'height: 70,')
$s = $s.Replace("const Text('🤝', style: TextStyle(fontSize: 70))", "const Text('🤝', style: TextStyle(fontSize: 42))")
$s = $s.Replace('fontSize: 19, fontWeight: FontWeight.w900', 'fontSize: 15, fontWeight: FontWeight.w900')
$s = $s.Replace('padding: const EdgeInsets.all(15),', 'padding: const EdgeInsets.all(10),')
$s = $s.Replace('fontSize: 18, height: 1.35, fontWeight: FontWeight.w800', 'fontSize: 14, height: 1.25, fontWeight: FontWeight.w800')
$s = $s.Replace('height: 64,', 'height: 52,')
$s = $s.Replace('borderRadius: BorderRadius.circular(34),', 'borderRadius: BorderRadius.circular(26),')
$s = $s.Replace('size: 30', 'size: 25')
$s = $s.Replace('fontSize: 14, fontWeight: FontWeight.w800', 'fontSize: 12, fontWeight: FontWeight.w800')

Set-Content -Path $p -Value $s -Encoding UTF8
Write-Host 'OK: confirmation popup resized to single job-card scale. It remains non-dismissible and stays open until worker confirmation.'
