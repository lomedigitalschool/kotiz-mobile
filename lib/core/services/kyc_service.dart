import 'package:kotiz_app/core/netework/api_config.dart';
import 'package:kotiz_app/data/models/kyc.dart';

class KycService {
  final ApiConfig _apiConfig;
  
  KycService(this._apiConfig);

  Future<List<KycSubmission>> fetchKycSubmissions() async {
    try {
      final response = await _apiConfig.get<Map<String, dynamic>>('/kyc/history');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => KycSubmission.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des soumissions KYC: $e');
    }
  }

  Future<void> submitKyc(KycSubmission submission) async {
    try {
      await _apiConfig.post('/kyc/submit', data: submission.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la soumission KYC: $e');
    }
  }

  Future<Map<String, dynamic>> getKycStatus() async {
    try {
      final response = await _apiConfig.get<Map<String, dynamic>>('/kyc/status');
      return response;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du statut KYC: $e');
    }
  }
}