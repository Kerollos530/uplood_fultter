import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_transit/models/user_model.dart';
import 'package:smart_transit/services/mock_auth_service.dart';

final authServiceProvider = Provider((ref) => MockAuthService());

final authLoadingProvider = StateProvider<bool>((ref) => false);
final authErrorProvider = StateProvider<String?>((ref) => null);

class AuthState extends StateNotifier<UserModel?> {
  final MockAuthService _authService;
  final Ref _ref;

  AuthState(this._authService, this._ref) : super(null) {
    _checkSession();
  }

  Future<void> _checkSession() async {
    final user = await _authService.getCurrentUser();
    state = user;
  }

  Future<void> login(String email, String password) async {
    try {
      _ref.read(authLoadingProvider.notifier).state = true;
      _ref.read(authErrorProvider.notifier).state = null;
      state = await _authService.login(email, password);
    } catch (e) {
      _ref.read(authErrorProvider.notifier).state = e.toString().replaceAll(
        'Exception: ',
        '',
      );
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<void> signup(String name, String email, String password) async {
    try {
      _ref.read(authLoadingProvider.notifier).state = true;
      _ref.read(authErrorProvider.notifier).state = null;
      state = await _authService.signup(name, email, password);
    } catch (e) {
      _ref.read(authErrorProvider.notifier).state = e.toString().replaceAll(
        'Exception: ',
        '',
      );
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<void> logout() async {
    try {
      _ref.read(authLoadingProvider.notifier).state = true;
      await _authService.logout();
      state = null;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }
}

final authProvider = StateNotifierProvider<AuthState, UserModel?>((ref) {
  return AuthState(ref.watch(authServiceProvider), ref);
});
