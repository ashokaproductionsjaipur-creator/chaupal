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
        titleSpacing: 18,
        title: const Text(
          'CHAUPAL',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0.6),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
          const SizedBox(width: 8),
        ],
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
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
              children: [
                _profileHeader(context, t, profile),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _statCard(t, Icons.work_outline_rounded, '$active', 'Active Jobs')),
                    const SizedBox(width: 10),
                    Expanded(child: _statCard(t, Icons.check_circle_outline_rounded, '$completed', 'Completed')),
                    const SizedBox(width: 10),
                    Expanded(child: _statCard(t, Icons.layers_outlined, '${jobs.length}', 'Total')),
                  ],
                ),
                const SizedBox(height: 16),
                _postingBanner(context, t, canPost, win),
                const SizedBox(height: 14),
                SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: canPost
                        ? () => context.goNamed(CreateJobPostWidget.routeName)
                        : null,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text(
                      'Create Job  |  जॉब पोस्ट करें',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'My Jobs  |  मेरी Jobs',
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                      ),
                    ),
                    TextButton(onPressed: () {}, child: const Text('See all')),
                  ],
                ),
                const SizedBox(height: 8),
                if (jobs.isEmpty)
                  _emptyJobs(t)
                else
                  ...jobs.map((j) => _jobCard(context, t, j)),
              ],
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
              _navItem(t, Icons.home_rounded, 'Home', true),
              _navItem(t, Icons.work_outline_rounded, 'Jobs', false),
              _navItem(t, Icons.add_circle_outline_rounded, 'Post', false),
              _navItem(t, Icons.person_outline_rounded, 'Profile', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileHeader(BuildContext context, FlutterFlowTheme t, Map<String, dynamic> profile) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: t.secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: t.alternate),
      ),
      child: Row(
        children: [
          _ProfileAvatar(path: profile['profile_photo']?.toString(), radius: 31),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'नमस्ते, ${profile['full_name'] ?? 'Owner'} 👋',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  '${profile['mobile_number'] ?? ''}  •  चौपाल ${profile['chaupal_location_id'] ?? ''}',
                  style: TextStyle(color: t.secondaryText, fontSize: 12.5),
                ),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz_rounded)),
        ],
      ),
    );
  }

  Widget _statCard(FlutterFlowTheme t, IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: t.secondaryBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.alternate),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 7),
          Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: TextStyle(color: t.secondaryText, fontSize: 10.5)),
        ],
      ),
    );
  }

  Widget _postingBanner(BuildContext context, FlutterFlowTheme t, bool canPost, Map<String, dynamic> win) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: t.primaryText.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.primaryText.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(color: t.primaryText, shape: BoxShape.circle),
            child: Icon(
              canPost ? Icons.bolt_rounded : Icons.schedule_rounded,
              color: t.primaryBackground,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              canPost
                  ? 'Job Posting अभी open है.\nआज नया काम पोस्ट कर सकते हैं.'
                  : 'Job Posting अभी बंद है.\nअगली Posting ${win['next_job_date'] ?? ''} को सुबह 10:30 बजे से शुरू होगी.',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _jobCard(BuildContext context, FlutterFlowTheme t, Map<String, dynamic> j) {
    final status = (j['status'] ?? '').toString();
    final pending = '${j['pending_requests'] ?? 0}';
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: t.secondaryBackground,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: t.alternate),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(21),
        onTap: () => context.goNamed(JobRequestManagementWidget.routeName),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${j['title']}',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                    ),
                  ),
                  _statusPill(t, status),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                '₹${j['expected_amount']}  •  ${j['profession_name']}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                '${j['job_date']}  •  ${j['start_time']}  •  ${j['location_name']}',
                style: TextStyle(color: t.secondaryText, fontSize: 12),
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  Icon(Icons.people_alt_outlined, size: 16, color: t.secondaryText),
                  const SizedBox(width: 6),
                  Text('$pending requests', style: TextStyle(color: t.secondaryText, fontSize: 12, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('View requests', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: t.primaryText)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusPill(FlutterFlowTheme t, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: t.primaryText.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(status.isEmpty ? 'Open' : status, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
    );
  }

  Widget _emptyJobs(FlutterFlowTheme t) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
      decoration: BoxDecoration(
        color: t.secondaryBackground,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: t.alternate),
      ),
      child: Column(
        children: [
          const Icon(Icons.work_history_outlined, size: 40),
          const SizedBox(height: 12),
          const Text('अभी कोई Job पोस्ट नहीं की गई है.', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          Text('अपना पहला काम पोस्ट करके शुरुआत करें.', style: TextStyle(color: t.secondaryText, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _navItem(FlutterFlowTheme t, IconData icon, String label, bool selected) {
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.path, required this.radius});
  final String? path;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return CircleAvatar(radius: radius, child: const Icon(Icons.person, size: 31));
    }
    final url = SupaFlow.client.storage.from('profile-media').getPublicUrl(path!);
    return CircleAvatar(radius: radius, backgroundImage: NetworkImage(url));
  }
}
