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
        titleSpacing: 18,
        title: const Text('CHAUPAL', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0.6)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Jobs load नहीं हो सके. Please try again.')));
          final jobs = snapshot.data ?? [];
          if (jobs.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                setState(() => future = _load());
                await future;
              },
              child: ListView(children: [
                const SizedBox(height: 130),
                Icon(Icons.explore_outlined, size: 54, color: t.secondaryText),
                const SizedBox(height: 14),
                const Center(child: Text('अभी आपके लिए कोई matching Job उपलब्ध नहीं है.', textAlign: TextAlign.center)),
                const SizedBox(height: 7),
                Center(child: Text('नई Jobs आते ही यहाँ दिखाई देंगी.', style: TextStyle(fontSize: 12))),
              ]),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() => future = _load());
              await future;
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 28),
              itemCount: jobs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) => _jobCard(context, t, jobs[i]),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 9, 18, 9),
          decoration: BoxDecoration(
            color: t.secondaryBackground,
            border: Border(top: BorderSide(color: t.alternate)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _nav(t, Icons.home_rounded, 'Home', true),
              _nav(t, Icons.explore_outlined, 'Explore', false),
              _nav(t, Icons.assignment_outlined, 'Requests', false),
              _nav(t, Icons.person_outline_rounded, 'Profile', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _jobCard(BuildContext context, FlutterFlowTheme t, Map<String, dynamic> j) {
    final audio = (j['audio_note'] ?? '').toString();
    final owner = (j['owner_name'] ?? 'Owner').toString();
    return Container(
      decoration: BoxDecoration(
        color: t.secondaryBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: t.alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 14, 12, 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor: t.primaryText,
                  child: Text(
                    owner.isEmpty ? 'O' : owner.characters.first.toUpperCase(),
                    style: TextStyle(color: t.primaryBackground, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(owner, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text('${j['location_name']}', style: TextStyle(color: t.secondaryText, fontSize: 11)),
                    ],
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz_rounded)),
              ],
            ),
          ),
          FutureBuilder<String?>(
            future: _signed('${j['work_photo'] ?? ''}'),
            builder: (c, img) {
              if (!img.hasData) return Container(height: 190, color: t.primaryText.withValues(alpha: 0.04), child: Center(child: Icon(Icons.image_outlined, size: 42, color: t.secondaryText)));
              return ClipRRect(
                child: Image.network(
                  img.data!,
                  height: 210,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 190, color: t.primaryText.withValues(alpha: 0.04), child: const Center(child: Icon(Icons.broken_image_outlined, size: 42))),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 14, 15, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('${j['title']}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900))),
                    Text('₹${j['expected_amount']}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 7),
                Text('${j['profession_name']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 5),
                Text('${j['job_date']}  •  ${j['start_time']}  •  ${j['location_name']}', style: TextStyle(color: t.secondaryText, fontSize: 11.5)),
                if ((j['description'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text('${j['description']}', maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: t.primaryText, fontSize: 12.5, height: 1.35)),
                ],
                if (audio.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: busy ? null : () => _play(audio),
                      icon: const Icon(Icons.play_circle_outline_rounded),
                      label: const Text('Play Audio Note  |  काम की आवाज़'),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: busy ? null : () => _request(j['id'].toString(), 'reject'), child: const Text('Reject'))),
                    const SizedBox(width: 8),
                    Expanded(child: OutlinedButton(onPressed: busy ? null : () => _negotiate(j['id'].toString()), child: const Text('Negotiate'))),
                    const SizedBox(width: 8),
                    Expanded(child: FilledButton(onPressed: busy ? null : () => _request(j['id'].toString(), 'accept'), child: const Text('Accept'))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nav(FlutterFlowTheme t, IconData icon, String label, bool selected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 21, color: selected ? t.primaryText : t.secondaryText),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: selected ? FontWeight.w800 : FontWeight.w500, color: selected ? t.primaryText : t.secondaryText)),
      ],
    );
  }
}
