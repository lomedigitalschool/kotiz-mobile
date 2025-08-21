import 'package:flutter/material.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: ColorConstant.colorWhite),
      backgroundColor: ColorConstant.colorWhite,
    );
  }
}
