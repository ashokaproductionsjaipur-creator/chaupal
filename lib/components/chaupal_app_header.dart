import '/auth/custom_auth/auth_util.dart';
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

  void _showProfile(BuildContext context) {
    final user = currentUserData;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Profile | प्रोफाइल'),
        content: Text(
          '${user?.fullName ?? ''}\n'
          '${user?.username ?? ''}\n'
          '${user?.mobileNumber ?? ''}',
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
