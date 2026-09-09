import '/auth/custom_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/role_selection/role_selection_widget.dart';
import 'package:flutter/material.dart';

/// Shared header for authenticated pages.
/// Login and role-selection pages intentionally do not use this header.
class ChaupalAppHeader extends StatelessWidget implements PreferredSizeWidget {
  const ChaupalAppHeader({
    super.key,
    required this.title,
    this.showBack = true,
  });

  final String title;
  final bool showBack;

  Future<void> _logout(BuildContext context) async {
    await authManager.signOut();
    if (context.mounted) {
      context.goNamed(RoleSelectionWidget.routeName);
    }
  }

  Future<Map<String, dynamic>> _loadProfile() async {
    final role = currentUserData?.role.toLowerCase() ?? '';

    try {
      if (role == 'worker') {
        final result = await SupaFlow.client.rpc('get_my_worker_status');
        final data = Map<String, dynamic>.from(result as Map);
        return Map<String, dynamic>.from((data['user'] as Map?) ?? {});
      }

      if (role == 'owner') {
        final result = await SupaFlow.client.rpc('get_owner_dashboard');
        final data = Map<String, dynamic>.from(result as Map);
        return Map<String, dynamic>.from((data['profile'] as Map?) ?? {});
      }
    } catch (_) {
      // Keep the profile dialog usable even if the profile RPC is unavailable.
    }

    return {
      'full_name': currentUserData?.fullName ?? '',
      'username': currentUserData?.username ?? '',
      'mobile_number': currentUserData?.mobileNumber ?? '',
      'profile_photo': '',
    };
  }

  Future<void> _showProfile(BuildContext context) async {
    final profile = await _loadProfile();
    if (!context.mounted) return;

    final photoPath = profile['profile_photo']?.toString() ?? '';
    final photoUrl = photoPath.isNotEmpty
        ? SupaFlow.client.storage.from('profile-media').getPublicUrl(photoPath)
        : '';

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Profile | प्रोफाइल'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 42,
              backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              child: photoUrl.isEmpty ? const Icon(Icons.person, size: 42) : null,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${profile['full_name'] ?? ''}\n'
                '${profile['username'] ?? currentUserData?.username ?? ''}\n'
                '${profile['mobile_number'] ?? currentUserData?.mobileNumber ?? ''}',
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close | बंद करें'),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return AppBar(
      backgroundColor: theme.primaryBackground,
      foregroundColor: theme.primaryText,
      elevation: 0,
      titleSpacing: 0,
      leading: showBack
          ? IconButton(
              tooltip: 'Back | पीछे',
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                }
              },
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w900,
          letterSpacing: .4,
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Profile | प्रोफाइल',
          icon: const Icon(Icons.account_circle_outlined),
          onPressed: () => _showProfile(context),
        ),
        IconButton(
          tooltip: 'Logout | लॉगआउट',
          icon: const Icon(Icons.logout_rounded),
          onPressed: () => _logout(context),
        ),
        const SizedBox(width: 6),
      ],
    );
  }
}
