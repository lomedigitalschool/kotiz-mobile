import 'package:kotiz_app/core/netework/api_config.dart';
import 'package:kotiz_app/data/models/transaction.dart';

class TransactionService {
  final ApiConfig _apiConfig;
  TransactionService(this._apiConfig);

  Future<List<Transaction>> fetchTransactions() async {
    try {
      final response = await _apiConfig.get<Map<String, dynamic>>('/contributions/my');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des transactions: $e');
    }
  }

  Future<Transaction> getTransactionDetails(String id) async {
    try {
      final response = await _apiConfig.get<Map<String, dynamic>>('/contributions/$id/status');
      return Transaction.fromJson(response['data']);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des détails de transaction: $e');
    }
  }

  Future<Map<String, dynamic>> createTransaction(Map<String, dynamic> transactionData) async {
    try {
      final response = await _apiConfig.post<Map<String, dynamic>>('/contributions', data: transactionData);
      return response;
    } catch (e) {
      throw Exception('Erreur lors de la création de la transaction: $e');
    }
  }
}