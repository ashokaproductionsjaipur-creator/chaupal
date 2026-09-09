import 'dart:html' as html;

import 'package:record/record.dart';

enum WebMicrophoneStatus { available, noDevice, denied, unavailable }

Future<WebMicrophoneStatus> requestWebMicrophoneStatus() async {
  final recorder = AudioRecorder();
  try {
    if (await recorder.hasPermission(request: true)) {
      return WebMicrophoneStatus.available;
    }
  } catch (_) {
    // Continue with the browser API so we can distinguish a missing device.
  } finally {
    await recorder.dispose();
  }

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
      return WebMicrophoneStatus.available;
    }
  } catch (e) {
    final name = e is html.DomException ? e.name : e.toString();
    if (name == 'NotFoundError' || name.contains('NotFoundError')) {
      return WebMicrophoneStatus.noDevice;
    }
    if (name == 'NotAllowedError' || name.contains('NotAllowedError')) {
      return WebMicrophoneStatus.denied;
    }
  }

  try {
    final stream = await html.window.navigator.getUserMedia(audio: true);
    for (final track in stream.getAudioTracks()) {
      track.stop();
    }
    return WebMicrophoneStatus.available;
  } catch (e) {
    final name = e is html.DomException ? e.name : e.toString();
    if (name == 'NotFoundError' || name.contains('NotFoundError')) {
      return WebMicrophoneStatus.noDevice;
    }
    if (name == 'NotAllowedError' || name.contains('NotAllowedError')) {
      return WebMicrophoneStatus.denied;
    }
    return WebMicrophoneStatus.unavailable;
  }
}

Future<bool> requestWebMicrophone() async =>
    (await requestWebMicrophoneStatus()) == WebMicrophoneStatus.available;
