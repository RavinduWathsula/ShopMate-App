import 'package:dio/dio.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'api_client.dart';

class AiService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>?> recognizeProduct(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: file.name),
      });
      final response = await _apiClient.dio.post('/ai/recognize', data: formData);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error recognizing product: $e');
    }
    return null;
  }
}
