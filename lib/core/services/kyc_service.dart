import 'package:kotiz_app/core/netework/api_config.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class KycService {
  final ApiConfig _apiConfig;

  KycService(this._apiConfig);

  Future<Map<String, dynamic>> submitKyc({
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
    try {
      final formData = FormData.fromMap({
        'nomLegal': nomLegal,
        'dateNaissance': dateNaissance,
        'adresse': adresse,
        'nationalite': nationalite,
        'typePiece': typePiece,
        'numeroPiece': numeroPiece,
        'dateExpiration': dateExpiration,
        'photoRecto': await MultipartFile.fromFile(
          photoRecto.path,
          filename: 'recto_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        'photoVerso': await MultipartFile.fromFile(
          photoVerso.path,
          filename: 'verso_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _apiConfig.post<Map<String, dynamic>>(
        '/kyc/submit',
        data: formData,
        headers: {'Content-Type': 'multipart/form-data'},
      );

      return {
        'success': true,
        'message': response['message'] ?? 'KYC soumis avec succès',
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la soumission KYC: $e',
      };
    }
  }
}
