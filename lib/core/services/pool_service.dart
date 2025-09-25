import 'package:flutter/foundation.dart';
import 'package:kotiz_app/core/netework/api_config.dart';
import 'package:kotiz_app/core/utils/secure_storage.dart';
import 'package:kotiz_app/data/models/dashboard_data.dart';
import 'package:kotiz_app/data/models/pool.dart';
import 'package:kotiz_app/data/models/user.dart';

class PoolService {
  final ApiConfig _app;
  PoolService(this._app);

  Future<Pool> poolDetails(String id) async {
    try {
      final data = await _app.get<Map<String, dynamic>>("public/pulls/$id");
      print(data);

      return Pool.fromJson(data['data']);
    } catch (e, s) {
      debugPrint(" error lors de la recuperation : $e\n$s");
      rethrow;
    }
  }

  Future<List<Pool>> fetchPools() async {
    try {
      final data = await _app.get<Map<String, dynamic>>('public/pulls');

      final list = data['data'] as List<dynamic>;
      return list.map((e) => Pool.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e, s) {
      debugPrint('Erreur de récupération des cagnottes : $e\n$s');
      rethrow;
    }
  }

  Future<DashboardData> fetchDashboard() async {
    try {
      final Map<String, dynamic> json = await _app.get<Map<String, dynamic>>(
        'users/dashboard',
      );

      return DashboardData.fromJson(json);
    } catch (e, s) {
      debugPrint('Erreur lors de la récupération du dashboard : $e\n$s');
      rethrow;
    }
  }
}
