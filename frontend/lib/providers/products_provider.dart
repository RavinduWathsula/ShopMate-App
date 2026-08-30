import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/product_service.dart';

final productServiceProvider = Provider((ref) => ProductService());

final productsProvider = FutureProvider<List<dynamic>>((ref) async {
  final service = ref.read(productServiceProvider);
  return await service.getProducts();
});

final productDetailsProvider = FutureProvider.family<dynamic, int>((ref, id) async {
  final service = ref.read(productServiceProvider);
  return await service.getProductDetails(id);
});
