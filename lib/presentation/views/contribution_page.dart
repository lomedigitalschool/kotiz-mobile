import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:kotiz_app/core/netework/api_config.dart';
import 'package:kotiz_app/core/services/payment_service.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/logic/auth_cubit.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/components/text_field.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

class ContributionPage extends StatefulWidget {
  final String poolId;
  const ContributionPage({super.key, required this.poolId});
  final String poolId;
  const ContributionPage({super.key, required this.poolId});

  @override
  State<ContributionPage> createState() => _ContributionPageState();
}

class _ContributionPageState extends State<ContributionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isAnonymous = false;
  String _paymentMethod = 'orange_money';
  bool _isSubmitting = false;
  String _completePhoneNumber = '';

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitContribution() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final authState = context.read<AuthCubit>().state;
      final isLoggedIn = authState is AuthSuccess;
      final paymentService = PaymentService(ApiConfig());

      if (isLoggedIn) {
        // Utilisateur connecté - utiliser l'API de paiement
        final response = await paymentService.initiatePayment(
          pullId: widget.poolId,
          amount: _amountController.text.trim(),
          phoneNumber: _completePhoneNumber,
          paymentMethod: _paymentMethod,
          message: _messageController.text.trim(),
          isAnonymous: _isAnonymous,
        );

        if (response['success'] == true) {
          // Ouvrir l'URL de paiement automatiquement
          if (response['paymentUrl'] != null &&
              response['paymentUrl'].isNotEmpty) {
            try {
              debugPrint(
                'Ouverture URL de paiement: ${response['paymentUrl']}',
              );
              await launchUrl(
                Uri.parse(response['paymentUrl']),
                mode: LaunchMode
                    .externalApplication, // Force ouverture dans navigateur externe
              );
              debugPrint('URL de paiement ouverte avec succès');
            } catch (urlError) {
              debugPrint(
                'Erreur lors de l\'ouverture de l\'URL de paiement: $urlError',
              );
              // Ne pas bloquer le processus si l'ouverture d'URL échoue
              if (mounted) {
                toastification.show(
                  context: context,
                  type: ToastificationType.warning,
                  title: const Text('URL de paiement'),
                  description: Text(
                    'Impossible d\'ouvrir automatiquement l\'URL de paiement. URL: ${response['paymentUrl']}',
                  ),
                  backgroundColor: Colors.orange.shade200,
                  autoCloseDuration: const Duration(seconds: 5),
                );
              }
            }
          } else {
            debugPrint('Aucune URL de paiement reçue');
          }

          // Rediriger vers la page de statut de paiement
          final contributionId = response['contribution']?['id']?.toString();
          if (contributionId != null) {
            debugPrint(
              'Redirection vers page de statut: /payment-status/$contributionId',
            );
            if (mounted) {
              context.go('/payment-status/$contributionId');
            }
          } else {
            // Fallback si pas d'ID de contribution
            debugPrint(
              'Pas d\'ID de contribution, affichage message de succès',
            );
            if (mounted) {
              toastification.show(
                context: context,
                type: ToastificationType.success,
                title: const Text('Paiement initié'),
                description: const Text(
                  'Votre paiement a été initié avec succès',
                ),
                backgroundColor: Colors.green.shade200,
                autoCloseDuration: const Duration(seconds: 3),
              );
              context.pop();
            }
          }
        } else {
          throw Exception(response['message'] ?? 'Erreur lors du paiement');
        }
      } else {
        // Utilisateur anonyme - contribution publique
        final response = await paymentService.processAnonymousContribution(
          pullId: widget.poolId,
          amount: _amountController.text.trim(),
          phoneNumber: _completePhoneNumber,
          paymentMethod: _paymentMethod,
          contributorName: _isAnonymous
              ? "Anonyme"
              : _nameController.text.trim(),
          contributorEmail: _isAnonymous ? "" : _emailController.text.trim(),
          message: _messageController.text.trim(),
        );

        if (response['success'] == true) {
          // Ouvrir l'URL de paiement automatiquement si disponible
          if (response['paymentUrl'] != null &&
              response['paymentUrl'].isNotEmpty) {
            try {
              debugPrint(
                'Ouverture URL de paiement anonyme: ${response['paymentUrl']}',
              );
              await launchUrl(
                Uri.parse(response['paymentUrl']),
                mode: LaunchMode.externalApplication,
              );
              debugPrint('URL de paiement anonyme ouverte avec succès');
            } catch (urlError) {
              debugPrint(
                'Erreur lors de l\'ouverture de l\'URL de paiement anonyme: $urlError',
              );
              if (mounted) {
                toastification.show(
                  context: context,
                  type: ToastificationType.warning,
                  title: const Text('URL de paiement'),
                  description: Text(
                    'Impossible d\'ouvrir l\'URL de paiement. Erreur: $urlError',
                  ),
                  backgroundColor: Colors.orange.shade200,
                  autoCloseDuration: const Duration(seconds: 5),
                );
              }
            }
          } else {
            debugPrint(
              'Aucune URL de paiement reçue pour contribution anonyme',
            );
            if (mounted) {
              toastification.show(
                context: context,
                type: ToastificationType.info,
                title: const Text('Paiement initié'),
                description: const Text(
                  'Votre paiement a été initié. Vous recevrez les instructions par SMS.',
                ),
                backgroundColor: Colors.blue.shade200,
                autoCloseDuration: const Duration(seconds: 3),
              );
            }
          }

          // Pour les contributions anonymes, ne rediriger vers la page de statut que si une URL de paiement a été ouverte
          final contributionId = response['contribution']?['id']?.toString();
          final paymentUrlOpened =
              response['paymentUrl'] != null &&
              response['paymentUrl'].isNotEmpty;

          if (contributionId != null && paymentUrlOpened) {
            debugPrint(
              'Redirection vers page de statut anonyme: /payment-status/$contributionId',
            );
            if (mounted) {
              context.go('/payment-status/$contributionId');
            }
          } else {
            // Pour les contributions anonymes sans URL de paiement (SMS ou autre méthode)
            debugPrint(
              'Contribution anonyme créée sans URL de paiement, affichage message de succès',
            );
            if (mounted) {
              toastification.show(
                context: context,
                type: ToastificationType.success,
                title: const Text('Contribution créée'),
                description: const Text(
                  'Votre contribution a été enregistrée avec succès',
                ),
                backgroundColor: Colors.green.shade200,
                autoCloseDuration: const Duration(seconds: 3),
              );
              context.pop();
            }
          }
        } else {
          throw Exception(
            response['message'] ?? 'Erreur lors de la contribution',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: const Text('Erreur'),
          description: Text('Erreur: $e'),
          backgroundColor: Colors.red.shade200,
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    } finally {
      if (context.mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle contribution'),
        backgroundColor: ColorConstant.colorWhite,
        leading: IconButton(
          onPressed: () {
            // S'assurer que la navigation fonctionne
            if (Navigator.canPop(context)) {
              context.pop();
            } else {
              // Fallback vers la page d'accueil
              context.go('/');
            }
          },
          icon: const Icon(LucideIcons.arrowLeft),
        ),
      ),
      backgroundColor: ColorConstant.colorWhite,
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          final isLoggedIn = authState is AuthSuccess;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Montant
                  TextFieldComponent(
                    labelTitle: "Montant (FCFA)",
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    astherix: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le montant est requis';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Veuillez entrer un montant valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Message optionnel
                  TextFieldComponent(
                    labelTitle: "Message (optionnel)",
                    controller: _messageController,
                    maxLines: 3,
                    hintText: "Votre message de soutien...",
                  ),
                  const SizedBox(height: 16),

                  // Checkbox anonymat
                  Row(
                    children: [
                      Checkbox(
                        value: _isAnonymous,
                        onChanged: (value) =>
                            setState(() => _isAnonymous = value ?? false),
                      ),
                      const Text("Contribuer anonymement"),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Numéro de téléphone
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Numéro de téléphone *",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      IntlPhoneField(
                        controller: _phoneController,
                        initialCountryCode: "TG",
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: "Numéro pour le paiement",
                        ),
                        onChanged: (phone) {
                          _completePhoneNumber = phone.completeNumber;
                        },
                        validator: (phone) {
                          if (phone == null || phone.number.isEmpty) {
                            return 'Le numéro de téléphone est requis';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                  // Champs pour utilisateurs non connectés
                  if (!isLoggedIn) ...[
                    const SizedBox(height: 16),
                    const Text(
                      "Informations du contributeur",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFieldComponent(
                      labelTitle: "Nom complet",
                      controller: _nameController,
                      astherix: !_isAnonymous,
                      validator: (value) {
                        if (!_isAnonymous &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Le nom est requis sauf si vous contribuez anonymement';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFieldComponent(
                      labelTitle: "Email",
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      astherix: !_isAnonymous,
                      validator: (value) {
                        if (!_isAnonymous) {
                          if (value == null || value.trim().isEmpty) {
                            return 'L\'email est requis sauf si vous contribuez anonymement';
                          }
                          if (!value.contains('@')) {
                            return 'Veuillez entrer un email valide';
                          }
                        }
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Méthode de paiement
                  const Text(
                    "Méthode de paiement",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text('Orange Money'),
                        value: 'orange_money',
                        groupValue: _paymentMethod,
                        onChanged: (value) =>
                            setState(() => _paymentMethod = value!),
                      ),
                      RadioListTile<String>(
                        title: const Text('MTN Mobile Money'),
                        value: 'mtn_money',
                        groupValue: _paymentMethod,
                        onChanged: (value) =>
                            setState(() => _paymentMethod = value!),
                      ),
                      RadioListTile<String>(
                        title: const Text('Moov Money'),
                        value: 'moov_money',
                        groupValue: _paymentMethod,
                        onChanged: (value) =>
                            setState(() => _paymentMethod = value!),
                      ),
                      RadioListTile<String>(
                        title: const Text('Wave'),
                        value: 'wave',
                        groupValue: _paymentMethod,
                        onChanged: (value) =>
                            setState(() => _paymentMethod = value!),
                      ),
                      RadioListTile<String>(
                        title: const Text('Flooz'),
                        value: 'flooz',
                        groupValue: _paymentMethod,
                        onChanged: (value) =>
                            setState(() => _paymentMethod = value!),
                      ),
                      RadioListTile<String>(
                        title: const Text('T-Money'),
                        value: 't_money',
                        groupValue: _paymentMethod,
                        onChanged: (value) =>
                            setState(() => _paymentMethod = value!),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Bouton de soumission
                  AppButton(
                    text: _isSubmitting ? "Traitement..." : "Valider et payer",
                    backgroundColor: _isSubmitting
                        ? Colors.grey
                        : ColorConstant.colorGreen,
                    onPressed: _isSubmitting ? null : _submitContribution,
                    widget: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
