import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PaymentStatusPage extends StatelessWidget {
  final String transactionId;
  final String status;
  final double amount;
  final String method;
  final String? poolTitle;

  const PaymentStatusPage({
    super.key,
    required this.transactionId,
    required this.status,
    required this.amount,
    required this.method,
    this.poolTitle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSuccess = status.toLowerCase() == 'success' || status.toLowerCase() == 'completed';
    final bool isPending = status.toLowerCase() == 'pending' || status.toLowerCase() == 'processing';
    final bool isFailed = status.toLowerCase() == 'failed' || status.toLowerCase() == 'error';

    return Scaffold(
      backgroundColor: ColorConstant.colorWhite,
      appBar: AppBar(
        title: const Text("Statut du paiement"),
        backgroundColor: ColorConstant.colorWhite,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône de statut
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSuccess 
                    ? Colors.green.shade100
                    : isPending 
                        ? Colors.orange.shade100
                        : Colors.red.shade100,
              ),
              child: Icon(
                isSuccess 
                    ? LucideIcons.check
                    : isPending 
                        ? LucideIcons.clock
                        : LucideIcons.x,
                size: 60,
                color: isSuccess 
                    ? Colors.green
                    : isPending 
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            
            // Titre du statut
            Text(
              isSuccess 
                  ? "Paiement réussi !"
                  : isPending 
                      ? "Paiement en cours"
                      : "Paiement échoué",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSuccess 
                    ? Colors.green
                    : isPending 
                        ? Colors.orange
                        : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Message de statut
            Text(
              isSuccess 
                  ? "Votre contribution a été enregistrée avec succès"
                  : isPending 
                      ? "Votre paiement est en cours de traitement"
                      : "Une erreur est survenue lors du paiement",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Détails de la transaction
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Détails de la transaction",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDetailRow("ID Transaction", transactionId),
                  _buildDetailRow("Montant", "${amount.toStringAsFixed(0)} FCFA"),
                  _buildDetailRow("Méthode", _getMethodName(method)),
                  if (poolTitle != null) _buildDetailRow("Cagnotte", poolTitle!),
                  _buildDetailRow("Statut", _getStatusText(status)),
                  _buildDetailRow("Date", _getCurrentDate()),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Messages spécifiques selon le statut
            if (isPending) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.info, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Veuillez patienter pendant que nous traitons votre paiement. Vous recevrez une notification une fois terminé.",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            if (isFailed) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.info, color: Colors.red),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Le paiement a échoué. Veuillez vérifier vos informations et réessayer.",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Boutons d'action
            if (isSuccess) ...[
              AppButton(
                text: "Retour à l'accueil",
                backgroundColor: ColorConstant.colorGreen,
                onPressed: () => context.go('/'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text(
                  "Voir la cagnotte",
                  style: TextStyle(color: ColorConstant.colorGreen),
                ),
              ),
            ] else if (isFailed) ...[
              AppButton(
                text: "Réessayer le paiement",
                backgroundColor: ColorConstant.colorGreen,
                onPressed: () => context.pop(),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text(
                  "Retour à l'accueil",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ] else ...[
              AppButton(
                text: "Vérifier le statut",
                backgroundColor: ColorConstant.colorGreen,
                onPressed: () {
                  // Actualiser le statut
                  // context.read<TransactionCubit>().checkTransactionStatus(transactionId);
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text(
                  "Retour à l'accueil",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getMethodName(String method) {
    switch (method.toLowerCase()) {
      case 'orange_money':
        return 'Orange Money';
      case 'mtn_money':
        return 'MTN Mobile Money';
      case 'moov_money':
        return 'Moov Money';
      case 'bank_transfer':
        return 'Virement bancaire';
      case 'semoa':
        return 'SEMOA';
      default:
        return method;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
        return 'Réussi';
      case 'pending':
      case 'processing':
        return 'En cours';
      case 'failed':
      case 'error':
        return 'Échoué';
      default:
        return status;
    }
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return "${now.day}/${now.month}/${now.year} à ${now.hour}:${now.minute.toString().padLeft(2, '0')}";
  }
}