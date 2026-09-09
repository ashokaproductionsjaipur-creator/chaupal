// Web-only bridge for requesting microphone access directly from the browser.
// The permission request is made from the user's microphone-button tap.
import 'dart:html' as html;

Future<bool> requestWebMicrophone() async {
  try {
    final devices = html.window.navigator.mediaDevices;
    if (devices == null) return false;

    final stream = await devices.getUserMedia({'audio': true});
    for (final track in stream.getAudioTracks()) {
      track.stop();
    }
    return true;
  } catch (_) {
    return false;
  }
}
