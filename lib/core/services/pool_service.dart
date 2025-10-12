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
      // ✅ CORRECTION: Utiliser l'endpoint mixte pour accéder aux détails avec contrôle d'accès
      final response = await _app.get("pulls/$id");
      debugPrint('Pool details response: $response');

      // Sécuriser l'accès aux données avec gestion de différents formats
      dynamic data;
      if (response is Map<String, dynamic>) {
        // Format { success: true, data: { ... } }
        data = response['data'];
        if (data == null) {
          // Format direct { ... } sans enveloppe
          data = response;
        }
      } else if (response is List) {
        // Format inattendu en liste - prendre le premier élément si possible
        debugPrint(
          '⚠️ Réponse inattendue en liste pour poolDetails, utilisation du premier élément',
        );
        if (response.isNotEmpty) {
          data = response[0];
        } else {
          throw ('Liste vide reçue du serveur');
        }
      } else {
        throw ('Type de réponse inattendu: ${response.runtimeType}');
      }

      if (data != null && data is Map<String, dynamic>) {
        debugPrint('✅ Parsing des détails de cagnotte réussi');
        return Pool.fromJson(data);
      }

      throw ('Données de cagnotte nulles ou mal formatées');
    } catch (e, s) {
      debugPrint("❌ Erreur lors de la récupération des détails : $e\n$s");
      rethrow;
    }
  }

  Future<List<Pool>> fetchPools() async {
    try {
      // ✅ CORRECTION: Utiliser l'endpoint privé pour récupérer les cagnottes de l'utilisateur connecté
      // Au lieu de 'public/pulls' qui retourne toutes les cagnottes publiques
      // Le backend retourne directement une liste, pas un objet avec clé 'data'
      final response = await _app.get('/pulls');

      final list = response as List<dynamic>;

      debugPrint('✅ Cagnottes utilisateur récupérées: ${list.length}');

      return list.map((e) => Pool.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e, s) {
      debugPrint('❌ Erreur de récupération des cagnottes utilisateur : $e\n$s');
      rethrow;
    }
  }

  Future<List<Pool>> fetchAllPools() async {
    try {
      // ✅ CORRECTION: Utiliser l'endpoint authentifié pour récupérer toutes les cagnottes (publiques et privées)
      final response = await _app.get('pulls/all');
      debugPrint('✅ Récupération de toutes les cagnottes via pulls/all');

      // Le backend peut retourner soit une liste directement, soit un objet avec 'data' ou 'pools'
      dynamic jsonData = response;

      List<dynamic> list;
      if (jsonData is List) {
        list = jsonData;
      } else if (jsonData is Map<String, dynamic>) {
        // Essayer différentes structures possibles
        list =
            jsonData['data'] as List<dynamic>? ??
            jsonData['pools'] as List<dynamic>? ??
            (jsonData['data'] is Map
                ? (jsonData['data']['pools'] as List<dynamic>? ?? [])
                : []);
      } else {
        list = [];
      }

      debugPrint('✅ Toutes les cagnottes récupérées: ${list.length}');

      return list.map((e) => Pool.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e, s) {
      debugPrint('❌ Erreur de récupération de toutes les cagnottes : $e\n$s');
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
    debugPrint("🔍 Début de création de cagnotte");
    debugPrint("📊 Données de cagnotte: ${poolData.toJson()}");

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
        debugPrint("📤 Envoi avec image via FormData");
        final Map<String, dynamic> response = await _app.post(
          "/pulls",
          data: formData,
          headers: {"Content-Type": "multipart/form-data"},
        );
        debugPrint("✅ Réponse: ${response["message"]}");
        return response;
      } catch (e) {
        debugPrint("❌ Erreur lors de la création avec image: $e");
        if (e is DioException) {
          debugPrint("🔍 Détails DioException:");
          debugPrint("   Status Code: ${e.response?.statusCode}");
          debugPrint("   Status Message: ${e.response?.statusMessage}");
          debugPrint("   Response Data: ${e.response?.data}");
          debugPrint("   Request Headers: ${e.requestOptions.headers}");
          debugPrint(
            "   Request URL: ${e.requestOptions.baseUrl}${e.requestOptions.path}",
          );
        }
        rethrow;
      }
    } else {
      // Si pas d'image, envoyer directement en JSON
      try {
        debugPrint("📤 Envoi sans image via JSON");
        debugPrint("📋 Payload JSON: ${poolData.toJson()}");
        final Map<String, dynamic> response = await _app.post(
          "/pulls",
          data: poolData.toJson(),
        );
        debugPrint("✅ Réponse: ${response["message"]}");
        return response;
      } catch (e) {
        debugPrint("❌ Erreur lors de la création sans image: $e");
        if (e is DioException) {
          debugPrint("🔍 Détails DioException:");
          debugPrint("   Status Code: ${e.response?.statusCode}");
          debugPrint("   Status Message: ${e.response?.statusMessage}");
          debugPrint("   Response Data: ${e.response?.data}");
          debugPrint("   Request Headers: ${e.requestOptions.headers}");
          debugPrint(
            "   Request URL: ${e.requestOptions.baseUrl}${e.requestOptions.path}",
          );
        }
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
