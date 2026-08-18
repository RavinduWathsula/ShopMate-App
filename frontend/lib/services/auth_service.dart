import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient;
  final _storage = const FlutterSecureStorage();

  AuthService(this._apiClient);

  Future<void> login(String email, String password) async {
    final response = await _apiClient.dio.post(
      '/auth/login',
      data: {
        'username': email,
        'password': password,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
    );
    final token = response.data['access_token'];
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<void> register(String email, String password) async {
    await _apiClient.dio.post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
      },
    );
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'jwt_token');
    return token != null;
  }
}
