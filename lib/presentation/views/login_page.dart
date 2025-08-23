import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isFill = true;

  // void _validateForm(){
  //   isFill
  // }

  // @override
  void dispose() {
    super.dispose();
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.go("/main"); // déclenché par le bouton physique
        return false; // empêche Flutter de fermer l'app
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: ColorConstant.colorWhite,
          title: Text("Connexion", style: TextStyle(fontSize: 24)),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => context.go("/main"),
            icon: Icon(
              LucideIcons.chevronLeft400,
              size: 50.0,
              color: ColorConstant.colorBlue,
            ),
          ),
        ),
        backgroundColor: ColorConstant.colorWhite,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: SizedBox(
              height: MediaQuery.of(context).size.height, // 👈 taille écran
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Email/phone",
                    style: TextStyle(fontSize: 24, color: Colors.black45),
                  ),
                  SizedBox(height: 15),

                  TextField(
                    controller: _emailOrPhoneController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ), // arrondi des coins
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Mot de passe",
                    style: TextStyle(fontSize: 24, color: Colors.black45),
                  ),
                  SizedBox(height: 15),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ), // arrondi des coins
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  AppButton(
                    text: "Connecter",
                    onPressed:
                        _emailOrPhoneController.text.trim().isEmpty &&
                            _passwordController.text.trim().isEmpty
                        ? () {
                            setState(() {
                              isFill = false;
                            });
                            return null;
                          }
                        : () {
                            setState(() {
                              isFill = true;
                            });
                          },
                    fontSize: 18,
                    backgroundColor: !isFill
                        ? Colors.grey
                        : ColorConstant.colorBlue,
                  ),
                  SizedBox(height: 20),
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Vous n'avez pas de compte?",
                          style: TextStyle(fontSize: 16),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              "Créer un compte",
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 16,
                                color: ColorConstant.colorBlue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
