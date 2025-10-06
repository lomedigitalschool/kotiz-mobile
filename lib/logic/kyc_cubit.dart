import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotiz_app/core/services/kyc_service.dart';
import 'package:kotiz_app/data/models/kyc.dart';

// States
abstract class KycState extends Equatable {
  @override
  List<Object?> get props => [];
}

class KycLoading extends KycState {}

class KycLoaded extends KycState {
  final List<KycSubmission> submissions;
  KycLoaded(this.submissions);
  @override
  List<Object?> get props => [submissions];
}

class KycSubmitted extends KycState {}

class KycError extends KycState {
  final String message;
  KycError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class KycCubit extends Cubit<KycState> {
  final KycService _service;
  KycCubit(this._service) : super(KycLoading());

  Future<void> submitKyc({
    required String nomLegal,
    required String dateNaissance,
    required String adresse,
    required String nationalite,
    required String typePiece,
    required String numeroPiece,
    required String dateExpiration,
    required File photoRecto,
    required File photoVerso,
  }) async {
    emit(KycLoading());
    try {
      final response = await _service.submitKyc(
        nomLegal: nomLegal,
        dateNaissance: dateNaissance,
        adresse: adresse,
        nationalite: nationalite,
        typePiece: typePiece,
        numeroPiece: numeroPiece,
        dateExpiration: dateExpiration,
        photoRecto: photoRecto,
        photoVerso: photoVerso,
      );

      if (response['success'] == true) {
        emit(KycSubmitted());
      } else {
        emit(
          KycError(response['message'] ?? "Erreur lors de la soumission KYC"),
        );
      }
    } catch (e) {
      emit(KycError("Erreur lors de la soumission KYC: $e"));
    }
  }
}
