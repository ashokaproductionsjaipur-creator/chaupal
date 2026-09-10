from pathlib import Path

p = Path('lib/pages/worker_job_feed/worker_job_feed_widget.dart')
s = p.read_text(encoding='utf-8')

needle = """  @override
  void initState() {
    super.initState();
    future = _load();
  }
"""
replacement = """  @override
  void initState() {
    super.initState();
    future = _load();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showPendingConfirmation());
  }

  Future<void> _showPendingConfirmation() async {
    if (!mounted || currentUserUid.isEmpty) return;
    try {
      final rows = await SupaFlow.client.rpc('get_pending_worker_confirmation_details');
      final list = List<Map<String, dynamic>>.from(rows as List);
      if (!mounted || list.isEmpty) return;
      final j = list.first;
      final ok = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (c) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520, maxHeight: 760),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF009C3B), Color(0xFF16A34A), Color(0xFF087F3D)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [BoxShadow(blurRadius: 28, spreadRadius: 3, offset: Offset(0, 10))],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              child: Column(children: [
                Row(children: [
                  const Expanded(child: Text('अपना सौदा पक्का करें', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900))),
                ]),
                Container(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7), decoration: BoxDecoration(color: const Color(0xFFFFF7B2), borderRadius: BorderRadius.circular(24)), child: const Text('काम तय हो गया है!', style: TextStyle(color: Color(0xFF14532D), fontSize: 21, fontWeight: FontWeight.w900))),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                  child: Column(children: [
                    if ('${j['work_photo'] ?? ''}'.trim().isNotEmpty) ...[
                      ClipRRect(borderRadius: BorderRadius.circular(14), child: FutureBuilder<String?>(future: _signed('${j['work_photo'] ?? ''}'), builder: (context, snap) => snap.hasData ? Image.network(snap.data!, height: 150, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox(height: 100, child: Center(child: Icon(Icons.image_not_supported, size: 40)))) : const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())))),
                      const SizedBox(height: 12),
                    ],
                    _dealDetail('🔨', 'काम का नाम', '${j['title'] ?? ''}'),
                    _dealDetail('💰', 'तय रकम', '₹${j['final_amount'] ?? ''}'),
                    _dealDetail('📅', 'काम की तारीख', '${j['job_date'] ?? ''}'),
                    _dealDetail('⏰', 'समय', '${j['start_time'] ?? ''}'.split('.').first),
                    _dealDetail('👤', 'मालिक का नाम', '${j['owner_name'] ?? ''}'),
                    _dealDetail('📞', 'मालिक का मोबाइल नंबर', '${j['owner_mobile'] ?? ''}'),
                  ]),
                ),
                const SizedBox(height: 12),
                const Text('🤝', style: TextStyle(fontSize: 70)),
                const SizedBox(height: 2),
                const Text('आपका भरोसा  •  हमारी साझेदारी', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: const Color(0xFFFFFDE7), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFFFD54F), width: 2)),
                  child: const Text('आपने मालिक से इस काम के बारे में फोन पर बात कर ली है और आपके बीच रेट भी तय हो गई है।\n\nअगर आप इस सौदे को पक्का करना चाहते हैं तो नीचे दिए गए “सौदा पक्का करें” बटन को दबाएँ।', textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 18, height: 1.35, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 64,
                  decoration: BoxDecoration(color: const Color(0xFFFF8C00), borderRadius: BorderRadius.circular(34), border: Border.all(color: Colors.white, width: 3), boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 10, offset: Offset(0, 5))]),
                  child: FilledButton.icon(onPressed: () => Navigator.pop(c, true), style: FilledButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent), icon: const Icon(Icons.check_circle, color: Colors.white, size: 30), label: const Text('सौदा पक्का करें  →', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900))),
                ),
                const SizedBox(height: 6),
                const Text('(काम फाइनल करें)', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
              ]),
            ),
          ),
        ),
      );
      if (ok != true || !mounted) return;
      final jobId = '${j['job_id']}';
      await SupaFlow.client.rpc('finalize_worker_job_confirmation_v2', params: {'p_job_id': jobId});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('काम पक्का हो गया। इस तारीख की दूसरी जॉब अब नहीं ली जा सकती।')));
      setState(() { future = _load(); });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_friendlyError(e))));
    }
  }

  Widget _dealDetail(String icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [SizedBox(width: 34, child: Text(icon, style: const TextStyle(fontSize: 23))), Expanded(flex: 4, child: Text('$label:', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))), Expanded(flex: 6, child: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)))]),
  );
"""
if needle not in s:
    raise SystemExit('initState marker not found')
s=s.replace(needle,replacement,1)
p.write_text(s,encoding='utf-8')
