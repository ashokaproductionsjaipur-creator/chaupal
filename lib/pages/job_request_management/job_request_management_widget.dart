import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/components/chaupal_app_header.dart';

class JobRequestManagementWidget extends StatefulWidget {
  const JobRequestManagementWidget({super.key});
  static String routeName = 'JobRequestManagement';
  static String routePath = '/jobRequestManagement';

  @override
  State<JobRequestManagementWidget> createState() => _JobRequestManagementWidgetState();
}

class _JobRequestManagementWidgetState extends State<JobRequestManagementWidget> {
  late Future<List<Map<String, dynamic>>> jobsFuture;
  Map<String, dynamic>? selectedJob;
  late Future<List<Map<String, dynamic>>> requestsFuture;
  final player = AudioPlayer();
  bool busy = false;

  @override
  void initState() {
    super.initState();
    jobsFuture = _loadJobs();
    requestsFuture = Future.value([]);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _loadJobs() async {
    final r = await SupaFlow.client.rpc('get_owner_job_cards');
    return List<Map<String, dynamic>>.from(r as List);
  }

  Future<List<Map<String, dynamic>>> _loadRequests(String jobId) async {
    final r = await SupaFlow.client.rpc('get_owner_job_requests', params: {'p_job_id': jobId});
    return List<Map<String, dynamic>>.from(r as List);
  }

  void _openJob(Map<String, dynamic> job) {
    setState(() {
      selectedJob = job;
      requestsFuture = _loadRequests(job['job_id'].toString());
    });
  }

  Future<void> _refreshJobs() async {
    setState(() => jobsFuture = _loadJobs());
    await jobsFuture;
  }

  Future<String?> _signedJob(String? path) async {
    if (path == null || path.trim().isEmpty || path == 'null') return null;
    try {
      return await SupaFlow.client.storage.from('job-media').createSignedUrl(path, 600);
    } catch (_) {
      return null;
    }
  }

  Future<String?> _signedProfile(String? path) async {
    if (path == null || path.trim().isEmpty || path == 'null') return null;
    try {
      return await SupaFlow.client.storage.from('profile-media').createSignedUrl(path, 600);
    } catch (_) {
      return null;
    }
  }

  Future<void> _playAudio(String path) async {
    final url = await _signedJob(path);
    if (url == null) return;
    try {
      await player.play(UrlSource(url));
    } catch (_) {}
  }

  Future<void> _accept(Map<String, dynamic> r) async {
    if (busy || selectedJob == null) return;
    final amount = double.tryParse('${r['offered_amount']}');
    if (amount == null || amount <= 0) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('कामगार स्वीकार करें'),
        content: Text('क्या ${r['worker_name']} को यह जॉब देना है?\n\nमोबाइल: ${r['worker_mobile']}\nरेट: ₹${r['offered_amount']}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('रद्द करें')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('स्वीकार करें'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => busy = true);
    try {
      await SupaFlow.client.rpc('confirm_job_worker', params: {
        'p_job_id': selectedJob!['job_id'],
        'p_worker_id': r['worker_id'],
        'p_final_amount': amount,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कामगार स्वीकार कर लिया गया।')));
        await _refreshSelectedJob();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('कामगार स्वीकार नहीं हो सका: $e')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _reject(Map<String, dynamic> r) async {
    if (busy) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('अनुरोध अस्वीकार करें'),
        content: Text('क्या ${r['worker_name']} का अनुरोध अस्वीकार करना है?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('रद्द करें')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('अस्वीकार करें'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => busy = true);
    try {
      await SupaFlow.client.rpc('reject_job_request', params: {'p_request_id': r['request_id']});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('अनुरोध अस्वीकार कर दिया गया।')));
        await _refreshSelectedJob();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('अनुरोध अस्वीकार नहीं हो सका: $e')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _refreshSelectedJob() async {
    final id = selectedJob?['job_id']?.toString();
    if (id == null) return;
    final jobs = await _loadJobs();
    final updated = jobs.where((j) => j['job_id'].toString() == id).toList();
    if (!mounted) return;
    setState(() {
      jobsFuture = Future.value(jobs);
      if (updated.isNotEmpty) selectedJob = updated.first;
      requestsFuture = _loadRequests(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: t.primaryBackground,
      appBar: ChaupalAppHeader(title: selectedJob == null ? 'मेरी पोस्ट की गई जॉब्स' : 'कामगार अनुरोध'),
      body: selectedJob == null ? _jobList(t) : _requestPage(t),
    );
  }

  Widget _jobList(FlutterFlowTheme t) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: jobsFuture,
      builder: (context, s) {
        if (s.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
        if (s.hasError) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('आपकी जॉब्स लोड नहीं हो सकीं।')));
        final jobs = s.data ?? [];
        if (jobs.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('अभी आपकी कोई पोस्ट की गई जॉब नहीं है।')));
        return RefreshIndicator(
          onRefresh: _refreshJobs,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) => _jobCard(t, jobs[i]),
          ),
        );
      },
    );
  }

  Widget _jobCard(FlutterFlowTheme t, Map<String, dynamic> j) {
    final count = (j['request_count'] as num?)?.toInt() ?? 0;
    final photo = '${j['work_photo'] ?? ''}'.trim();
    return Card(
      color: t.secondaryBackground,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: t.alternate, width: 1.2)),
      child: InkWell(
        onTap: () => _openJob(j),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (photo.isNotEmpty)
            FutureBuilder<String?>(
              future: _signedJob(photo),
              builder: (context, s) {
                if (s.connectionState != ConnectionState.done) return const SizedBox(height: 170, child: Center(child: CircularProgressIndicator()));
                if (!s.hasData || s.data == null) return Container(height: 120, width: double.infinity, alignment: Alignment.center, child: const Icon(Icons.image_not_supported_outlined, size: 42));
                return Image.network(s.data!, height: 190, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 120, width: double.infinity, alignment: Alignment.center, child: const Icon(Icons.image_not_supported_outlined, size: 42)));
              },
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text('${j['title'] ?? '-'}', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900))),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: count > 0 ? const Color(0xFF16A34A) : const Color(0xFF64748B), borderRadius: BorderRadius.circular(22)), child: Text('$count अनुरोध', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
              ]),
              const SizedBox(height: 9),
              Text('काम: ${j['profession_name'] ?? '-'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 5),
              Text('राशि: ₹${j['amount'] ?? '-'}   •   चौपाल: ${j['location_name'] ?? '-'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 5),
              Text('तारीख: ${j['job_date'] ?? '-'}   •   समय: ${j['start_time'] ?? '-'}', style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, height: 52, child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white), onPressed: () => _openJob(j), icon: const Icon(Icons.people_alt_outlined, size: 26), label: Text(count > 0 ? 'कामगार अनुरोध देखें' : 'जॉब खोलें', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)))),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _requestPage(FlutterFlowTheme t) {
    final j = selectedJob!;
    return RefreshIndicator(
      onRefresh: _refreshSelectedJob,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
        children: [
          SizedBox(width: double.infinity, height: 50, child: OutlinedButton.icon(style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF2563EB), side: const BorderSide(color: Color(0xFF2563EB), width: 2)), onPressed: busy ? null : () => setState(() => selectedJob = null), icon: const Icon(Icons.arrow_back, size: 25), label: const Text('सभी जॉब्स देखें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)))),
          const SizedBox(height: 12),
          _jobSummary(t, j),
          const SizedBox(height: 18),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: requestsFuture,
            builder: (context, s) {
              if (s.connectionState != ConnectionState.done) return const Padding(padding: EdgeInsets.all(35), child: Center(child: CircularProgressIndicator()));
              if (s.hasError) return const Padding(padding: EdgeInsets.all(20), child: Text('इस जॉब के अनुरोध लोड नहीं हो सके।'));
              final rows = s.data ?? [];
              final pending = rows.where((r) => '${r['request_status']}' == 'pending').toList();
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Expanded(child: Text('कामगार अनुरोध', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900))),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: pending.isEmpty ? const Color(0xFF64748B) : const Color(0xFF16A34A), borderRadius: BorderRadius.circular(20)), child: Text('${pending.length}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900))),
                ]),
                const SizedBox(height: 10),
                if (pending.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(22), child: Center(child: Text('इस जॉब पर अभी कोई pending कामगार अनुरोध नहीं है।', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))))
                else ...pending.map(_requestCard),
              ]);
            },
          ),
        ],
      ),
    );
  }

  Widget _jobSummary(FlutterFlowTheme t, Map<String, dynamic> j) {
    final photo = '${j['work_photo'] ?? ''}'.trim();
    return Card(
      color: t.secondaryBackground,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: t.alternate)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${j['title'] ?? '-'}', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('काम: ${j['profession_name'] ?? '-'}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          Text('राशि: ₹${j['amount'] ?? '-'}   •   चौपाल: ${j['location_name'] ?? '-'}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          Text('तारीख: ${j['job_date'] ?? '-'}   •   समय: ${j['start_time'] ?? '-'}', style: const TextStyle(fontSize: 16)),
          if ('${j['description'] ?? ''}'.trim().isNotEmpty) ...[const SizedBox(height: 7), Text('${j['description']}', style: const TextStyle(fontSize: 15))],
          if (photo.isNotEmpty) ...[
            const SizedBox(height: 12),
            FutureBuilder<String?>(
              future: _signedJob(photo),
              builder: (_, s) {
                if (!s.hasData || s.data == null) return const SizedBox(height: 130, child: Center(child: CircularProgressIndicator()));
                return ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(s.data!, height: 180, width: double.infinity, fit: BoxFit.cover));
              },
            ),
          ],
          if ('${j['audio_note'] ?? ''}'.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, height: 52, child: OutlinedButton.icon(onPressed: () => _playAudio('${j['audio_note']}'), icon: const Icon(Icons.play_arrow_outlined, size: 28), label: const Text('ऑडियो सुनें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)))),
          ],
        ]),
      ),
    );
  }

  Widget _requestCard(Map<String, dynamic> r) {
    final profilePhoto = '${r['worker_profile_photo'] ?? ''}'.trim();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Color(0xFFE2E8F0))),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            _workerPhoto(profilePhoto),
            const SizedBox(width: 12),
            Expanded(child: Text('${r['worker_name'] ?? '-'}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900))),
            const SizedBox(width: 8),
            Text('${r['request_type'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 10),
          Text('मोबाइल: ${r['worker_mobile'] ?? '-'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          Text('काम: ${r['worker_profession'] ?? '-'}   •   चौपाल: ${r['worker_location'] ?? '-'}', style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 6),
          Text('कामगार का रेट: ₹${r['offered_amount'] ?? '-'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: SizedBox(height: 52, child: OutlinedButton.icon(style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFDC2626), side: const BorderSide(color: Color(0xFFDC2626), width: 2)), onPressed: busy ? null : () => _reject(r), icon: const Icon(Icons.close, size: 25), label: const Text('अस्वीकार', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800))))),
            const SizedBox(width: 10),
            Expanded(child: SizedBox(height: 52, child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white), onPressed: busy ? null : () => _accept(r), icon: const Icon(Icons.check, size: 25), label: const Text('स्वीकार', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800))))),
          ]),
          const SizedBox(height: 7),
          const Text('मोबाइल नंबर दिखाया गया है। मालिक अपने सामान्य फोन से कॉल करेगा।', style: TextStyle(fontSize: 12)),
        ]),
      ),
    );
  }

  Widget _workerPhoto(String path) {
    if (path.isEmpty) return _workerPhotoFallback();
    return FutureBuilder<String?>(
      future: _signedProfile(path),
      builder: (context, s) {
        if (s.connectionState != ConnectionState.done) return _workerPhotoFallback(loading: true);
        final url = s.data;
        if (url == null || url.isEmpty) return _workerPhotoFallback();
        return ClipOval(
          child: Image.network(
            url,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _workerPhotoFallback(),
          ),
        );
      },
    );
  }

  Widget _workerPhotoFallback({bool loading = false}) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFE2E8F0)),
      alignment: Alignment.center,
      child: loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.person, size: 34, color: Color(0xFF64748B)),
    );
  }
}
