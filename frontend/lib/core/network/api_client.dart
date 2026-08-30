import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/env.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient() : _dio = Dio(BaseOptions(baseUrl: Env.baseUrl, connectTimeout: const Duration(seconds: 10))) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer ';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            await _storage.delete(key: 'jwt_token');
            // Trigger logout logic via provider later
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get client => _dio;
}
