import '/backend/supabase/supabase.dart';
import '/auth/custom_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/admin_login/admin_login_widget.dart';
import '/pages/admin_verification_panel/admin_verification_panel_widget.dart';
import 'package:flutter/material.dart';

class AdminDashboardWidget extends StatefulWidget {
  const AdminDashboardWidget({super.key});

  static String routeName = 'AdminDashboard';
  static String routePath = '/adminDashboard';

  @override
  State<AdminDashboardWidget> createState() => _AdminDashboardWidgetState();
}

class _AdminDashboardWidgetState extends State<AdminDashboardWidget> {
  late Future<List<Map<String, dynamic>>> pendingFuture;

  @override
  void initState() {
    super.initState();
    pendingFuture = _loadPending();
  }

  Future<List<Map<String, dynamic>>> _loadPending() async {
    final r = await SupaFlow.client.rpc('get_admin_pending_workers');
    return List<Map<String, dynamic>>.from(r as List);
  }

  Future<void> _logout() async {
    try {
      await SupaFlow.client.auth.signOut();
    } finally {
      try {
        await authManager.signOut();
      } catch (_) {}
      if (mounted) context.go(AdminLoginWidget.routePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: t.primaryBackground,
      appBar: AppBar(
        title: const Text('CHAUPAL ADMIN', style: TextStyle(fontWeight: FontWeight.w900)),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilledButton.icon(
              onPressed: _logout,
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
              icon: const Icon(Icons.logout),
              label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: pendingFuture,
        builder: (context, s) {
          if (s.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (s.hasError) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Admin authorization verify नहीं हो सकी।')));
          final pending = s.data?.length ?? 0;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() => pendingFuture = _loadPending());
              await pendingFuture;
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
              children: [
                const Text('Admin Dashboard', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text('CHAUPAL marketplace का control center', style: TextStyle(color: t.secondaryText, fontSize: 14)),
                const SizedBox(height: 22),
                _statCard(Icons.pending_actions, 'Pending Worker Verification', '$pending', const Color(0xFFF59E0B)),
                const SizedBox(height: 14),
                SizedBox(
                  height: 64,
                  child: FilledButton.icon(
                    onPressed: () => context.pushNamed(AdminVerificationPanelWidget.routeName),
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
                    icon: const Icon(Icons.verified_user_outlined, size: 30),
                    label: Text('Worker Verification खोलें  ($pending)', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(height: 20),
                _infoCard('अभी Admin क्या कर सकता है?', [
                  'Pending Worker की profile देखना',
                  'Aadhaar और live verification photo देखना',
                  'Worker को मंजूर / अस्वीकार करना',
                  'More Information मांगना',
                ]),
                const SizedBox(height: 14),
                _infoCard('Worker access rule', [
                  'Pending Worker jobs नहीं देख सकता।',
                  'Rejected Worker jobs नहीं देख सकता।',
                  'केवल Approved/Active Worker matching jobs देख सकता है।',
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCard(IconData icon, String title, String value, Color color) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(children: [
          Container(width: 58, height: 58, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: Colors.white, size: 30)),
          const SizedBox(width: 15),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
          Text(value, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: color)),
        ]),
      ),
    );
  }

  Widget _infoCard(String title, List<String> lines) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ...lines.map((x) => Padding(padding: const EdgeInsets.only(bottom: 7), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('• ', style: TextStyle(fontWeight: FontWeight.w900)), Expanded(child: Text(x, style: const TextStyle(fontSize: 14)))]))),
        ]),
      ),
    );
  }
}
