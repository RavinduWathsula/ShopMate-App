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
  final String? imageUrl;

  const ShoppingListItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    this.isChecked = false,
    required this.icon,
    this.imageUrl,
  });

  ShoppingListItem copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    int? quantity,
    bool? isChecked,
    IconData? icon,
    String? imageUrl,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
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
            imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=200',
          ),
          const ShoppingListItem(
            id: '2',
            name: 'Rice 5kg',
            category: 'Grains',
            price: 1250.0,
            quantity: 1,
            isChecked: false,
            icon: Icons.grain_rounded,
            imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=200',
          ),
          const ShoppingListItem(
            id: '3',
            name: 'Bread',
            category: 'Bakery',
            price: 300.0,
            quantity: 1,
            isChecked: false,
            icon: Icons.bakery_dining_rounded,
            imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200',
          ),
          const ShoppingListItem(
            id: '4',
            name: 'Eggs 6pcs',
            category: 'Dairy',
            price: 450.0,
            quantity: 1,
            isChecked: false,
            icon: Icons.egg_rounded,
            imageUrl: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=200',
          ),
          const ShoppingListItem(
            id: '5',
            name: 'Munchee Super Cream Cracker 490g',
            category: 'Snacks',
            price: 360.0,
            quantity: 2,
            isChecked: false,
            icon: Icons.cookie_outlined,
            imageUrl: 'https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e?w=200',
          ),
          const ShoppingListItem(
            id: '6',
            name: 'Anchor Butter 227g',
            category: 'Dairy',
            price: 850.0,
            quantity: 1,
            isChecked: false,
            icon: Icons.local_drink_rounded,
            imageUrl: 'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=200',
          ),
          const ShoppingListItem(
            id: '7',
            name: 'Cargills Magic Vanilla Ice Cream 1L',
            category: 'Household',
            price: 540.0,
            quantity: 1,
            isChecked: false,
            icon: Icons.ac_unit_rounded,
            imageUrl: 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=200',
          ),
          const ShoppingListItem(
            id: '8',
            name: 'Sunlight Washing Powder 1kg',
            category: 'Household',
            price: 600.0,
            quantity: 1,
            isChecked: false,
            icon: Icons.cleaning_services_rounded,
            imageUrl: 'https://images.unsplash.com/photo-1626806819282-2c1dc01a5e0c?w=200',
          ),
          const ShoppingListItem(
            id: '9',
            name: 'Coca Cola 1.5L',
            category: 'Drinks',
            price: 450.0,
            quantity: 1,
            isChecked: false,
            icon: Icons.local_bar_rounded,
            imageUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=200',
          ),
          const ShoppingListItem(
            id: '10',
            name: 'Maliban Lemon Puff 200g',
            category: 'Snacks',
            price: 250.0,
            quantity: 3,
            isChecked: false,
            icon: Icons.cookie_outlined,
            imageUrl: 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=200',
          ),
          const ShoppingListItem(
            id: '11',
            name: 'Keells Chicken Sausages 500g',
            category: 'Frozen',
            price: 850.0,
            quantity: 1,
            isChecked: false,
            icon: Icons.kitchen_rounded,
            imageUrl: 'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=200',
          ),
          const ShoppingListItem(
            id: '12',
            name: 'Red Onions 1kg',
            category: 'Vegetables',
            price: 450.0,
            quantity: 1,
            isChecked: false,
            icon: Icons.eco_rounded,
            imageUrl: 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=200',
          ),
          const ShoppingListItem(
            id: '13',
            name: 'Potatoes 1kg',
            category: 'Vegetables',
            price: 350.0,
            quantity: 2,
            isChecked: false,
            icon: Icons.eco_rounded,
            imageUrl: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=200',
          ),
          const ShoppingListItem(
            id: '14',
            name: 'Carrots 500g',
            category: 'Vegetables',
            price: 200.0,
            quantity: 1,
            isChecked: false,
            icon: Icons.eco_rounded,
            imageUrl: 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=200',
          ),
          const ShoppingListItem(
            id: '15',
            name: 'MD Tomato Sauce 400g',
            category: 'Household',
            price: 480.0,
            quantity: 1,
            isChecked: false,
            icon: Icons.kitchen_rounded,
            imageUrl: 'https://images.unsplash.com/photo-1607305387299-a3d9611cd469?w=200',
          ),
          const ShoppingListItem(
            id: '16',
            name: 'Maggi Noodles 400g',
            category: 'Snacks',
            price: 320.0,
            quantity: 2,
            isChecked: false,
            icon: Icons.fastfood_rounded,
            imageUrl: 'https://images.unsplash.com/photo-1612929633738-8fe01f746694?w=200',
          ),
          const ShoppingListItem(
            id: '17',
            name: 'Signal Toothpaste 160g',
            category: 'Household',
            price: 280.0,
            quantity: 1,
            isChecked: false,
            icon: Icons.cleaning_services_rounded,
            imageUrl: 'https://images.unsplash.com/photo-1559596395-9b244766bc70?w=200',
          ),
          const ShoppingListItem(
            id: '18',
            name: 'Lifebuoy Soap 100g',
            category: 'Household',
            price: 150.0,
            quantity: 4,
            isChecked: false,
            icon: Icons.wash_rounded,
            imageUrl: 'https://images.unsplash.com/photo-1600857062241-98e5dba7f214?w=200',
          ),
          const ShoppingListItem(
            id: '19',
            name: 'Sera Coconut Milk 400ml',
            category: 'Dairy',
            price: 250.0,
            quantity: 2,
            isChecked: false,
            icon: Icons.local_drink_rounded,
            imageUrl: 'https://images.unsplash.com/photo-1582236592209-a1b7e61ff0eb?w=200',
          ),
          const ShoppingListItem(
            id: '20',
            name: 'Milo Powder 400g',
            category: 'Drinks',
            price: 950.0,
            quantity: 1,
            isChecked: false,
            icon: Icons.local_cafe_rounded,
            imageUrl: 'https://images.unsplash.com/photo-1579899201099-dafb3cc961ff?w=200',
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
