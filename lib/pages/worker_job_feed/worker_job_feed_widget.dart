import 'dart:ui' as ui;

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
  final Set<String> _busyJobs = <String>{};
  final Map<String, String> _submittedActions = <String, String>{};

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
    if (_busyJobs.contains(jobId) || _submittedActions.containsKey(jobId)) return;
    setState(() => _busyJobs.add(jobId));
    try {
      await SupaFlow.client.rpc('create_worker_request', params: {
        'p_job_id': jobId,
        'p_request_type': type,
        'p_offered_amount': offer,
      });
      if (!mounted) return;
      if (type == 'reject') {
        final next = _load();
        setState(() {
          _busyJobs.remove(jobId);
          future = next;
        });
        return;
      }
      setState(() {
        _busyJobs.remove(jobId);
        _submittedActions[jobId] = type;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _busyJobs.remove(jobId));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_friendlyError(e))));
      }
    }
  }

  String _friendlyError(Object e) {
    final s = e.toString();
    if (s.contains('worker_not_verified')) return 'आपका खाता अभी सत्यापन में है। मंजूरी मिलने के बाद आप जॉब देख और स्वीकार कर सकेंगे।';
    if (s.contains('already_booked')) return 'आप आज के लिए एक जॉब पर बुक हैं।';
    if (s.contains('request_limit_reached')) return 'इस जॉब के लिए कामगार अनुरोध की अधिकतम सीमा पूरी हो चुकी है।';
    if (s.contains('duplicate_request')) return 'आप इस जॉब के लिए पहले ही अनुरोध भेज चुके हैं।';
    return 'अनुरोध नहीं भेजा जा सका। फिर से प्रयास करें।';
  }

  Future<void> _negotiate(String jobId) async {
    if (_busyJobs.contains(jobId) || _submittedActions.containsKey(jobId)) return;
    final c = TextEditingController();
    final v = await showDialog<double>(
      context: context,
      builder: (x) => AlertDialog(
        title: const Text('मोल-भाव करें'),
        content: TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: '₹ ', labelText: 'अपना रेट लिखें'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(x), child: const Text('रद्द करें')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white),
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
    if (v != null && mounted) await _request(jobId, 'negotiate', offer: v);
  }

  String _actionMessage(String type) => type == 'accept'
      ? 'स्वीकार करने का अनुरोध मालिक को भेज दिया गया है'
      : 'मोल-भाव का अनुरोध मालिक को भेज दिया गया है';

  String _actionHelpMessage() => 'अगर आपकी रेट मालिक को पसंद आई तो काम देने वाला आपके बताए मोबाइल नंबर पर फोन करेगा और तभी आज का काम मिलेगा। नहीं तो दूसरे कामों की request भेजते रहें।';

  Color _actionColor(String type) => type == 'accept'
      ? const Color(0xFF16A34A)
      : const Color(0xFFF59E0B);

  Widget _summaryChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _lockedJobSummary(BuildContext context, Map<String, dynamic> j, String submitted) {
    final photoPath = '${j['work_photo'] ?? ''}';
    final title = '${j['title'] ?? 'जॉब'}';
    final profession = '${j['profession_name'] ?? ''}';
    final location = '${j['location_name'] ?? ''}';
    final amount = '${j['expected_amount'] ?? ''}';
    final date = '${j['job_date'] ?? ''}';
    final time = '${j['start_time'] ?? ''}'.split('.').first;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 390, maxHeight: 390),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.97),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _actionColor(submitted), width: 3),
        boxShadow: const [BoxShadow(blurRadius: 18, spreadRadius: 1, offset: Offset(0, 5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 82,
                height: 62,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(9)),
                child: FutureBuilder<String?>(
                  future: _signed(photoPath),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Image.network(snapshot.data!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined, size: 28)));
                    }
                    return const Center(child: Icon(Icons.image_outlined, size: 28));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                    if (profession.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(profession, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _summaryChip('₹$amount'),
              _summaryChip(date),
              _summaryChip(time),
              if (location.isNotEmpty) _summaryChip(location),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(submitted == 'accept' ? Icons.check_circle : Icons.forum, size: 27, color: _actionColor(submitted)),
              const SizedBox(width: 7),
              Flexible(
                child: Text(_actionMessage(submitted), textAlign: TextAlign.center, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _actionColor(submitted))),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(_actionHelpMessage(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, height: 1.3, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('मालिक के जवाब का इंतजार करें। इस जॉब पर दोबारा कोई action नहीं किया जा सकता।', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _jobCard(BuildContext context, Map<String, dynamic> j) {
    final t = FlutterFlowTheme.of(context);
    final jobId = j['id'].toString();
    final audio = (j['audio_note'] ?? '').toString();
    final submitted = _submittedActions[jobId] ?? j['existing_request_type']?.toString();
    final isBusy = _busyJobs.contains(jobId);
    final locked = submitted != null;

    final cardContent = Padding(
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
                child: Image.network(img.data!, height: 170, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(height: 130, child: Center(child: Icon(Icons.broken_image_outlined, size: 40))),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text('${j['title']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('₹${j['expected_amount']} • ${j['job_date']} • ${j['start_time']}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 6),
          Text('${j['profession_name']} • ${j['location_name']}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 6),
          Text('मालिक: ${j['owner_name']}', style: const TextStyle(fontSize: 16)),
          if ((j['description'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('${j['description']}', style: const TextStyle(fontSize: 16)),
          ],
          if (audio.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, height: 54,
              child: OutlinedButton.icon(
                onPressed: isBusy ? null : () => _play(audio),
                icon: const Icon(Icons.play_arrow_outlined, size: 28),
                label: const Text('ऑडियो सुनें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: SizedBox(height: 56, child: OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFDC2626), side: const BorderSide(color: Color(0xFFDC2626), width: 2)),
              onPressed: isBusy || locked ? null : () => _request(jobId, 'reject'),
              child: const Text('अस्वीकार करें', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ))),
            const SizedBox(width: 8),
            Expanded(child: SizedBox(height: 56, child: OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFF59E0B), side: const BorderSide(color: Color(0xFFF59E0B), width: 2)),
              onPressed: isBusy || locked ? null : () => _negotiate(jobId),
              child: const Text('मोल-भाव करें', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ))),
            const SizedBox(width: 8),
            Expanded(child: SizedBox(height: 56, child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
              onPressed: isBusy || locked ? null : () => _request(jobId, 'accept'),
              child: const Text('स्वीकार करें', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ))),
          ]),
        ],
      ),
    );

    return Card(
      color: t.secondaryBackground,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: t.alternate)),
      child: Stack(children: [
        cardContent,
        if (isBusy) Positioned.fill(child: Container(color: Colors.white.withOpacity(0.45), child: const Center(child: CircularProgressIndicator()))),
        if (locked) Positioned.fill(
          child: ClipRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: Colors.white.withOpacity(0.58),
                padding: const EdgeInsets.all(14),
                child: Center(child: _lockedJobSummary(context, j, submitted!)),
              ),
            ),
          ),
        ),
      ]),
    );
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
          if (mounted) setState(() { future = _load(); });
        },
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('जॉब्स लोड नहीं हो सकीं। फिर से प्रयास करें।')));
          final jobs = snapshot.data ?? [];
          if (jobs.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('अभी आपके लिए कोई जॉब उपलब्ध नहीं है।')));
          return RefreshIndicator(
            onRefresh: () async {
              final next = _load();
              setState(() { future = next; });
              await next;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: jobs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) => _jobCard(context, jobs[i]),
            ),
          );
        },
      ),
    );
  }
}
