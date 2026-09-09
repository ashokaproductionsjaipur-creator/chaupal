// Web microphone permission bridge.
// Prefer the same permission path used by the `record` package, then fall
// back to the browser MediaDevices API if the package cannot request it.
import 'dart:html' as html;

import 'package:record/record.dart';

Future<bool> requestWebMicrophone() async {
  final recorder = AudioRecorder();
  try {
    final allowedByRecorder = await recorder.hasPermission(request: true);
    if (allowedByRecorder) return true;
  } catch (_) {
    // Try the browser API below.
  } finally {
    recorder.dispose();
  }

  try {
    final devices = html.window.navigator.mediaDevices;
    if (devices == null) return false;

    final stream = await devices.getUserMedia(<String, dynamic>{
      'audio': <String, dynamic>{
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
    });

    for (final track in stream.getAudioTracks()) {
      track.stop();
    }
    return true;
  } catch (_) {
    return false;
  }
}
