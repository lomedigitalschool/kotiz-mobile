import 'package:kotiz_app/core/netework/api_config.dart';

class PaymentService {
  final ApiConfig _apiConfig;

  PaymentService(this._apiConfig);

  /// Initier un paiement pour utilisateur connecté
  Future<Map<String, dynamic>> initiatePayment({
    required String pullId,
    required double amount,
    required String phoneNumber,
    required String paymentMethod,
    String? message,
    bool isAnonymous = false,
    String? successUrl,
    String? cancelUrl,
  }) async {
    try {
      final data = {
        'pullId': pullId,
        'amount': amount,
        'phoneNumber': phoneNumber,
        'paymentMethod': paymentMethod,
        'message': message ?? '',
        'isAnonymous': isAnonymous,
      };
      if (successUrl != null) data['successUrl'] = successUrl;
      if (cancelUrl != null) data['cancelUrl'] = cancelUrl;

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
    required double amount,
    required String phoneNumber,
    required String paymentMethod,
    required String contributorName,
    required String contributorEmail,
    String? message,
    String? successUrl,
    String? cancelUrl,
  }) async {
    try {
      final data = {
        'amount': amount,
        'contributorName': contributorName,
        'phoneNumber': phoneNumber,
        'contributorEmail': contributorEmail,
        'paymentMethod': paymentMethod,
        'message': message ?? '',
      };
      if (successUrl != null) data['successUrl'] = successUrl;
      if (cancelUrl != null) data['cancelUrl'] = cancelUrl;

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
