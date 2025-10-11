import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/data/models/pool.data.dart';
import 'package:kotiz_app/logic/auth_cubit.dart';
import 'package:kotiz_app/logic/bottom_nav_cubit.dart';
import 'package:kotiz_app/logic/pool_cubit.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/components/pool_page1.dart';
import 'package:kotiz_app/presentation/components/pool_page2.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:toastification/toastification.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  int currentStep = 0;

  final formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>()];
  PoolData poolData = PoolData();

  List<Step> getSteps() => [
    Step(
      state: currentStep > 0 ? StepState.complete : StepState.indexed,
      title: Text(""),
      content: Form(
        key: formKeys[0],
        child: PoolPage1(poolData: poolData),
      ),
      isActive: currentStep >= 0,
    ),
    Step(
      state: currentStep > 1 ? StepState.complete : StepState.indexed,
      title: Text(""),
      content: Form(
        key: formKeys[1],
        child: PoolPage2(poolData: poolData),
      ),
      isActive: currentStep >= 1,
    ),
  ];

  void _submit() async {
    // Synchroniser d'abord le statut de vérification email avec Firebase
    final authCubit = context.read<AuthCubit>();
    await authCubit.syncEmailVerification();

    // Petite pause pour s'assurer que l'état est mis à jour
    await Future.delayed(const Duration(milliseconds: 500));

    // Vérifier si l'email est vérifié côté backend après synchronisation
    final authState = authCubit.state;

    if (authState is! AuthSuccess || !(authState.profil?.isVerified ?? false)) {
      // Afficher un dialog pour expliquer le problème et proposer de rafraîchir ou renvoyer l'email
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            backgroundColor: ColorConstant.colorWhite,
            title: const Text("Vérification email requise"),
            content: const Text(
              "Vous devez vérifier votre adresse email avant de pouvoir créer une cagnotte. Si vous venez de vérifier votre email dans le dashboard, cliquez sur 'Rafraîchir le statut'.",
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text(
                      "Annuler",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();
                      // Rafraîchir le profil et réessayer
                      await authCubit.refreshProfile();
                      await Future.delayed(const Duration(milliseconds: 500));
                      _submit(); // Réessayer la soumission
                    },
                    child: const Text(
                      "Rafraîchir le statut",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();
                      try {
                        await authCubit.sendEmailVerification();
                        toastification.show(
                          context: context,
                          type: ToastificationType.success,
                          title: const Text("Email envoyé"),
                          description: const Text(
                            "Un nouvel email de vérification a été envoyé à votre adresse.",
                          ),
                          backgroundColor: Colors.green.shade200,
                          autoCloseDuration: const Duration(seconds: 3),
                        );
                      } catch (e) {
                        toastification.show(
                          context: context,
                          type: ToastificationType.error,
                          title: const Text("Erreur"),
                          description: Text("Impossible d'envoyer l'email: $e"),
                          backgroundColor: Colors.red.shade200,
                          autoCloseDuration: const Duration(seconds: 3),
                        );
                      }
                    },
                    child: const Text(
                      "Renvoyer l'email",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
      return;
    }

    await context.read<PoolCubit>().create(poolData);
  }

  Future<void> _refreshAndNavigate() async {
    try {
      // Attendre que le dashboard soit rafraîchi
      await context.read<AuthCubit>().refreshDashboard();
      // Petite pause pour s'assurer que l'état est mis à jour
      await Future.delayed(const Duration(milliseconds: 500));
      // Retourner au dashboard (page précédente)
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      // En cas d'erreur, retourner quand même
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthSuccess) {
          // Rediriger vers la page de connexion si non connecté
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              GoRouter.of(context).go('/register');
            }
          });
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            // Permettre la navigation arrière normale
          },
          child: BlocListener<PoolCubit, PoolState>(
            listener: (context, state) {
              if (state is PoolError) {
                toastification.show(
                  context: context,
                  type: ToastificationType.error,
                  title: const Text("Échec lors de la creation de la cagnotte"),
                  description: Text(state.message),
                  icon: const Icon(Icons.error, color: Colors.white),
                  backgroundColor: Colors.red.shade200,
                  autoCloseDuration: Duration(seconds: 3),
                  animationDuration: Duration(milliseconds: 600),
                );
              }
              final String message = state is PoolCreated
                  ? state.poolCreated["message"]
                  : "";
              if (state is PoolCreated) {
                toastification.show(
                  context: context,
                  type: ToastificationType.success,
                  title: Text(message),
                  icon: const Icon(Icons.check, color: Colors.white),
                  backgroundColor: Colors.green.shade200,
                  autoCloseDuration: Duration(seconds: 3),
                  animationDuration: Duration(milliseconds: 600),
                );
                // Rafraîchir le dashboard après création et rediriger
                _refreshAndNavigate();
              }
            },
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: ColorConstant.colorWhite,
              appBar: AppBar(
                backgroundColor: ColorConstant.colorWhite,
                title: Text(
                  "Créer une cagnotte",
                  style: TextStyle(fontSize: 24),
                ),
                centerTitle: true,
                leading: IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(
                    LucideIcons.arrowLeft,
                    size: 24.0,
                    color: ColorConstant.colorBlue,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.close,
                      size: 24.0,
                      color: ColorConstant.colorBlue,
                    ),
                    tooltip: "Fermer",
                  ),
                ],
              ),
              body: BlocBuilder<PoolCubit, PoolState>(
                builder: (context, state) {
                  return Stepper(
                    steps: getSteps(),
                    currentStep: currentStep,
                    type: StepperType.horizontal,
                    margin: EdgeInsetsGeometry.all(50),
                    elevation: 0,
                    stepIconMargin: EdgeInsets.all(0),
                    onStepContinue: () {
                      final form = formKeys[currentStep].currentState!;
                      if (state is! PoolLoading) {
                        if (form.validate()) {
                          if (currentStep == 1) {
                            _submit();
                          } else {
                            setState(() => currentStep += 1);
                          }
                        }
                      }
                    },
                    onStepCancel: currentStep > 0
                        ? () {
                            setState(() {
                              currentStep -= 1;
                            });
                          }
                        : null,
                    controlsBuilder: (context, details) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 15,
                        children: [
                          SizedBox(height: 10),
                          AppButton(
                            widget: state is PoolLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : null,
                            onPressed: details.onStepContinue,
                            text: currentStep == 1 ? "Créer " : "Suivant",
                            backgroundColor: state is PoolLoading
                                ? Colors.grey
                                : ColorConstant.colorGreen,
                          ),
                          currentStep == 1
                              ? AppButton(
                                  onPressed: details.onStepCancel,
                                  backgroundColor: Colors.grey,
                                  text: "Retour",
                                )
                              : Text(""),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
