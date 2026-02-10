import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_transit/models/user_model.dart';

import 'package:smart_transit/models/failure.dart';
import 'package:smart_transit/data/datasources/auth_remote_source.dart';

final authServiceProvider = Provider(
  (ref) => AuthRemoteDataSource(),
); // Changed from MockAuthService

final authLoadingProvider = StateProvider<bool>((ref) => false);
final authErrorProvider = StateProvider<Failure?>((ref) => null);

class AuthState extends StateNotifier<UserModel?> {
  final AuthRemoteDataSource _authService; // Changed type
  final Ref _ref;

  AuthState(this._authService, this._ref) : super(null) {
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      final user = await _authService
          .getProfile(); // Changed from getCurrentUser (mock)
      state = user;
    } catch (_) {
      // Session restoration failure is silent usually
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _ref.read(authLoadingProvider.notifier).state = true;
      _ref.read(authErrorProvider.notifier).state = null;
      state = await _authService.login(email, password);
    } catch (e) {
      _handleAuthError(e);
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
      _handleAuthError(e);
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<void> logout() async {
    try {
      _ref.read(authLoadingProvider.notifier).state = true;
      // await _authService.logout(); // Remote source might not have logout if stateless JWT, or delete token locally
      // For now we just clear state. Ideally we delete token from storage.
      state = null;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  void _handleAuthError(Object error) {
    String message = error.toString().replaceAll('Exception: ', '');
    // In a real app, you would map specific error codes here.
    if (message.contains('SocketException') || message.contains('Network')) {
      _ref.read(authErrorProvider.notifier).state = const NetworkFailure();
    } else {
      _ref.read(authErrorProvider.notifier).state = AuthFailure(message);
    }
  }
}

final authProvider = StateNotifierProvider<AuthState, UserModel?>((ref) {
  return AuthState(ref.watch(authServiceProvider), ref);
});
