import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/components/chaupal_app_header.dart';
import 'package:flutter/material.dart';

class AdminVerificationPanelWidget extends StatefulWidget {
  const AdminVerificationPanelWidget({super.key});
  static String routeName = 'AdminVerificationPanel';
  static String routePath = '/adminVerificationPanel';

  @override
  State<AdminVerificationPanelWidget> createState() => _AdminVerificationPanelWidgetState();
}

class _AdminVerificationPanelWidgetState extends State<AdminVerificationPanelWidget> {
  late Future<List<Map<String, dynamic>>> future;
  final Set<String> _busyWorkers = <String>{};

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final r = await SupaFlow.client.rpc('get_admin_pending_workers');
    return List<Map<String, dynamic>>.from(r as List);
  }

  Future<void> _review(Map<String, dynamic> w, String status) async {
    final workerId = w['user_id']?.toString();
    if (workerId == null || workerId.isEmpty || _busyWorkers.contains(workerId)) return;

    setState(() {
      _busyWorkers.add(workerId);
    });
    try {
      await SupaFlow.client.rpc(
        'review_worker_verification',
        params: {
          'p_worker_id': workerId,
          'p_status': status,
          'p_note': status == 'more_info' ? 'Please provide clearer verification information.' : null,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'approved'
                ? 'कामगार को मंजूरी मिल गई।'
                : status == 'rejected'
                    ? 'कामगार को अस्वीकार कर दिया गया।'
                    : 'और जानकारी मांगी गई है.',
          ),
        ),
      );

      final next = _load();
      if (!mounted) return;
      setState(() {
        future = next;
      });
      await next;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Admin action नहीं हो सका: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _busyWorkers.remove(workerId);
        });
      }
    }
  }

  Future<void> _view(String bucket, String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final url = await SupaFlow.client.storage.from(bucket).createSignedUrl(path, 300);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('दस्तावेज देखें'),
          content: SizedBox(
            width: 300,
            height: 360,
            child: Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(child: Text('फोटो नहीं खुल सकी।')),
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(c),
                child: const Text('बंद करें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('दस्तावेज नहीं खुल सका: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: t.primaryBackground,
      appBar: const ChaupalAppHeader(title: 'कामगार सत्यापन'),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: future,
        builder: (context, s) {
          if (s.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (s.hasError) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Admin access required या verification data उपलब्ध नहीं है।')));
          final rows = s.data ?? [];
          if (rows.isEmpty) return const Center(child: Text('कोई pending कामगार सत्यापन नहीं है।'));

          return RefreshIndicator(
            onRefresh: () async {
              final next = _load();
              setState(() {
                future = next;
              });
              await next;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (c, i) {
                final w = rows[i];
                final workerId = w['user_id']?.toString() ?? '';
                final busy = _busyWorkers.contains(workerId);
                return Card(
                  color: t.secondaryBackground,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: t.alternate)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _ProfileAvatar(path: w['profile_photo']?.toString(), radius: 36),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${w['full_name']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 6),
                                  Text('${w['mobile_number']} • ${w['username']}', style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('${w['profession_name'] ?? 'अन्य काम'} • ${w['location_name'] ?? ''}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('स्थिति: ${w['verification_status']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        Text('आधार नंबर: ${w['aadhaar_number'] ?? ''}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 54,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF1976D2), side: const BorderSide(color: Color(0xFF1976D2), width: 2)),
                                  onPressed: busy ? null : () => _view('aadhaar-private', w['aadhaar_photo'] as String?),
                                  child: const Text('आधार फोटो', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 54,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF1976D2), side: const BorderSide(color: Color(0xFF1976D2), width: 2)),
                                  onPressed: busy ? null : () => _view('worker-verification', w['live_verification_photo'] as String?),
                                  child: const Text('लाइव फोटो', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 56,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
                                  onPressed: busy ? null : () => _review(w, 'approved'),
                                  child: busy ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('मंजूर करें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 56,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFF59E0B), side: const BorderSide(color: Color(0xFFF59E0B), width: 2)),
                                  onPressed: busy ? null : () => _review(w, 'more_info'),
                                  child: const Text('और जानकारी', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 56,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFDC2626), side: const BorderSide(color: Color(0xFFDC2626), width: 2)),
                                  onPressed: busy ? null : () => _review(w, 'rejected'),
                                  child: const Text('अस्वीकार करें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                                ),
                              ),
                            ),
                          ],
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.path, required this.radius});
  final String? path;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) return CircleAvatar(radius: radius, child: const Icon(Icons.person, size: 32));
    final url = SupaFlow.client.storage.from('profile-media').getPublicUrl(path!);
    return CircleAvatar(radius: radius, backgroundImage: NetworkImage(url), onBackgroundImageError: (_, __) {});
  }
}
