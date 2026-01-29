import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_transit/models/user_model.dart';
import 'dart:convert';

class MockAuthService {
  Future<UserModel?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    if (email == 'error@test.com') {
      throw Exception('بيانات الدخول غير صحيحة'); // Invalid credentials
    }
    if (email.contains('@') && password.length > 5) {
      final isAdmin = email.toLowerCase().startsWith('admin');
      final user = UserModel(
        id: 'u_123',
        name: isAdmin ? 'Admin User' : 'Smart User',
        email: email,
        isAdmin: isAdmin,
      );
      await _saveSession(user);
      return user;
    }
    throw Exception('بيانات الدخول غير صحيحة');
  }

  Future<UserModel?> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'exist@test.com') {
      throw Exception('البريد الالكتروني مستخدم مسبقا');
    }
    final isAdmin = email.toLowerCase().startsWith('admin');
    final user = UserModel(
      id: 'u_456',
      name: name,
      email: email,
      isAdmin: isAdmin,
    );
    await _saveSession(user);
    return user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_session');
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString('user_session');
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_session', jsonEncode(user.toJson()));
  }
}
