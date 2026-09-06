class Env {
  static const String baseUrl = String.fromEnvironment(
    'API_URL', 
    defaultValue: 'http://127.0.0.1:8000'
  );
}

