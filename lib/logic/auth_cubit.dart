import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotiz_app/core/services/auth_service.dart';
import 'package:kotiz_app/core/services/pool_service.dart';
import 'package:kotiz_app/core/utils/secure_storage.dart';
import 'package:kotiz_app/data/models/dashboard_data.dart';
import 'package:kotiz_app/data/models/profil_user.dart';
import 'package:kotiz_app/data/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:shared_preferences/shared_preferences.dart';

// les States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthRegisterSucces extends AuthState {}

class Unauthenticated extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;
  final ProfilUser? profil;
  final DashboardData? dashboardData;

  const AuthSuccess({required this.user, this.profil, this.dashboardData});

  @override
  List<Object?> get props => [user, profil, dashboardData];
}

class AuthProfil extends AuthState {
  final ProfilUser profil;
  const AuthProfil(this.profil);
  @override
  List<Object> get props => [profil];
}

class AuthLoading extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthFormInvalid extends AuthState {
  final bool isValid;
  const AuthFormInvalid(this.isValid);

  @override
  List<Object?> get props => [isValid];
}

// cubit

class AuthCubit extends Cubit<AuthState> {
  final AuthService authService;
  final PoolService _service;

  final _secureStorage = SecureStorage();

  AuthCubit(this.authService, this._service) : super(AuthInitial());

  void validateLoginForm(String email, String password) {
    final isValid = email.trim().isNotEmpty && password.trim().isNotEmpty;
    emit(AuthFormInvalid(isValid));
  }

  void validateRegisterForm(
    String name,
    String prenom,
    String email,
    String phone,
    String password,
    String confirmPassword,
  ) {
    final hasEmail = email.trim().isNotEmpty;
    final hasPhone = phone.trim().isNotEmpty;
    final hasPassword = password.trim().isNotEmpty;
    final hasConfirmPassword = confirmPassword.trim().isNotEmpty;

    // Au moins un identifiant (email ou téléphone) et nom/prénom
    final hasIdentifier = hasEmail || hasPhone;
    final isValid =
        name.trim().isNotEmpty &&
        prenom.trim().isNotEmpty &&
        hasIdentifier &&
        // Si email fourni, mot de passe requis
        (!hasEmail || (hasPassword && hasConfirmPassword)) &&
        // Si téléphone fourni sans email, pas besoin de mot de passe
        (hasEmail || !hasPhone || !hasPassword || hasConfirmPassword);
    emit(AuthFormInvalid(isValid));
  }

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      // Nettoyer les anciennes données
      await _secureStorage.clearAll();

      final User user = await authService.login(email, password);
      final ProfilUser profil = await authService.fetchProfile();
      final DashboardData dashboard = await _service.fetchDashboard();

      await _secureStorage.saveUser(user);
      await _secureStorage.saveProfil(profil);

      emit(AuthSuccess(user: user, profil: profil, dashboardData: dashboard));

