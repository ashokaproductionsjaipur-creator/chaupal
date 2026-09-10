from pathlib import Path

p = Path('lib/pages/create_job_post/create_job_post_widget.dart')
s = p.read_text()
if "package:file_picker/file_picker.dart" in s:
    s = s.replace("const maxBytes = 157286400;", "const maxBytes = 3145728;")
    s = s.replace("if (duration.inSeconds > 3600) throw Exception('audio_duration_too_long');", "if (duration > const Duration(seconds: 60)) throw Exception('audio_duration_too_long');")
    s = s.replace("'ऑडियो फाइल 150 MB से बड़ी नहीं हो सकती।'", "'ऑडियो फाइल 3 MB से बड़ी नहीं हो सकती।'")
    s = s.replace("'ऑडियो की अधिकतम लंबाई 60 मिनट है।'", "'ऑडियो की अधिकतम लंबाई 60 सेकंड है।'")
    s = s.replace("MP3, M4A, WAV, AAC, OGG, OPUS • अधिकतम 60 मिनट • 150 MB", "MP3, M4A, WAV, AAC, OGG, OPUS • अधिकतम 60 सेकंड • 3 MB")
    p.write_text(s)
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
      const maxBytes = 3145728;
      if (bytes.length > maxBytes) throw Exception('audio_file_too_large');

      await player.setSource(BytesSource(bytes));
      final duration = await player.getDuration();
      await player.stop();
      if (duration == null) throw Exception('audio_duration_unknown');
      if (duration > const Duration(seconds: 60)) throw Exception('audio_duration_too_long');

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
                ? 'ऑडियो फाइल 3 MB से बड़ी नहीं हो सकती।'
                : s.contains('audio_duration_too_long')
                    ? 'ऑडियो की अधिकतम लंबाई 60 सेकंड है।'
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
new = """      if (audioPath != null || uploadedAudioBytes != null) {\n        final ext = uploadedAudioExtension ?? 'wav';\n        audioStoragePath = '$uid/job_$stamp.$ext';\n        final audioBytes = audioPath != null ? await _readRecordedAudio(audioPath!) : uploadedAudioBytes!;\n        const maxAudioBytes = 3145728;\n        if (audioBytes.length > maxAudioBytes) throw Exception('audio_file_too_large');\n        final contentType = switch (ext) {\n          'mp3' => 'audio/mpeg',\n          'm4a' => 'audio/mp4',\n          'wav' => 'audio/wav',\n          'aac' => 'audio/aac',\n          'ogg' => 'audio/ogg',\n          'opus' => 'audio/opus',\n          _ => 'audio/octet-stream',\n        };\n        await SupaFlow.client.storage.from('job-media').uploadBinary(\n          audioStoragePath!,\n          audioBytes,\n          fileOptions: FileOptions(contentType: contentType, upsert: false),\n        );\n      }"""
if old not in s: raise SystemExit('upload block not found')
s = s.replace(old, new)
