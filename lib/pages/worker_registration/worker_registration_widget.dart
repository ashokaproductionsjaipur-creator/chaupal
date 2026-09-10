import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '/backend/supabase/supabase.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/schema/structs/chaupal_auth_user_struct.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/index.dart';

class WorkerRegistrationWidget extends StatefulWidget {
  const WorkerRegistrationWidget({super.key});
  static String routeName = 'WorkerRegistration';
  static String routePath = '/workerRegistration';
  @override
  State<WorkerRegistrationWidget> createState() => _WorkerRegistrationWidgetState();
}

class _WorkerRegistrationWidgetState extends State<WorkerRegistrationWidget> {
  final name = TextEditingController();
  final mobile = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  final aadhaar = TextEditingController();
  final otherProfession = TextEditingController();
  final picker = ImagePicker();

  String role = 'owner';
  int? locationId;
  int? professionId;
  List<Map<String, dynamic>> locations = [];
  List<Map<String, dynamic>> professions = [];
  XFile? profilePhoto;
  XFile? aadhaarPhoto;
  XFile? livePhoto;
  bool busy = false;
  bool loadingMasters = true;

  @override
  void initState() { super.initState(); _loadMasters(); }
  @override
  void dispose() {
    for (final c in [name, mobile, username, password, confirm, aadhaar, otherProfession]) c.dispose();
    super.dispose();
  }

