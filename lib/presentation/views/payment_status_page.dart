import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/netework/api_config.dart';
import 'package:kotiz_app/core/services/payment_service.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/logic/auth_cubit.dart';
import 'package:kotiz_app/logic/pool_cubit.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:toastification/toastification.dart';

class PaymentStatusPage extends StatefulWidget {
  final String contributionId;

  const PaymentStatusPage({super.key, required this.contributionId});

  @override
  State<PaymentStatusPage> createState() => _PaymentStatusPageState();
}

class _PaymentStatusPageState extends State<PaymentStatusPage> {
  String _status = 'checking';
  Map<String, dynamic>? _contribution;
  Map<String, dynamic>? _transaction;
  String? _error;
  int _countdown = 300; // 5 minutes
  Timer? _pollingTimer;
  Timer? _countdownTimer;

  final PaymentService _paymentService = PaymentService(ApiConfig());

  @override
  void initState() {
    super.initState();
    _startPolling();
    _startCountdown();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // Vérification initiale
    _checkPaymentStatus();

    // Polling toutes les 5 secondes
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_status == 'pending' || _status == 'checking') {
        _checkPaymentStatus();
      }
    });
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        _handleTimeout();
      }
    });
  }

  Future<void> _checkPaymentStatus() async {
    try {
      final response = await _paymentService.checkContributionStatus(
        widget.contributionId,
      );

      if (response['success'] == true) {
        final contribution = response['contribution'];
        final transaction = response['transaction'];

        setState(() {
          _contribution = contribution;
          _transaction = transaction;
        });

        if (contribution['status'] == 'completed') {
          setState(() {
            _status = 'success';
          });
          _handleSuccess();
        } else if (contribution['status'] == 'failed') {
          setState(() {
            _status = 'failed';
          });
        } else {
          setState(() {
            _status = 'pending';
          });
        }
      } else {
        setState(() {
          _error = response['message'] ?? 'Erreur lors de la vérification';
          _status = 'error';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur de connexion: $e';
        _status = 'error';
      });
    }
  }

  void _handleSuccess() {
    // Arrêter les timers
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();

    // Refresh dashboard and pools
    context.read<AuthCubit>().refreshDashboard();
    context.read<PoolCubit>().getAll();
    // Forcer le refresh des pools publiques aussi
    context.read<PoolCubit>().getAllPools();

    // Afficher message de succès
    toastification.show(
      context: context,
      type: ToastificationType.success,
      title: const Text('Paiement réussi'),
      description: const Text(
        'Votre contribution a été enregistrée avec succès',
      ),
      backgroundColor: Colors.green.shade200,
      autoCloseDuration: const Duration(seconds: 3),
    );

    // Rediriger vers le dashboard après 3 secondes
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/main');
      }
    });
  }

  void _handleTimeout() {
    // Arrêter les timers
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();

    // Afficher message d'avertissement
    toastification.show(
      context: context,
      type: ToastificationType.warning,
      title: const Text('Délai dépassé'),
      description: const Text('Vérifiez vos transactions dans l\'historique'),
      backgroundColor: Colors.orange.shade200,
      autoCloseDuration: const Duration(seconds: 3),
    );

    // Rediriger vers le dashboard
    if (mounted) {
      context.go('/main');
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildStatusIcon() {
    switch (_status) {
      case 'checking':
      case 'pending':
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: ColorConstant.colorBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ColorConstant.colorBlue),
            strokeWidth: 3,
          ),
        );

      case 'success':
        return Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.check, color: Colors.white, size: 40),
        );

      case 'failed':
        return Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.x, color: Colors.white, size: 40),
        );

      case 'error':
        return Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.warning, color: Colors.white, size: 40),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  String _getStatusTitle() {
    switch (_status) {
      case 'checking':
        return 'Vérification du paiement...';
      case 'pending':
        return 'Paiement en cours...';
      case 'success':
        return 'Paiement réussi !';
      case 'failed':
        return 'Paiement échoué';
      case 'error':
        return 'Erreur de vérification';
      default:
        return 'Statut inconnu';
    }
  }

  String _getStatusMessage() {
    switch (_status) {
      case 'checking':
        return 'Nous vérifions le statut de votre paiement.';
      case 'pending':
        return 'Votre paiement est en cours de traitement. Cela peut prendre quelques instants.';
      case 'success':
        return 'Votre contribution a été enregistrée avec succès.';
      case 'failed':
        return 'Le paiement n\'a pas pu être traité. Veuillez réessayer.';
      case 'error':
        return _error ?? 'Une erreur est survenue lors de la vérification.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statut du paiement'),
        backgroundColor: ColorConstant.colorWhite,
        leading: IconButton(
          onPressed: () => context.go('/main'),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
      ),
      backgroundColor: ColorConstant.colorWhite,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusIcon(),
              const SizedBox(height: 24),

              Text(
                _getStatusTitle(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Text(
                _getStatusMessage(),
                style: const TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),

              if (_contribution != null) ...[
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Montant: ${_contribution!['amount']} ${_contribution!['currency'] ?? 'FCFA'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_transaction != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Référence: ${_transaction!['providerReference'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              if (_status == 'pending' || _status == 'checking') ...[
                const SizedBox(height: 32),
                Text(
                  'Temps restant: ${_formatTime(_countdown)}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Veuillez patienter pendant que nous vérifions votre paiement...',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ],

              if (_status == 'success') ...[
                const SizedBox(height: 32),
                const Text(
                  'Redirection vers le dashboard...',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
