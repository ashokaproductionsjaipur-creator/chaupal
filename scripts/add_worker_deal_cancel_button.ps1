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
      bool finalized = false;

      try {
        final confirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (c) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 390, maxHeight: 540),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF009C3B), Color(0xFF16A34A), Color(0xFF087F3D)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [BoxShadow(blurRadius: 22, spreadRadius: 2, offset: Offset(0, 8))],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  children: [
                    const Text(
                      '\u{905}\u{92A}\u{928}\u{93E} \u{938}\u{94C}\u{926}\u{93E} \u{92A}\u{915}\u{94D}\u{915}\u{93E} \u{915}\u{930}\u{947}\u{902}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                      decoration: BoxDecoration(color: const Color(0xFFFFF7B2), borderRadius: BorderRadius.circular(20)),
                      child: const Text(
                        '\u{915}\u{93E}\u{92E} \u{924}\u{92F} \u{939}\u{94B} \u{917}\u{92F}\u{93E} \u{939}\u{948}!',
                        style: TextStyle(color: Color(0xFF14532D), fontSize: 17, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          if ('${j['work_photo'] ?? ''}'.trim().isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: FutureBuilder<String?>(
                                future: _signed('${j['work_photo'] ?? ''}'),
                                builder: (context, snap) {
                                  if (snap.hasData) {
                                    return Image.network(
                                      snap.data!,
                                      height: 82,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const SizedBox(
                                        height: 60,
                                        child: Center(child: Icon(Icons.image_not_supported, size: 30)),
                                      ),
                                    );
                                  }
                                  return const SizedBox(height: 60, child: Center(child: CircularProgressIndicator()));
                                },
                              ),
                            ),
                          if ('${j['work_photo'] ?? ''}'.trim().isNotEmpty) const SizedBox(height: 7),
                          _dealDetail('\u{1F528}', '\u{915}\u{93E}\u{92E} \u{915}\u{93E} \u{928}\u{93E}\u{92E}', '${j['title'] ?? ''}'),
                          _dealDetail('\u{1F4B0}', '\u{924}\u{92F} \u{930}\u{915}\u{92E}', '\u{20B9}${j['final_amount'] ?? ''}'),
                          _dealDetail('\u{1F4C5}', '\u{915}\u{93E}\u{92E} \u{915}\u{940} \u{924}\u{93E}\u{930}\u{940}\u{916}', '${j['job_date'] ?? ''}'),
                          _dealDetail('\u{23F0}', '\u{938}\u{92E}\u{92F}', '${j['start_time'] ?? ''}'.split('.').first),
                          _dealDetail('\u{1F464}', '\u{92E}\u{93E}\u{932}\u{93F}\u{915} \u{915}\u{93E} \u{928}\u{93E}\u{92E}', '${j['owner_name'] ?? ''}'),
                          _dealDetail('\u{1F4DE}', '\u{92E}\u{93E}\u{932}\u{93F}\u{915} \u{915}\u{93E} \u{92E}\u{94B}\u{92C}\u{93E}\u{907}\u{932} \u{928}\u{902}\u{92C}\u{930}', '${j['owner_mobile'] ?? ''}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '\u{906}\u{92A}\u{928}\u{947} \u{92E}\u{93E}\u{932}\u{93F}\u{915} \u{938}\u{947} \u{907}\u{938} \u{915}\u{93E}\u{92E} \u{915}\u{947} \u{92C}\u{93E}\u{930}\u{947} \u{92E}\u{947}\u{902} \u{92B}\u{94B}\u{928} \u{92A}\u{930} \u{92C}\u{93E}\u{924} \u{915}\u{930} \u{932}\u{940} \u{939}\u{948} \u{914}\u{930} \u{906}\u{92A}\u{915}\u{947} \u{92C}\u{940}\u{91A} \u{930}\u{947}\u{91F} \u{92D}\u{940} \u{924}\u{92F} \u{939}\u{94B} \u{917}\u{908} \u{939}\u{948}\u{964}\n\n\u{905}\u{917}\u{930} \u{906}\u{92A} \u{907}\u{938} \u{938}\u{94C}\u{926}\u{947} \u{915}\u{94B} \u{92A}\u{915}\u{94D}\u{915}\u{93E} \u{915}\u{930}\u{928}\u{93E} \u{91A}\u{93E}\u{939}\u{924}\u{947} \u{939}\u{948}\u{902} \u{924}\u{94B} \u{928}\u{940}\u{91A}\u{947} \u{926}\u{93F}\u{90F} \u{917}\u{90F} \u{201C}\u{938}\u{94C}\u{926}\u{93E} \u{92A}\u{915}\u{94D}\u{915}\u{93E} \u{915}\u{930}\u{947}\u{902}\u{201D} \u{92C}\u{91F}\u{928} \u{915}\u{94B} \u{926}\u{92C}\u{93E}\u{90F}\u{901}\u{964}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 13.5, height: 1.25, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 9),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.pop(c, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8C00),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                        ),
                        icon: const Icon(Icons.check_circle, size: 23),
                        label: const Text('\u{938}\u{94C}\u{926}\u{93E} \u{92A}\u{915}\u{94D}\u{915}\u{93E} \u{915}\u{930}\u{947}\u{902}  \u{2192}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      '(\u{915}\u{93E}\u{92E} \u{92B}\u{93E}\u{907}\u{928}\u{932} \u{915}\u{930}\u{947}\u{902})',
                      style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 7),
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(c, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('\u{921}\u{940}\u{932} \u{915}\u{948}\u{902}\u{938}\u{932} \u{915}\u{930}\u{947}\u{902}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        if (!mounted || confirmed == null) return;

        if (confirmed) {
          await SupaFlow.client.rpc(
            'finalize_worker_job_confirmation_v2',
            params: {'p_job_id': '${j['job_id']}'},
          );
          finalized = true;
          if (!mounted) return;
          setState(() => future = _load());
        } else {
          await SupaFlow.client.rpc(
            'cancel_worker_job_confirmation',
            params: {'p_job_id': '${j['job_id']}'},
          );
          if (!mounted) return;
          setState(() => future = _load());
        }
      } finally {
        _confirmationDialogOpen = false;
      }
    } catch (e) {
      _confirmationDialogOpen = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_friendlyError(e))),
        );
      }
    }
  }


'@

$s = $s.Substring(0, $start) + $newMethod + $s.Substring($end)
Set-Content -Path $p -Value $s -Encoding UTF8

Write-Host 'OK: Worker confirmation frontend fixed with confirm + cancel flow.'
Write-Host 'No placeholder data or Base64 decoding is used.'
