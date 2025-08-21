import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/logic/bottomNavCubit.dart';
import 'package:kotiz_app/presentation/views/create_page.dart';
import 'package:kotiz_app/presentation/views/explore_page.dart';
import 'package:kotiz_app/presentation/views/home_page.dart';
import 'package:kotiz_app/presentation/views/login_page.dart';
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
  final bool showHome;
  MyApp({super.key, required this.showHome});

  @override
  Widget build(BuildContext context) {
    final GoRouter _router = GoRouter(
      initialLocation: kDebugMode ? "/main" : "/",
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
      ],
    );

    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => BottomNavCubit())],
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
