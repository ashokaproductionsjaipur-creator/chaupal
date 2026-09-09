import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/chaupal_app_header.dart';
import 'package:flutter/material.dart';

class NotificationsWidget extends StatefulWidget {
  const NotificationsWidget({super.key});
  static String routeName = 'Notifications';
  static String routePath = '/notifications';

  @override
  State<NotificationsWidget> createState() => _NotificationsWidgetState();
}

class _NotificationsWidgetState extends State<NotificationsWidget> {
  late Future<List<Map<String, dynamic>>> future;

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final r = await SupaFlow.client
        .from('notifications')
        .select('id,title,message,kind,read_at,created_at')
        .order('created_at', ascending: false)
        .limit(100);
    return List<Map<String, dynamic>>.from(r as List);
  }

  Future<void> _markRead(String id) async {
    try {
      await SupaFlow.client.rpc('mark_notification_read', params: {'p_notification_id': id});
      if (mounted) setState(() => future = _load());
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: t.primaryBackground,
      appBar: const ChaupalAppHeader(title: 'सूचनाएँ'),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Center(child: Text('सूचनाएँ लोड नहीं हो सकीं।'));
          final rows = snapshot.data ?? [];
          if (rows.isEmpty) return const Center(child: Text('अभी कोई सूचना नहीं है।'));
          return RefreshIndicator(
            onRefresh: () async {
              setState(() => future = _load());
              await future;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final n = rows[index];
                final unread = n['read_at'] == null;
                return Card(
                  color: t.secondaryBackground,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: t.alternate)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    minVerticalPadding: 10,
                    leading: Icon(unread ? Icons.notifications_active_outlined : Icons.notifications_none_outlined, size: 32),
                    title: Text('${n['title']}', style: TextStyle(fontSize: 17, fontWeight: unread ? FontWeight.w800 : FontWeight.w600)),
                    subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text('${n['message']}', style: const TextStyle(fontSize: 15))),
                    onTap: unread ? () => _markRead(n['id'].toString()) : null,
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
