import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotiz_app/core/services/contribution_service.dart';

//state
abstract class ContributionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ContributionInitial extends ContributionState {}

class ContributionSuccess extends ContributionState {
  final Map<String, dynamic> response;
  ContributionSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class ContributionProgress extends ContributionState {}

class ContributionError extends ContributionState {
  final String message;
  ContributionError(this.message);

  @override
  List<Object?> get props => [message];
}

//cubit

class ContributionCubit extends Cubit<ContributionState> {
  final ContributionService _service;

  ContributionCubit(this._service) : super(ContributionInitial());

  Future<void> contribute({
    required String poolId,
    required int amount,
    String? message,
    bool? isAnonymous,
  }) async {
    try {
      emit(ContributionProgress());
      final Map<String, dynamic> response = await _service.contribute(
        poolId: poolId,
        amount: amount,
        message: message,
        isAnonymous: isAnonymous,
      );

      emit(ContributionSuccess(response));
    } catch (e, s) {
      debugPrint("ContributionCubit error: $e\n$s");
      emit(ContributionError("Erreur lors de la contribution"));
    }
  }
}
