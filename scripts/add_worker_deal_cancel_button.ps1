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

$newMethod = @'
  Future<void> _showPendingConfirmation() async {
    if (!mounted || currentUserUid.isEmpty || _confirmationDialogOpen) return;

    try {
      final rows = await SupaFlow.client.rpc('get_pending_worker_confirmation_details');
      final list = List<Map<String, dynamic>>.from(rows as List);
      if (!mounted || list.isEmpty || _confirmationDialogOpen) return;

      final j = list.first;
      _confirmationDialogOpen = true;

      try {
        final confirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (c) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 390, maxHeight: 540),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF009C3B), Color(0xFF16A34A), Color(0xFF087F3D)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [BoxShadow(blurRadius: 18, spreadRadius: 2, offset: Offset(0, 6))],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '\u{0905}\u{092A}\u{0928}\u{093E} \u{0938}\u{094C}\u{0926}\u{093E} \u{092A}\u{0915}\u{094D}\u{0915}\u{093E} \u{0915}\u{0930}\u{0947}\u{0902}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(color: const Color(0xFFFFF7B2), borderRadius: BorderRadius.circular(20)),
                      child: const Text(
                        '\u{0915}\u{093E}\u{092E} \u{0924}\u{092F} \u{0939}\u{094B} \u{0917}\u{092F}\u{093E} \u{0939}\u{0948}!',
                        style: TextStyle(color: Color(0xFF14532D), fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                      child: Column(
                        children: [
                          if ('${j['work_photo'] ?? ''}'.trim().isNotEmpty) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: FutureBuilder<String?>(
                                future: _signed('${j['work_photo'] ?? ''}'),
                                builder: (context, snap) {
                                  if (snap.hasData) {
                                    return Image.network(
                                      snap.data!,
                                      height: 90,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const SizedBox(
                                        height: 70,
                                        child: Center(child: Icon(Icons.image_not_supported, size: 34)),
                                      ),
                                    );
                                  }
                                  return const SizedBox(height: 70, child: Center(child: CircularProgressIndicator()));
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          _dealDetail('\u{1F528}', '\u{0915}\u{093E}\u{092E} \u{0915}\u{093E} \u{0928}\u{093E}\u{092E}', '${j['title'] ?? ''}'),
                          _dealDetail('\u{1F4B0}', '\u{0924}\u{092F} \u{0930}\u{0915}\u{092E}', '\u{20B9}${j['final_amount'] ?? ''}'),
                          _dealDetail('\u{1F4C5}', '\u{0915}\u{093E}\u{092E} \u{0915}\u{0940} \u{0924}\u{093E}\u{0930}\u{0940}\u{0916}', '${j['job_date'] ?? ''}'),
                          _dealDetail('\u{23F0}', '\u{0938}\u{092E}\u{092F}', '${j['start_time'] ?? ''}'.split('.').first),
                          _dealDetail('\u{1F464}', '\u{092E}\u{093E}\u{0932}\u{093F}\u{0915} \u{0915}\u{093E} \u{0928}\u{093E}\u{092E}', '${j['owner_name'] ?? ''}'),
                          _dealDetail('\u{1F4DE}', '\u{092E}\u{093E}\u{0932}\u{093F}\u{0915} \u{0915}\u{093E} \u{092E}\u{094B}\u{092C}\u{093E}\u{0907}\u{0932} \u{0928}\u{0902}\u{092C}\u{0930}', '${j['owner_mobile'] ?? ''}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('\u{1F91D}', style: TextStyle(fontSize: 42)),
                    const Text('\u{0906}\u{092A}\u{0915}\u{093E} \u{092D}\u{0930}\u{094B}\u{0938}\u{093E}  \u{2022}  \u{0939}\u{092E}\u{093E}\u{0930}\u{0940} \u{0938}\u{093E}\u{091D}\u{0947}\u{0926}\u{093E}\u{0930}\u{0940}', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFFFFFDE7), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFFD54F), width: 2)),
                      child: const Text(
                        '\u{0906}\u{092A}\u{0928}\u{0947} \u{092E}\u{093E}\u{0932}\u{093F}\u{0915} \u{0938}\u{0947} \u{0907}\u{0938} \u{0915}\u{093E}\u{092E} \u{0915}\u{0947} \u{092C}\u{093E}\u{0930}\u{0947} \u{092E}\u{0947}\u{0902} \u{092B}\u{094B}\u{0928} \u{092A}\u{0930} \u{092C}\u{093E}\u{0924} \u{0915}\u{0930} \u{0932}\u{0940} \u{0939}\u{0948} \u{0914}\u{0930} \u{0906}\u{092A}\u{0915}\u{0947} \u{092C}\u{0940}\u{091A} \u{0930}\u{0947}\u{091F} \u{092D}\u{0940} \u{0924}\u{092F} \u{0939}\u{094B}\u{0917}\u{0908} \u{0939}\u{0948}\u{0964}\n\n\u{0905}\u{0917}\u{0930} \u{0906}\u{092A} \u{0907}\u{0938} \u{0938}\u{094C}\u{0926}\u{0947} \u{0915}\u{094B} \u{092A}\u{0915}\u{0915}\u{093E} \u{0915}\u{0930}\u{0928}\u{093E} \u{091A}\u{093E}\u{0939}\u{0924}\u{0947} \u{0939}\u{0948}\u{0902} \u{0924}\u{094B} \u{0928}\u{0940}\u{091A}\u{0947} \u{0926}\u{093F}\u{090F} \u{0917}\u{090F} \u{201C}\u{0938}\u{094C}\u{0926}\u{093E} \u{092A}\u{0915}\u{094D}\u{0915}\u{093E} \u{0915}\u{0930}\u{0947}\u{0902}\u{201D} \u{092C}\u{091F}\u{0928} \u{0915}\u{094B} \u{0926}\u{092C}\u{093E}\u{090F}\u{0901} \u{0964}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black87, fontSize: 14, height: 1.25, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.pop(c, true),
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF8C00), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))),
                        icon: const Icon(Icons.check_circle, size: 25),
                        label: const Text('\u{0938}\u{094C}\u{0926}\u{093E} \u{092A}\u{0915}\u{094D}\u{0915}\u{093E} \u{0915}\u{0930}\u{0947}\u{0902}  \u{2192}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('(\u{0915}\u{093E}\u{092E} \u{092B}\u{093E}\u{0907}\u{0928}\u{0932} \u{0915}\u{0930}\u{0947}\u{0902})', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(c, false),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
                        icon: const Icon(Icons.cancel_outlined, size: 21),
                        label: const Text('\u{0921}\u{0940}\u{0932} \u{0915}\u{0948}\u{0902}\u{0938}\u{0932} \u{0915}\u{0930}\u{0947}\u{0902}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        if (!mounted || confirmed == null) return;

        if (confirmed == false) {
          await SupaFlow.client.rpc(
            'cancel_worker_job_confirmation',
            params: {'p_job_id': '${j['job_id']}'},
          );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('\u{0921}\u{0940}\u{0932} \u{0915}\u{0948}\u{0902}\u{0938}\u{0932} \u{0915}\u{0930} \u{0926}\u{0940}\u{0917}\u{0908}\u{0964} \u{092F}\u{0939} \u{091C}\u{0949}\u{092C} \u{0905}\u{092C} \u{092B}\u{093F}\u{0930} \u{0938}\u{0947} \u{0909}\u{092A}\u{0932}\u{092C}\u{094D}\u{0927} \u{0939}\u{0948}\u{0964}'),
          );
          setState(() => future = _load());
          return;
        }

        await SupaFlow.client.rpc(
          'finalize_worker_job_confirmation_v2',
          params: {'p_job_id': '${j['job_id']}'},
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('\u{0915}\u{093E}\u{092E} \u{092A}\u{0915}\u{094D}\u{0915}\u{093E} \u{0939}\u{094B} \u{0917}\u{092F}\u{093E} \u{0964} \u{0907}\u{0938} \u{0924}\u{093E}\u{0930}\u{0940}\u{0916} \u{0915}\u{0940} \u{0926}\u{0942}\u{0938}\u{0930}\u{0940} \u{091C}\u{0949}\u{092C} \u{0905}\u{092C} \u{0928}\u{0939}\u{0940}\u{0902} \u{0932}\u{0940}\u{091C}\u{093E} \u{0938}\u{0915}\u{0924}\u{0940} \u{0964}'),
        );
        setState(() => future = _load());
      } finally {
        _confirmationDialogOpen = false;
      }
    } catch (e) {
      _confirmationDialogOpen = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_friendlyError(e))));
      }
    }
  }

'@

$s = $s.Substring(0, $start) + $newMethod + $s.Substring($end)
Set-Content -Path $p -Value $s -Encoding UTF8
Write-Host 'OK: Worker confirmation popup fixed. Hindi is UTF-8 safe, and Confirm/Cancel use separate backend paths.'
Write-Host 'Cancel -> cancel_worker_job_confirmation; Confirm -> finalize_worker_job_confirmation_v2.'
