import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/index.dart';
import 'package:flutter/material.dart';

class OwnerDashboardWidget extends StatefulWidget {
  const OwnerDashboardWidget({super.key});
  static String routeName = 'OwnerDashboard';
  static String routePath = '/ownerDashboard';
  @override
  State<OwnerDashboardWidget> createState() => _OwnerDashboardWidgetState();
}

class _OwnerDashboardWidgetState extends State<OwnerDashboardWidget> {
  late Future<Map<String, dynamic>> _future;
  @override
  void initState() { super.initState(); _future = _load(); }
  Future<Map<String, dynamic>> _load() async {
    final value = await SupaFlow.client.rpc('get_owner_dashboard');
    return Map<String, dynamic>.from(value as Map);
  }
  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: t.primaryBackground,
      appBar: AppBar(backgroundColor: t.primaryBackground, foregroundColor: t.primaryText, elevation: 0, title: const Text('चौपाल | CHAUPAL')),
      body: FutureBuilder<Map<String, dynamic>>(future: _future, builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return const Center(child: Text('Dashboard load नहीं हो सका.'));
        final data = snapshot.data ?? {};
        final profile = Map<String, dynamic>.from((data['profile'] as Map?) ?? {});
        final jobs = List<Map<String, dynamic>>.from(((data['jobs'] as List?) ?? []).map((e) => Map<String, dynamic>.from(e as Map)));
        final active = jobs.where((j) => !['completed','expired','closed'].contains(j['status'])).length;
        final completed = jobs.where((j) => j['status'] == 'completed').length;
        return RefreshIndicator(onRefresh: () async { setState(() { _future = _load(); }); await _future; }, child: ListView(padding: const EdgeInsets.all(16), children: [
          Card(color: t.secondaryBackground, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: t.alternate)), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('नमस्ते, ${profile['full_name'] ?? 'Owner'}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text('${profile['mobile_number'] ?? ''}  •  चौपाल ${profile['chaupal_location_id'] ?? ''}')])),
          const SizedBox(height: 14),
          Row(children: [Expanded(child: _stat(t, 'Active Jobs', '$active')), const SizedBox(width: 10), Expanded(child: _stat(t, 'Completed', '$completed')), const SizedBox(width: 10), Expanded(child: _stat(t, 'Total', '${jobs.length}'))]),
          const SizedBox(height: 14),
          Card(color: t.secondaryBackground, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: t.alternate)), child: const Padding(padding: EdgeInsets.all(16), child: Row(children: [Icon(Icons.schedule_outlined), SizedBox(width: 12), Expanded(child: Text('Job Posting Window: previous day 10:30 AM से Job Date 9:50 AM तक. Final validation backend पर होती है.'))]))),
          const SizedBox(height: 14),
          SizedBox(height: 52, child: FilledButton.icon(onPressed: () => context.goNamed(CreateJobPostWidget.routeName), icon: const Icon(Icons.add), label: const Text('Create Job | जॉब पोस्ट करो'))),
          const SizedBox(height: 20),
          const Text('My Jobs | मेरी Jobs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          if (jobs.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('अभी कोई Job पोस्ट नहीं की गई है.'))),
          ...jobs.map((j) => Card(color: t.secondaryBackground, elevation: 0, margin: const EdgeInsets.only(bottom: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: t.alternate)), child: ListTile(title: Text('${j['title']}', style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text('₹${j['expected_amount']} • ${j['job_date']} • ${j['start_time']}\n${j['profession_name']} • ${j['location_name']}'), trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('${j['status']}'), Text('${j['pending_requests']} requests')]), onTap: () => context.goNamed(JobRequestManagementWidget.routeName)))
        ]));
      }),
    );
  }
  Widget _stat(FlutterFlowTheme t, String label, String value) => Card(color: t.secondaryBackground, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: t.alternate)), child: Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Column(children: [Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11))])));
}
