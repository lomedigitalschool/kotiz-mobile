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
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String currentDialCode = '+228';
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
    final displayName =
        '${_prenomController.text.trim()} ${_nameController.text.trim()}';
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    final hasEmail = email.isNotEmpty;
    final hasPhone = phone.isNotEmpty;
    final hasPassword = password.isNotEmpty;

    // Validation basique
    if (_prenomController.text.trim().isEmpty ||
        _nameController.text.trim().isEmpty) {
      return;
    }

    if (!hasEmail && !hasPhone) {
      return; // Au moins un identifiant requis
    }

    // Détecter le type d'inscription
    if (hasEmail && hasPhone && hasPassword) {
      // 🎯 INSCRIPTION UNIFIÉE : Email + Téléphone + Mot de passe
      if (_passwordController.text.trim() !=
          _confirmPasswordController.text.trim()) {
        return; // Mots de passe ne correspondent pas
      }
      context.read<AuthCubit>().registerUnified(
        email: email,
        password: password,
        displayName: displayName,
        phoneNumber: phone,
      );
    } else if (hasEmail && hasPassword) {
      // 📧 INSCRIPTION EMAIL : Email + Mot de passe
      if (_passwordController.text.trim() !=
          _confirmPasswordController.text.trim()) {
        return; // Mots de passe ne correspondent pas
      }
      context.read<AuthCubit>().registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
        phoneNumber: hasPhone ? phone : null,
      );
    } else if (hasPhone) {
      // 📱 INSCRIPTION TÉLÉPHONE : Téléphone seulement (OTP)
      context.read<AuthCubit>().registerWithPhone(phone);
    } else {
      // Cas non géré
      return;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _prenomController.dispose();
    _confirmPasswordController.dispose();
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
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: ColorConstant.colorWhite,
          title: Text("Créer un compte", style: TextStyle(fontSize: 24)),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => context.push("/home"),
            icon: Icon(
              LucideIcons.arrowLeft,
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
                    controller: _prenomController,
                    labelTitle: "Prénom",
                    astherix: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Le prénom est obligatoire";
                      }
                      if (value.trim().length < 2) {
                        return "Le prénom doit contenir au moins 2 caractères";
                      }
                      return null;
                    },
                    onChanged: (_) {
                      context.read<AuthCubit>().validateRegisterForm(
                        _nameController.text.trim(),
                        _prenomController.text.trim(),
                        _emailController.text.trim(),
                        _phoneController.text.trim(),
                        _passwordController.text.trim(),
                        _confirmPasswordController.text.trim(),
                      );
                    },
                  ),

                  TextFieldComponent(
                    controller: _nameController,
                    labelTitle: "Nom",
                    astherix: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Le nom est obligatoire";
                      }
                      if (value.trim().length < 2) {
                        return "Le nom doit contenir au moins 2 caractères";
                      }
                      return null;
                    },
                    onChanged: (_) {
                      context.read<AuthCubit>().validateRegisterForm(
                        _nameController.text.trim(),
                        _prenomController.text.trim(),
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
                    astherix: false,
                    onChanged: (_) {
                      context.read<AuthCubit>().validateRegisterForm(
                        _nameController.text.trim(),
                        _prenomController.text.trim(),
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
                          "Numéro de téléphone",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(fontSize: 24, color: Colors.black45),
                        ),
                      ),
                    ],
                  ),
                  IntlPhoneField(
                    initialCountryCode: "TG",
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (phone) {
                      _phoneController.text =
                          "${phone.countryCode}${phone.number}";
                      context.read<AuthCubit>().validateRegisterForm(
                        _nameController.text.trim(),
                        _prenomController.text.trim(),
                        _emailController.text.trim(),
                        _phoneController.text.trim(),
                        _passwordController.text.trim(),
                        _confirmPasswordController.text.trim(),
                      );
                    },
                    onCountryChanged: (country) {
                      setState(() {
                        currentDialCode = country.dialCode;
                      });
                      _phoneController.text =
                          "$currentDialCode${_phoneController.text.replaceAll(RegExp(r'^\+\d+'), '')}";
                    },
                  ),

                  // decoration: ,
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
                        _prenomController.text.trim(),
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
                        _prenomController.text.trim(),
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
                          child: AppButton(
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
                      Flexible(
                        child: InkWell(
                          onTap: () {
                            context.push("/login");
                          },
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
