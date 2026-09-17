import 'package:flutter/foundation.dart';

class Env {
  static String get baseUrl {
    const String envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.macOS) {
      return 'http://127.0.0.1:8000'; // Avoids Chrome's Private Network Access blocks
    } else {
      return 'http://192.168.8.127:8000'; // For physical Android/iOS devices on Wi-Fi
    }
  }
}
