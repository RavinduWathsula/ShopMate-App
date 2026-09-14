class Env {
  static String get baseUrl {
    const String envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    // Using the host's local network IP for physical device / emulator compatibility
    return 'http://192.168.8.127:8000';
  }
}
