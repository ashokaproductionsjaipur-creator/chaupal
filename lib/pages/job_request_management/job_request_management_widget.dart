import 'package:audioplayers/audioplayers.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/components/chaupal_app_header.dart';
import 'package:flutter/material.dart';

class JobRequestManagementWidget extends StatefulWidget {
  const JobRequestManagementWidget({super.key});
  static String routeName = 'JobRequestManagement';
  static String routePath = '/jobRequestManagement';

  @override
  State<JobRequestManagementWidget> createState() => _JobRequestManagementWidgetState();
}

class _JobRequestManagementWidgetState extends State<JobRequestManagementWidget> {
  late Future<Map<String, dynamic>?> jobFuture;
  late Future<List<Map<String, dynamic>>> requestsFuture;
  final player = AudioPlayer();
  bool busy = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void _reload() {
    jobFuture = _loadJob();
    requestsFuture = _loadRequests();
  }

  Future<Map<String, dynamic>?> _loadJob() async {
    final r = await SupaFlow.client.rpc('get_owner_latest_job_details');
    if (r is List && r.isNotEmpty) return Map<String, dynamic>.from(r.first as Map);
    return null;
  }

  Future<List<Map<String, dynamic>>> _loadRequests() async {
    final r = await SupaFlow.client.rpc('get_owner_requests');
    return List<Map<String, dynamic>>.from(r as List);
  }

  Future<String?> _signed(String? path) async {
    if (path == null || path.trim().isEmpty || path == 'null') return null;
    try {
      return await SupaFlow.client.storage.from('job-media').createSignedUrl(path, 600);
    } catch (_) {
      return null;
    }
  }

  Future<void> _playAudio(String path) async {
    final url = await _signed(path);
    if (url == null) return;
    try {
      await player.play(UrlSource(url));
    } catch (_) {}
  }

  Future<void> _confirm(Map<String, dynamic> r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('कामगार तय करें'),
        content: Text(
          'क्या आपने इस कामगार से फोन पर बात कर ली है और काम/रेट तय कर लिया है?\n\n'
          'कामगार: ${r['worker_name']}\n'
          'मोबाइल: ${r['worker_mobile']}\n'
          'रेट: ₹${r['offered_amount']}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('रद्द करें')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('हाँ, तय करें'),
          ),
        ],
      ),
    );
    if (ok != true || busy) return;
    setState(() => busy = true);
    try {
      await SupaFlow.client.rpc('confirm_job_worker', params: {
        'p_job_id': r['job_id'],
        'p_worker_id': r['worker_id'],
        'p_final_amount': r['offered_amount'],
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कामगार तय हो गया।')));
        setState(() => requestsFuture = _loadRequests());
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कामगार तय नहीं हो सका। फिर से प्रयास करें।')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget _jobDetails(Map<String, dynamic> j, FlutterFlowTheme t) {
    final photo = j['work_photo']?.toString();
    final audio = j['audio_note']?.toString();
    final description = (j['description'] ?? '').toString().trim();
    return Card(
      color: t.secondaryBackground,
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: t.alternate, width: 1.5)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('आपकी पोस्ट की गई जॉब', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          if (photo != null && photo.isNotEmpty)
            FutureBuilder<String?>(
              future: _signed(photo),
              builder: (c, s) {
                if (!s.hasData) return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()));
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    s.data!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(height: 120, alignment: Alignment.center, child: const Text('काम की फोटो उपलब्ध नहीं है।')),
                  ),
                );
              },
            ),
          const SizedBox(height: 12),
          Text('${j['title'] ?? ''}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('काम: ${j['profession_name'] ?? '-'}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          Text('चौपाल: ${j['location_name'] ?? '-'}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          Text('राशि: ₹${j['expected_amount'] ?? '-'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text('तारीख: ${j['job_date'] ?? '-'}  •  समय: ${j['start_time'] ?? '-'}', style: const TextStyle(fontSize: 16)),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('अतिरिक्त जानकारी: $description', style: const TextStyle(fontSize: 16)),
          ],
          const SizedBox(height: 10),
          if (audio != null && audio.isNotEmpty)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: () => _playAudio(audio),
                icon: const Icon(Icons.play_arrow_outlined, size: 28),
                label: const Text('जॉब का ऑडियो सुनें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            )
          else
            const Text('ऑडियो उपलब्ध नहीं है (इस डिवाइस में रिकॉर्डिंग डिवाइस नहीं मिला था)।', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _requests(List<Map<String, dynamic>> rows, FlutterFlowTheme t) {
    if (rows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Center(child: Text('इस जॉब के लिए अभी कोई कामगार अनुरोध नहीं आया है।', textAlign: TextAlign.center, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
      itemCount: rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (c, i) {
        final r = rows[i];
        return Card(
          color: t.secondaryBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: t.alternate)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${r['worker_name']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('मोबाइल: ${r['worker_mobile']}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              Text('जॉब: ${r['job_title']}', style: const TextStyle(fontSize: 16)),
              Text('${r['job_date']} • ${r['start_time']}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              Text('${r['worker_profession'] ?? ''} • ${r['worker_location'] ?? ''}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('अनुरोध: ${r['request_type']} • ₹${r['offered_amount']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              const Text('मोबाइल नंबर केवल दिखाया गया है। मालिक अपने सामान्य फोन से खुद कॉल करेगा।', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
                  onPressed: busy ? null : () => _confirm(r),
                  child: const Text('कामगार तय करें', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: t.primaryBackground,
      appBar: const ChaupalAppHeader(title: 'कामगार अनुरोध'),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(_reload);
          await Future.wait([jobFuture, requestsFuture]);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            FutureBuilder<Map<String, dynamic>?>(
              future: jobFuture,
              builder: (context, s) {
                if (s.connectionState != ConnectionState.done) return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()));
                if (s.hasError) return const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('जॉब की जानकारी लोड नहीं हो सकी।')));
                final j = s.data;
                if (j == null) return const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('कोई पोस्ट की गई जॉब नहीं मिली।')));
                return _jobDetails(j, t);
              },
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Text('कामगारों के अनुरोध', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: requestsFuture,
              builder: (context, s) {
                if (s.connectionState != ConnectionState.done) return const Padding(padding: EdgeInsets.all(30), child: Center(child: CircularProgressIndicator()));
                if (s.hasError) return const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('अनुरोध लोड नहीं हो सके।')));
                return _requests(s.data ?? [], t);
              },
            ),
          ],
        ),
      ),
    );
  }
}
