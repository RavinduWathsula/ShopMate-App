import '../core/network/api_client.dart';

class ShoppingService {
  final ApiClient _apiClient = ApiClient();

  Future<dynamic> startSession(int shopId, double budget) async {
    final response = await _apiClient.client.post('/shopping-sessions', data: {
      'shop_id': shopId,
      'budget_limit': budget,
    });
    return response.data;
  }

  Future<dynamic> addItem(int sessionId, int productId, int quantity, double price) async {
    final response = await _apiClient.client.post('/shopping-sessions//items', data: {
      'product_id': productId,
      'quantity': quantity,
      'price_at_time': price,
    });
    return response.data;
  }

  Future<dynamic> getSession(int sessionId) async {
    final response = await _apiClient.client.get('/shopping-sessions/');
    return response.data;
  }
}
