from pathlib import Path

p = Path('lib/pages/create_job_post/create_job_post_widget.dart')
s = p.read_text()
if "package:file_picker/file_picker.dart" in s:
    raise SystemExit(0)
s = s.replace("import 'package:audioplayers/audioplayers.dart';\n", "import 'package:audioplayers/audioplayers.dart';\nimport 'package:file_picker/file_picker.dart';\n")
s = s.replace("  bool audioUnavailable = false;\n", "  bool audioUnavailable = false;\n  Uint8List? uploadedAudioBytes;\n  String? uploadedAudioName;\n  String? uploadedAudioExtension;\n  int? uploadedAudioSeconds;\n")
marker = "  Future<void> _showNoMicrophoneDialog() async {"
method = r'''  Future<void> _pickAudioFile() async {
    if (saving || recording) return;
    const allowedExtensions = ['mp3', 'm4a', 'wav', 'aac', 'ogg', 'opus'];
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      final ext = (file.extension ?? '').toLowerCase();
      final bytes = file.bytes;
      if (!allowedExtensions.contains(ext) || bytes == null || bytes.isEmpty) {
        throw Exception('audio_format_not_allowed');
      }
      const maxBytes = 157286400;
      if (bytes.length > maxBytes) throw Exception('audio_file_too_large');

      await player.setSource(BytesSource(bytes));
      final duration = await player.getDuration();
      await player.stop();
      if (duration == null) throw Exception('audio_duration_unknown');
      if (duration.inSeconds > 3600) throw Exception('audio_duration_too_long');

      if (!mounted) return;
      setState(() {
        uploadedAudioBytes = bytes;
        uploadedAudioName = file.name;
        uploadedAudioExtension = ext;
        uploadedAudioSeconds = duration.inSeconds;
        audioPath = null;
        audioUnavailable = false;
      });
    } catch (e) {
      if (mounted) {
        final s = e.toString();
        final message = s.contains('audio_format_not_allowed')
            ? 'केवल MP3, M4A, WAV, AAC, OGG या OPUS ऑडियो ही चुनें।'
            : s.contains('audio_file_too_large')
                ? 'ऑडियो फाइल 150 MB से बड़ी नहीं हो सकती।'
                : s.contains('audio_duration_too_long')
                    ? 'ऑडियो की अधिकतम लंबाई 60 मिनट है।'
                    : 'ऑडियो फाइल पढ़ी नहीं जा सकी। कृपया दूसरी ऑडियो फाइल चुनें।';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      await player.stop();
    }
  }

  Future<void> _playUploadedAudio() async {
    final bytes = uploadedAudioBytes;
    if (bytes == null) return;
    try {
      await player.play(BytesSource(bytes));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ऑडियो चल नहीं सका।')));
    }
  }

'''
s = s.replace(marker, method + marker)
s = s.replace("    if (!audioUnavailable && audioPath == null) missing.add('ऑडियो रिकॉर्डिंग');", "    if (!audioUnavailable && audioPath == null && uploadedAudioBytes == null) missing.add('ऑडियो नोट');")
old = """      if (audioPath != null) {\n        audioStoragePath = '$uid/job_$stamp.wav';\n        final audioBytes = await _readRecordedAudio(audioPath!);\n        await SupaFlow.client.storage.from('job-media').uploadBinary(\n          audioStoragePath!,\n          audioBytes,\n          fileOptions: const FileOptions(contentType: 'audio/wav', upsert: false),\n        );\n      }"""
new = """      if (audioPath != null || uploadedAudioBytes != null) {\n        final ext = uploadedAudioExtension ?? 'wav';\n        audioStoragePath = '$uid/job_$stamp.$ext';\n        final audioBytes = audioPath != null ? await _readRecordedAudio(audioPath!) : uploadedAudioBytes!;\n        final contentType = switch (ext) {\n          'mp3' => 'audio/mpeg',\n          'm4a' => 'audio/mp4',\n          'wav' => 'audio/wav',\n          'aac' => 'audio/aac',\n          'ogg' => 'audio/ogg',\n          'opus' => 'audio/opus',\n          _ => 'audio/octet-stream',\n        };\n        await SupaFlow.client.storage.from('job-media').uploadBinary(\n          audioStoragePath!,\n          audioBytes,\n          fileOptions: FileOptions(contentType: contentType, upsert: false),\n        );\n      }"""
if old not in s: raise SystemExit('upload block not found')
s = s.replace(old, new)
oldui = """                  const Text('काम क्या है, कितना काम है और पैसों की जानकारी बोलकर बताएं।', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),\n                  const SizedBox(height: 10),\n                  Text('${seconds.toString().padLeft(2, '0')} / 60 सेकंड', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),\n                  const SizedBox(height: 12),\n                  SizedBox(\n                    width: double.infinity,\n                    height: 62,\n                    child: FilledButton.icon(\n                      style: FilledButton.styleFrom(backgroundColor: recording ? const Color(0xFFDC2626) : const Color(0xFFF59E0B), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),\n                      onPressed: recording ? _stopRecording : _startRecording,\n                      icon: Icon(recording ? Icons.stop_circle_outlined : Icons.mic_none_outlined, size: 32),\n                      label: Text(recording ? 'रिकॉर्डिंग बंद करें' : 'ऑडियो रिकॉर्ड करें', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),\n                    ),\n                  ),"""
newui = """                  const Text('काम और मोल की जानकारी ऑडियो में बताएं।', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),\n                  const SizedBox(height: 12),\n                  Row(children: [\n                    Expanded(child: SizedBox(height: 62, child: FilledButton.icon(\n                      style: FilledButton.styleFrom(backgroundColor: recording ? const Color(0xFFDC2626) : const Color(0xFFF59E0B), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),\n                      onPressed: recording ? _stopRecording : _startRecording,\n                      icon: Icon(recording ? Icons.stop_circle_outlined : Icons.mic_none_outlined, size: 30),\n                      label: Text(recording ? 'रिकॉर्डिंग बंद करें' : 'लाइव रिकॉर्ड करें', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),\n                    ))),\n                    const SizedBox(width: 10),\n                    Expanded(child: SizedBox(height: 62, child: OutlinedButton.icon(\n                      onPressed: saving || recording ? null : _pickAudioFile,\n                      icon: const Icon(Icons.audio_file_outlined, size: 30),\n                      label: const Text('फोन से ऑडियो चुनें', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),\n                    ))),\n                  ]),\n                  const SizedBox(height: 8),\n                  const Text('MP3, M4A, WAV, AAC, OGG, OPUS • अधिकतम 60 मिनट • 150 MB', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),"""
if oldui not in s: raise SystemExit('audio UI block not found')
s = s.replace(oldui, newui)
marker2 = "                  if (audioUnavailable) ...["
preview = """                  if (uploadedAudioBytes != null && !recording) ...[\n                    const SizedBox(height: 10),\n                    Container(\n                      padding: const EdgeInsets.all(10),\n                      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2563EB), width: 1.5)),\n                      child: Row(children: [\n                        const Icon(Icons.audiotrack, color: Color(0xFF2563EB), size: 30),\n                        const SizedBox(width: 9),\n                        Expanded(child: Text('${uploadedAudioName ?? 'ऑडियो'} • ${((uploadedAudioSeconds ?? 0) ~/ 60)} मिनट', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800))),\n                        IconButton(onPressed: _playUploadedAudio, icon: const Icon(Icons.play_arrow, size: 30), tooltip: 'ऑडियो सुनें'),\n                        IconButton(onPressed: () => setState(() { uploadedAudioBytes = null; uploadedAudioName = null; uploadedAudioExtension = null; uploadedAudioSeconds = null; }), icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)), tooltip: 'हटाएं'),\n                      ]),\n                    ),\n                  ],\n"""
s = s.replace(marker2, preview + marker2)
p.write_text(s)
