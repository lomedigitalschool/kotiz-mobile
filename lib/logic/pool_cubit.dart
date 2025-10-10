import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotiz_app/core/services/pool_service.dart';
import 'package:kotiz_app/data/models/pool.dart';
import 'package:kotiz_app/data/models/pool.data.dart';

// les States
abstract class PoolState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PoolLoading extends PoolState {}

class PoolLoaded extends PoolState {
  final List<Pool> pools;

  PoolLoaded(this.pools);
  @override
  List<Object?> get props => [pools];
}

class UserPoolsLoaded extends PoolState {
  final List<Pool> userPools;

  UserPoolsLoaded(this.userPools);
  @override
  List<Object?> get props => [userPools];
}

class AllPoolsLoaded extends PoolState {
  final List<Pool> allPools;

  AllPoolsLoaded(this.allPools);
  @override
  List<Object?> get props => [allPools];
}

class PoolCreated extends PoolState {
  final Map<String, dynamic> poolCreated;
  PoolCreated(this.poolCreated);
  @override
  List<Object?> get props => [poolCreated];
}

class PoolDetailsLoaded extends PoolState {
  final Pool pool;
  PoolDetailsLoaded(this.pool);
  @override
  List<Object?> get props => [pool];
}

class PoolError extends PoolState {
  final String message;
  PoolError(this.message);
  @override
  List<Object?> get props => [message];
}

class PoolSuccess extends PoolState {
  final String message;
  PoolSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

// cubit

class PoolCubit extends Cubit<PoolState> {
  final PoolService _service;
  PoolCubit(this._service) : super(PoolLoading());

  Future<void> getPoolDetails(String id) async {
    emit(PoolLoading());
    try {
      final pool = await _service.poolDetails(id);
      emit(PoolDetailsLoaded(pool));
    } catch (e) {
      emit(PoolError("Erreur lors du chargement"));
    }
  }

  Future<void> getAll() async {
    emit(PoolLoading());
    try {
      final pools = await _service.fetchPools();
      emit(UserPoolsLoaded(pools));
    } catch (e) {
      emit(PoolError("Erreur lors de la récupération des cagnottes utilisateur"));
    }
  }

  Future<void> getAllPools() async {
    emit(PoolLoading());
    try {
      final pools = await _service.fetchAllPools();
      emit(AllPoolsLoaded(pools));
    } catch (e) {
      emit(PoolError("Erreur lors de la récupération de toutes les cagnottes"));
    }
  }

  Future<void> create(PoolData poolData) async {
    emit(PoolLoading());
    try {
      final Map<String, dynamic> response = await _service.createPool(poolData);
      emit(PoolCreated(response));
    } catch (e) {
      emit(PoolError("Erreur lors de la  creation de la cagnotte"));
    }
  }

  Future<void> updatePool(Pool pool) async {
    emit(PoolLoading());
    try {
      final updateData = {
        'title': pool.title,
        'description': pool.description,
        'goalAmount': pool.goalAmount,
        'deadline': pool.deadline.toIso8601String(),
        'type': pool.type,
      };
      await _service.updatePool(pool.id.toString(), updateData);
      emit(PoolSuccess("Cagnotte modifiée avec succès"));
    } catch (e) {
      emit(PoolError("Erreur lors de la modification de la cagnotte"));
    }
  }

  Future<void> createContribution(Map<String, dynamic> contributionData) async {
    emit(PoolLoading());
    try {
      await _service.createContribution(contributionData);
      emit(PoolSuccess("Contribution créée avec succès"));
    } catch (e) {
      emit(PoolError("Erreur lors de la création de la contribution"));
    }
  }

  Future<void> deletePool(String poolId) async {
    emit(PoolLoading());
    try {
      await _service.deletePool(poolId);
      emit(PoolSuccess("Cagnotte supprimée avec succès"));
    } catch (e) {
      emit(PoolError("Erreur lors de la suppression de la cagnotte"));
    }
  }

  Future<void> requestWithdraw({
    required String poolId,
    required double amount,
    required String method,
    required String reason,
  }) async {
    emit(PoolLoading());
    try {
      // Simuler la demande de retrait (à remplacer par l'appel API réel)
      await Future.delayed(const Duration(seconds: 2));
      // await _service.requestWithdraw(poolId, amount, method, reason);
      emit(PoolSuccess("Demande de retrait envoyée avec succès"));
    } catch (e) {
      emit(PoolError("Erreur lors de la demande de retrait"));
    }
  }
}
