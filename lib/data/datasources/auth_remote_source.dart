import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_transit/core/api/api_client.dart';
import 'package:smart_transit/models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  AuthRemoteDataSource({ApiClient? apiClient, FlutterSecureStorage? storage})
    : _apiClient = apiClient ?? ApiClient(),
      _storage = storage ?? const FlutterSecureStorage();

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _apiClient.client.post(
        '/auth/login',
        data: {'username': email, 'password': password},
        // Note: FastAPI OAuth2PasswordRequestForm expects 'username', not 'email'
      );

      final token = response.data['access_token'];
      await _storage.write(key: 'auth_token', value: token);

      // Assuming login returns user details OR we fetch them separately
      // ideally we return user here. If API only returns token, we need another call.
      // For this plan, assuming response includes user info or we just decode generic.
      // Let's assume response: { "access_token": "...", "user": { ... } }

      if (response.data['user'] != null) {
        final user = UserModel.fromJson(response.data['user']);
        await _saveSession(user);
        return user;
      } else {
        // Fetch profile
        return await getProfile();
      }
    } catch (e) {
      throw Exception('Login Failed: ${e.toString()}');
    }
  }

  Future<UserModel> signup(String name, String email, String password) async {
    try {
      final response = await _apiClient.client.post(
        '/auth/signup',
        data: {'name': name, 'email': email, 'password': password},
      );

      // Auto login after signup if API returns token, else just return user
      if (response.data['user'] != null) {
        return UserModel.fromJson(response.data['user']);
      }
      return UserModel(id: 'temp', name: name, email: email, isAdmin: false);
    } catch (e) {
      throw Exception('Signup Failed: ${e.toString()}');
    }
  }

  Future<UserModel> getProfile() async {
    final response = await _apiClient.client.get('/auth/me');
    return UserModel.fromJson(response.data);
  }

  Future<void> _saveSession(UserModel user) async {
    // Save minimal session info if needed, but token is key
  }
}
