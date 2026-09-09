// Web microphone permission bridge.
// The browser must grant microphone access before the recorder can start.
import 'dart:html' as html;

import 'package:record/record.dart';

Future<bool> requestWebMicrophone() async {
  final recorder = AudioRecorder();
  try {
    if (await recorder.hasPermission(request: true)) {
      return true;
    }
  } catch (_) {
    // Continue with the browser API below.
  } finally {
    await recorder.dispose();
  }

  final devices = html.window.navigator.mediaDevices;
  if (devices == null) {
    throw Exception(
      'MIC_ERROR: browser microphone API उपलब्ध नहीं है. '
      'secure=${html.window.isSecureContext}, origin=${html.window.location.origin}',
    );
  }

  try {
    final stream = await devices.getUserMedia(<String, dynamic>{
      'audio': true,
      'video': false,
    });
    for (final track in stream.getAudioTracks()) {
      track.stop();
    }
    return true;
  } catch (e) {
    String name = 'UnknownError';
    String message = e.toString();
    if (e is html.DomException) {
      name = e.name;
      message = e.message ?? e.toString();
    }
    throw Exception(
      'MIC_ERROR: $name - $message | '
      'secure=${html.window.isSecureContext} | '
      'origin=${html.window.location.origin}',
    );
  }
}
