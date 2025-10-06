import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/data/models/pool.dart';
import 'package:kotiz_app/logic/pool_cubit.dart';
import 'package:kotiz_app/logic/auth_cubit.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/components/text_field.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:toastification/toastification.dart';

class WithdrawPoolPage extends StatefulWidget {
  final Pool pool;
  
  const WithdrawPoolPage({super.key, required this.pool});

  @override
  State<WithdrawPoolPage> createState() => _WithdrawPoolPageState();
}

class _WithdrawPoolPageState extends State<WithdrawPoolPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  String _withdrawMethod = 'orange_money';

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _requestWithdraw() {
    if (_formKey.currentState!.validate()) {
      final amount = int.parse(_amountController.text);
      
      // Vérifier que le montant ne dépasse pas le montant disponible
      if (amount > widget.pool.currentAmount) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: const Text('Montant invalide'),
          description: const Text('Le montant demandé dépasse le montant disponible'),
          backgroundColor: Colors.red.shade100,
          autoCloseDuration: const Duration(seconds: 3),
        );
        return;
      }

      // Simuler la demande de retrait
      context.read<PoolCubit>().requestWithdraw(
        poolId: widget.pool.id.toString(),
        amount: amount.toDouble(),
        method: _withdrawMethod,
        reason: _reasonController.text.trim(),
      );
    }
  }

  bool _canWithdraw() {
    // Vérifier les conditions de retrait
    final now = DateTime.now();
    final isGoalReached = widget.pool.currentAmount >= widget.pool.goalAmount;
    final isDeadlinePassed = now.isAfter(widget.pool.deadline);
    final isClosed = widget.pool.status == 'closed';
    
    return isClosed || isGoalReached || isDeadlinePassed;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        // Vérifier le KYC
        bool hasApprovedKyc = false;
        if (authState is AuthSuccess) {
          // Supposons que le KYC est dans les données utilisateur
          hasApprovedKyc = true; // À adapter selon votre structure de données
        }
        
        final canWithdraw = _canWithdraw() && hasApprovedKyc;
        
        if (!canWithdraw) {
          return Scaffold(
            backgroundColor: ColorConstant.colorWhite,
            appBar: AppBar(
              title: const Text("Retirer des fonds"),
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
                  Icon(
                    Icons.warning,
                    size: 64,
                    color: Colors.orange.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Conditions de retrait non remplies",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Pour retirer des fonds, vous devez avoir un KYC validé ET (cagnotte fermée OU objectif atteint OU date limite dépassée).",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  if (!hasApprovedKyc)
                    AppButton(
                      text: "Soumettre KYC",
                      backgroundColor: Colors.orange,
                      onPressed: () => context.push("/kyc"),
                    ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: "Retour",
                    backgroundColor: Colors.grey,
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
          );
        }
        
        return Scaffold(
          backgroundColor: ColorConstant.colorWhite,
          appBar: AppBar(
            title: const Text("Retirer des fonds"),
            backgroundColor: ColorConstant.colorWhite,
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () => context.pop(),
            ),
          ),
      body: BlocListener<PoolCubit, PoolState>(
        bloc: context.read<PoolCubit>(),
        listener: (context, state) {
          if (state is PoolSuccess) {
            toastification.show(
              context: context,
              type: ToastificationType.success,
              title: const Text('Demande de retrait envoyée'),
              description: const Text('Votre demande sera traitée sous 24-48h'),
              backgroundColor: Colors.green.shade100,
              autoCloseDuration: const Duration(seconds: 3),
            );
            context.pop();
          } else if (state is PoolError) {
            toastification.show(
              context: context,
              type: ToastificationType.error,
              title: Text('Erreur: ${state.message}'),
              backgroundColor: Colors.red.shade100,
              autoCloseDuration: const Duration(seconds: 3),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Informations de la cagnotte
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.pool.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Montant disponible:"),
                          Text(
                            "${widget.pool.currentAmount.toStringAsFixed(0)} FCFA",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ColorConstant.colorGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                TextFieldComponent(
                  labelTitle: "Montant à retirer (FCFA)",
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le montant est requis';
                    }
                    final amount = int.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Montant invalide';
                    }
                    if (amount > widget.pool.currentAmount) {
                      return 'Montant supérieur au disponible';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Méthode de retrait
                DropdownButtonFormField<String>(
                  value: _withdrawMethod,
                  decoration: const InputDecoration(
                    labelText: "Méthode de retrait",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(LucideIcons.creditCard),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'orange_money', child: Text('Orange Money')),
                    DropdownMenuItem(value: 'mtn_money', child: Text('MTN Mobile Money')),
                    DropdownMenuItem(value: 'moov_money', child: Text('Moov Money')),
                    DropdownMenuItem(value: 'bank_transfer', child: Text('Virement bancaire')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _withdrawMethod = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                TextFieldComponent(
                  labelTitle: "Motif du retrait (optionnel)",
                  controller: _reasonController,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                
                // Avertissement
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
                          "Les retraits sont traités sous 24-48h ouvrables. Des frais peuvent s'appliquer selon la méthode choisie.",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                BlocBuilder<PoolCubit, PoolState>(
                  bloc: context.read<PoolCubit>(),
                  builder: (context, state) {
                    return AppButton(
                      text: state is PoolLoading ? "Traitement..." : "Demander le retrait",
                      backgroundColor: ColorConstant.colorGreen,
                      onPressed: state is PoolLoading ? null : _requestWithdraw,
                    );
                  },
                ),
              ],
            ),
          ),
          ),
        ),
      );
      },
    );
  }
}