import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../services/shopping_service.dart';
import '../models/product.dart';

final apiClientProvider = Provider((ref) => ApiClient());

final authServiceProvider = Provider((ref) {
  return AuthService(ref.watch(apiClientProvider));
});

final productServiceProvider = Provider((ref) {
  return ProductService(ref.watch(apiClientProvider));
});

final shoppingServiceProvider = Provider((ref) {
  return ShoppingService(ref.watch(apiClientProvider));
});

class AuthNotifier extends StateNotifier<bool> {
  final AuthService _authService;
  
  AuthNotifier(this._authService) : super(false) {
    checkLogin();
  }

  Future<void> checkLogin() async {
    state = await _authService.isLoggedIn();
  }

  Future<void> login(String email, String password) async {
    await _authService.login(email, password);
    state = true;
  }
  
  Future<void> register(String email, String password) async {
    await _authService.register(email, password);
  }

  Future<void> logout() async {
    await _authService.logout();
    state = false;
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

final productsFutureProvider = FutureProvider<List<Product>>((ref) async {
  return ref.watch(productServiceProvider).getProducts();
});

final productDetailProvider = FutureProvider.family<Product, String>((ref, id) async {
  return ref.watch(productServiceProvider).getProduct(id);
});
