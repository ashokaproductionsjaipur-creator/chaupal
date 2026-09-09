import '/backend/api_requests/api_calls.dart';
import 'package:flutter/material.dart';

class WorkerRegistrationWidget extends StatefulWidget {
  const WorkerRegistrationWidget({super.key});

  static String routeName = 'WorkerRegistration';
  static String routePath = '/workerRegistration';

  @override
  State<WorkerRegistrationWidget> createState() =>
      _WorkerRegistrationWidgetState();
}

class _WorkerRegistrationWidgetState extends State<WorkerRegistrationWidget> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String _role = 'owner';
  String _profession = 'चिणाई मिस्त्री';
  String _chaupal = 'चौपाल नंबर 4';
  bool _loading = false;
  String? _result;

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _username.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_password.text != _confirm.text) {
      setState(() => _result = 'error: Passwords do not match.');
      return;
    }

    setState(() {
      _loading = true;
      _result = null;
    });

    try {
      final response = await ChaupalSignupCall.call(
        username: _username.text.trim(),
        password: _password.text,
        role: _role,
        fullName: _name.text.trim(),
        mobileNumber: _mobile.text.trim(),
      );

      final body = response.jsonBody;
      final ok = body is Map && body['ok'] == true;
      final code = body is Map ? '${body['code'] ?? ''}' : '';
      final message = body is Map
          ? '${body['message'] ?? (ok ? 'Registration successful.' : 'Registration failed.')}'
          : 'Unexpected server response.';

      if (!mounted) return;
      setState(() {
        _result = '${ok ? 'success' : 'error'}: $message${code.isNotEmpty ? ' [$code]' : ''}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _result = 'error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _dec(String label, String hint) => InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('कामगार पंजीकरण | Worker Registration')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'owner', label: Text('Owner | मालिक')),
                      ButtonSegment(value: 'worker', label: Text('Worker | कामगार')),
                    ],
                    selected: {_role},
                    onSelectionChanged: (v) => setState(() => _role = v.first),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(controller: _name, decoration: _dec('पूरा नाम | Full Name', 'अपना नाम लिखें'), validator: (v) => v == null || v.trim().isEmpty ? 'Full name required' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: _mobile, keyboardType: TextInputType.phone, decoration: _dec('मोबाइल नंबर | Mobile Number', '10 अंकों का नंबर'), validator: (v) => v == null || v.trim().length < 5 ? 'Valid mobile required' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: _username, decoration: _dec('यूजरनेम | Username', 'Username'), validator: (v) => v == null || v.trim().length < 3 ? 'Username must be at least 3 characters' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: _password, obscureText: true, decoration: _dec('पासवर्ड | Password', 'New password'), validator: (v) => v == null || v.length < 6 ? 'Password must be at least 6 characters' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: _confirm, obscureText: true, decoration: _dec('पासवर्ड की पुष्टि | Confirm Password', 'Repeat password'), validator: (v) => v == null || v.isEmpty ? 'Confirm password' : null),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _chaupal,
                    decoration: _dec('चौपाल लोकेशन | Chaupal Location', ''),
                    items: const [
                      DropdownMenuItem(value: 'चौपाल नंबर 1', child: Text('चौपाल नंबर 1')),
                      DropdownMenuItem(value: 'चौपाल नंबर 2', child: Text('चौपाल नंबर 2')),
                      DropdownMenuItem(value: 'चौपाल नंबर 3', child: Text('चौपाल नंबर 3')),
                      DropdownMenuItem(value: 'चौपाल नंबर 4', child: Text('चौपाल नंबर 4')),
                    ],
                    onChanged: (v) => setState(() => _chaupal = v ?? _chaupal),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _profession,
                    decoration: _dec('प्रोफेशन | Profession', ''),
                    items: const [
                      DropdownMenuItem(value: 'चिणाई मिस्त्री', child: Text('चिणाई मिस्त्री')),
                      DropdownMenuItem(value: 'प्लंबर मिस्त्री', child: Text('प्लंबर मिस्त्री')),
                      DropdownMenuItem(value: 'इलेक्ट्रिक मिस्त्री', child: Text('इलेक्ट्रिक मिस्त्री')),
                      DropdownMenuItem(value: 'पेंटर', child: Text('पेंटर')),
                      DropdownMenuItem(value: 'बढ़ई', child: Text('बढ़ई')),
                      DropdownMenuItem(value: 'अन्य', child: Text('अन्य')),
                    ],
                    onChanged: (v) => setState(() => _profession = v ?? _profession),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _loading ? null : _register,
                    child: Text(_loading ? 'Registering...' : 'पंजीकरण करें | Register'),
                  ),
                  if (_result != null) ...[
                    const SizedBox(height: 16),
                    SelectableText(_result!, style: TextStyle(fontWeight: FontWeight.w600, color: _result!.startsWith('success:') ? Colors.green : Colors.red)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
