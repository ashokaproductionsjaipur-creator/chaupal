import 'package:audioplayers/audioplayers.dart';
import '/backend/supabase/supabase.dart';
import '/auth/custom_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class WorkerJobFeedWidget extends StatefulWidget {
  const WorkerJobFeedWidget({super.key});
  static String routeName = 'WorkerJobFeed';
  static String routePath = '/workerJobFeed';

  @override
  State<WorkerJobFeedWidget> createState() => _WorkerJobFeedWidgetState();
}

class _WorkerJobFeedWidgetState extends State<WorkerJobFeedWidget> {
  late Future<List<Map<String, dynamic>>> future;
  final player = AudioPlayer();
  bool busy = false;

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    if (currentUserUid.isEmpty) return [];
    final r = await SupaFlow.client.rpc('get_worker_job_feed');
    return List<Map<String, dynamic>>.from(r as List);
  }

  Future<String?> _signed(String path) async {
    if (path.trim().isEmpty || path == 'null') return null;
    try {
      return await SupaFlow.client.storage.from('job-media').createSignedUrl(path, 300);
    } catch (_) {
      return null;
    }
  }

  Future<void> _play(String path) async {
    final url = await _signed(path);
    if (url != null) await player.play(UrlSource(url));
  }

  Future<void> _request(String jobId, String type, {double? offer}) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await SupaFlow.client.rpc(
        'create_worker_request',
        params: {
          'p_job_id': jobId,
          'p_request_type': type,
          'p_offered_amount': offer,
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              type == 'accept'
                  ? 'Request sent to Owner.'
                  : type == 'negotiate'
                      ? 'Negotiation request sent.'
                      : 'Job rejected.',
            ),
          ),
        );
        setState(() => future = _load());
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_friendlyError(e))));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String _friendlyError(Object e) {
    final s = e.toString();
    if (s.contains('worker_not_verified')) return 'आपका Account अभी Verification में है। Approval मिलने के बाद आप Job देख और Accept कर सकेंगे।';
    if (s.contains('already_booked')) return 'आप आज के लिए एक Job पर Booked हैं।';
    if (s.contains('request_limit_reached')) return 'इस Job के लिए Worker Requests की maximum limit पूरी हो चुकी है।';
    if (s.contains('duplicate_request')) return 'आप इस Job के लिए पहले ही Request भेज चुके हैं।';
    return 'Request नहीं भेजी जा सकी। Please try again.';
  }

  Future<void> _negotiate(String jobId) async {
    final c = TextEditingController();
    final v = await showDialog<double>(
      context: context,
      builder: (x) => AlertDialog(
        title: const Text('Negotiate | बातचीत'),
        content: TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: '₹ ', labelText: 'Your offer'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(x), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final n = double.tryParse(c.text.trim());
              if (n != null && n > 0) Navigator.pop(x, n);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
    c.dispose();
    if (v != null) await _request(jobId, 'negotiate', offer: v);
  }

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: t.primaryBackground,
      appBar: AppBar(
        backgroundColor: t.primaryBackground,
        foregroundColor: t.primaryText,
        elevation: 0,
        title: const Text('Jobs | जॉब्स'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Jobs load नहीं हो सके. Please try again.')));
          final jobs = snapshot.data ?? [];
          if (jobs.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('अभी आपके लिए कोई matching Job उपलब्ध नहीं है.')));

          return RefreshIndicator(
            onRefresh: () async {
              setState(() => future = _load());
              await future;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: jobs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final j = jobs[i];
                final audio = (j['audio_note'] ?? '').toString();
                return Card(
                  color: t.secondaryBackground,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: t.alternate),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<String?>(
                          future: _signed('${j['work_photo'] ?? ''}'),
                          builder: (c, img) {
                            if (!img.hasData) return const SizedBox(height: 130, child: Center(child: Icon(Icons.image_outlined, size: 40)));
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                img.data!,
                                height: 170,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const SizedBox(height: 130, child: Center(child: Icon(Icons.broken_image_outlined, size: 40))),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Text('${j['title']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Text('₹${j['expected_amount']} • ${j['job_date']} • ${j['start_time']}'),
                        const SizedBox(height: 6),
                        Text('${j['profession_name']} • ${j['location_name']}'),
                        const SizedBox(height: 6),
                        Text('Owner: ${j['owner_name']}'),
                        if ((j['description'] ?? '').toString().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('${j['description']}'),
                        ],
                        if (audio.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: busy ? null : () => _play(audio),
                            icon: const Icon(Icons.play_arrow_outlined),
                            label: const Text('Play Audio Note'),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: OutlinedButton(onPressed: busy ? null : () => _request(j['id'].toString(), 'reject'), child: const Text('Reject | अस्वीकार'))),
                            const SizedBox(width: 8),
                            Expanded(child: OutlinedButton(onPressed: busy ? null : () => _negotiate(j['id'].toString()), child: const Text('Negotiate | बातचीत'))),
                            const SizedBox(width: 8),
                            Expanded(child: FilledButton(onPressed: busy ? null : () => _request(j['id'].toString(), 'accept'), child: const Text('Accept | स्वीकार'))),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
