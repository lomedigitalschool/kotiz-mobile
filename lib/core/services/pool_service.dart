import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kotiz_app/core/netework/api_config.dart';
import 'package:kotiz_app/data/models/dashboard_data.dart';
import 'package:kotiz_app/data/models/pool.dart';
import 'package:kotiz_app/data/models/pool.data.dart';

class PoolService {
  final ApiConfig _app;
  PoolService(this._app);

  Future<Pool> poolDetails(String id) async {
    try {
      final data = await _app.get<Map<String, dynamic>>("public/pulls/$id");
      debugPrint('Pool details: $data');

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

      debugPrint('Dashboard JSON reçu: $json');
      return DashboardData.fromJson(json);
    } catch (e, s) {
      debugPrint('Erreur lors de la récupération du dashboard : $e\n$s');
      // Retourner un dashboard vide plutôt que de faire planter l'app
      return DashboardData(
        totalCollected: 0.0,
        activePullsCount: 0,
        contributorsCount: 0,
        myPools: [],
        myContributions: [],
      );
    }
  }

  Future<Map<String, dynamic>> createContribution(
    Map<String, dynamic> contributionData,
  ) async {
    try {
      final Map<String, dynamic> response = await _app.post(
        "/contributions",
        data: contributionData,
      );
      debugPrint("✅ Contribution créée: ${response["message"]}");
      return response;
    } catch (e) {
      debugPrint("❌ Erreur contribution: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createPool(PoolData poolData) async {
    if (poolData.image != null) {
      // Si il y a une image, utiliser FormData mais avec les champs séparés
      final formData = FormData.fromMap({
        "title": poolData.title,
        "description": poolData.description,
        "goalAmount": poolData.goalAmount.toString(),
        "deadline": poolData.deadline?.toIso8601String(),
        "type": poolData.type,
        "image": await MultipartFile.fromFile(
          poolData.image!.path,
          filename: poolData.image!.path.split('/').last,
        ),
      });

      try {
        final Map<String, dynamic> response = await _app.post(
          "/pulls",
          data: formData,
          headers: {"Content-Type": "multipart/form-data"},
        );
        debugPrint("✅ Réponse: ${response["message"]}");
        return response;
      } catch (e) {
        debugPrint("❌ Erreur: $e");
        rethrow;
      }
    } else {
      // Si pas d'image, envoyer directement en JSON
      try {
        final Map<String, dynamic> response = await _app.post(
          "/pulls",
          data: poolData.toJson(),
        );
        debugPrint("✅ Réponse: ${response["message"]}");
        return response;
      } catch (e) {
        debugPrint("❌ Erreur: $e");
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> updatePool(
    String poolId,
    Map<String, dynamic> poolData,
  ) async {
    try {
      final Map<String, dynamic> response = await _app.put(
        "/pulls/$poolId",
        data: poolData,
      );
      debugPrint("✅ Cagnotte mise à jour: ${response["message"]}");
      return response;
    } catch (e) {
      debugPrint("❌ Erreur lors de la mise à jour: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deletePool(String poolId) async {
    try {
      final Map<String, dynamic> response = await _app.delete("/pulls/$poolId");
      debugPrint("✅ Cagnotte supprimée: ${response["message"]}");
      return response;
    } catch (e) {
      debugPrint("❌ Erreur lors de la suppression: $e");
      rethrow;
    }
  }
}
