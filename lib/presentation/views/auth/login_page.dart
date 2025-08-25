import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/logic/auth_cubit.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/components/text_field.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool passwordView = false;

  void _toggleView() {
    setState(() {
      passwordView = !passwordView;
    });
  }

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.pop();
        return false;
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
                  TextFieldComponent(
                    labelTitle: "Email/numero",
                    controller: _emailOrPhoneController,
                    onChanged: (_) {
                      context.read<AuthCubit>().validateLoginForm(
                        _emailOrPhoneController.text.trim(),
                        _passwordController.text.trim(),
                      );
                    },
                  ),
                  SizedBox(height: 20),

                  TextFieldComponent(
                    labelTitle: "Mot de passe",
                    controller: _passwordController,
                    obscureText: passwordView ? false : true,
                    suffixIcon: GestureDetector(
                      onTap: () => _toggleView(),
                      child: Icon(
                        passwordView ? LucideIcons.eyeOff : LucideIcons.eye,
                      ),
                    ),

                    onChanged: (_) {
                      context.read<AuthCubit>().validateLoginForm(
                        _emailOrPhoneController.text.trim(),
                        _passwordController.text.trim(),
                      );
                    },
                  ),
                  SizedBox(height: 50),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      bool isFill = false;

                      if (state is AuthFormInvalid) {
                        isFill = state.isValid;
                      }

                      return AppButton(
                        text: "Connecter",
                        onPressed: () {},

                        fontSize: 18,
                        backgroundColor: isFill == false
                            ? Colors.grey
                            : ColorConstant.colorBlue,
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  Flexible(
                    child: Row(
                      spacing: 4,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Vous n'avez pas de compte?",
                          style: TextStyle(fontSize: 16),
                        ),
                        InkWell(
                          onTap: () {
                            context.push("/register");
                          },
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
