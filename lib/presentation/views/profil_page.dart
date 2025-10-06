import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/data/models/profil_user.dart';
import 'package:kotiz_app/logic/auth_cubit.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/components/profil_tile.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:toastification/toastification.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  @override
  void initState() {
    super.initState();
    // Vérifier le statut d'authentification et récupérer le profil
    context.read<AuthCubit>().checkAuthStatus();
    _refreshProfile();
  }

  Future<void> _refreshProfile() async {
    final state = context.read<AuthCubit>().state;
    if (state is AuthSuccess) {
      // Forcer la récupération du profil depuis l'API
      try {
        await context.read<AuthCubit>().refreshProfile();
      } catch (e) {
        // Gérer l'erreur silencieusement
        // print('Erreur lors de la récupération du profil: $e');
      }
    }
  }

  Future<void> _showEditNameDialog(
    BuildContext context,
    String currentName,
  ) async {
    final TextEditingController nameController = TextEditingController(
      text: currentName,
    );
    final _formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier le nom'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nouveau nom',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom est requis';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    final authState = context.read<AuthCubit>().state;
                    if (authState is AuthSuccess) {
                      await context.read<AuthCubit>().authService.updateProfile(
                        name: nameController.text.trim(),
                        email: authState.profil?.email ?? '',
                        phone: authState.profil?.phone ?? '',
                      );
                      await _refreshProfile();
                      if (mounted) {
                        Navigator.of(context).pop();
                        toastification.show(
                          context: context,
                          type: ToastificationType.success,
                          title: const Text('Nom modifié'),
                          description: const Text('Votre nom a été mis à jour'),
                          backgroundColor: Colors.green.shade100,
                          autoCloseDuration: const Duration(seconds: 3),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      toastification.show(
                        context: context,
                        type: ToastificationType.error,
                        title: const Text('Erreur'),
                        description: Text('Erreur: $e'),
                        backgroundColor: Colors.red.shade100,
                        autoCloseDuration: const Duration(seconds: 3),
                      );
                    }
                  }
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  String initialLetter(String? name) {
    if (name != null && name.isNotEmpty) {
      return name[0].toUpperCase();
    }
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess && authState.user.name.isNotEmpty) {
      return authState.user.name[0].toUpperCase();
    }
    return '?';
  }

  bool isOn = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthSuccess) {
          return Container(
            color: ColorConstant.colorWhite,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber),
                      Text(
                        "Vous n’êtes pas connecter",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: AppButton(
                      text: "Se connecter",
                      backgroundColor: ColorConstant.colorGreen,
                      onPressed: () => context.push("/login"),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final ProfilUser? profil = state.profil;

        return Scaffold(
          backgroundColor: ColorConstant.colorWhite,
          appBar: AppBar(
            title: Text("Profil"),
            centerTitle: true,
            backgroundColor: ColorConstant.colorWhite,
            actions: [
              IconButton(
                icon: Icon(LucideIcons.refreshCw),
                onPressed: _refreshProfile,
                tooltip: "Actualiser le profil",
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                spacing: 8,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 56,
                    child: Text(
                      initialLetter(profil?.name),
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Text(
                    profil?.name ?? state.user.name,
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Text(
                        "Compte",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: ColorConstant.colorGreen,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            _showEditNameDialog(context, profil?.name ?? ''),
                        child: ProfilTile(
                          type: "Nom",
                          icon: Icon(LucideIcons.user),
                          content: profil?.name,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: Implémenter la modification de l'email
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Modification de l\'email bientôt disponible',
                              ),
                            ),
                          );
                        },
                        child: ProfilTile(
                          type: "Email",
                          icon: Icon(LucideIcons.mail),
                          content: profil?.email,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: Implémenter la modification du téléphone
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Modification du téléphone bientôt disponible',
                              ),
                            ),
                          );
                        },
                        child: ProfilTile(
                          type: "Telephone",
                          icon: Icon(LucideIcons.phone),
                          content: profil?.phone,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push("/change-password"),
                        child: ProfilTile(
                          type: "Modifier le mot de passe",
                          icon: Icon(LucideIcons.lockKeyhole),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ColorConstant.colorGreen.withValues(alpha: 0.1),
                              Colors.transparent,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: ColorConstant.colorGreen.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () => context.push("/kyc"),
                          child: ProfilTile(
                            type: "🛡️ Vérifier mon identité (KYC)",
                            icon: Icon(
                              LucideIcons.shieldCheck,
                              color: ColorConstant.colorGreen,
                            ),
                            showPen: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Text(
                        "Notifications",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: ColorConstant.colorGreen,
                        ),
                      ),
                    ),
                  ),
                  ProfilTile(
                    type: "Activé les notifications",
                    icon: Icon(LucideIcons.bell),
                    showPen: false,
                    widget: Switch(
                      activeColor: ColorConstant.colorGreen,
                      value: isOn,
                      onChanged: (value) => setState(() => isOn = value),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Text(
                        "Autres",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: ColorConstant.colorGreen,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.read<AuthCubit>().logout();
                          toastification.show(
                            context: context,
                            type: ToastificationType.success,
                            title: const Text('Déconnexion effectuée'),
                            backgroundColor: Colors.green.shade100,
                            autoCloseDuration: Duration(seconds: 2),
                            animationDuration: Duration(milliseconds: 600),
                          );
                          // Redirection vers login
                          context.go('/login');
                        },
                        child: ProfilTile(
                          type: "Se Deconnecter",
                          icon: Icon(LucideIcons.logOut),
                          showPen: false,
                        ),
                      ),

                      GestureDetector(
                        onTap: () => context.push("/transactions"),
                        child: ProfilTile(
                          type: "Historique des Transactions",
                          icon: Icon(LucideIcons.history),
                          showPen: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
