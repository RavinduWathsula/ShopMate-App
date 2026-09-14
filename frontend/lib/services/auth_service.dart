import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/network/api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiClient.client.post('/auth/login', data: {
        'username': email,
        'password': password,
      }, options: Options(contentType: Headers.formUrlEncodedContentType));
      
      final token = response.data['access_token'];
      await _storage.write(key: 'jwt_token', value: token);
      await _storage.write(key: 'user_email', value: email);
      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response?.statusCode == 400) {
          throw Exception(e.response?.data['detail'] ?? 'Invalid email or password');
        } else {
          throw Exception('Server error: ${e.response?.statusCode}');
        }
      }
      throw Exception('Network error: Unable to connect to server');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      await _apiClient.client.post('/auth/register', data: {
        'email': email,
        'password': password,
      });
      await _storage.write(key: 'user_email', value: email);
      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response?.statusCode == 400) {
          throw Exception(e.response?.data['detail'] ?? 'Registration failed');
        } else {
          throw Exception('Server error: ${e.response?.statusCode}');
        }
      }
      throw Exception('Network error: Unable to connect to server');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_email');
  }
}

