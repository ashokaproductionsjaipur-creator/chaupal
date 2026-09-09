enum WebMicrophoneStatus { available, noDevice, denied, unavailable }

Future<WebMicrophoneStatus> requestWebMicrophoneStatus() async =>
    WebMicrophoneStatus.available;

Future<bool> requestWebMicrophone() async => true;
