import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotiz_app/core/services/pool_service.dart';
import 'package:kotiz_app/data/models/dashboard_data.dart';

//state
abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardLoading extends DashboardState {}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}

class DashboardLoaded extends DashboardState {
  final DashboardData dashboardData;
  DashboardLoaded(this.dashboardData);
  List<Object?> get props => [dashboardData];
}

class DashboardCubit extends Cubit<DashboardState> {
  final PoolService _service;

  DashboardCubit(super.initialState, this._service);

  Future<void> loadDashboard() async {
    emit(DashboardLoading());
    try {
      final DashboardData dashboard = await _service.fetchDashboard();
      debugPrint('Total collecté : ${dashboard.totalCollected}');
      debugPrint('Cagnottes actives : ${dashboard.activePullsCount}');
      emit(DashboardLoaded(dashboard));
    } catch (e) {
      debugPrint('Impossible de charger le dashboard : $e');
      emit(DashboardError("Erreur lors du chargement du dashboard"));
    }
  }
}
