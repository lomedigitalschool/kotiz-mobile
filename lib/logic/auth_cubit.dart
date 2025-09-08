import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotiz_app/core/services/auth_service.dart';
import 'package:kotiz_app/core/utils/secure_storage.dart';
import 'package:kotiz_app/data/models/user.dart';

// les States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthRegisterSucces extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
  @override
  List<Object> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;
  const AuthSuccess(this.user);
  @override
  List<Object> get props => [user];
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
  final _secureStorage = SecureStorage();

  AuthCubit(this.authService) : super(AuthInitial());

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
      final user = await authService.login(email, password);
      await _secureStorage.saveUser(user);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(
        AuthError(
          e is DioException
              ? e.response?.data["error"] ?? "Erreur réseau"
              : "Erreur inattendue : $e",
        ),
      );
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
    } on DioException catch (e) {
      emit(AuthError(e.response?.data["error"] ?? "Impossible de s’inscrire."));
    }
  }

  void logout() async {
    authService.logout();
    await _secureStorage.deleteUser();
    emit(AuthInitial());
  }

  Future<void> checkAuthStatus() async {
    final token = await _secureStorage.getToken();
    if (token != null && token.isNotEmpty) {
      final user = await _secureStorage.getUser();
      emit(Authenticated(user!));
    } else {
      emit(Unauthenticated());
    }
  }
}
