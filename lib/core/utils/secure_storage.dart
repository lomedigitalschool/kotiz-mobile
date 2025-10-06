import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kotiz_app/data/models/profil_user.dart';
import 'package:kotiz_app/data/models/user.dart';

class SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _keyToken = 'token';
  static const _keyUser = 'user';
  static const _keyProfil = 'profil';

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

  Future<void> saveProfil(ProfilUser profil) async {
    final profilJson = jsonEncode(profil.toJson());
    await _storage.write(key: _keyProfil, value: profilJson);
  }

  Future<ProfilUser?> getProfil() async {
    final profilJson = await _storage.read(key: _keyProfil);
    if (profilJson == null) return null;
    final Map<String, dynamic> profilMap = jsonDecode(profilJson);
    return ProfilUser.fromJson(profilMap);
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

  Future<void> deleteProfil() async {
    await _storage.delete(key: _keyProfil);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
