import 'api_client.dart';

class ShoppingService {
  final ApiClient _apiClient;

  ShoppingService(this._apiClient);

  Future<int> createSession(int shopId) async {
    final response = await _apiClient.dio.post(
      '/shopping-sessions',
      data: {'shop_id': shopId},
    );
    return response.data['id'];
  }

  Future<void> addItem(int sessionId, int productId, int quantity, double price) async {
    await _apiClient.dio.post(
      '/shopping-sessions/$sessionId/items',
      data: {
        'product_id': productId,
        'quantity': quantity,
        'price_at_time': price,
      },
    );
  }

  Future<void> removeItem(int sessionId, int productId) async {
    await _apiClient.dio.delete('/shopping-sessions/$sessionId/items/$productId');
  }

  Future<void> updateQuantity(int sessionId, int productId, int quantity) async {
    await _apiClient.dio.put(
      '/shopping-sessions/$sessionId/items/$productId',
      queryParameters: {'quantity': quantity},
    );
  }
}
