import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/data/models/profil_user.dart';
import 'package:kotiz_app/logic/auth_cubit.dart';
import 'package:kotiz_app/logic/bottom_nav_cubit.dart';
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
    context.read<AuthCubit>().checkAuthStatus();
    super.initState();
  }

  String initialLetter(String? name) {
    return name?.isNotEmpty == true ? name![0].toUpperCase() : '?';
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
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
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
                    profil?.name ?? 'Utilisateur',
                    style: TextStyle(fontSize: 19),
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
                      ProfilTile(
                        type: "Email",
                        icon: Icon(LucideIcons.mail),
                        content: profil?.email,
                      ),
                      ProfilTile(
                        type: "Telephone",
                        icon: Icon(LucideIcons.phone),
                        content: profil?.phone,
                      ),
                      ProfilTile(
                        type: "Modifier le mot de passe",
                        icon: Icon(LucideIcons.lockKeyhole),
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
                            title: const Text('Déconnexion effectué'),
                            backgroundColor: Colors.green,
                            autoCloseDuration: Duration(seconds: 3),
                            animationDuration: Duration(milliseconds: 600),
                          );
                          context.read<BottomNavCubit>().setIndex(0);
                        },
                        child: ProfilTile(
                          type: "Se Deconnecter",
                          icon: Icon(LucideIcons.logOut),
                          showPen: false,
                        ),
                      ),

                      ProfilTile(
                        type: "Historique des Transactions",
                        icon: Icon(LucideIcons.history),
                        showPen: false,
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