      // Charger les notifications après la connexion réussie
      // Note: Ceci nécessiterait l'injection du NotificationCubit,
      // mais pour simplifier, on le fera dans l'UI
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    emit(AuthLoading());
    try {
      await authService.register(email, password, name, phone);
      emit(AuthRegisterSucces());
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> registerUnified({
    required String email,
    required String password,
    required String displayName,
    required String phoneNumber,
  }) async {
    emit(AuthLoading());
    try {
      await authService.registerUnified(
        email,
        password,
        displayName,
        phoneNumber,
      );
      emit(AuthRegisterSucces());
      emit(AuthInitial());
    } catch (e) {
      print(e);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
  }) async {
    emit(AuthLoading());
    try {
      await authService.registerWithEmail(
        email,
        password,
        displayName,
        phoneNumber,
      );
      emit(AuthRegisterSucces());
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> registerWithPhone(String phoneNumber) async {
    emit(AuthLoading());
    try {
      final confirmationResult = await authService.registerWithPhoneNumber(
        phoneNumber,
      );
      emit(
        AuthSuccess(
          user: User(id: null, name: '', email: '', phone: phoneNumber),
          profil: null,
        ),
      );
      // Note: Pour l'inscription téléphone, il faudrait gérer l'OTP séparément
      // Pour l'instant, on simule le succès
      emit(AuthRegisterSucces());
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Future<void> getProfil() async {
  //   emit(AuthLoading());
  //   try {
  //     final ProfilUser profil = await authService.fetchProfile();
  //     print("profil $profil");

  //     emit(AuthProfil(profil));
  //   } catch (e) {
  //     emit(AuthError(e.toString()));
  //   }
  // }

  void logout() async {
    await authService.logout();
    await _secureStorage.clearAll();

    // Effacer aussi SharedPreferences pour éviter tout cache résiduel
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    emit(Unauthenticated());
  }

  Future<void> refreshProfile() async {
    final currentState = state;
    if (currentState is AuthSuccess) {
      try {
        final profil = await authService.fetchProfile();
        final dashboard = await _service.fetchDashboard();
        await _secureStorage.saveProfil(profil);
        emit(
          AuthSuccess(
            user: currentState.user,
            profil: profil,
            dashboardData: dashboard,
          ),
        );
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    }
  }

  Future<void> refreshDashboard() async {
    final currentState = state;
    if (currentState is AuthSuccess) {
      try {
        final dashboard = await _service.fetchDashboard();
        emit(
          AuthSuccess(
            user: currentState.user,
            profil: currentState.profil,
            dashboardData: dashboard,
          ),
        );
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    }
  }

  Future<void> checkAuthStatus() async {
    final user = fb.FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken(true);
    if (token != null && token.isNotEmpty) {
      final fb.User? firebaseUser = fb.FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        try {
          // Toujours récupérer les données fraîches depuis l'API
          final ProfilUser profil = await authService.fetchProfile();
          final DashboardData dashboard = await _service.fetchDashboard();

          // Créer un utilisateur à partir des données Firebase et du profil
          final User currentUser = User(
            id: null, // L'ID sera dans le profil
            email: firebaseUser.email ?? '',
            name: profil.name.isNotEmpty == true && profil.name != 'Utilisateur'
                ? profil.name
                : (firebaseUser.displayName?.isNotEmpty == true
                      ? firebaseUser.displayName!
                      : firebaseUser.email?.split('@')[0] ?? 'Utilisateur'),
            phone: profil.phone ?? '',
          );

          // Sauvegarder les données
          await _secureStorage.saveUser(currentUser);
          await _secureStorage.saveProfil(profil);

          emit(
            AuthSuccess(
              user: currentUser,
              profil: profil,
              dashboardData: dashboard,
            ),
          );
          return;
        } catch (e) {
          debugPrint('Erreur lors de la récupération du profil: $e');
          // Fallback avec les données stockées
          final User? storedUser = await _secureStorage.getUser();
          final ProfilUser? storedProfil = await _secureStorage.getProfil();
          if (storedUser != null) {
            emit(AuthSuccess(user: storedUser, profil: storedProfil));
            return;
          }
        }
      }
    }

    emit(Unauthenticated());
  }

  // Vérifier si l'email de l'utilisateur est vérifié
  bool isEmailVerified() {
    final user = fb.FirebaseAuth.instance.currentUser;
    return user?.emailVerified ?? false;
  }

  // Renvoyer l'email de vérification
  Future<void> sendEmailVerification() async {
    try {
      final user = fb.FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        debugPrint('Email de vérification envoyé à ${user.email}');
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'envoi de l\'email de vérification: $e');
      rethrow;
    }
  }

  // Rafraîchir le profil utilisateur depuis le backend
  Future<void> fetchUserProfile() async {
    final currentState = state;
    if (currentState is AuthSuccess) {
      try {
        final profil = await authService.fetchProfile();
        final dashboard = await _service.fetchDashboard();

        // Mettre à jour l'utilisateur avec les données du profil
        final updatedUser = User(
          id: currentState.user.id,
          email: currentState.user.email,
          name: profil.name.isNotEmpty && profil.name != 'Utilisateur'
              ? profil.name
              : currentState.user.name,
          phone: profil.phone ?? currentState.user.phone,
          avatarUrl: currentState.user.avatarUrl,
        );

        await _secureStorage.saveUser(updatedUser);
        await _secureStorage.saveProfil(profil);

        emit(
          AuthSuccess(
            user: updatedUser,
            profil: profil,
            dashboardData: dashboard,
          ),
        );
      } catch (e) {
        debugPrint('Erreur lors du rafraîchissement du profil: $e');
        // Ne pas émettre d'erreur pour éviter de casser l'UX
      }
    }
  }

  Future<void> syncEmailVerification() async {
    final currentState = state;
    if (currentState is AuthSuccess) {
      try {
        emit(AuthLoading());
        await authService.syncEmailVerification();
        // Rafraîchir le profil après la synchronisation
        await fetchUserProfile();
        final User? user = await _secureStorage.getUser();

        emit(AuthSuccess(user: user!));
      } catch (e) {
        debugPrint('Erreur lors de la synchronisation email: $e');
        // Ne pas émettre d'erreur pour éviter de casser l'UX
      }
    }
  }
}