  Future<void> _loadMasters() async {
    if (mounted) setState(() => loadingMasters = true);
    try {
      final r = await http.get(Uri.parse('https://iaumkrgocskwhhwdwnxj.supabase.co/functions/v1/chaupal-masters'));
      final body = jsonDecode(r.body);
      if (r.statusCode < 200 || r.statusCode >= 300 || body is! Map || body['ok'] != true) throw Exception(body is Map && body['message'] is String ? body['message'] : 'Master data could not be loaded.');
      if (mounted) setState(() {
        locations = List<Map<String, dynamic>>.from(body['locations'] is List ? body['locations'] : const []);
        professions = List<Map<String, dynamic>>.from(body['professions'] is List ? body['professions'] : const []);
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dropdown data load failed: ${e.toString().replaceFirst('Exception: ', '')}')));
    } finally { if (mounted) setState(() => loadingMasters = false); }
  }

  Future<XFile?> _image({required bool cameraOnly}) async {
    final source = cameraOnly ? ImageSource.camera : await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (c) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(title: const Text('Camera'), leading: const Icon(Icons.camera_alt_outlined), onTap: () => Navigator.pop(c, ImageSource.camera)),
        ListTile(title: const Text('Gallery'), leading: const Icon(Icons.photo_library_outlined), onTap: () => Navigator.pop(c, ImageSource.gallery)),
      ])),
    );
    if (source == null) return null;
    return picker.pickImage(source: source, imageQuality: 80, maxWidth: 1600);
  }

  Future<void> _pickAndSet(String type) async {
    final x = await _image(cameraOnly: type == 'live');
    if (x == null || !mounted) return;
    setState(() {
      if (type == 'profile') profilePhoto = x;
      else if (type == 'aadhaar') aadhaarPhoto = x;
      else livePhoto = x;
    });
  }

  Future<void> _register() async {
    if (busy) return;
    final selectedRole = role.toLowerCase();
    final u = username.text.trim().toLowerCase();
    final m = mobile.text.trim();
    final p = password.text;
    final commonInvalid = name.text.trim().isEmpty || !RegExp(r'^\d{10}$').hasMatch(m) || u.length < 3 || p.length < 8 || p != confirm.text || profilePhoto == null || aadhaar.text.trim().length != 12 || aadhaarPhoto == null;
    if (commonInvalid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Required fields सही भरें और सभी जरूरी photos चुनें. Password कम से कम 8 characters होना चाहिए.')));
      return;
    }
    if (selectedRole == 'worker' && locationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Worker के लिए चौपाल लोकेशन चुनना जरूरी है।')));
      return;
    }
    if (selectedRole == 'worker' && professionId == null && otherProfession.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profession चुनें.')));
      return;
    }
    if (selectedRole == 'worker' && livePhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Worker verification के लिए Live Verification Photo जरूरी है.')));
      return;
    }

    setState(() => busy = true);
    try {
      final response = await http.post(
        Uri.parse('https://iaumkrgocskwhhwdwnxj.supabase.co/functions/v1/username-auth'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'signup', 'username': u, 'password': p, 'role': selectedRole, 'full_name': name.text.trim(), 'mobile_number': m}),
      );
      dynamic body;
      try { body = jsonDecode(response.body); } catch (_) { body = null; }
      if (response.statusCode < 200 || response.statusCode >= 300 || body is! Map || body['ok'] != true) {
        final code = body is Map && body['code'] is String ? body['code'] : 'http_${response.statusCode}';
        final message = body is Map && body['message'] is String ? body['message'] : 'Account could not be created.';
        throw Exception('$code: $message');
      }

      final access = body['access_token']?.toString();
      final refresh = body['refresh_token']?.toString();
      final uid = body['user_id']?.toString();
      if (access == null || refresh == null || uid == null) throw Exception('Registration session could not be created.');
      await SupaFlow.client.auth.setSession(refresh);
      final expires = body['expires_at'] is num
          ? DateTime.fromMillisecondsSinceEpoch((body['expires_at'] as num).toInt() * 1000)
          : DateTime.now().add(Duration(seconds: (body['expires_in'] ?? 3600) is num ? (body['expires_in'] as num).toInt() : 3600));

      // Do NOT publish the temporary signup profile to the app router yet.
      // complete_registration is the authoritative source for the final role/status.
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final profilePath = '$uid/profile_$stamp.jpg';
      final aadhaarPath = '$uid/aadhaar_$stamp.jpg';
      await SupaFlow.client.storage.from('profile-media').uploadBinary(profilePath, await profilePhoto!.readAsBytes(), fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: false));
      await SupaFlow.client.storage.from('aadhaar-private').uploadBinary(aadhaarPath, await aadhaarPhoto!.readAsBytes(), fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: false));
      String? livePath;
      if (selectedRole == 'worker') {
        livePath = '$uid/live_$stamp.jpg';
        await SupaFlow.client.storage.from('worker-verification').uploadBinary(livePath, await livePhoto!.readAsBytes(), fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: false));
      }

      final result = await SupaFlow.client.rpc('complete_registration', params: {
        'p_full_name': name.text.trim(),
        'p_mobile_number': m,
        'p_username': u,
        'p_role': selectedRole,
        'p_chaupal_location_id': selectedRole == 'worker' ? locationId : null,
        'p_profession_id': selectedRole == 'worker' ? professionId : null,
        'p_other_profession': selectedRole == 'worker' ? otherProfession.text.trim() : '',
        'p_aadhaar_number': aadhaar.text.trim(),
        'p_aadhaar_photo': aadhaarPath,
        'p_profile_photo': profilePath,
        'p_live_verification_photo': livePath,
      });
      final profile = Map<String, dynamic>.from(result as Map);
      final registeredRole = (profile['role'] ?? '').toString().trim().toLowerCase();
      final registeredStatus = (profile['account_status'] ?? '').toString().trim().toLowerCase();
      if (registeredRole != 'owner' && registeredRole != 'worker') throw Exception('Server returned an invalid registration role.');
      if (registeredRole != selectedRole) throw Exception('Registration role mismatch. Please try again.');

      // Publish auth state only after the server has completed registration.
      await authManager.signIn(
        authenticationToken: access,
        refreshToken: refresh,
        tokenExpiration: expires,
        authUid: uid,
        userData: ChaupalAuthUserStruct.fromMap(profile),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
        registeredRole == 'worker' ? 'Account created. Verification pending.' : 'Account created successfully.',
      )));

      // Route strictly from the authoritative server role/status.
      if (registeredRole == 'worker') {
        context.pushNamed(WorkerProfileStatusWidget.routeName);
      } else if (registeredRole == 'owner' && registeredStatus == 'active') {
        context.pushNamed(OwnerDashboardWidget.routeName);
      } else {
        throw Exception('Owner account is not active.');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed: ${e.toString().replaceFirst('Exception: ', '')}')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: t.primaryBackground,
      appBar: AppBar(backgroundColor: t.primaryBackground, foregroundColor: t.primaryText, elevation: 0, title: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.w900))),
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560), child: ListView(padding: const EdgeInsets.fromLTRB(16, 6, 16, 30), children: [
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: t.secondaryBackground, borderRadius: BorderRadius.circular(24), border: Border.all(color: t.alternate)), child: Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: t.primaryText, borderRadius: BorderRadius.circular(16)), alignment: Alignment.center, child: Text('च', style: TextStyle(color: t.primaryBackground, fontSize: 25, fontWeight: FontWeight.w900))),
          const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Join CHAUPAL', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)), SizedBox(height: 3), Text('काम और कामगार — एक ही जगह', style: TextStyle(fontSize: 12))])), const Icon(Icons.verified_outlined),
        ])),
        const SizedBox(height: 18), Text('आप कैसे जुड़ना चाहते हैं?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: t.primaryText)),
        const SizedBox(height: 4), Text('Choose your role to continue', style: TextStyle(color: t.secondaryText, fontSize: 13)), const SizedBox(height: 14),
        Row(children: [Expanded(child: _roleChoice(t, 'owner', Icons.business_center_rounded, 'Owner', 'मालिक')), const SizedBox(width: 10), Expanded(child: _roleChoice(t, 'worker', Icons.construction_rounded, 'Worker', 'कामगार'))]),
        const SizedBox(height: 22), _section(t, 'Basic Information', 'बुनियादी जानकारी'), const SizedBox(height: 12),
        _field('Full Name | पूरा नाम', name, 'अपना नाम', icon: Icons.person_outline_rounded), const SizedBox(height: 11),
        _field('Mobile Number | मोबाइल', mobile, '10 digit mobile', keyboard: TextInputType.phone, icon: Icons.phone_outlined), const SizedBox(height: 11),
        _field('Username | यूजरनेम', username, 'unique username', icon: Icons.alternate_email_rounded), const SizedBox(height: 11),
        _field('Password | पासवर्ड', password, 'कम से कम 8 characters', obscure: true, icon: Icons.lock_outline_rounded), const SizedBox(height: 11),
        _field('Confirm Password | पुष्टि', confirm, 'password again', obscure: true, icon: Icons.lock_reset_outlined), const SizedBox(height: 18),
        _section(t, 'Work Details', 'काम की जानकारी'), const SizedBox(height: 12),
        if (role == 'worker') _locationDropdown(),
        if (role == 'worker') ...[const SizedBox(height: 11), _professionDropdown(), const SizedBox(height: 11), _field('Other Profession | अन्य', otherProfession, 'Only if needed', icon: Icons.work_outline)],
        if (role == 'owner') const Padding(padding: EdgeInsets.only(top: 2), child: Text('Owner किसी भी चौपाल से जॉब पोस्ट कर सकता है। जॉब पोस्ट करते समय चौपाल चुनी जाएगी।', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        const SizedBox(height: 18), _section(t, 'Verification', 'सत्यापन'), const SizedBox(height: 5),
        Text(role == 'worker' ? 'Worker verification के लिए identity और live photo जरूरी हैं.' : 'Identity verification के लिए Aadhaar और profile photo जरूरी हैं.', style: TextStyle(color: t.secondaryText, fontSize: 12, height: 1.35)), const SizedBox(height: 12),
        _field('Aadhaar Number | आधार', aadhaar, '12 digit', keyboard: TextInputType.number, icon: Icons.badge_outlined), const SizedBox(height: 11),
        _photoTile('Profile Photo | प्रोफाइल फोटो *', profilePhoto, () => _pickAndSet('profile'), cameraOnly: false), const SizedBox(height: 10),
        _photoTile('Aadhaar Photo | आधार फोटो *', aadhaarPhoto, () => _pickAndSet('aadhaar'), cameraOnly: false),
        if (role == 'worker') ...[const SizedBox(height: 10), _photoTile('Live Verification Photo | Live फोटो *', livePhoto, () => _pickAndSet('live'), cameraOnly: true)],
        const SizedBox(height: 20), SizedBox(height: 56, child: FilledButton.icon(onPressed: busy ? null : _register, icon: Icon(busy ? Icons.hourglass_top_rounded : Icons.check_circle_outline_rounded), label: Text(busy ? 'Creating account...' : 'Create Account  |  अकाउंट बनाएं', style: const TextStyle(fontWeight: FontWeight.w800)))),
        const SizedBox(height: 14), Text('By continuing, you agree to use CHAUPAL responsibly.', textAlign: TextAlign.center, style: TextStyle(color: t.secondaryText, fontSize: 10.5)),
      ]))),
    );
  }

  Widget _section(FlutterFlowTheme t, String en, String hi) => Row(children: [Text(en, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)), const SizedBox(width: 7), Text('• $hi', style: TextStyle(color: t.secondaryText, fontSize: 12, fontWeight: FontWeight.w600))]);

  Widget _roleChoice(FlutterFlowTheme t, String value, IconData icon, String en, String hi) {
    final selected = role == value;
    return InkWell(borderRadius: BorderRadius.circular(18), onTap: busy ? null : () => setState(() { role = value; if (role == 'owner') { locationId = null; professionId = null; livePhoto = null; } }), child: AnimatedContainer(duration: const Duration(milliseconds: 160), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: selected ? t.primaryText.withValues(alpha: 0.06) : t.secondaryBackground, borderRadius: BorderRadius.circular(18), border: Border.all(color: selected ? t.primaryText : t.alternate, width: selected ? 1.5 : 1)), child: Row(children: [Container(width: 43, height: 43, decoration: BoxDecoration(color: selected ? t.primaryText : t.primaryText.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: selected ? t.primaryBackground : t.primaryText)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(en, style: const TextStyle(fontWeight: FontWeight.w800)), Text(hi, style: TextStyle(color: t.secondaryText, fontSize: 11))])), Icon(selected ? Icons.check_circle_rounded : Icons.circle_outlined, size: 21)])));
  }

  Widget _photoTile(String label, XFile? file, VoidCallback onTap, {required bool cameraOnly}) {
    final t = FlutterFlowTheme.of(context);
    return InkWell(onTap: busy ? null : onTap, borderRadius: BorderRadius.circular(18), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: t.secondaryBackground, borderRadius: BorderRadius.circular(18), border: Border.all(color: t.alternate)), child: Row(children: [_LocalPhotoPreview(file: file, size: 72), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(file == null ? label : '$label ✓', style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(file == null ? (cameraOnly ? 'Camera से photo लें' : 'Camera या Gallery से photo चुनें') : 'Photo selected • Tap to change', style: TextStyle(color: t.secondaryText, fontSize: 11.5))])), Icon(file == null ? Icons.add_a_photo_outlined : Icons.edit_outlined)])));
  }

  Widget _locationDropdown() => DropdownButtonFormField<int>(value: locationId, isExpanded: true, menuMaxHeight: 420, decoration: const InputDecoration(labelText: 'Chaupal Location | चौपाल लोकेशन *', hintText: 'Select Chaupal Location', border: OutlineInputBorder(), suffixIcon: Icon(Icons.location_on_outlined)), items: loadingMasters ? const [] : locations.map((x) { final id = (x['id'] as num).toInt(); return DropdownMenuItem<int>(value: id, child: Text('${x['display_name']}', overflow: TextOverflow.ellipsis)); }).toList(), onChanged: loadingMasters || busy ? null : (v) => setState(() => locationId = v));
  Widget _professionDropdown() => DropdownButtonFormField<int>(value: professionId, isExpanded: true, menuMaxHeight: 420, decoration: const InputDecoration(labelText: 'Profession | प्रोफेशन', hintText: 'Select Profession', border: OutlineInputBorder(), suffixIcon: Icon(Icons.work_outline)), items: professions.map((x) { final id = (x['id'] as num).toInt(); return DropdownMenuItem<int>(value: id, child: Text('${x['display_name']}', overflow: TextOverflow.ellipsis)); }).toList(), onChanged: busy ? null : (v) => setState(() => professionId = v));
  Widget _field(String label, TextEditingController c, String hint, {TextInputType? keyboard, bool obscure = false, IconData? icon}) => TextField(controller: c, keyboardType: keyboard, obscureText: obscure, enabled: !busy, decoration: InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder(), prefixIcon: icon == null ? null : Icon(icon)));
}

class _LocalPhotoPreview extends StatelessWidget {
  const _LocalPhotoPreview({required this.file, required this.size});
  final XFile? file;
  final double size;
  @override
  Widget build(BuildContext context) {
    if (file == null) return Container(width: size, height: size, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: FlutterFlowTheme.of(context).alternate)), child: const Icon(Icons.image_outlined, size: 30));
    return ClipRRect(borderRadius: BorderRadius.circular(12), child: FutureBuilder<Uint8List>(future: file!.readAsBytes(), builder: (context, snapshot) { if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) return Image.memory(snapshot.data!, width: size, height: size, fit: BoxFit.cover); return Container(width: size, height: size, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: FlutterFlowTheme.of(context).alternate)), child: const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)))); }));
  }
}