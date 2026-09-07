import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/shop_service.dart';

final shopServiceProvider = Provider((ref) => ShopService());

final shopsProvider = FutureProvider<List<dynamic>>((ref) async {
  final service = ref.read(shopServiceProvider);
  return await service.getShops();
});

// Provides the currently selected store name for the UI
final selectedStoreProvider = StateProvider<String>((ref) => 'Food City');


