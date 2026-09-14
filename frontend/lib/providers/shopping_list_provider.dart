import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShoppingListItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final int quantity;
  final bool isChecked;
  final IconData icon;

  const ShoppingListItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    this.isChecked = false,
    required this.icon,
  });

  ShoppingListItem copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    int? quantity,
    bool? isChecked,
    IconData? icon,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
      icon: icon ?? this.icon,
    );
  }
}

class ShoppingListNotifier extends StateNotifier<List<ShoppingListItem>> {
  ShoppingListNotifier()
      : super([
          const ShoppingListItem(
            id: '1',
            name: 'Milk 1L',
            category: 'Dairy',
            price: 500.0,
            quantity: 1,
            isChecked: false,
            icon: Icons.local_drink_rounded,
          ),
          const ShoppingListItem(
            id: '2',
            name: 'Rice 5kg',
            category: 'Grains',
            price: 1250.0,
            quantity: 1,
            isChecked: false,
            icon: Icons.grain_rounded,
          ),
          const ShoppingListItem(
            id: '3',
            name: 'Bread',
            category: 'Bakery',
            price: 300.0,
            quantity: 1,
            isChecked: false,
            icon: Icons.bakery_dining_rounded,
          ),
          const ShoppingListItem(
            id: '4',
            name: 'Eggs 6pcs',
            category: 'Dairy',
            price: 450.0,
            quantity: 1,
            isChecked: false,
            icon: Icons.egg_rounded,
          ),
          const ShoppingListItem(
            id: '5',
            name: 'Munchee Super Cream Cracker 490g',
            category: 'Snacks',
            price: 360.0,
            quantity: 2,
            isChecked: false,
            icon: Icons.cookie_outlined,
          ),
          const ShoppingListItem(
            id: '6',
            name: 'Anchor Butter 227g',
            category: 'Dairy',
            price: 850.0,
            quantity: 1,
            isChecked: false,
            icon: Icons.local_drink_rounded,
          ),
          const ShoppingListItem(
            id: '7',
            name: 'Cargills Magic Vanilla Ice Cream 1L',
            category: 'Household',
            price: 540.0,
            quantity: 1,
            isChecked: false,
            icon: Icons.ac_unit_rounded,
          ),
          const ShoppingListItem(
            id: '8',
            name: 'Sunlight Washing Powder 1kg',
            category: 'Household',
            price: 600.0,
            quantity: 1,
            isChecked: false,
            icon: Icons.cleaning_services_rounded,
          ),
        ]);

  void addItem(ShoppingListItem item) {
    // If an item with similar name already exists, increase its quantity
    final existingIndex = state.indexWhere(
      (i) => i.name.toLowerCase().trim() == item.name.toLowerCase().trim(),
    );
    if (existingIndex >= 0) {
      final updated = List<ShoppingListItem>.from(state);
      updated[existingIndex] = updated[existingIndex].copyWith(
        quantity: updated[existingIndex].quantity + item.quantity,
      );
      state = updated;
    } else {
      // Add new item at the beginning of the list so user sees it right away
      state = [item, ...state];
    }
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void updateQuantity(String id, int delta) {
    state = state.map((item) {
      if (item.id == id) {
        final newQuantity = item.quantity + delta;
        if (newQuantity <= 0) return item;
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();
  }

  void toggleCheck(String id) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(isChecked: !item.isChecked);
      }
      return item;
    }).toList();
  }

  void clearAll() {
    state = [];
  }
}

final shoppingListProvider =
    StateNotifierProvider<ShoppingListNotifier, List<ShoppingListItem>>((ref) {
  return ShoppingListNotifier();
});
