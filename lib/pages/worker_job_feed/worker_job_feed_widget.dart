import '/backend/supabase/supabase.dart';
import '/auth/custom_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

class WorkerJobFeedWidget extends StatefulWidget {
  const WorkerJobFeedWidget({super.key});
  static String routeName = 'WorkerJobFeed';
  static String routePath = '/workerJobFeed';
  @override
  State<WorkerJobFeedWidget> createState() => _WorkerJobFeedWidgetState();
}

class _WorkerJobFeedWidgetState extends State<WorkerJobFeedWidget> {
  late Future<List<Map<String, dynamic>>> _jobsFuture;
  bool _busy = false;

  @override
  void initState() { super.initState(); _jobsFuture = _loadJobs(); }

  Future<List<Map<String, dynamic>>> _loadJobs() async {
    final uid = currentUserUid;
    if (uid.isEmpty) return [];
    final user = await SupaFlow.client.from('users').select('chaupal_location_id,account_status').eq('id', uid).maybeSingle();
    final worker = await SupaFlow.client.from('worker_profiles').select('profession_id,verification_status').eq('user_id', uid).maybeSingle();
    if (user == null || worker == null || user['account_status'] != 'active' || worker['verification_status'] != 'approved') return [];
    final professionId = worker['profession_id'];
    final locationId = user['chaupal_location_id'];
    if (professionId == null || locationId == null) return [];
    final rows = await SupaFlow.client.from('jobs').select('id,title,description,expected_amount,job_date,start_time,status,work_photo,audio_note,professions(display_name),chaupal_locations(display_name),users!jobs_owner_id_fkey(full_name)').eq('profession_id', professionId).eq('chaupal_location_id', locationId).inFilter('status', ['open','worker_request_received','negotiation_pending']).order('job_date').order('start_time');
    return List<Map<String, dynamic>>.from(rows as List);
  }

  Future<void> _request(String jobId, String type, {double? offer}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await SupaFlow.client.rpc('create_worker_request', params: {'p_job_id': jobId, 'p_request_type': type, 'p_offered_amount': offer});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(type == 'accept' ? 'Request sent to Owner.' : type == 'negotiate' ? 'Negotiation request sent.' : 'Job rejected.')));
        setState(() { _jobsFuture = _loadJobs(); });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_friendlyError(e))));
    } finally { if (mounted) setState(() => _busy = false); }
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
    final controller = TextEditingController();
    final amount = await showDialog<double>(context: context, builder: (context) => AlertDialog(title: const Text('Negotiate | बातचीत'), content: TextField(controller: controller, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(prefixText: '₹ ', labelText: 'Your offer')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () { final v = double.tryParse(controller.text.trim()); if (v != null && v > 0) Navigator.pop(context, v); }, child: const Text('Send'))]));
    if (amount != null) await _request(jobId, 'negotiate', offer: amount);
  }

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: t.primaryBackground,
      appBar: AppBar(backgroundColor: t.primaryBackground, foregroundColor: t.primaryText, elevation: 0, title: const Text('Jobs | जॉब्स')),
      body: FutureBuilder<List<Map<String, dynamic>>>(future: _jobsFuture, builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Jobs load नहीं हो सके. Please try again.')));
        final jobs = snapshot.data ?? [];
        if (jobs.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('अभी आपके लिए कोई matching Job उपलब्ध नहीं है.')));
        return RefreshIndicator(onRefresh: () async { setState(() { _jobsFuture = _loadJobs(); }); await _jobsFuture; }, child: ListView.separated(padding: const EdgeInsets.all(16), itemCount: jobs.length, separatorBuilder: (_, __) => const SizedBox(height: 14), itemBuilder: (context, i) {
          final j = jobs[i];
          final prof = (j['professions'] as Map?)?['display_name'] ?? '';
          final loc = (j['chaupal_locations'] as Map?)?['display_name'] ?? '';
          final owner = (j['users'] as Map?)?['full_name'] ?? 'Owner';
          return Card(color: t.secondaryBackground, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: t.alternate)), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${j['title']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8), Text('₹${j['expected_amount']}  •  ${j['job_date']}  •  ${j['start_time']}'),
            const SizedBox(height: 6), Text('$prof  •  $loc'), const SizedBox(height: 6), Text('Owner: $owner'),
            if ((j['description'] ?? '').toString().isNotEmpty) ...[const SizedBox(height: 8), Text('${j['description']}')],
            const SizedBox(height: 14),
            Row(children: [Expanded(child: OutlinedButton(onPressed: _busy ? null : () => _request(j['id'].toString(), 'reject'), child: const Text('Reject | अस्वीकार'))), const SizedBox(width: 8), Expanded(child: OutlinedButton(onPressed: _busy ? null : () => _negotiate(j['id'].toString()), child: const Text('Negotiate | बातचीत'))), const SizedBox(width: 8), Expanded(child: FilledButton(onPressed: _busy ? null : () => _request(j['id'].toString(), 'accept'), child: const Text('Accept | स्वीकार')))]),
          ])));
        }));
      }),
    );
  }
}
