import '/backend/supabase/supabase.dart';
import '/backend/schema/structs/chaupal_auth_user_struct.dart';
import '/auth/custom_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/owner_dashboard/owner_dashboard_widget.dart';
import '/pages/worker_job_feed/worker_job_feed_widget.dart';
import '/pages/worker_profile_status/worker_profile_status_widget.dart';
import '/pages/worker_registration/worker_registration_widget.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreenWidget extends StatefulWidget {
  const LoginScreenWidget({super.key});
  static String routeName = 'LoginScreen';
  static String routePath = '/loginScreen';

  @override
  State<LoginScreenWidget> createState() => _LoginScreenWidgetState();
}

class _LoginScreenWidgetState extends State<LoginScreenWidget> {
  final username = TextEditingController();
  final password = TextEditingController();
  String selectedRole = 'owner';
  bool obscure = true;
  bool busy = false;

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final u = username.text.trim();
    final p = password.text;
    if (u.isEmpty || p.isEmpty) {
      showSnackbar(context, 'Username/Mobile and Password are required.');
      return;
    }
    if (busy) return;
    setState(() => busy = true);
    try {
      final response = await http.post(
        Uri.parse('https://iaumkrgocskwhhwdwnxj.supabase.co/functions/v1/chaupal-login-v3'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'username': u, 'password': p, 'role': selectedRole}),
      );
      dynamic body;
      try { body = jsonDecode(response.body); } catch (_) { body = null; }
      if (response.statusCode < 200 || response.statusCode >= 300 || body is! Map || body['ok'] != true) {
        final message = body is Map && body['message'] is String ? body['message'] as String : 'Invalid username/mobile or password.';
        showSnackbar(context, message);
        return;
      }
      final accessToken = body['access_token']?.toString();
      final refreshToken = body['refresh_token']?.toString();
      final userId = body['user_id']?.toString();
      if (accessToken == null || refreshToken == null || userId == null || body['user'] is! Map) {
        showSnackbar(context, 'Login session could not be created. Please try again.');
        return;
      }
      try { await SupaFlow.client.auth.setSession(refreshToken); } catch (_) {
        await SupaFlow.client.auth.signOut();
        showSnackbar(context, 'Login session could not be established. Please try again.');
        return;
      }
      final profile = await SupaFlow.client.from('users').select('id, username, mobile_number, full_name, role, account_status').eq('id', userId).maybeSingle();
      if (profile == null) {
        await SupaFlow.client.auth.signOut();
        showSnackbar(context, 'Account profile not found. Please contact support.');
        return;
      }
      final actualRole = (profile['role'] ?? '').toString().toLowerCase();
      final accountStatus = (profile['account_status'] ?? 'active').toString().toLowerCase();
      if (actualRole != selectedRole) {
        await SupaFlow.client.auth.signOut();
        showSnackbar(context, 'Selected role does not match this account.');
        return;
      }
      if (accountStatus == 'blocked' || accountStatus == 'rejected') {
        await SupaFlow.client.auth.signOut();
        showSnackbar(context, 'This account is not active. Please contact support.');
        return;
      }
      final expiresAt = body['expires_at'] is num ? DateTime.fromMillisecondsSinceEpoch((body['expires_at'] as num).toInt() * 1000) : null;
      await authManager.signIn(authenticationToken: accessToken, refreshToken: refreshToken, tokenExpiration: expiresAt, authUid: userId, userData: ChaupalAuthUserStruct.fromMap(profile));
      if (!mounted) return;
      if (selectedRole == 'owner') context.goNamed(OwnerDashboardWidget.routeName);
      else if (accountStatus == 'active') context.goNamed(WorkerJobFeedWidget.routeName);
      else context.goNamed(WorkerProfileStatusWidget.routeName);
    } catch (_) {
      showSnackbar(context, 'Login failed. Please try again.');
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
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Container(width: 46, height: 46, decoration: BoxDecoration(color: t.primaryText, borderRadius: BorderRadius.circular(15)), alignment: Alignment.center, child: Text('च', style: TextStyle(color: t.primaryBackground, fontSize: 25, fontWeight: FontWeight.w900))),
                    const SizedBox(width: 12),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('CHAUPAL', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: .6)), Text('काम • कामगार • भरोसा', style: TextStyle(fontSize: 11.5))])),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.help_outline_rounded)),
                  ]),
                  const SizedBox(height: 38),
                  Text('वापस स्वागत है 👋', style: TextStyle(color: t.primaryText, fontSize: 30, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 7),
                  Text('Login करके अपना CHAUPAL खोलें', style: TextStyle(color: t.secondaryText, fontSize: 14)),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: t.secondaryBackground, borderRadius: BorderRadius.circular(17), border: Border.all(color: t.alternate)),
                    child: Row(children: [
                      Expanded(child: _roleTab(t, 'owner', Icons.business_center_rounded, 'Owner', 'मालिक')),
                      Expanded(child: _roleTab(t, 'worker', Icons.construction_rounded, 'Worker', 'कामगार')),
                    ]),
                  ),
                  const SizedBox(height: 23),
                  _input(t, 'Username / Mobile', 'Username या mobile number', username, Icons.person_outline_rounded),
                  const SizedBox(height: 13),
                  TextField(
                    controller: password,
                    obscureText: obscure,
                    decoration: InputDecoration(labelText: 'Password | पासवर्ड', hintText: 'अपना password डालें', prefixIcon: const Icon(Icons.lock_outline_rounded), suffixIcon: IconButton(onPressed: () => setState(() => obscure = !obscure), icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined)), border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(height: 55, child: FilledButton.icon(onPressed: busy ? null : _login, icon: Icon(busy ? Icons.hourglass_top_rounded : Icons.login_rounded), label: Text(busy ? 'Logging in...' : 'Login  |  लॉगिन करें', style: const TextStyle(fontWeight: FontWeight.w800)))),
                  const SizedBox(height: 13),
                  OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.support_agent_outlined), label: const Text('Forgot Password?  •  Contact Support')),
                  const SizedBox(height: 26),
                  Row(children: [Expanded(child: Divider(color: t.alternate)), Padding(padding: const EdgeInsets.symmetric(horizontal: 13), child: Text('OR', style: TextStyle(color: t.secondaryText, fontSize: 11, fontWeight: FontWeight.w700))), Expanded(child: Divider(color: t.alternate))]),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: t.secondaryBackground, borderRadius: BorderRadius.circular(20), border: Border.all(color: t.alternate)),
                    child: Column(children: [
                      const Text('पहली बार CHAUPAL पर?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text('अपना Owner या Worker account बनाएं', style: TextStyle(color: t.secondaryText, fontSize: 11.5)),
                      const SizedBox(height: 12),
                      SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => context.goNamed(WorkerRegistrationWidget.routeName), child: const Text('Create Account  |  नया अकाउंट बनाएं', style: TextStyle(fontWeight: FontWeight.w800)))),
                    ]),
                  ),
                  const SizedBox(height: 22),
                  Text('Secure • Verified • Local marketplace', textAlign: TextAlign.center, style: TextStyle(color: t.secondaryText, fontSize: 10.5)),
                  const SizedBox(height: 5),
                  Text('v1.0.0', textAlign: TextAlign.center, style: TextStyle(color: t.secondaryText, fontSize: 10)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleTab(FlutterFlowTheme t, String value, IconData icon, String en, String hi) {
    final selected = selectedRole == value;
    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: () => setState(() => selectedRole = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
        decoration: BoxDecoration(color: selected ? t.primaryText : Colors.transparent, borderRadius: BorderRadius.circular(13)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 18, color: selected ? t.primaryBackground : t.primaryText), const SizedBox(width: 7), Text('$en | $hi', style: TextStyle(color: selected ? t.primaryBackground : t.primaryText, fontSize: 12, fontWeight: FontWeight.w800))]),
      ),
    );
  }

  Widget _input(FlutterFlowTheme t, String label, String hint, TextEditingController c, IconData icon) => TextField(controller: c, decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: Icon(icon), border: const OutlineInputBorder()));
}
