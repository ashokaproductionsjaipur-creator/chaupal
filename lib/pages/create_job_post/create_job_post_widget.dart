import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
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
    setState(() => loadingProfessions = true);

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
          SnackBar(content: Text('Profession list load failed: $e')),
        );
      }
    }

    try {
      final uid = currentUserUid;
      final user = await SupaFlow.client
          .from('users')
          .select('chaupal_location_id')
          .eq('id', uid)
          .maybeSingle();
      if (mounted && user != null) {
        setState(() {
          final value = user['chaupal_location_id'];
          locationId = value is num ? value.toInt() : null;
        });
      }
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(c, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(c, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final image = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (mounted && image != null) {
      setState(() => workImage = image);
    }
  }

  Future<void> _startRecording() async {
    if (recording) return;

    try {
      // On Chrome, request permission directly through getUserMedia from the
      // microphone-button tap. This creates/uses the real site permission and
      // avoids treating a missing site grant as a permanent denial.
      final allowed = kIsWeb
          ? await requestWebMicrophone()
          : await recorder.hasPermission(request: true);

      if (!allowed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Chrome microphone access नहीं दे रहा. Browser site permission और Windows microphone access check करें.',
              ),
            ),
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
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: path,
      );

      timer?.cancel();
      if (!mounted) return;
      setState(() {
        recording = true;
        seconds = 0;
        audioPath = null;
      });

      timer = Timer.periodic(const Duration(seconds: 1), (t) async {
        if (!mounted) return;
        if (seconds >= 59) {
          await _stopRecording();
          return;
        }
        setState(() => seconds++);
      });
    } catch (e) {
      timer?.cancel();
      if (mounted) {
        setState(() => recording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Microphone start failed: $e')),
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
          SnackBar(content: Text('Recording stop failed: $e')),
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
          SnackBar(content: Text('Audio playback failed: $e')),
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

    if (title.text.trim().isEmpty ||
        professionId == null ||
        workImage == null ||
        audioPath == null ||
        amount.text.trim().isEmpty ||
        jobDate == null ||
        startTime == null ||
        locationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'सभी required fields भरें. Work Photo और Audio Note दोनों required हैं. Audio Note max 1 minute है.',
          ),
        ),
      );
      return;
    }

    final price = double.tryParse(amount.text.trim().replaceAll(',', ''));
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expected Amount सही दर्ज करें.')),
      );
      return;
    }

    setState(() => saving = true);
    String? photoPath;
    String? audioStoragePath;

    try {
      final dateText =
          '${jobDate!.year.toString().padLeft(4, '0')}-${jobDate!.month.toString().padLeft(2, '0')}-${jobDate!.day.toString().padLeft(2, '0')}';
      final timeText =
          '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00';

      final allowed = await SupaFlow.client.rpc(
        'enforce_job_posting_window',
        params: {'p_job_date': dateText},
      );
      if (allowed != true) throw Exception('posting_window_closed');

      final uid = currentUserUid;
      final stamp = DateTime.now().millisecondsSinceEpoch;

      photoPath = '$uid/job_$stamp.jpg';
      await SupaFlow.client.storage.from('job-media').upload(
            photoPath!,
            File(workImage!.path),
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );

      audioStoragePath = '$uid/job_$stamp.wav';
      final audioBytes = await _readRecordedAudio(audioPath!);
      await SupaFlow.client.storage.from('job-media').uploadBinary(
            audioStoragePath!,
            audioBytes,
            fileOptions: const FileOptions(
              contentType: 'audio/wav',
              upsert: false,
            ),
          );

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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job successfully posted.')),
        );
        context.goNamed('OwnerDashboard');
      }
    } catch (e) {
      try {
        if (photoPath != null) {
          await SupaFlow.client.storage.from('job-media').remove([photoPath!]);
        }
        if (audioStoragePath != null) {
          await SupaFlow.client.storage.from('job-media').remove([audioStoragePath!]);
        }
      } catch (_) {}

      final s = e.toString();
      final message = s.contains('posting_window_closed')
          ? 'अभी Job Posting बंद है। अगली Posting window में try करें.'
          : s.contains('audio_note_required')
              ? 'Audio Note जरूरी है. कृपया 1 मिनट तक की voice recording करें.'
              : 'Job post नहीं हुई: $s';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: t.primaryBackground,
      appBar: AppBar(
        backgroundColor: t.primaryBackground,
        foregroundColor: t.primaryText,
        elevation: 0,
        title: const Text('नई Job Post करें'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field('Job Title | जॉब का नाम', title, 'जैसे: Bathroom Tile Work'),
          const SizedBox(height: 14),
          DropdownButtonFormField<int>(
            value: professionId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Job Profession | प्रोफेशन',
              hintText: loadingProfessions
                  ? 'Professions load हो रहे हैं...'
                  : 'Profession चुनें',
              border: const OutlineInputBorder(),
              suffixIcon: loadingProfessions
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.arrow_drop_down),
            ),
            items: professions
                .map(
                  (p) => DropdownMenuItem<int>(
                    value: (p['id'] as num).toInt(),
                    child: Text(
                      '${p['display_name']}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: loadingProfessions || professions.isEmpty
                ? null
                : (v) => setState(() => professionId = v),
          ),
          if (!loadingProfessions && professions.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('Profession list उपलब्ध नहीं है. Please refresh.'),
            ),
          const SizedBox(height: 14),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: t.alternate),
            ),
            title: Text(
              workImage == null
                  ? 'Work Photo | काम की फोटो'
                  : 'Work Photo selected ✓',
            ),
            subtitle: const Text('Camera या Gallery • Required'),
            trailing: const Icon(Icons.camera_alt_outlined),
            onTap: _pickImage,
          ),
          const SizedBox(height: 14),
          Card(
            color: t.secondaryBackground,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: t.alternate),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: t.alternate),
                    ),
                    child: const Text(
                      '⚠️ जरूरी सूचना | Important\nअपने काम और लागत के पैसों की जानकारी Audio Note में ज़रूर रिकॉर्ड करें।\nWorker आपके काम की जानकारी Audio Note से समझेगा।',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Audio Note | काम की जानकारी (Required • max 1 min)',
                        ),
                      ),
                      Text('${seconds.toString().padLeft(2, '0')}/60'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recording
                        ? 'Recording चल रही है... Stop दबाकर save करें.'
                        : audioPath == null
                            ? 'Mic दबाएँ — Chrome microphone permission माँगेगा.'
                            : 'Audio ready ✓',
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        tooltip: recording ? 'Stop recording' : 'Start recording',
                        onPressed: recording ? _stopRecording : _startRecording,
                        icon: Icon(
                          recording
                              ? Icons.stop_circle_outlined
                              : Icons.mic_none_outlined,
                          size: 36,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Play recording',
                        onPressed: audioPath == null || recording
                            ? null
                            : _playRecording,
                        icon: const Icon(Icons.play_arrow_outlined, size: 32),
                      ),
                      IconButton(
                        tooltip: 'Record again',
                        onPressed: audioPath == null || recording
                            ? null
                            : _startRecording,
                        icon: const Icon(Icons.refresh_outlined, size: 28),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _field(
            'Additional Details | अतिरिक्त जानकारी',
            details,
            'Optional',
            maxLines: 4,
          ),
          const SizedBox(height: 14),
          _field(
            'Expected Amount | अनुमानित राशि',
            amount,
            '₹ Amount',
            keyboard: TextInputType.number,
          ),
          const SizedBox(height: 14),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: t.alternate),
            ),
            title: Text(
              jobDate == null
                  ? 'Job Date | तारीख चुनें'
                  : '${jobDate!.day}/${jobDate!.month}/${jobDate!.year}',
            ),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 60)),
                initialDate: DateTime.now().add(const Duration(days: 1)),
              );
              if (d != null) setState(() => jobDate = d);
            },
          ),
          const SizedBox(height: 10),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: t.alternate),
            ),
            title: Text(
              startTime == null
                  ? 'Job Start Time | समय चुनें'
                  : startTime!.format(context),
            ),
            trailing: const Icon(Icons.access_time_outlined),
            onTap: () async {
              final d = await showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 9, minute: 0),
              );
              if (d != null) setState(() => startTime = d);
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: saving ? null : _submit,
              child: Text(saving ? 'Posting...' : 'Post Job | जॉब पोस्ट करें'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
