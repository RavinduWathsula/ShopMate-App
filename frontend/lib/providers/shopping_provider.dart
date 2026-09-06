import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/shopping_service.dart';

final shoppingServiceProvider = Provider((ref) => ShoppingService());

final activeSessionProvider = StateNotifierProvider<ShoppingSessionNotifier, AsyncValue<dynamic>>((ref) {
  return ShoppingSessionNotifier(ref.read(shoppingServiceProvider));
});

class ShoppingSessionNotifier extends StateNotifier<AsyncValue<dynamic>> {
  final ShoppingService _service;
  int? currentSessionId;

  ShoppingSessionNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> startSession(int shopId, double budget) async {
    state = const AsyncValue.loading();
    try {
      final session = await _service.startSession(shopId, budget);
      currentSessionId = session['id'];
      state = AsyncValue.data(session);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> addItem(int productId, int quantity, double price) async {
    if (currentSessionId == null) return;
    try {
      await _service.addItem(currentSessionId!, productId, quantity, price);
      // Refresh session data
      final session = await _service.getSession(currentSessionId!);
      state = AsyncValue.data(session);
    } catch (e) {
      // In a real app we might want to just show a snackbar instead of destroying the whole session state
      debugPrint('Failed to add item: $e');
    }
  }
}

