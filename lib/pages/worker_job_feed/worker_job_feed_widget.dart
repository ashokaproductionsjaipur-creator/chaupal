import 'package:audioplayers/audioplayers.dart';
import '/backend/supabase/supabase.dart';
import '/auth/custom_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/chaupal_app_header.dart';
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
      return await SupaFlow.client.storage
          .from('job-media')
          .createSignedUrl(path, 300);
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
                  ? 'मालिक को अनुरोध भेज दिया गया।'
                  : type == 'negotiate'
                      ? 'बातचीत का अनुरोध भेज दिया गया।'
                      : 'जॉब अस्वीकार कर दी गई।',
            ),
          ),
        );
        setState(() => future = _load());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_friendlyError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String _friendlyError(Object e) {
    final s = e.toString();
    if (s.contains('worker_not_verified')) {
      return 'आपका खाता अभी सत्यापन में है। मंजूरी मिलने के बाद आप जॉब देख और स्वीकार कर सकेंगे।';
    }
    if (s.contains('already_booked')) return 'आप आज के लिए एक जॉब पर बुक हैं।';
    if (s.contains('request_limit_reached')) {
      return 'इस जॉब के लिए कामगार अनुरोध की अधिकतम सीमा पूरी हो चुकी है।';
    }
    if (s.contains('duplicate_request')) {
      return 'आप इस जॉब के लिए पहले ही अनुरोध भेज चुके हैं।';
    }
    return 'अनुरोध नहीं भेजा जा सका। फिर से प्रयास करें।';
  }

  Future<void> _negotiate(String jobId) async {
    final c = TextEditingController();
    final v = await showDialog<double>(
      context: context,
      builder: (x) => AlertDialog(
        title: const Text('बातचीत करें'),
        content: TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            prefixText: '₹ ',
            labelText: 'अपना रेट लिखें',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(x),
            child: const Text('रद्द करें'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final n = double.tryParse(c.text.trim());
              if (n != null && n > 0) Navigator.pop(x, n);
            },
            child: const Text('भेजें'),
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
      appBar: ChaupalAppHeader(
        title: 'जॉब्स',
        showWorkerLocation: true,
        onWorkerLocationChanged: () {
          if (mounted) setState(() => future = _load());
        },
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('जॉब्स लोड नहीं हो सकीं। फिर से प्रयास करें।'),
              ),
            );
          }

          final jobs = snapshot.data ?? [];
          if (jobs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('अभी आपके लिए कोई जॉब उपलब्ध नहीं है।'),
              ),
            );
          }

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
                            if (!img.hasData) {
                              return const SizedBox(
                                height: 130,
                                child: Center(
                                  child: Icon(Icons.image_outlined, size: 40),
                                ),
                              );
                            }

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                img.data!,
                                height: 170,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  return const SizedBox(
                                    height: 130,
                                    child: Center(
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                        size: 40,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${j['title']}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${j['expected_amount']} • ${j['job_date']} • ${j['start_time']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${j['profession_name']} • ${j['location_name']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'मालिक: ${j['owner_name']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        if ((j['description'] ?? '').toString().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${j['description']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                        if (audio.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: OutlinedButton.icon(
                              onPressed: busy ? null : () => _play(audio),
                              icon: const Icon(
                                Icons.play_arrow_outlined,
                                size: 28,
                              ),
                              label: const Text(
                                'ऑडियो सुनें',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 56,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFDC2626),
                                    side: const BorderSide(
                                      color: Color(0xFFDC2626),
                                      width: 2,
                                    ),
                                  ),
                                  onPressed: busy
                                      ? null
                                      : () => _request(
                                            j['id'].toString(),
                                            'reject',
                                          ),
                                  child: const Text(
                                    'अस्वीकार करें',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 56,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFF59E0B),
                                    side: const BorderSide(
                                      color: Color(0xFFF59E0B),
                                      width: 2,
                                    ),
                                  ),
                                  onPressed: busy
                                      ? null
                                      : () => _negotiate(j['id'].toString()),
                                  child: const Text(
                                    'बातचीत करें',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 56,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF16A34A),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: busy
                                      ? null
                                      : () => _request(
                                            j['id'].toString(),
                                            'accept',
                                          ),
                                  child: const Text(
                                    'स्वीकार करें',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
