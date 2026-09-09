import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/components/chaupal_app_header.dart';
import 'package:flutter/material.dart';

class JobHistoryArchiveWidget extends StatefulWidget {
  const JobHistoryArchiveWidget({super.key});
  static String routeName = 'JobHistoryArchive';
  static String routePath = '/jobHistoryArchive';

  @override
  State<JobHistoryArchiveWidget> createState() => _JobHistoryArchiveWidgetState();
}

class _JobHistoryArchiveWidgetState extends State<JobHistoryArchiveWidget> {
  late Future<List<Map<String, dynamic>>> future;

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final r = await SupaFlow.client.rpc('get_my_job_history');
    return List<Map<String, dynamic>>.from(r as List);
  }

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: t.primaryBackground,
      appBar: const ChaupalAppHeader(title: 'पुरानी जॉब्स'),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: future,
        builder: (context, s) {
          if (s.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (s.hasError) return const Center(child: Text('पुरानी जॉब्स लोड नहीं हो सकीं।'));
          final rows = s.data ?? [];
          if (rows.isEmpty) return const Center(child: Text('अभी कोई पुरानी जॉब नहीं है।'));

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
                        Text('${r['title']}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Text('${r['job_date']} • ${r['start_time']}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 5),
                        Text('${r['profession_name']} • ${r['location_name']}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 5),
                        Text('राशि: ₹${r['final_amount'] ?? r['expected_amount']} • स्थिति: ${r['status']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        if (r['final_worker_name'] != null) ...[
                          const SizedBox(height: 8),
                          Text('कामगार: ${r['final_worker_name']}', style: const TextStyle(fontSize: 16)),
                          Text('मोबाइल: ${r['final_worker_mobile'] ?? ''}', style: const TextStyle(fontSize: 16)),
                        ],
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
