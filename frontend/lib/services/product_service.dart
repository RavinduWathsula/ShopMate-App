import 'api_client.dart';
import '../models/product.dart';

class ProductService {
  final ApiClient _apiClient;

  ProductService(this._apiClient);

  Future<List<Product>> getProducts() async {
    final response = await _apiClient.dio.get('/products');
    final List<dynamic> data = response.data;
    return data.map((e) => Product(
      id: e['product_id'].toString(),
      name: e['product_name'],
      brand: e['brand'] ?? 'Unknown',
      category: 'General',
      price: double.parse(e['normal_price'].toString()),
      discount: e['discount_price'] != null 
          ? (double.parse(e['normal_price'].toString()) - double.parse(e['discount_price'].toString())) 
          : 0.0,
      imageUrl: 'https://via.placeholder.com/150',
      locationNodeId: 'A1',
    )).toList();
  }

  Future<Product> getProduct(String id) async {
    final response = await _apiClient.dio.get('/products/$id');
    final e = response.data;
    return Product(
      id: e['product_id'].toString(),
      name: e['product_name'],
      brand: e['brand'] ?? 'Unknown',
      category: 'General',
      price: double.parse(e['normal_price'].toString()),
      discount: e['discount_price'] != null 
          ? (double.parse(e['normal_price'].toString()) - double.parse(e['discount_price'].toString())) 
          : 0.0,
      imageUrl: 'https://via.placeholder.com/150',
      locationNodeId: 'A1',
    );
  }
}
