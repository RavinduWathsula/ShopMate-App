import '../core/network/api_client.dart';

class ProductService {
  final ApiClient _apiClient = ApiClient();

  Future<List<dynamic>> getProducts() async {
    final response = await _apiClient.client.get('/products');
    return response.data;
  }

  Future<dynamic> getProductDetails(int id) async {
    final response = await _apiClient.client.get('/products/');
    return response.data;
  }
}
