import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kotiz_app/data/models/user.dart';

class SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // clé pour ton token
  static const _keyToken = 'token';
  static const _keyUser = 'user';

  // sauvegarder le token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }

  Future<void> saveUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    await _storage.write(key: _keyUser, value: userJson);
  }

  Future<User?> getUser() async {
    final userJson = await _storage.read(key: _keyUser);
    if (userJson == null) return null;
    final Map<String, dynamic> userMap = jsonDecode(userJson);
    return User.fromJson(userMap);
  }

  Future<void> deleteUser() async {
    await _storage.delete(key: _keyUser);
  }
}
