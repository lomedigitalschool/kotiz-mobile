import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/logic/auth_cubit.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/components/text_field.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

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
  bool password1View = false;
  bool password2View = false;

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
    return WillPopScope(
      onWillPop: () async {
        context.pop();
        return false;
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
              height: MediaQuery.of(context).size.height,
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
                  TextFieldComponent(
                    controller: _phoneController,
                    labelTitle: "Numero de telephone",
                    keyboardType: TextInputType.phone,
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
                    controller: _passwordController,
                    labelTitle: "Mot de passe",
                    astherix: true,
                    obscureText: true,
                    suffixIcon: GestureDetector(
                      onTap: () => toggleView1(),
                      child: Icon(
                        password1View ? LucideIcons.eyeOff : LucideIcons.eye,
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
                    controller: _confirmPasswordController,
                    labelTitle: "Confirmer le mot de passe",
                    astherix: true,
                    obscureText: true,
                    suffixIcon: GestureDetector(
                      onTap: () => toggleView2(),
                      child: Icon(
                        password2View ? LucideIcons.eyeOff : LucideIcons.eye,
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

                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      bool isFill = true;

                      if (state is AuthFormInvalid) {
                        isFill = state.isValid;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 45.0),
                        child: AppButton(
                          text: "Créer le compte",
                          backgroundColor: isFill == false
                              ? Colors.grey
                              : ColorConstant.colorBlue,
                          onPressed: () {},
                        ),
                      );
                    },
                  ),

                  Expanded(
                    child: Row(
                      spacing: 4,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Vous  avez déjà un compte ?",
                          style: TextStyle(fontSize: 16),
                        ),
                        InkWell(
                          onTap: () {
                            context.push("/login");
                          },
                          child: Text(
                            "Se connecter",
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
