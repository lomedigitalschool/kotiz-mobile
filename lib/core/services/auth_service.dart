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
  final fb.FirebaseAuth _firebase = fb.FirebaseAuth.instance;

  AuthService(this._app);

  Future<User> login(String email, String password) async {
    try {
      final cred = await _firebase.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final userFromFire = cred.user;
      if (userFromFire == null) {
        throw Exception('Utilisateur introuvable');
      }

      final idToken = await userFromFire.getIdToken(true);
      final user = await firebaseSync(idToken.toString());

      await fetchProfile();

      return User.fromJson(user["user"]);
    } on fb.FirebaseAuthException catch (e, s) {
      debugPrint("Firebase login error: ${e.code} – ${e.message}\n$s");
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Aucun compte ne correspond à cet e-mail');
        case 'wrong-password':
          throw Exception('Email ou mot de passe incorrect');
        case 'invalid-email':
          throw Exception('Email ou mot de passe incorrect');
        case 'user-disabled':
          throw Exception('Ce compte a été désactivé');
        default:
          throw Exception("Erreur lors de la connexion");
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

      final idToken = await cred.user!.getIdToken();
      // synchronisation avec l'api du User en mettant a jour les infos de l utilisateur
      await firebaseSync(idToken.toString());
      await updateProfile(name: name, email: email, phone: phone);
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
          throw Exception('Erreur d’authentification.');
      }
    } catch (e, s) {
      debugPrint("Autre erreur: $e\n$s");
      throw Exception('Une erreur inattendue est survenue.');
    }
  }

  //Synchronisation avec l admin de l api
  Future<Map<String, dynamic>> firebaseSync(String idToken) async {
    try {
      final response = await _app.post<Map<String, dynamic>>(
        "auth/firebase-sync",
        headers: {'Authorization': 'Bearer $idToken'},
      );
      // debugPrint('Réponse: $response');
      return response;
    } on DioException catch (e) {
      debugPrint('Erreur ${e.response?.statusCode}');
      debugPrint('Body: ${e.response?.data}');
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      final response = await _app.put(
        "auth/profile",
        data: {"name": name, "email": email, "phone": phone},
      );

      debugPrint('Réponse: $response');
    } on DioException catch (e) {
      debugPrint('Erreur ${e.response?.statusCode}');
      debugPrint('Body: ${e.response?.data}');
      rethrow;
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
    try {
      await _app.post("auth/logout");
      await _firebase.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
