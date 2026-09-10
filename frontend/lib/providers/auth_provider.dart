import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<bool>>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<bool>> {
  final AuthService _authService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _checkInitialAuth();
  }

  Future<void> _checkInitialAuth() async {
    final token = await _storage.read(key: 'jwt_token');
    state = AsyncValue.data(token != null);
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final success = await _authService.login(email, password);
      state = AsyncValue.data(success);
      return success;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final success = await _authService.register(email, password);
      state = AsyncValue.data(success);
      return success;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AsyncValue.data(false);
  }
}

