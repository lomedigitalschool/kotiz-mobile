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

  Future<void> getKycSubmissions() async {
    emit(KycLoading());
    try {
      final submissions = await _service.fetchKycSubmissions();
      emit(KycLoaded(submissions));
    } catch (e) {
      emit(KycError("Erreur lors de la récupération des soumissions KYC"));
    }
  }

  Future<void> submitKyc(
    String legalName,
    DateTime birthDate,
    String address,
    String documentType,
  ) async {
    emit(KycLoading());
    try {
      final submission = KycSubmission(
        id: '', // Will be set by server
        legalName: legalName,
        birthDate: birthDate,
        address: address,
        documentType: documentType,
        status: 'In Review', // Default status
        submittedAt: DateTime.now(),
      );
      await _service.submitKyc(submission);
      emit(KycSubmitted());
      // Refresh submissions after submit
      await getKycSubmissions();
    } catch (e) {
      emit(KycError("Erreur lors de la soumission KYC"));
    }
  }
}
