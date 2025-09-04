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
        "/auth/login",
        data: {"email": email, "password": password},
      );
      await _secureStorage.saveToken(data["token"]);

      return User.fromJson(data);
    } on Exception catch (e) {
      rethrow;
    }
  }

  Future<void> register(String email, String password, String name) async {
    await _app.post(
      "/auth/register",
      data: {"email": email, "password": password, "name": name},
    );
  }

  Future<void> logout() async {
    await _app.post("/auth/logout");
  }
}
