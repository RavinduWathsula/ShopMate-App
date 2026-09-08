import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'budget_provider.dart';

class BasketItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String category;
  final String? imageUrl;
  final bool isSelected;

  BasketItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    required this.category,
    this.imageUrl,
    this.isSelected = true,
  });

  BasketItem copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? category,
    String? imageUrl,
    bool? isSelected,
  }) {
    return BasketItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class BasketNotifier extends StateNotifier<List<BasketItem>> {
  BasketNotifier()
      : super([
          BasketItem(
            id: 'cart_1',
            name: 'Anchor Full Cream Milk 1L',
            price: 480.0,
            quantity: 2,
            category: 'Dairy',
            imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=200',
            isSelected: true,
          ),
          BasketItem(
            id: 'cart_2',
            name: 'Prima Special Bread 450g',
            price: 190.0,
            quantity: 1,
            category: 'Bakery',
            imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200',
            isSelected: true,
          ),
          BasketItem(
            id: 'cart_3',
            name: 'Munchee Super Cream Cracker 490g',
            price: 360.0,
            quantity: 1,
            category: 'Snacks',
            imageUrl: 'https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e?w=200',
            isSelected: false,
          ),
          BasketItem(
            id: 'cart_4',
            name: 'Cargills Magic Vanilla Ice Cream 1L',
            price: 540.0,
            quantity: 1,
            category: 'Frozen',
            imageUrl: 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=200',
            isSelected: true,
          ),
        ]);

  void addItem(BasketItem item) {
    final existingIndex = state.indexWhere((i) => i.id == item.id);
    if (existingIndex >= 0) {
      final updated = List<BasketItem>.from(state);
      updated[existingIndex] = updated[existingIndex].copyWith(
        quantity: updated[existingIndex].quantity + item.quantity
      );
      state = updated;
    } else {
      state = [...state, item];
    }
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void updateQuantity(String id, int delta) {
    final updated = List<BasketItem>.from(state);
    final index = updated.indexWhere((i) => i.id == id);
    if (index >= 0) {
      final newQuantity = updated[index].quantity + delta;
      if (newQuantity <= 0) {
        removeItem(id);
      } else {
        updated[index] = updated[index].copyWith(quantity: newQuantity);
        state = updated;
      }
    }
  }

  void toggleSelection(String id) {
    final updated = List<BasketItem>.from(state);
    final index = updated.indexWhere((i) => i.id == id);
    if (index >= 0) {
      updated[index] = updated[index].copyWith(isSelected: !updated[index].isSelected);
      state = updated;
    }
  }

  void toggleAllSelection(bool selectAll) {
    state = state.map((item) => item.copyWith(isSelected: selectAll)).toList();
  }
  
  void clear() {
    state = [];
  }
}

final basketProvider = StateNotifierProvider<BasketNotifier, List<BasketItem>>((ref) => BasketNotifier());

final basketTotalProvider = Provider<double>((ref) {
  final items = ref.watch(basketProvider);
  return items.where((item) => item.isSelected).fold(0.0, (total, item) => total + (item.price * item.quantity));
});

final budgetPercentageProvider = Provider<double>((ref) {
  final total = ref.watch(basketTotalProvider);
  final budget = ref.watch(budgetProvider).budget;
  if (budget == 0) return 0.0;
  return total / budget;
});

final originalTotalProvider = StateProvider<double>((ref) => 4500.0);
final savingsProvider = StateProvider<double>((ref) => 0.0);
