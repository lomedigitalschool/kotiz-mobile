import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:kotiz_app/core/netework/api_config.dart';
import 'package:kotiz_app/core/utils/secure_storage.dart';
import 'package:kotiz_app/data/models/profil_user.dart';
import 'package:kotiz_app/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

class AuthService {
  final ApiConfig _app;
  final SecureStorage _secureStorage;
  final fb.FirebaseAuth _firebase = fb.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AuthService(this._secureStorage, this._app);

  Future<User> login(String email, String password) async {
    try {
      final cred = await _firebase.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        throw Exception('Utilisateur introuvable');
      }

      final idToken = await user.getIdToken();
      await firebaseSync(idToken.toString());

      await _secureStorage.saveToken(idToken.toString());

      final doc = await _db.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        throw Exception('Profil Firestore manquant');
      }
      // await fetchProfile();
      final extraData = doc.data()!;

      return User(
        id: int.tryParse(user.uid),
        email: user.email!,
        name: extraData['name'],
        phone: extraData['phone'],
        // isVerified: extraData['isVerified'],
      );
    } on fb.FirebaseAuthException catch (e, s) {
      debugPrint("Firebase login error: ${e.code} – ${e.message}\n$s");
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Aucun compte ne correspond à cet e-mail.');
        case 'wrong-password':
          throw Exception('Mot de passe incorrect.');
        case 'invalid-email':
          throw Exception('Adresse e-mail invalide.');
        case 'user-disabled':
          throw Exception('Ce compte a été désactivé.');
        default:
          throw Exception(e.message ?? 'Erreur de connexion.');
      }
    } catch (e, s) {
      debugPrint("Autre erreur de connexion: $e\n$s");
      throw Exception('Une erreur inattendue est survenue.');
    }
  }

  Future<void> register(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    try {
      final cred = await fb.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // 1. Enregistrer les infos de base dans Firestore
      await _db.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'phone': phone,
      });

      final idToken = await cred.user!.getIdToken();
      await firebaseSync(idToken.toString());
    } on fb.FirebaseAuthException catch (e, s) {
      debugPrint("Auth error: ${e.code} – ${e.message}\n$s");
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Cet e-mail est déjà utilisé.');
        case 'invalid-email':
          throw Exception('Adresse e-mail invalide.');
        case 'weak-password':
          throw Exception('Mot de passe trop faible.');
        default:
          throw Exception(e.message ?? 'Erreur d’authentification.');
      }
    } catch (e, s) {
      debugPrint("Autre erreur: $e\n$s");
      rethrow;
    }
  }

  Future<void> firebaseSync(String idToken) async {
    try {
      final response = await _app.post<Map<String, dynamic>>(
        "auth/firebase-sync",
        headers: {'Authorization': 'Bearer $idToken'},
      );
      debugPrint('Réponse: $response');
    } on DioException catch (e) {
      debugPrint('Erreur ${e.response?.statusCode}');
      debugPrint('Body: ${e.response?.data}');
    }
  }

  Future<ProfilUser> fetchProfile() async {
    try {
      final Map<String, dynamic> data = await _app.get<Map<String, dynamic>>(
        'auth/me',
      );

      return ProfilUser.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _firebase.signOut();
  }
}
