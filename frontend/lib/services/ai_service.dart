import 'package:dio/dio.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'api_client.dart';

class AiRecognitionResponse {
  final bool isSuccess;
  final Map<String, dynamic>? product;
  final String? errorMessage;

  AiRecognitionResponse({
    required this.isSuccess,
    this.product,
    this.errorMessage,
  });
}

class AiService {
  final ApiClient _apiClient = ApiClient();

  Future<AiRecognitionResponse> recognizeProduct(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: file.name),
      });
      final response = await _apiClient.dio.post('/ai/recognize', data: formData);
      if (response.statusCode == 200 && response.data != null) {
        return AiRecognitionResponse(
          isSuccess: true,
          product: response.data as Map<String, dynamic>,
        );
      }
    } on DioException catch (e) {
      debugPrint('DioException in recognizeProduct: ${e.response?.data}');
      String? detail;
      if (e.response?.data is Map) {
        detail = e.response?.data['detail']?.toString();
      }
      return AiRecognitionResponse(
        isSuccess: false,
        errorMessage: detail ?? 'Could not recognize product. Please scan again.',
      );
    } catch (e) {
      debugPrint('Error recognizing product: $e');
      return AiRecognitionResponse(
        isSuccess: false,
        errorMessage: 'Scanning failed. Please try again.',
      );
    }
    return AiRecognitionResponse(
      isSuccess: false,
      errorMessage: 'Could not recognize product. Please try again.',
    );
  }
}
