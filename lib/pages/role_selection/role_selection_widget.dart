import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/login_screen/login_screen_widget.dart';
import '/pages/worker_registration/worker_registration_widget.dart';
import 'package:flutter/material.dart';

class RoleSelectionWidget extends StatefulWidget {
  const RoleSelectionWidget({super.key});

  static String routeName = 'RoleSelection';
  static String routePath = '/roleSelection';

  @override
  State<RoleSelectionWidget> createState() => _RoleSelectionWidgetState();
}

class _RoleSelectionWidgetState extends State<RoleSelectionWidget> {
  String selectedRole = 'owner';

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isOwner = selectedRole == 'owner';

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: theme.primaryText,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'च',
                          style: TextStyle(
                            color: theme.primaryBackground,
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CHAUPAL',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                              ),
                            ),
                            Text(
                              'काम मिले • काम मिले सही लोगों को',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.help_outline_rounded),
                        tooltip: 'Help',
                      ),
                    ],
                  ),
                  const SizedBox(height: 34),
                  Text(
                    'चौपाल में आपका स्वागत है 👋',
                    style: TextStyle(
                      color: theme.primaryText,
                      fontSize: 30,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'अपने काम के हिसाब से शुरुआत करें',
                    style: TextStyle(
                      color: theme.secondaryText,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 25),
                  _roleCard(
                    context,
                    selected: isOwner,
                    icon: Icons.business_center_rounded,
                    title: 'मालिक (Owner)',
                    subtitle: 'मुझे काम पोस्ट करना है',
                    detail: 'काम डालें और सही कामगार से जुड़ें',
                    onTap: () => setState(() => selectedRole = 'owner'),
                  ),
                  const SizedBox(height: 14),
                  _roleCard(
                    context,
                    selected: !isOwner,
                    icon: Icons.construction_rounded,
                    title: 'कामगार (Worker)',
                    subtitle: 'मुझे काम ढूँढना है',
                    detail: 'अपने हुनर के अनुसार आसपास के काम देखें',
                    onTap: () => setState(() => selectedRole = 'worker'),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: theme.alternate),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.primaryText.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.verified_user_outlined,
                            color: theme.primaryText,
                            size: 21,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'सुरक्षित और verified marketplace\nSafe & verified marketplace',
                            style: TextStyle(
                              color: theme.primaryText,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 56,
                    child: FilledButton(
                      onPressed: () => context.pushNamed(LoginScreenWidget.routeName),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isOwner ? 'Owner Login | मालिक लॉगिन' : 'Worker Login | कामगार लॉगिन',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 9),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  OutlinedButton(
                    onPressed: () => context.pushNamed(WorkerRegistrationWidget.routeName),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'नया अकाउंट बनाएं  •  Create account',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Owner और Worker दोनों के लिए एक ही आसान CHAUPAL अनुभव',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.secondaryText,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'v1.0.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.secondaryText,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleCard(
    BuildContext context, {
    required bool selected,
    required IconData icon,
    required String title,
    required String subtitle,
    required String detail,
    required VoidCallback onTap,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: selected
                ? theme.primaryText.withValues(alpha: 0.055)
                : theme.secondaryBackground,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? theme.primaryText : theme.alternate,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: selected ? theme.primaryText : theme.primaryText.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  icon,
                  color: selected ? theme.primaryBackground : theme.primaryText,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: theme.primaryText,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.primaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      detail,
                      style: TextStyle(
                        color: theme.secondaryText,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected ? theme.primaryText : theme.secondaryText,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
