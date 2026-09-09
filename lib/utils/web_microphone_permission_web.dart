// Web-only bridge for requesting microphone access directly from the browser.
// The permission request is made from the user's microphone-button tap.
import 'dart:html' as html;

Future<bool> requestWebMicrophone() async {
  // First use the modern MediaDevices API.
  try {
    final devices = html.window.navigator.mediaDevices;
    if (devices != null) {
      final stream = await devices.getUserMedia({'audio': true});
      for (final track in stream.getAudioTracks()) {
        track.stop();
      }
      return true;
    }
  } catch (_) {
    // Fall through to the browser's legacy getUserMedia bridge.
  }

  // Compatibility fallback for Chromium environments where the modern
  // navigator.mediaDevices bridge is unavailable or blocked by the wrapper.
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
