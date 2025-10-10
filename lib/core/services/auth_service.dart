import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:kotiz_app/core/netework/api_config.dart';
import 'package:kotiz_app/data/models/profil_user.dart';
import 'package:kotiz_app/data/models/user.dart';

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
      debugPrint(
        '🔄 Début inscription - Email: $email, Name: $name, Phone: $phone',
      );

      final cred = await fb.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final idToken = await cred.user!.getIdToken();
      debugPrint('✅ Firebase Auth réussi, ID Token obtenu');

      // synchronisation avec l'api du User en mettant a jour les infos de l utilisateur
      final syncResult = await firebaseSync(idToken.toString());
      debugPrint('✅ Firebase sync réussi: $syncResult');

      debugPrint(
        '📤 Envoi du profil - Name: $name, Email: $email, Phone: $phone',
      );
      await updateProfile(name: name, email: email, phone: phone);
      debugPrint('✅ Profil mis à jour avec succès');
    } on fb.FirebaseAuthException catch (e, s) {
      debugPrint("❌ Auth error: ${e.code} – ${e.message}\n$s");
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Cet e-mail est déjà utilisé.');
        case 'invalid-email':
          throw Exception('Adresse e-mail invalide.');
        case 'weak-password':
          throw Exception('Mot de passe trop faible.');
        default:
          throw Exception('Erreur d\'authentification.');
      }
    } catch (e, s) {
      debugPrint("❌ Autre erreur lors de l'inscription: $e\n$s");
      throw Exception('Une erreur inattendue est survenue.');
    }
  }

  Future<void> registerUnified(
    String email,
    String password,
    String displayName,
    String phoneNumber,
  ) async {
    try {
      debugPrint(
        '🎯 Début inscription unifiée - Email: $email, DisplayName: $displayName, Phone: $phoneNumber',
      );

      final response = await _app.post(
        "auth/register-unified",
        data: {
          "email": email,
          "password": password,
          "displayName": displayName,
          "phoneNumber": phoneNumber,
        },
      );

      debugPrint('✅ Inscription unifiée réussie: $response');
    } on DioException catch (e) {
      debugPrint(
        '❌ Erreur inscription unifiée - Status: ${e.response?.statusCode}',
      );
      debugPrint('❌ Erreur inscription unifiée - Body: ${e.response?.data}');
      rethrow;
    } catch (e, s) {
      debugPrint("❌ Autre erreur lors de l'inscription unifiée: $e\n$s");
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
    required String idToken,
  }) async {
    try {
      debugPrint(
        '📤 Mise à jour du profil - Payload: {"name": "$name", "email": "$email", "phone": "$phone"}',
      );
      final response = await _app.put(
        "auth/profile",
        data: {"name": name, "email": email, "phone": phone},
        headers: {'Authorization': 'Bearer $idToken'},
      );

      debugPrint('✅ Profil mis à jour - Réponse: $response');
    } on DioException catch (e) {
      debugPrint(
        '❌ Erreur mise à jour profil - Status: ${e.response?.statusCode}',
      );
      debugPrint('❌ Erreur mise à jour profil - Body: ${e.response?.data}');
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

  Future<void> syncEmailVerification() async {
    try {
      debugPrint('🔄 Synchronisation du statut de vérification email...');
      final user = _firebase.currentUser;
      if (user != null) {
        final idToken = await user.getIdToken(true);
        if (idToken != null) {
          await firebaseSync(idToken);
          debugPrint('✅ Synchronisation email terminée');
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la synchronisation email: $e');
      rethrow;
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _firebase.currentUser;
      if (user == null || user.email == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Réauthentifier avec le mot de passe actuel
      final cred = fb.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);

      // Changer le mot de passe
      await user.updatePassword(newPassword);
    } on fb.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          throw Exception('Mot de passe actuel incorrect');
        case 'weak-password':
          throw Exception('Le nouveau mot de passe est trop faible');
        case 'requires-recent-login':
          throw Exception('Réauthentification requise');
        default:
          throw Exception('Erreur lors du changement de mot de passe');
      }
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _app.post("auth/logout");
      await _firebase.signOut();
      // Effacer le cache du token dans ApiConfig
      _app.clearTokenCache();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registerWithEmail(
    String email,
    String password,
    String displayName,
    String? phoneNumber,
  ) async {
    try {
      debugPrint(
        '📧 Début inscription email - Email: $email, DisplayName: $displayName, Phone: $phoneNumber',
      );

      final cred = await fb.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final idToken = await cred.user!.getIdToken();
      debugPrint('✅ Firebase Auth réussi, ID Token obtenu');

      // synchronisation avec l'api du User
      final syncResult = await firebaseSync(idToken.toString());
      debugPrint('✅ Firebase sync réussi: $syncResult');

      debugPrint(
        '📤 Envoi du profil - Name: $displayName, Email: $email, Phone: $phoneNumber',
      );
      await updateProfile(
        name: displayName,
        email: email,
        phone: phoneNumber ?? '',
      );
      debugPrint('✅ Profil mis à jour avec succès');
    } on fb.FirebaseAuthException catch (e, s) {
      debugPrint("❌ Auth error: ${e.code} – ${e.message}\n$s");
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Cet e-mail est déjà utilisé.');
        case 'invalid-email':
          throw Exception('Adresse e-mail invalide.');
        case 'weak-password':
          throw Exception('Mot de passe trop faible.');
        default:
          throw Exception('Erreur d\'authentification.');
      }
    } catch (e, s) {
      debugPrint("❌ Autre erreur lors de l'inscription email: $e\n$s");
      throw Exception('Une erreur inattendue est survenue.');
    }
  }

  Future<dynamic> registerWithPhoneNumber(String phoneNumber) async {
    try {
      final formattedPhone = formatPhoneNumber(phoneNumber);

      // En développement avec numéro de test, simuler complètement
      if (!kReleaseMode && formattedPhone == '+22899974644') {
        debugPrint('📱 Simulation complète pour numéro de test');

        return {
          'confirm': (String code) async {
            if (code == '974644') {
              // Créer un utilisateur anonyme Firebase
              final userCredential = await fb.FirebaseAuth.instance
                  .signInAnonymously();
              return userCredential;
            } else {
              throw Exception('Code de vérification invalide');
            }
          },
        };
      }

      // Pour l'instant, simuler pour les autres numéros
      debugPrint('📱 Simulation inscription téléphone pour $formattedPhone');
      return {
        'confirm': (String code) async {
          // Simuler vérification réussie
          final userCredential = await fb.FirebaseAuth.instance
              .signInAnonymously();
          return userCredential;
        },
      };
    } catch (error) {
      throw error;
    }
  }

  String formatPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.startsWith(RegExp(r'\d'))) {
      cleaned = '+' + cleaned;
    }
    return cleaned;
  }

  Future<void> initRecaptcha() async {
    // Implémentation simplifiée pour mobile
    // Dans une vraie implémentation, il faudrait gérer reCAPTCHA
  }

  void cleanupRecaptcha() {
    // Nettoyer reCAPTCHA si nécessaire
  }
}
