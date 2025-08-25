import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/logic/auth_cubit.dart';
import 'package:kotiz_app/logic/bottom_nav_cubit.dart';
import 'package:kotiz_app/presentation/views/auth/register_page.dart';
import 'package:kotiz_app/presentation/views/create_page.dart';
import 'package:kotiz_app/presentation/views/explore_page.dart';
import 'package:kotiz_app/presentation/views/home_page.dart';
import 'package:kotiz_app/presentation/views/auth/login_page.dart';
import 'package:kotiz_app/presentation/views/main_page.dart';
import 'package:kotiz_app/presentation/views/onboarding.dart';
import 'package:kotiz_app/presentation/views/profil_page.dart';
import 'package:kotiz_app/presentation/views/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final showHome = prefs.getBool("showHome") ?? false;

  runApp(MyApp(showHome: showHome));
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.showHome});
  final bool showHome;

  @override
  Widget build(BuildContext context) {
    final GoRouter _router = GoRouter(
      initialLocation: "/register",
      routes: [
        GoRoute(
          path: "/",
          builder: (context, state) => SplashScreen(showHome: showHome),
        ),
        GoRoute(path: "/login", builder: (context, state) => LoginPage()),
        GoRoute(path: "/onboarding", builder: (context, state) => OnBoarding()),
        GoRoute(path: "/home", builder: (context, state) => HomePage()),
        GoRoute(path: "/explore", builder: (context, state) => ExplorePage()),
        GoRoute(path: "/create", builder: (context, state) => CreatePage()),
        GoRoute(path: "/profil", builder: (context, state) => ProfilPage()),
        GoRoute(path: "/main", builder: (context, state) => MainPage()),
        GoRoute(path: "/register", builder: (context, state) => RegisterPage()),
      ],
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => BottomNavCubit()),
        BlocProvider(create: (_) => AuthCubit()),
      ],
      child: MaterialApp.router(
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: "Roboto",
          colorSchemeSeed: ColorConstant.colorWhite,
        ),
        // home: SplashScreen(showHome: showHome),
      ),
    );
  }
}
