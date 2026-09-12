from pathlib import Path

p = Path('lib/pages/worker_job_feed/worker_job_feed_widget.dart')
if not p.exists():
    raise SystemExit(f'Worker job feed file not found: {p}')

s = p.read_text(encoding='utf-8')
start_marker = "  Future<void> _showPendingConfirmation() async {"
end_marker = "  Widget _dealDetail(String icon, String label, String value) {"
start = s.find(start_marker)
end = s.find(end_marker)
if start < 0 or end <= start:
    raise SystemExit('Could not find confirmation method boundary.')

new_method = r'''  Future<void> _showPendingConfirmation() async {
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
          builder: (c) {
            final screenHeight = MediaQuery.sizeOf(c).height;
            final dialogHeight = (screenHeight * 0.82).clamp(420.0, 620.0).toDouble();
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Container(
                constraints: BoxConstraints(maxWidth: 390, maxHeight: dialogHeight),
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
                  padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
                  child: Column(
                    children: [
                      const Text('अपना सौदा पक्का करें', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFFFF7B2), borderRadius: BorderRadius.circular(20)),
                        child: const Text('काम तय हो गया है!', style: TextStyle(color: Color(0xFF14532D), fontSize: 16, fontWeight: FontWeight.w900)),
                      ),
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          children: [
                            if ('${j['work_photo'] ?? ''}'.trim().isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: FutureBuilder<String?>(
                                  future: _signed('${j['work_photo'] ?? ''}'),
                                  builder: (context, snap) {
                                    if (snap.hasData) {
                                      return Image.network(snap.data!, height: 74, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox(height: 52, child: Center(child: Icon(Icons.image_not_supported, size: 28))));
                                    }
                                    return const SizedBox(height: 52, child: Center(child: CircularProgressIndicator()));
                                  },
                                ),
                              ),
                            if ('${j['work_photo'] ?? ''}'.trim().isNotEmpty) const SizedBox(height: 5),
                            _dealDetail('🔨', 'काम का नाम', '${j['title'] ?? ''}'),
                            _dealDetail('💰', 'तय रकम', '₹${j['final_amount'] ?? ''}'),
                            _dealDetail('📅', 'काम की तारीख', '${j['job_date'] ?? ''}'),
                            _dealDetail('⏰', 'समय', '${j['start_time'] ?? ''}'.split('.').first),
                            _dealDetail('👤', 'मालिक का नाम', '${j['owner_name'] ?? ''}'),
                            _dealDetail('📞', 'मालिक का मोबाइल नंबर', '${j['owner_mobile'] ?? ''}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text('आपने मालिक से इस काम के बारे में फोन पर बात कर ली है और आपके बीच रेट भी तय हो गई है।\n\nअगर आप इस सौदे को पक्का करना चाहते हैं तो नीचे दिए गए “सौदा पक्का करें” बटन को दबाएँ।', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12.5, height: 1.2, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 7),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: FilledButton(
                          onPressed: () => Navigator.pop(c, true),
                          style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF8C00), foregroundColor: Colors.white, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.check_circle, size: 21),
                              const SizedBox(width: 8),
                              const Text('सौदा पक्का करें  →', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                            ]),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text('(काम फाइनल करें)', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: double.infinity,
                        height: 34,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(c, false),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white, width: 1.5), padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                          child: const FittedBox(fit: BoxFit.scaleDown, child: Text('डील कैंसल करें', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );

        if (!mounted || confirmed == null) return;
        if (confirmed) {
          await SupaFlow.client.rpc('finalize_worker_job_confirmation_v2', params: {'p_job_id': '${j['job_id']}'});
        } else {
          await SupaFlow.client.rpc('cancel_worker_job_confirmation', params: {'p_job_id': '${j['job_id']}'});
        }
        if (!mounted) return;
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

'''

s = s[:start] + new_method + s[end:]
p.write_text(s, encoding='utf-8')
print('OK: worker confirmation dialog patched')
