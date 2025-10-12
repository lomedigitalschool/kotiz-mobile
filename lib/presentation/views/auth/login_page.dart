import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/logic/auth_cubit.dart';
import 'package:kotiz_app/logic/bottom_nav_cubit.dart';
import 'package:kotiz_app/logic/pool_cubit.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/components/text_field.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:toastification/toastification.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool passwordView = false;

  void toggleView() {
    setState(() {
      passwordView = !passwordView;
    });
  }

  void _onSubmit() {
    context.read<AuthCubit>().login(
      email: _emailOrPhoneController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.pop();
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: ColorConstant.colorWhite,
            title: Text("Connexion", style: TextStyle(fontSize: 24)),
            centerTitle: true,
            leading: IconButton(
              onPressed: () => context.go("/home"),
              icon: Icon(
                LucideIcons.arrowLeft400,
                size: 30.0,
                color: ColorConstant.colorBlue,
              ),
            ),
          ),
          backgroundColor: ColorConstant.colorWhite,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
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
                        onTap: () => toggleView(),
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

                    BlocListener<AuthCubit, AuthState>(
                      listener: (context, state) {
                        if (state is AuthError) {
                          toastification.show(
                            context: context,
                            type: ToastificationType.error,
                            title: const Text('Erreur de connexion'),
                            description: Text(state.message),
                            icon: const Icon(Icons.error, color: Colors.white),
                            backgroundColor: Colors.red.shade200,
                            autoCloseDuration: Duration(seconds: 3),
                            animationDuration: Duration(milliseconds: 600),
                          );
                        }
                        if (state is AuthSuccess) {
                          toastification.show(
                            context: context,
                            type: ToastificationType.success,
                            title: const Text('connexion réussie'),
                            description: Text("Bienvenue ${state.user.name}"),
                            icon: const Icon(Icons.check, color: Colors.white),
                            backgroundColor: Colors.green.shade200,
                            autoCloseDuration: Duration(seconds: 3),
                            animationDuration: Duration(milliseconds: 600),
                          );
                          // Rediriger vers le dashboard après connexion
                          context.go('/main');
                          // Puis naviguer vers le dashboard (index 1)
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              context.read<BottomNavCubit>().setIndex(1);
                              context.read<PoolCubit>().getAllPools();
                            }
                          });
                        }
                      },
                      child: BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          bool isFill = false;

                          if (state is AuthFormInvalid) {
                            isFill = state.isValid;
                          }

                          return AppButton(
                            widget: state is AuthLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text("Connexion..."),
                                    ],
                                  )
                                : null,
                            text: "Connecter",

                            onPressed: () {
                              isFill == true ? _onSubmit() : null;
                            },

                            fontSize: 18,
                            backgroundColor: isFill == false
                                ? Colors.grey
                                : ColorConstant.colorGreen,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: () => context.push("/reset-password"),
                        child: Text(
                          "Mot de passe oublié ?",
                          style: TextStyle(
                            fontSize: 16,
                            color: ColorConstant.colorBlue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 3),
                    Row(
                      spacing: 4,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            "Vous n'avez pas de compte?",
                            softWrap: true,
                            maxLines: 3,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Flexible(
                          child: InkWell(
                            onTap: () {
                              context.push("/register");
                            },
                            child: Text(
                              "Créer un compte",
                              softWrap: true,
                              maxLines: 3,
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
