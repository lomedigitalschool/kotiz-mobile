import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotiz_app/core/services/auth_service.dart';
import 'package:kotiz_app/core/services/pool_service.dart';
import 'package:kotiz_app/core/utils/secure_storage.dart';
import 'package:kotiz_app/data/models/dashboard_data.dart';
import 'package:kotiz_app/data/models/profil_user.dart';
import 'package:kotiz_app/data/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

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
    String email,
    String phone,
    String password,
    String confirmPassword,
  ) {
    final bool phoneOrEmail =
        email.trim().isNotEmpty || phone.trim().isNotEmpty;
    final isValid =
        name.trim().isNotEmpty &&
        phoneOrEmail &&
        password.trim().isNotEmpty &&
        confirmPassword.trim().isNotEmpty;
    emit(AuthFormInvalid(isValid));
  }

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final User user = await authService.login(email, password);
      final ProfilUser profil = await authService.fetchProfile();
      final DashboardData dashboard = await _service.fetchDashboard();

      await _secureStorage.saveUser(user);
      await _secureStorage.saveProfil(profil);

      emit(AuthSuccess(user: user, profil: profil, dashboardData: dashboard));
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

    emit(AuthInitial());
  }

  Future<void> checkAuthStatus() async {
    final user = fb.FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken(true);
    if (token != null && token.isNotEmpty) {
      final fb.User? firebaseUser = fb.FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        final User? storedUser = await _secureStorage.getUser();
        final ProfilUser? storedProfil = await _secureStorage.getProfil();
        if (storedUser != null) {
          emit(AuthSuccess(user: storedUser, profil: storedProfil));
          return;
        }
      }
    }

    emit(Unauthenticated());
  }
}
