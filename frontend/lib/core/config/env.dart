import 'package:flutter/foundation.dart';

class Env {
  static String get baseUrl {
    const String envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    // Default URLs for local development
    // 10.0.2.2 is used for Android emulator to access the host loopback interface
    // 127.0.0.1 is used for Windows desktop / iOS simulator
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://127.0.0.1:8000';
    }
  }
}
