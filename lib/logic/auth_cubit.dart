import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// les States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String token;
  const Authenticated(this.token);

  @override
  List<Object?> get props => [token];
}

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
  AuthCubit() : super(AuthInitial());

  void validateForm(String email, String password) {
    final isValid = email.trim().isNotEmpty && password.trim().isNotEmpty;
    emit(AuthFormInvalid(isValid));
  }
}
