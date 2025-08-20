import 'package:flutter/material.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/presentation/views/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final showHome = prefs.getBool("showHome") ?? false;

  runApp(MyApp(showHome: showHome));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.showHome});
  final bool showHome;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Roboto",
        colorSchemeSeed: ColorConstant.colorWhite,
      ),
      home: SplashScreen(showHome: showHome),
    );
  }
}
