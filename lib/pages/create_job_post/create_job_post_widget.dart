import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '/backend/supabase/supabase.dart';
import '/auth/custom_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

class CreateJobPostWidget extends StatefulWidget {
  const CreateJobPostWidget({super.key});
  static String routeName = 'CreateJobPost';
  static String routePath = '/createJobPost';
  @override
  State<CreateJobPostWidget> createState() => _CreateJobPostWidgetState();
}

class _CreateJobPostWidgetState extends State<CreateJobPostWidget> {
  final title = TextEditingController();
  final details = TextEditingController();
  final amount = TextEditingController();
  final picker = ImagePicker();
  final recorder = AudioRecorder();
  final player = AudioPlayer();
  List<Map<String, dynamic>> professions = [];
  int? professionId;
  int? locationId;
  DateTime? jobDate;
  TimeOfDay? startTime;
  XFile? workImage;
  String? audioPath;
  Timer? timer;
  int seconds = 0;
  bool recording = false;
  bool saving = false;

  @override
  void initState() { super.initState(); _loadMasters(); }
  @override
  void dispose() { timer?.cancel(); recorder.dispose(); player.dispose(); title.dispose(); details.dispose(); amount.dispose(); super.dispose(); }

  Future<void> _loadMasters() async {
    final uid = currentUserUid;
    final user = await SupaFlow.client.from('users').select('chaupal_location_id').eq('id', uid).maybeSingle();
    final p = await SupaFlow.client.from('professions').select('id,display_name').eq('active', true).order('sort_order');
    if (mounted) setState(() { locationId = user?['chaupal_location_id']; professions = List<Map<String, dynamic>>.from(p as List); });
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(context: context, builder: (c) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [ListTile(leading: const Icon(Icons.camera_alt_outlined), title: const Text('Camera'), onTap: () => Navigator.pop(c, ImageSource.camera)), ListTile(leading: const Icon(Icons.photo_library_outlined), title: const Text('Gallery'), onTap: () => Navigator.pop(c, ImageSource.gallery))])));
    if (source == null) return;
    final image = await picker.pickImage(source: source, imageQuality: 80, maxWidth: 1600);
    if (mounted && image != null) setState(() => workImage = image);
  }

  Future<void> _startRecording() async {
    if (!await recorder.hasPermission()) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Microphone permission is required.'))); return; }
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/chaupal_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 96000, sampleRate: 44100), path: path);
    timer?.cancel();
    setState(() { recording = true; seconds = 0; audioPath = null; });
    timer = Timer.periodic(const Duration(seconds: 1), (t) async { if (!mounted) return; setState(() => seconds++); if (seconds >= 60) await _stopRecording(); });
  }

  Future<void> _stopRecording() async {
    timer?.cancel();
    final path = await recorder.stop();
    if (mounted) setState(() { recording = false; audioPath = path; });
  }

  Future<void> _playRecording() async { if (audioPath != null) await player.play(DeviceFileSource(audioPath!)); }

  Future<void> _submit() async {
    if (saving) return;
    if (title.text.trim().isEmpty || professionId == null || workImage == null || audioPath == null || amount.text.trim().isEmpty || jobDate == null || startTime == null || locationId == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('सभी required fields भरें. Work Photo और Audio Note भी required हैं.'))); return; }
    final price = double.tryParse(amount.text.trim().replaceAll(',', ''));
    if (price == null || price <= 0) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expected Amount सही दर्ज करें.'))); return; }
    setState(() => saving = true);
    try {
      final allowed = await SupaFlow.client.rpc('enforce_job_posting_window', params: {'p_job_date': '${jobDate!.year.toString().padLeft(4,'0')}-${jobDate!.month.toString().padLeft(2,'0')}-${jobDate!.day.toString().padLeft(2,'0')}'});
      if (allowed != true) throw Exception('posting_window_closed');
      final uid = currentUserUid;
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final photoPath = '$uid/job_$stamp.jpg';
      final audioStoragePath = '$uid/job_$stamp.m4a';
      await SupaFlow.client.storage.from('job-media').upload(photoPath, File(workImage!.path), fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: false));
      await SupaFlow.client.storage.from('job-media').upload(audioStoragePath, File(audioPath!), fileOptions: const FileOptions(contentType: 'audio/mp4', upsert: false));
      final dateText = '${jobDate!.year.toString().padLeft(4,'0')}-${jobDate!.month.toString().padLeft(2,'0')}-${jobDate!.day.toString().padLeft(2,'0')}';
      final timeText = '${startTime!.hour.toString().padLeft(2,'0')}:${startTime!.minute.toString().padLeft(2,'0')}:00';
      await SupaFlow.client.rpc('create_chaupal_job', params: {'p_title': title.text.trim(), 'p_profession_id': professionId, 'p_work_photo': photoPath, 'p_audio_note': audioStoragePath, 'p_description': details.text.trim(), 'p_expected_amount': price, 'p_job_date': dateText, 'p_start_time': timeText, 'p_chaupal_location_id': locationId});
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job successfully posted.'))); context.goNamed('OwnerDashboard'); }
    } catch (e) {
      final s = e.toString();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.contains('posting_window_closed') ? 'अभी Job Posting बंद है। अगली Posting window में try करें.' : 'Job post नहीं हुई. Please try again.')));
    } finally { if (mounted) setState(() => saving = false); }
  }

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Scaffold(backgroundColor: t.primaryBackground, appBar: AppBar(backgroundColor: t.primaryBackground, foregroundColor: t.primaryText, elevation: 0, title: const Text('नई Job Post करें')), body: ListView(padding: const EdgeInsets.all(16), children: [
      _field('Job Title | जॉब का नाम', title, 'जैसे: Bathroom Tile Work'),
      const SizedBox(height: 14),
      DropdownButtonFormField<int>(value: professionId, decoration: const InputDecoration(labelText: 'Job Profession | प्रोफेशन'), items: professions.map((p) => DropdownMenuItem<int>(value: p['id'] as int, child: Text('${p['display_name']}'))).toList(), onChanged: (v) => setState(() => professionId = v)),
      const SizedBox(height: 14),
      ListTile(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: t.alternate)), title: Text(workImage == null ? 'Work Photo | काम की फोटो' : 'Work Photo selected ✓'), subtitle: const Text('Camera या Gallery'), trailing: const Icon(Icons.camera_alt_outlined), onTap: _pickImage),
      const SizedBox(height: 14),
      Card(color: t.secondaryBackground, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: t.alternate)), child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [Row(children: [const Expanded(child: Text('Audio Note | काम की जानकारी (max 1 min)')), Text('${seconds.toString().padLeft(2,'0')}/60')]), const SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.center, children: [IconButton(onPressed: recording ? _stopRecording : _startRecording, icon: Icon(recording ? Icons.stop_circle_outlined : Icons.mic_none_outlined, size: 36)), IconButton(onPressed: audioPath == null || recording ? null : _playRecording, icon: const Icon(Icons.play_arrow_outlined, size: 32)), IconButton(onPressed: audioPath == null || recording ? null : _startRecording, icon: const Icon(Icons.refresh_outlined, size: 28))]), if (audioPath != null) const Text('Audio ready ✓')]))),
      const SizedBox(height: 14), _field('Additional Details | अतिरिक्त जानकारी', details, 'Optional', maxLines: 4), const SizedBox(height: 14), _field('Expected Amount | अनुमानित राशि', amount, '₹ Amount', keyboard: TextInputType.number), const SizedBox(height: 14),
      ListTile(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: t.alternate)), title: Text(jobDate == null ? 'Job Date | तारीख चुनें' : '${jobDate!.day}/${jobDate!.month}/${jobDate!.year}'), trailing: const Icon(Icons.calendar_today_outlined), onTap: () async { final d = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 60)), initialDate: DateTime.now().add(const Duration(days: 1))); if (d != null) setState(() => jobDate = d); }),
      const SizedBox(height: 10), ListTile(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: t.alternate)), title: Text(startTime == null ? 'Job Start Time | समय चुनें' : startTime!.format(context)), trailing: const Icon(Icons.access_time_outlined), onTap: () async { final d = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 9, minute: 0)); if (d != null) setState(() => startTime = d); }),
      const SizedBox(height: 20), SizedBox(height: 52, child: FilledButton(onPressed: saving ? null : _submit, child: Text(saving ? 'Posting...' : 'Post Job | जॉब पोस्ट करें'))),
    ]));
  }
  Widget _field(String label, TextEditingController c, String hint, {TextInputType? keyboard, int maxLines = 1}) => TextField(controller: c, keyboardType: keyboard, maxLines: maxLines, decoration: InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder()));
}
