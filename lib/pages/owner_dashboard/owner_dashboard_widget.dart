import 'dart:typed_data';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
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
  late Future<Map<String, dynamic>> future;

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final r = await SupaFlow.client.rpc('get_owner_dashboard');
    return Map<String, dynamic>.from(r as Map);
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
        title: const Text('चौपाल | CHAUPAL'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Dashboard load नहीं हो सका.'));
          }

          final d = snapshot.data ?? {};
          final profile = Map<String, dynamic>.from((d['profile'] as Map?) ?? {});
          final jobs = ((d['jobs'] as List?) ?? [])
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          final win = Map<String, dynamic>.from((d['posting_window'] as Map?) ?? {});
          final canPost = win['can_post'] == true;
          final active = jobs
              .where((j) => !['completed', 'expired', 'closed'].contains(j['status']))
              .length;
          final completed = jobs.where((j) => j['status'] == 'completed').length;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() => future = _load());
              await future;
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: t.secondaryBackground,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: t.alternate),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _ProfileAvatar(
                          path: profile['profile_photo']?.toString(),
                          radius: 32,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'नमस्ते, ${profile['full_name'] ?? 'Owner'}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${profile['mobile_number'] ?? ''}  •  चौपाल ${profile['chaupal_location_id'] ?? ''}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _stat(t, 'Active Jobs', '$active')),
                    const SizedBox(width: 10),
                    Expanded(child: _stat(t, 'Completed', '$completed')),
                    const SizedBox(width: 10),
                    Expanded(child: _stat(t, 'Total', '${jobs.length}')),
                  ],
                ),
                const SizedBox(height: 14),
                Card(
                  color: t.secondaryBackground,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: t.alternate),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          canPost ? Icons.schedule_outlined : Icons.lock_outline,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            canPost
                                ? 'Job Posting अभी open है.'
                                : 'अभी Job Posting बंद है। अगली Posting ${win['next_job_date'] ?? ''} को सुबह 10:30 बजे से शुरू होगी.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: canPost
                        ? () => context.goNamed(CreateJobPostWidget.routeName)
                        : null,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Job | जॉब पोस्ट करो'),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'My Jobs | मेरी Jobs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                if (jobs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('अभी कोई Job पोस्ट नहीं की गई है.')),
                  ),
                ...jobs.map((j) {
                  return Card(
                    color: t.secondaryBackground,
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: t.alternate),
                    ),
                    child: ListTile(
                      title: Text(
                        '${j['title']}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '₹${j['expected_amount']} • ${j['job_date']} • ${j['start_time']}\n'
                        '${j['profession_name']} • ${j['location_name']}',
                      ),
                      trailing: SizedBox(
                        width: 90,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${j['status']}'),
                            Text('${j['pending_requests']} requests'),
                          ],
                        ),
                      ),
                      onTap: () => context.goNamed(
                        JobRequestManagementWidget.routeName,
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _stat(FlutterFlowTheme t, String label, String value) {
    return Card(
      color: t.secondaryBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: t.alternate),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.path, required this.radius});
  final String? path;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        child: const Icon(Icons.person, size: 32),
      );
    }

    final url = SupaFlow.client.storage.from('profile-media').getPublicUrl(path!);
    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(url),
    );
  }
}
