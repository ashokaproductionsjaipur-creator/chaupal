$ErrorActionPreference = 'Stop'

$p = Join-Path (Get-Location) 'lib/pages/worker_job_feed/worker_job_feed_widget.dart'
if (-not (Test-Path $p)) { throw "Worker job feed file not found: $p" }
$s = Get-Content -Raw -Encoding UTF8 $p

# Do not depend on indentation, whitespace, or the exact generated FlutterFlow formatting.
# Replace the complete confirmation method between its stable method markers.
$startMarker = '  Future<void> _showPendingConfirmation() async {'
$endMarker = '  Widget _dealDetail(String icon, String label, String value) {'
$start = $s.IndexOf($startMarker, [StringComparison]::Ordinal)
$end = $s.IndexOf($endMarker, [StringComparison]::Ordinal)

if ($start -lt 0) { throw 'Could not find _showPendingConfirmation method.' }
if ($end -lt 0 -or $end -le $start) { throw 'Could not find the method boundary after _showPendingConfirmation.' }

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
                boxShadow: const [
                  BoxShadow(blurRadius: 18, spreadRadius: 2, offset: Offset(0, 6)),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'अपना सौदा पक्का करें',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7B2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'काम तय हो गया है!',
                        style: TextStyle(color: Color(0xFF14532D), fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
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
                                  return const SizedBox(
                                    height: 70,
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          _dealDetail('🔨', 'काम का नाम', '${j['title'] ?? ''}'),
                          _dealDetail('💰', 'तय रकम', '₹${j['final_amount'] ?? ''}'),
                          _dealDetail('📅', 'काम की तारीख', '${j['job_date'] ?? ''}'),
                          _dealDetail('⏰', 'समय', '${j['start_time'] ?? ''}'.split('.').first),
                          _dealDetail('👤', 'मालिक का नाम', '${j['owner_name'] ?? ''}'),
                          _dealDetail('📞', 'मालिक का मोबाइल नंबर', '${j['owner_mobile'] ?? ''}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('🤝', style: TextStyle(fontSize: 42)),
                    const Text(
                      'आपका भरोसा  •  हमारी साझेदारी',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFDE7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                      ),
                      child: const Text(
                        'आपने मालिक से इस काम के बारे में फोन पर बात कर ली है और आपके बीच रेट भी तय हो गई है।\n\nअगर आप इस सौदे को पक्का करना चाहते हैं तो नीचे दिए गए “सौदा पक्का करें” बटन को दबाएँ।',
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
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8C00),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                        ),
                        icon: const Icon(Icons.check_circle, size: 25),
                        label: const Text(
                          'सौदा पक्का करें  →',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '(काम फाइनल करें)',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(c, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        ),
                        icon: const Icon(Icons.cancel_outlined, size: 21),
                        label: const Text(
                          'डील कैंसल करें',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                        ),
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
            const SnackBar(content: Text('डील कैंसल कर दी गई। यह जॉब अब फिर से उपलब्ध है।')),
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
          const SnackBar(content: Text('काम पक्का हो गया। इस तारीख की दूसरी जॉब अब नहीं ली जा सकती।')),
        );
        setState(() => future = _load());
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
Write-Host 'OK: worker confirmation method replaced safely with confirm + cancel flow.'
Write-Host 'Cancel uses cancel_worker_job_confirmation; finalize is called only when confirmed == true.'