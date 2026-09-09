// Web microphone permission bridge.
// The browser must grant microphone access before the recorder can start.
// Try the record package first, then the modern and legacy browser APIs.
import 'dart:html' as html;

import 'package:record/record.dart';

Future<bool> requestWebMicrophone() async {
  final recorder = AudioRecorder();
  try {
    if (await recorder.hasPermission(request: true)) {
      return true;
    }
  } catch (_) {
    // Continue with the browser APIs below.
  } finally {
    await recorder.dispose();
  }

  // Modern Chrome/Edge/Firefox API.
  try {
    final devices = html.window.navigator.mediaDevices;
    if (devices != null) {
      final stream = await devices.getUserMedia(<String, dynamic>{
        'audio': true,
        'video': false,
      });
      for (final track in stream.getAudioTracks()) {
        track.stop();
      }
      return true;
    }
  } catch (_) {
    // Try the legacy browser API below.
  }

  // Legacy API is useful on some browser/WebView combinations.
  try {
    final stream = await html.window.navigator.getUserMedia(audio: true);
    for (final track in stream.getAudioTracks()) {
      track.stop();
    }
    return true;
  } catch (_) {
    return false;
  }
}
