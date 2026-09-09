import '/auth/custom_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/role_selection/role_selection_widget.dart';
import 'package:flutter/material.dart';

/// Shared header for authenticated pages.
/// Login and role-selection pages intentionally do not use this header.
/// The controls use strong, distinct colors and large touch targets so the
/// app remains easy to understand for users with limited literacy.
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
        final user = Map<String, dynamic>.from((data['user'] as Map?) ?? {});
        final location = Map<String, dynamic>.from((data['location'] as Map?) ?? {});
        user['location_name'] = location['display_name']?.toString() ?? '';
        return user;
      }

      if (role == 'owner') {
        final result = await SupaFlow.client.rpc('get_owner_dashboard');
        final data = Map<String, dynamic>.from(result as Map);
        final profile = Map<String, dynamic>.from((data['profile'] as Map?) ?? {});
        final locationId = profile['chaupal_location_id']?.toString() ?? '';
        profile['location_name'] = locationId.isNotEmpty
            ? 'चौपाल नंबर $locationId'
            : '';
        return profile;
      }
    } catch (_) {
      // Keep the profile dialog usable even if the profile RPC is unavailable.
    }

    return {
      'full_name': currentUserData?.fullName ?? '',
      'username': currentUserData?.username ?? '',
      'mobile_number': currentUserData?.mobileNumber ?? '',
      'profile_photo': '',
      'location_name': '',
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
        title: const Text(
          'प्रोफाइल देखें',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 52,
                backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                child: photoUrl.isEmpty ? const Icon(Icons.person, size: 52) : null,
              ),
              const SizedBox(height: 20),
              _ProfileDetail(label: 'नाम', value: profile['full_name']?.toString()),
              _ProfileDetail(label: 'उपयोगकर्ता नाम', value: profile['username']?.toString()),
              _ProfileDetail(label: 'मोबाइल नंबर', value: profile['mobile_number']?.toString()),
              _ProfileDetail(label: 'स्थान', value: profile['location_name']?.toString()),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF15803D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'बंद करें',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(82);

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return AppBar(
      backgroundColor: theme.primaryBackground,
      foregroundColor: theme.primaryText,
      elevation: 0,
      toolbarHeight: 82,
      titleSpacing: 6,
      leadingWidth: showBack ? 92 : 0,
      leading: showBack
          ? _HeaderAction(
              icon: Icons.arrow_back_rounded,
              label: 'पीछे जाएँ',
              backgroundColor: const Color(0xFF1565C0),
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                }
              },
            )
          : null,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      actions: [
        _HeaderAction(
          icon: Icons.account_circle_outlined,
          label: 'प्रोफाइल देखें',
          backgroundColor: const Color(0xFF15803D),
          onTap: () => _showProfile(context),
        ),
        const SizedBox(width: 5),
        _HeaderAction(
          icon: Icons.logout_rounded,
          label: 'लॉगआउट',
          backgroundColor: const Color(0xFFDC2626),
          onTap: () => _logout(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.onTap,
  });

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
        child: Ink(
          width: 86,
          height: 72,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                blurRadius: 3,
                offset: Offset(0, 2),
                color: Color(0x33000000),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 30, color: Colors.white),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
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
          SizedBox(
            width: 125,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ),
          Expanded(
            child: Text(
              value?.isNotEmpty == true ? value! : 'उपलब्ध नहीं',
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
