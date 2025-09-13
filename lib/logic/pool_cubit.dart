import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotiz_app/core/services/auth_service.dart';
import 'package:kotiz_app/core/services/pool_service.dart';
import 'package:kotiz_app/core/utils/secure_storage.dart';
import 'package:kotiz_app/data/models/pool.dart';
import 'package:kotiz_app/data/models/user.dart';

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

class PoolError extends PoolState {
  final String message;
  PoolError(this.message);
  @override
  List<Object?> get props => [message];
}

// cubit

class PoolCubit extends Cubit<PoolState> {
  final PoolService _service;
  PoolCubit(this._service) : super(PoolLoading());

  Future<void> getAll() async {
    emit(PoolLoading());
    try {
      final pools = await _service.fetchPools();
      emit(PoolLoaded(pools));
    } catch (e) {
      emit(PoolError("Erreur lors de la  récupération des cagnottes"));
    }
  }
}
