import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/chaupal_app_header.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/job_request_management/job_request_management_widget.dart';
import '/utils/web_microphone_permission.dart';

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
  List<Map<String, dynamic>> locations = [];
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
  bool loadingProfessions = true;
  bool loadingLocations = true;
  bool audioUnavailable = false;

  @override
  void initState() {
    super.initState();
    _loadMasters();
  }

  @override
  void dispose() {
    timer?.cancel();
    recorder.dispose();
    player.dispose();
    title.dispose();
    details.dispose();
    amount.dispose();
    super.dispose();
  }

  Future<void> _loadMasters() async {
    if (mounted) {
      setState(() {
        loadingProfessions = true;
        loadingLocations = true;
      });
    }
    try {
      final rows = await SupaFlow.client
          .from('professions')
          .select('id,display_name')
          .eq('active', true)
          .order('sort_order', ascending: true);
      final loaded = (rows as List)
          .map((row) => Map<String, dynamic>.from(row as Map))
          .toList();
      if (mounted) {
        setState(() {
          professions = loaded;
          loadingProfessions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => loadingProfessions = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('काम की सूची लोड नहीं हो सकी: $e')),
        );
      }
    }

    try {
      final rows = await SupaFlow.client
          .from('chaupal_locations')
          .select('id,display_name')
          .eq('active', true)
          .order('id', ascending: true);
      final loaded = (rows as List)
          .map((row) => Map<String, dynamic>.from(row as Map))
          .toList();
      if (mounted) {
        setState(() {
          locations = loaded;
          loadingLocations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => loadingLocations = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('चौपाल की सूची लोड नहीं हो सकी: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('फोटो चुनें', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(c, ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined, size: 28),
                  label: const Text('कैमरा से फोटो लें', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(c, ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined, size: 28),
                  label: const Text('गैलरी से फोटो चुनें', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;
    final image = await picker.pickImage(source: source, imageQuality: 80, maxWidth: 1600);
    if (mounted && image != null) setState(() => workImage = image);
  }

  Future<void> _showNoMicrophoneDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('रिकॉर्डिंग डिवाइस नहीं मिला'),
        content: const Text(
          'इस डिवाइस में कोई माइक्रोफोन / रिकॉर्डिंग डिवाइस उपलब्ध नहीं है।\n\n'
          'ऑडियो रिकॉर्ड नहीं होगा, लेकिन आप बाकी जानकारी भरकर जॉब पोस्ट कर सकते हैं।',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('ठीक है'),
          ),
        ],
      ),
    );
  }

  Future<void> _startRecording() async {
    if (recording) return;
    try {
      if (kIsWeb) {
        final status = await requestWebMicrophoneStatus();
        if (status == WebMicrophoneStatus.noDevice) {
          if (mounted) {
            setState(() {
              audioUnavailable = true;
              audioPath = null;
              seconds = 0;
            });
          }
          await _showNoMicrophoneDialog();
          return;
        }
        if (status != WebMicrophoneStatus.available) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('माइक्रोफोन की अनुमति नहीं मिली। कृपया अनुमति दें।')),
            );
          }
          return;
        }
      } else if (!await recorder.hasPermission(request: true)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('माइक्रोफोन की अनुमति नहीं मिली। कृपया अनुमति दें।')),
          );
        }
        return;
      }

      final String path;
      if (kIsWeb) {
        path = '';
      } else {
        final dir = await getTemporaryDirectory();
        path = '${dir.path}/chaupal_${DateTime.now().millisecondsSinceEpoch}.wav';
      }
      await recorder.start(
        const RecordConfig(encoder: AudioEncoder.wav, sampleRate: 44100, numChannels: 1),
        path: path,
      );
      timer?.cancel();
      if (!mounted) return;
      setState(() {
        recording = true;
        seconds = 0;
        audioPath = null;
        audioUnavailable = false;
      });
      timer = Timer.periodic(const Duration(seconds: 1), (_) async {
        if (!mounted) return;
        if (seconds >= 59) {
          await _stopRecording();
        } else {
          setState(() => seconds++);
        }
      });
    } catch (e) {
      timer?.cancel();
      if (mounted) {
        setState(() => recording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('रिकॉर्डिंग शुरू नहीं हो सकी: $e')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    timer?.cancel();
    try {
      final path = await recorder.stop();
      if (mounted) {
        setState(() {
          recording = false;
          audioPath = path;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => recording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('रिकॉर्डिंग बंद नहीं हो सकी: $e')),
        );
      }
    }
  }

  Future<void> _playRecording() async {
    final path = audioPath;
    if (path == null || recording) return;
    try {
      if (kIsWeb) {
        await player.play(UrlSource(path));
      } else {
        await player.play(DeviceFileSource(path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ऑडियो चल नहीं सका: $e')),
        );
      }
    }
  }

  Future<Uint8List> _readRecordedAudio(String path) async {
    if (kIsWeb) {
      final response = await http.get(Uri.parse(path));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Recorded audio could not be read from browser.');
      }
      return response.bodyBytes;
    }
    return File(path).readAsBytes();
  }

  Future<void> _submit() async {
    if (saving) return;

    final missing = <String>[];
    if (title.text.trim().isEmpty) missing.add('जॉब का नाम');
    if (professionId == null) missing.add('काम का प्रकार');
    if (workImage == null) missing.add('काम की फोटो');
    if (!audioUnavailable && audioPath == null) missing.add('ऑडियो रिकॉर्डिंग');
    if (amount.text.trim().isEmpty) missing.add('राशि');
    if (locationId == null) missing.add('चौपाल स्थान');
    if (jobDate == null) missing.add('काम की तारीख');
    if (startTime == null) missing.add('काम शुरू होने का समय');

    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ये जानकारी भरें: ${missing.join(', ')}')),
      );
      return;
    }

    final price = double.tryParse(amount.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया सही राशि दर्ज करें।')),
      );
      return;
    }

    setState(() => saving = true);
    String? photoPath;
    String? audioStoragePath;
    try {
      final dateText = '${jobDate!.year.toString().padLeft(4, '0')}-${jobDate!.month.toString().padLeft(2, '0')}-${jobDate!.day.toString().padLeft(2, '0')}';
      final timeText = '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00';

      final allowed = await SupaFlow.client.rpc(
        'enforce_job_posting_window',
        params: {'p_job_date': dateText},
      );
      if (allowed != true) throw Exception('posting_window_closed');

      final uid = currentUserUid;
      final stamp = DateTime.now().millisecondsSinceEpoch;
      photoPath = '$uid/job_$stamp.jpg';

      final imageBytes = await workImage!.readAsBytes();
      await SupaFlow.client.storage.from('job-media').uploadBinary(
        photoPath!,
        imageBytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: false),
      );

      if (audioPath != null) {
        audioStoragePath = '$uid/job_$stamp.wav';
        final audioBytes = await _readRecordedAudio(audioPath!);
        await SupaFlow.client.storage.from('job-media').uploadBinary(
          audioStoragePath!,
          audioBytes,
          fileOptions: const FileOptions(contentType: 'audio/wav', upsert: false),
        );
      }

      await SupaFlow.client.rpc(
        'create_chaupal_job',
        params: {
          'p_title': title.text.trim(),
          'p_profession_id': professionId,
          'p_work_photo': photoPath,
          'p_audio_note': audioStoragePath,
          'p_description': details.text.trim(),
          'p_expected_amount': price,
          'p_job_date': dateText,
          'p_start_time': timeText,
          'p_chaupal_location_id': locationId,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('जॉब सफलतापूर्वक पोस्ट हो गई।')),
      );
      context.goNamed(JobRequestManagementWidget.routeName);
    } catch (e) {
      try {
        if (photoPath != null) await SupaFlow.client.storage.from('job-media').remove([photoPath!]);
        if (audioStoragePath != null) await SupaFlow.client.storage.from('job-media').remove([audioStoragePath!]);
      } catch (_) {}
      final s = e.toString();
      final message = s.contains('posting_window_closed')
          ? 'अभी जॉब पोस्टिंग बंद है। अगली पोस्टिंग में कोशिश करें।'
          : s.contains('work_photo_required')
              ? 'काम की फोटो जरूरी है।'
              : s.contains('invalid_location')
                  ? 'चौपाल स्थान सही नहीं है।'
                  : s.contains('audio_note_required')
                      ? 'ऑडियो नोट जरूरी है। कृपया रिकॉर्डिंग करें।'
                      : 'जॉब पोस्ट नहीं हुई: $s';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: t.primaryBackground,
      appBar: const ChaupalAppHeader(title: 'नई जॉब पोस्ट करें'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          _sectionTitle('1. जॉब का नाम लिखें'),
          _field('जॉब का नाम', title, 'जैसे: बाथरूम में टाइल लगाना', icon: Icons.work_outline),
          const SizedBox(height: 20),
          _sectionTitle('2. काम का प्रकार चुनें'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: t.secondaryBackground, borderRadius: BorderRadius.circular(14), border: Border.all(color: t.alternate, width: 1.5)),
            child: DropdownButtonFormField<int>(
              value: professionId,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, size: 32),
              decoration: const InputDecoration(border: InputBorder.none, labelText: 'काम का प्रकार', labelStyle: TextStyle(fontSize: 17)),
              items: professions.map((p) => DropdownMenuItem<int>(
                value: (p['id'] as num).toInt(),
                child: Text('${p['display_name']}', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              )).toList(),
              onChanged: loadingProfessions || professions.isEmpty ? null : (v) => setState(() => professionId = v),
              hint: Text(loadingProfessions ? 'काम की सूची लोड हो रही है...' : 'काम चुनें', style: const TextStyle(fontSize: 17)),
            ),
          ),
          if (!loadingProfessions && professions.isEmpty) const Padding(padding: EdgeInsets.only(top: 8), child: Text('काम की सूची उपलब्ध नहीं है। कृपया दोबारा कोशिश करें।')),
          const SizedBox(height: 20),
          _sectionTitle('3. काम की फोटो दें'),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              onPressed: _pickImage,
              icon: Icon(workImage == null ? Icons.camera_alt_outlined : Icons.check_circle_outline, size: 30),
              label: Text(workImage == null ? 'फोटो लें / चुनें' : 'फोटो चुन ली गई है ✓', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
          ),
          if (workImage != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(workImage!.path, height: 190, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 100, alignment: Alignment.center, child: const Text('फोटो चुनी गई है ✓'))),
            ),
          ],
          const SizedBox(height: 20),
          _sectionTitle('4. काम की जानकारी बोलकर बताएं'),
          Card(
            color: t.secondaryBackground,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: t.alternate, width: 1.5)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('काम क्या है, कितना काम है और पैसों की जानकारी बोलकर बताएं।', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Text('${seconds.toString().padLeft(2, '0')} / 60 सेकंड', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: recording ? const Color(0xFFDC2626) : const Color(0xFFF59E0B), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      onPressed: recording ? _stopRecording : _startRecording,
                      icon: Icon(recording ? Icons.stop_circle_outlined : Icons.mic_none_outlined, size: 32),
                      label: Text(recording ? 'रिकॉर्डिंग बंद करें' : 'ऑडियो रिकॉर्ड करें', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  if (audioUnavailable) ...[
                    const SizedBox(height: 10),
                    const Text('इस डिवाइस में रिकॉर्डिंग डिवाइस नहीं मिला। ऑडियो के बिना भी जॉब पोस्ट की जा सकती है.', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ],
                  if (audioPath != null && !recording) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: _playRecording,
                              icon: const Icon(Icons.play_arrow_outlined, size: 30),
                              label: const Text('ऑडियो सुनें', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: _startRecording,
                              icon: const Icon(Icons.refresh_outlined, size: 28),
                              label: const Text('दोबारा बोलें', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle('5. अतिरिक्त जानकारी'),
          _field('अतिरिक्त जानकारी (जरूरी नहीं)', details, 'अगर कुछ और बताना हो तो यहां लिखें', icon: Icons.notes_outlined, maxLines: 4),
          const SizedBox(height: 20),
          _sectionTitle('6. कितने रुपये देने हैं?'),
          TextField(
            controller: amount,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            decoration: InputDecoration(labelText: 'राशि', hintText: 'जैसे 10000', prefixText: '₹ ', prefixStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800), labelStyle: const TextStyle(fontSize: 17), hintStyle: const TextStyle(fontSize: 17), filled: true, fillColor: t.secondaryBackground, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: t.alternate, width: 1.5)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: t.alternate, width: 1.5)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2))),
          ),
          const SizedBox(height: 20),
          _sectionTitle('7. चौपाल का स्थान चुनें *'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: t.secondaryBackground, borderRadius: BorderRadius.circular(14), border: Border.all(color: locationId == null ? const Color(0xFFDC2626) : t.alternate, width: 1.5)),
            child: DropdownButtonFormField<int>(
              value: locationId,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, size: 34),
              decoration: const InputDecoration(border: InputBorder.none, labelText: 'चौपाल स्थान (जरूरी)', labelStyle: TextStyle(fontSize: 17)),
              items: locations.map((p) => DropdownMenuItem<int>(
                value: (p['id'] as num).toInt(),
                child: Text('${p['display_name']}', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              )).toList(),
              onChanged: loadingLocations || locations.isEmpty ? null : (v) => setState(() => locationId = v),
              hint: Text(loadingLocations ? 'चौपाल की सूची लोड हो रही है...' : 'चौपाल चुनें', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
          if (!loadingLocations && locations.isEmpty) const Padding(padding: EdgeInsets.only(top: 8), child: Text('चौपाल की सूची उपलब्ध नहीं है।')),
          if (locationId == null && !loadingLocations && locations.isNotEmpty) const Padding(padding: EdgeInsets.only(top: 7), child: Text('चौपाल स्थान चुनना जरूरी है।', style: TextStyle(color: Color(0xFFDC2626), fontSize: 15, fontWeight: FontWeight.w700))),
          const SizedBox(height: 20),
          _sectionTitle('8. काम की तारीख चुनें'),
          _largeChoiceButton(icon: Icons.calendar_month_outlined, color: const Color(0xFF2563EB), title: jobDate == null ? 'तारीख चुनें' : '${jobDate!.day.toString().padLeft(2, '0')}/${jobDate!.month.toString().padLeft(2, '0')}/${jobDate!.year}', onTap: () async {
            final d = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 60)), initialDate: DateTime.now().add(const Duration(days: 1)));
            if (d != null) setState(() => jobDate = d);
          }),
          const SizedBox(height: 14),
          _sectionTitle('9. काम शुरू होने का समय चुनें'),
          _largeChoiceButton(icon: Icons.access_time_outlined, color: const Color(0xFF2563EB), title: startTime == null ? 'समय चुनें' : startTime!.format(context), onTap: () async {
            final d = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 9, minute: 0));
            if (d != null) setState(() => startTime = d);
          }),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 68,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: saving ? null : _submit,
              icon: saving ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)) : const Icon(Icons.check_circle_outline, size: 32),
              label: Text(saving ? 'जॉब पोस्ट हो रही है...' : 'जॉब पोस्ट करें', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
      );

  Widget _largeChoiceButton({required IconData icon, required Color color, required String title, required VoidCallback onTap}) => SizedBox(
        width: double.infinity,
        height: 64,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          onPressed: onTap,
          icon: Icon(icon, size: 30),
          label: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ),
      );

  Widget _field(String label, TextEditingController controller, String hint, {IconData? icon, int maxLines = 1}) {
    final t = FlutterFlowTheme.of(context);
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon, size: 28),
        labelStyle: const TextStyle(fontSize: 17),
        hintStyle: const TextStyle(fontSize: 16),
        filled: true,
        fillColor: t.secondaryBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: t.alternate, width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: t.alternate, width: 1.5)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF2563EB), width: 2)),
      ),
    );
  }
}
