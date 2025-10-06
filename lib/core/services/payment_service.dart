import 'package:kotiz_app/core/netework/api_config.dart';

class PaymentService {
  final ApiConfig _apiConfig;

  PaymentService(this._apiConfig);

  /// Initier un paiement pour utilisateur connecté ou anonyme
  Future<Map<String, dynamic>> initiatePayment({
    required String pullId,
    required String amount,
    required String phoneNumber,
    required String paymentMethod,
    String? message,
    bool isAnonymous = false,
  }) async {
    try {
      final data = <String, dynamic>{
        'pullId': pullId,
        'amount': amount,
        'phoneNumber': phoneNumber,
        'paymentMethod': paymentMethod,
        'isAnonymous': isAnonymous,
      };
      if (message != null && message.isNotEmpty) data['message'] = message;

      final response = await _apiConfig.post<Map<String, dynamic>>(
        '/contributions',
        data: data,
      );

      return {
        'success': true,
        'contribution': response['contribution'],
        'payment': response['payment'],
        'message': response['message'] ?? 'Paiement initié avec succès',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de l\'initiation du paiement: $e',
      };
    }
  }

  /// Traiter une contribution anonyme
  Future<Map<String, dynamic>> processAnonymousContribution({
    required String pullId,
    required String amount,
    required String phoneNumber,
    required String paymentMethod,
    required String contributorName,
    required String contributorEmail,
    String? message,
  }) async {
    try {
      final data = <String, dynamic>{
        'amount': amount,
        'contributorName': contributorName,
        'phoneNumber': phoneNumber,
        'contributorEmail': contributorEmail,
        'paymentMethod': paymentMethod,
      };
      if (message != null && message.isNotEmpty) data['message'] = message;

      final response = await _apiConfig.post<Map<String, dynamic>>(
        '/public/contributions/anonymous/$pullId',
        data: data,
      );

      return {
        'success': true,
        'contribution': response['contribution'],
        'message': response['message'] ?? 'Contribution créée avec succès',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la contribution: $e',
      };
    }
  }

  /// Vérifier le statut d'une contribution
  Future<Map<String, dynamic>> checkContributionStatus(
    String contributionId,
  ) async {
    try {
      final response = await _apiConfig.get<Map<String, dynamic>>(
        '/contributions/$contributionId/status',
      );

      return {
        'success': true,
        'contribution': response['contribution'],
        'transaction': response['transaction'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la vérification du statut: $e',
      };
    }
  }
}
