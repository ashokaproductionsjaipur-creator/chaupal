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
  late Future<List<Map<String, dynamic>>> future;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final r = await SupaFlow.client.rpc('get_owner_requests');
    return List<Map<String, dynamic>>.from(r as List);
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
      await SupaFlow.client.rpc(
        'confirm_job_worker',
        params: {
          'p_job_id': r['job_id'],
          'p_worker_id': r['worker_id'],
          'p_final_amount': r['offered_amount'],
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कामगार तय हो गया।')));
        setState(() => future = _load());
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कामगार तय नहीं हो सका। फिर से प्रयास करें।')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: t.primaryBackground,
      appBar: const ChaupalAppHeader(title: 'कामगार अनुरोध'),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: future,
        builder: (context, s) {
          if (s.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (s.hasError) return const Center(child: Text('अनुरोध लोड नहीं हो सके।'));
          final rows = s.data ?? [];
          if (rows.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('अभी कोई कामगार अनुरोध नहीं है।')));

          return RefreshIndicator(
            onRefresh: () async {
              setState(() => future = _load());
              await future;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
