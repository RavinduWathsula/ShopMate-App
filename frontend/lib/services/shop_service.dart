import '../core/network/api_client.dart';

class ShopService {
  final ApiClient _apiClient = ApiClient();

  Future<List<dynamic>> getShops() async {
    final response = await _apiClient.client.get('/shops');
    return response.data;
  }
}
