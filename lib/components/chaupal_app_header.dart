import '/auth/custom_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/role_selection/role_selection_widget.dart';
import '/pages/job_history_archive/job_history_archive_widget.dart';
import 'package:flutter/material.dart';

class ChaupalAppHeader extends StatelessWidget implements PreferredSizeWidget {
  const ChaupalAppHeader({super.key, required this.title, this.showBack = true, this.showWorkerLocation = false, this.onWorkerLocationChanged});
  final String title;
  final bool showBack;
  final bool showWorkerLocation;
  final VoidCallback? onWorkerLocationChanged;

  Future<void> _logout(BuildContext context) async {
    await authManager.signOut();
    if (context.mounted) context.goNamed(RoleSelectionWidget.routeName);
  }

  Future<Map<String, dynamic>> _loadProfile() async {
    final role = currentUserData?.role.toLowerCase() ?? '';
    try {
      if (role == 'worker') {
        final result = await SupaFlow.client.rpc('get_my_worker_status');
        final data = Map<String, dynamic>.from(result as Map);
        final user = Map<String, dynamic>.from((data['user'] as Map?) ?? {});
        final location = Map<String, dynamic>.from((data['location'] as Map?) ?? {});
        user['location_name'] = location['display_name']?.toString() ?? '';
        return user;
      }
      if (role == 'owner') {
        final result = await SupaFlow.client.rpc('get_owner_dashboard');
        final data = Map<String, dynamic>.from(result as Map);
        final profile = Map<String, dynamic>.from((data['profile'] as Map?) ?? {});
        profile['location_name'] = '';
        return profile;
      }
    } catch (_) {}
    return {'full_name': currentUserData?.fullName ?? '', 'username': currentUserData?.username ?? '', 'mobile_number': currentUserData?.mobileNumber ?? '', 'profile_photo': '', 'location_name': ''};
  }

  Future<void> _showProfile(BuildContext context) async {
    final profile = await _loadProfile();
    if (!context.mounted) return;
    final photoPath = profile['profile_photo']?.toString() ?? '';
    final photoUrl = photoPath.isNotEmpty ? SupaFlow.client.storage.from('profile-media').getPublicUrl(photoPath) : '';
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('प्रोफाइल देखें', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(radius: 52, backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null, child: photoUrl.isEmpty ? const Icon(Icons.person, size: 52) : null),
          const SizedBox(height: 20),
          _ProfileDetail(label: 'नाम', value: profile['full_name']?.toString()),
          _ProfileDetail(label: 'उपयोगकर्ता नाम', value: profile['username']?.toString()),
          _ProfileDetail(label: 'मोबाइल नंबर', value: profile['mobile_number']?.toString()),
          if ((profile['location_name']?.toString() ?? '').isNotEmpty) _ProfileDetail(label: 'स्थान', value: profile['location_name']?.toString()),
        ])),
        actions: [
          SizedBox(width: double.infinity, height: 52, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1976D2), foregroundColor: Colors.white), onPressed: () { Navigator.pop(dialogContext); context.pushNamed(JobHistoryArchiveWidget.routeName); }, child: const Text('मेरी जॉब हिस्ट्री देखें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)))),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, height: 52, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white), onPressed: () => Navigator.pop(dialogContext), child: const Text('बंद करें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)))),
        ],
      ),
    );
  }

  Future<void> _changeWorkerLocation(BuildContext context) async {
    if ((currentUserData?.role ?? '').toLowerCase() != 'worker') return;
    try {
      final result = await SupaFlow.client.rpc('get_my_worker_status');
      final data = Map<String, dynamic>.from(result as Map);
      final user = Map<String, dynamic>.from((data['user'] as Map?) ?? {});
      final currentId = (user['chaupal_location_id'] as num?)?.toInt();
      final rows = await SupaFlow.client.from('chaupal_locations').select('id,display_name').eq('active', true).order('id');
      final locations = (rows as List).map((r) => Map<String, dynamic>.from(r as Map)).toList();
      if (!context.mounted) return;
      final selected = await showDialog<int>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('अपनी चौपाल बदलें', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
          content: SizedBox(width: 420, child: DropdownButtonFormField<int>(
            value: locations.any((x) => (x['id'] as num).toInt() == currentId) ? currentId : null,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'चौपाल स्थान', border: OutlineInputBorder()),
            items: locations.map((x) => DropdownMenuItem<int>(value: (x['id'] as num).toInt(), child: Text('${x['display_name']}'))).toList(),
            onChanged: (v) { if (v != null) Navigator.pop(dialogContext, v); },
          )),
          actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('रद्द करें'))],
        ),
      );
      if (selected == null) return;
      await SupaFlow.client.rpc('update_my_worker_location', params: {'p_chaupal_location_id': selected});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('चौपाल स्थान बदल दिया गया है। अब जॉब्स इसी चौपाल के अनुसार मिलेंगी।')));
        onWorkerLocationChanged?.call();
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('चौपाल बदल नहीं सकी: $e')));
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return AppBar(
      backgroundColor: theme.primaryBackground,
      foregroundColor: theme.primaryText,
      elevation: 0,
      toolbarHeight: 76,
      titleSpacing: 0,
      leadingWidth: showBack ? 84 : 0,
      leading: showBack ? _HeaderAction(
        icon: Icons.arrow_back_rounded,
        label: 'पीछे जाएँ',
        backgroundColor: const Color(0xFF1976D2),
        onTap: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.goNamed(RoleSelectionWidget.routeName);
          }
        },
      ) : null,
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
      actions: [
        if (showWorkerLocation) _HeaderAction(icon: Icons.location_on_outlined, label: 'चौपाल बदलें', backgroundColor: const Color(0xFFF59E0B), onTap: () => _changeWorkerLocation(context)),
        if (showWorkerLocation) const SizedBox(width: 2),
        _HeaderAction(icon: Icons.account_circle_outlined, label: 'प्रोफाइल देखें', backgroundColor: const Color(0xFF16A34A), onTap: () => _showProfile(context)),
        const SizedBox(width: 2),
        _HeaderAction(icon: Icons.logout_rounded, label: 'लॉगआउट', backgroundColor: const Color(0xFFDC2626), onTap: () => _logout(context)),
        const SizedBox(width: 6),
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({required this.icon, required this.label, required this.backgroundColor, required this.onTap});
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 78,
          height: 68,
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
          decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 29, color: Colors.white),
              const SizedBox(height: 2),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileDetail extends StatelessWidget {
  const _ProfileDetail({required this.label, this.value});
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 125, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
          Expanded(child: Text(value?.isNotEmpty == true ? value! : 'उपलब्ध नहीं', style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
