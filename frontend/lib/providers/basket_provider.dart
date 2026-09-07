import 'package:flutter_riverpod/flutter_riverpod.dart';

class BasketItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String category;

  BasketItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    required this.category,
  });
}

class BasketNotifier extends StateNotifier<List<BasketItem>> {
  BasketNotifier() : super([]);

  void addItem(BasketItem item) {
    final existingIndex = state.indexWhere((i) => i.id == item.id);
    if (existingIndex >= 0) {
      final updated = List<BasketItem>.from(state);
      updated[existingIndex] = BasketItem(
        id: item.id,
        name: item.name,
        price: item.price,
        quantity: item.quantity + 1,
        category: item.category,
      );
      state = updated;
    } else {
      state = [...state, item];
    }
  }
}

final basketProvider = StateNotifierProvider<BasketNotifier, List<BasketItem>>((ref) => BasketNotifier());
