$ErrorActionPreference = 'Stop'

$p = Join-Path (Get-Location) 'lib/pages/worker_job_feed/worker_job_feed_widget.dart'
if (-not (Test-Path $p)) { throw "Worker job feed file not found: $p" }

$s = Get-Content -Raw -Encoding UTF8 $p

$confirmPattern = '(?s)SizedBox\(\s*width: double\.infinity,\s*height: 45,\s*child: FilledButton\.icon\(.*?\n\s*\),\s*\n\s*\),'
$confirmReplacement = @'
SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: () => Navigator.pop(c, true),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8C00),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, size: 21),
                                SizedBox(width: 7),
                                Text('\u{938}\u{94C}\u{926}\u{93E} \u{92A}\u{915}\u{94D}\u{915}\u{93E} \u{915}\u{930}\u{947}\u{902}  \u{2192}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ),
                        ),
                      ),
'@

$s2 = [regex]::Replace($s, $confirmPattern, $confirmReplacement, 1)
if ($s2 -eq $s) { throw 'Confirm button pattern not found.' }

$cancelPattern = '(?s)SizedBox\(\s*width: double\.infinity,\s*height: 34,\s*child: OutlinedButton\(.*?\n\s*\),\s*\n\s*\),'
$cancelReplacement = @'
SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(c, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white, width: 1.5),
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
                          ),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('\u{921}\u{940}\u{932} \u{915}\u{948}\u{902}\u{938}\u{932} \u{915}\u{930}\u{947}\u{902}', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ),
'@

$s3 = [regex]::Replace($s2, $cancelPattern, $cancelReplacement, 1)
if ($s3 -eq $s2) { throw 'Cancel button pattern not found.' }

Set-Content -Path $p -Value $s3 -Encoding UTF8
Write-Host 'OK: worker confirmation buttons are mobile-safe; text scales instead of clipping.'
