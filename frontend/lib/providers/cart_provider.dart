import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import 'api_providers.dart';

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier(ref);
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  final Ref ref;
  int? sessionId;

  CartNotifier(this.ref) : super([]);

  Future<void> initSession(int shopId) async {
    try {
      sessionId = await ref.read(shoppingServiceProvider).createSession(shopId);
    } catch (e) {
      print('Failed to create shopping session: $e');
    }
  }

  Future<void> addItem(Product product, int quantity) async {
    final existingIndex = state.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      final updatedList = List<CartItem>.from(state);
      updatedList[existingIndex] = updatedList[existingIndex].copyWith(
        quantity: updatedList[existingIndex].quantity + quantity,
      );
      state = updatedList;
      
      if (sessionId != null) {
        try {
          await ref.read(shoppingServiceProvider).updateQuantity(sessionId!, int.parse(product.id), updatedList[existingIndex].quantity);
        } catch (e) {
          print('API error: $e');
        }
      }
    } else {
      state = [...state, CartItem(product: product, quantity: quantity)];
      if (sessionId != null) {
        try {
          await ref.read(shoppingServiceProvider).addItem(sessionId!, int.parse(product.id), quantity, product.price);
        } catch (e) {
           print('API error: $e');
        }
      }
    }
  }

  Future<void> removeItem(String productId) async {
    state = state.where((item) => item.product.id != productId).toList();
    if (sessionId != null) {
       try {
         await ref.read(shoppingServiceProvider).removeItem(sessionId!, int.parse(productId));
       } catch (e) {}
    }
  }

  void clearCart() {
    state = [];
    sessionId = null;
  }

  double get totalAmount {
    return state.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }
}
