import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/logic/auth_cubit.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/components/text_field.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:toastification/toastification.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool password1View = true;
  bool password2View = true;
  final formKey = GlobalKey<FormState>();

  void toggleView1() {
    setState(() {
      password1View = !password1View;
    });
  }

  void toggleView2() {
    setState(() {
      password2View = !password2View;
    });
  }

  void _onSubmit() {
    context.read<AuthCubit>().register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.pop();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: ColorConstant.colorWhite,
          title: Text("Créer un compte", style: TextStyle(fontSize: 24)),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => context.go("/main"),
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
            child: Form(
              key: formKey,
              child: Column(
                spacing: 20,
                children: [
                  TextFieldComponent(
                    controller: _nameController,
                    labelTitle: "Nom",
                    astherix: true,
                    onChanged: (_) {
                      context.read<AuthCubit>().validateRegisterForm(
                        _nameController.text.trim(),
                        _emailController.text.trim(),
                        _phoneController.text.trim(),
                        _passwordController.text.trim(),
                        _confirmPasswordController.text.trim(),
                      );
                    },
                  ),

                  TextFieldComponent(
                    controller: _emailController,
                    labelTitle: "Email",
                    onChanged: (_) {
                      context.read<AuthCubit>().validateRegisterForm(
                        _nameController.text.trim(),
                        _emailController.text.trim(),
                        _phoneController.text.trim(),
                        _passwordController.text.trim(),
                        _confirmPasswordController.text.trim(),
                      );
                    },
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 5,
                    children: [
                      Flexible(
                        child: Text(
                          "Numero de telephone",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(fontSize: 24, color: Colors.black45),
                        ),
                      ),
                    ],
                  ),
                  IntlPhoneField(
                    controller: _phoneController,
                    initialCountryCode: "TG",
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // decoration: ,
                  ),
                  TextFieldComponent(
                    controller: _passwordController,
                    labelTitle: "Mot de passe",
                    astherix: true,
                    obscureText: password1View,
                    suffixIcon: GestureDetector(
                      onTap: () => toggleView1(),
                      child: Icon(
                        password1View ? LucideIcons.eye : LucideIcons.eyeOff,
                      ),
                    ),
                    onChanged: (_) {
                      context.read<AuthCubit>().validateRegisterForm(
                        _nameController.text.trim(),
                        _emailController.text.trim(),
                        _phoneController.text.trim(),
                        _passwordController.text.trim(),
                        _confirmPasswordController.text.trim(),
                      );
                    },
                  ),
                  TextFieldComponent(
                    validator: (value) {
                      if (value == null ||
                          value != _passwordController.text.trim()) {
                        return "Les mots de passe ne correspondent pas";
                      }
                      return null;
                    },
                    controller: _confirmPasswordController,
                    labelTitle: "Confirmer le mot de passe",
                    astherix: true,
                    obscureText: password2View,
                    suffixIcon: GestureDetector(
                      onTap: () => toggleView2(),
                      child: Icon(
                        password2View ? LucideIcons.eye : LucideIcons.eyeOff,
                      ),
                    ),
                    onChanged: (_) {
                      context.read<AuthCubit>().validateRegisterForm(
                        _nameController.text.trim(),
                        _emailController.text.trim(),
                        _phoneController.text.trim(),
                        _passwordController.text.trim(),
                        _confirmPasswordController.text.trim(),
                      );
                    },
                  ),

                  BlocListener<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is AuthError) {
                        toastification.show(
                          context: context,
                          type: ToastificationType.error,
                          title: const Text('Erreur lors de l\' inscription '),
                          description: Text(state.message),
                          icon: const Icon(Icons.error, color: Colors.white),
                          backgroundColor: Colors.red.shade200,
                          autoCloseDuration: Duration(seconds: 3),
                          animationDuration: Duration(milliseconds: 600),
                        );
                      }
                      if (state is AuthRegisterSucces) {
                        toastification.show(
                          context: context,
                          type: ToastificationType.success,
                          title: const Text('Inscription  réussie'),
                          icon: const Icon(Icons.error, color: Colors.white),
                          backgroundColor: Colors.green.shade200,
                          autoCloseDuration: Duration(seconds: 3),
                          animationDuration: Duration(milliseconds: 600),
                        );
                        context.push("/login");
                      }
                    },
                    child: BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        bool isFill = state is AuthFormInvalid && state.isValid;

                        return Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Flexible(
                            child: AppButton(
                              widget: state is AuthLoading
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text("creation du ..."),
                                      ],
                                    )
                                  : null,
                              text: "Créer le compte",
                              backgroundColor: isFill == false
                                  ? Colors.grey
                                  : ColorConstant.colorGreen,
                              onPressed: () {
                                final form = formKey.currentState!;
                                if (isFill == false) {
                                  null;
                                } else if (form.validate()) {
                                  _onSubmit();
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Row(
                    spacing: 4,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          "Vous  avez déjà un compte ?",
                          softWrap: true,
                          maxLines: 2,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          context.push("/login");
                        },
                        child: Flexible(
                          child: Text(
                            "Se connecter",
                            softWrap: true,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 16,
                              color: ColorConstant.colorBlue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
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
