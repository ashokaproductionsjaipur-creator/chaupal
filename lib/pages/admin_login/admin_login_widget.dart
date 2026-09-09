import '/backend/supabase/supabase.dart';
import '/auth/custom_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class AdminLoginWidget extends StatefulWidget {
  const AdminLoginWidget({super.key});

  static String routeName = 'AdminLogin';
  static String routePath = '/adminLogin';

  @override
  State<AdminLoginWidget> createState() => _AdminLoginWidgetState();
}

class _AdminLoginWidgetState extends State<AdminLoginWidget> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool obscure = true;
  bool busy = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _login() async {
    final e = email.text.trim().toLowerCase();
    final p = password.text;
    if (e.isEmpty || p.isEmpty) {
      _message('Admin Email और Password भरें।');
      return;
    }
    if (busy) return;
    FocusScope.of(context).unfocus();
    setState(() => busy = true);
    try {
      final result = await SupaFlow.client.auth.signInWithPassword(email: e, password: p);
      final user = result.user;
      final session = result.session;
      if (user == null || session == null) {
        _message('Admin login नहीं हो सका।');
        return;
      }

      final allowed = await SupaFlow.client.rpc('is_admin');
      if (allowed != true) {
        await SupaFlow.client.auth.signOut();
        _message('यह account Admin के लिए authorized नहीं है।');
        return;
      }

      await authManager.signIn(
        authenticationToken: session.accessToken,
        refreshToken: session.refreshToken,
        tokenExpiration: DateTime.now().add(const Duration(hours: 1)),
        authUid: user.id,
        userData: null,
      );

      if (!mounted) return;
      context.go('/adminDashboard');
    } catch (e) {
      if (mounted) _message('Admin login failed। Email/Password जाँचें।');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: t.primaryBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    child: const Icon(Icons.admin_panel_settings_outlined, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 22),
                  const Text('CHAUPAL ADMIN', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text('केवल authorized Admin के लिए', style: TextStyle(color: t.secondaryText, fontSize: 15)),
                  const SizedBox(height: 28),
                  TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Admin Email', hintText: 'admin@example.com', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: password,
                    obscureText: obscure,
                    onSubmitted: (_) => _login(),
                    decoration: InputDecoration(labelText: 'Password | पासवर्ड', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => obscure = !obscure), icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined)), border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 58,
                    child: FilledButton.icon(
                      onPressed: busy ? null : _login,
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF111827), foregroundColor: Colors.white),
                      icon: Icon(busy ? Icons.hourglass_top : Icons.login),
                      label: Text(busy ? 'Login हो रहा है...' : 'ADMIN LOGIN', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: t.secondaryBackground, borderRadius: BorderRadius.circular(16), border: Border.all(color: t.alternate)),
                    child: const Row(children: [Icon(Icons.verified_user_outlined, size: 28), SizedBox(width: 12), Expanded(child: Text('Admin authorization Supabase backend पर verify होगी। केवल password जानना पर्याप्त नहीं है।', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)))]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
