import 'package:flutter/foundation.dart';
import 'package:kotiz_app/core/netework/api_config.dart';
import 'package:kotiz_app/core/utils/secure_storage.dart';
import 'package:kotiz_app/data/models/user.dart';

class AuthService {
  final ApiConfig _app;
  final SecureStorage _secureStorage;
  AuthService(this._app, this._secureStorage);

  Future<User> login(String email, String password) async {
    try {
      final data = await _app.post<Map<String, dynamic>>(
        "/auth/login-normal",
        data: {"email": email, "password": password},
      );
      await _secureStorage.saveToken(data["token"]);

      return User.fromJson(data['user']);
    } catch (e, s) {
      debugPrint("Login error: $e\n$s");
      rethrow;
    }
  }

  Future<void> register(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    await _app.post(
      "/auth/register",
      data: {
        "email": email,
        "password": password,
        "name": name,
        "phone": phone,
      },
    );
  }

  Future<void> logout() async {
    await _app.post("/auth/logout");
  }
}
