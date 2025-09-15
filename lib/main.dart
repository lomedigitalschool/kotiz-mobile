import 'dart:async';
import 'dart:math';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/netework/api_config.dart';
import 'package:kotiz_app/core/services/auth_service.dart';
import 'package:kotiz_app/core/services/pool_service.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/core/utils/secure_storage.dart';
import 'package:kotiz_app/logic/auth_cubit.dart';
import 'package:kotiz_app/logic/bottom_nav_cubit.dart';
import 'package:kotiz_app/logic/pool_cubit.dart';
import 'package:kotiz_app/presentation/views/auth/register_page.dart';
import 'package:kotiz_app/presentation/views/create_page.dart';
import 'package:kotiz_app/presentation/views/dashboard_page.dart';
import 'package:kotiz_app/presentation/views/home_page.dart';
import 'package:kotiz_app/presentation/views/auth/login_page.dart';
import 'package:kotiz_app/presentation/views/main_page.dart';
import 'package:kotiz_app/presentation/views/onboarding.dart';
import 'package:kotiz_app/presentation/views/pool_details.dart';
import 'package:kotiz_app/presentation/views/profil_page.dart';
import 'package:kotiz_app/presentation/views/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final showHome = prefs.getBool("showHome") ?? false;

  runApp(MyApp(showHome: showHome));
}

class MyApp extends StatefulWidget {
  MyApp({super.key, required this.showHome});
  final bool showHome;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final apiConfig = ApiConfig();

  final secureStorage = SecureStorage();

  late final authService = AuthService(apiConfig, secureStorage);

  late final _poolService = PoolService(apiConfig);
  StreamSubscription<Uri>? sub;

  final _appLinks = AppLinks();
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _buildRouter();
    listenDeepLinks();
  }

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: kDebugMode ? "/main" : "/",
      routes: [
        GoRoute(
          path: "/",
          builder: (context, state) => SplashScreen(showHome: widget.showHome),
        ),
        GoRoute(path: "/login", builder: (context, state) => LoginPage()),
        GoRoute(path: "/onboarding", builder: (context, state) => OnBoarding()),
        GoRoute(path: "/home", builder: (context, state) => HomePage()),
        GoRoute(path: "/explore", builder: (context, state) => DashboardPage()),
        GoRoute(path: "/create", builder: (context, state) => CreatePage()),
        GoRoute(path: "/profil", builder: (context, state) => ProfilPage()),
        GoRoute(path: "/main", builder: (context, state) => MainPage()),
        GoRoute(path: "/register", builder: (context, state) => RegisterPage()),
        GoRoute(
          path: "/poolDetails/:id",
          builder: (context, state) {
            final String id = state.pathParameters["id"]!;

            return PoolDetails(id: id);
          },
        ),
      ],
    );
  }

  // void _handleUri(Uri uri) {

  // }

  Future<void> listenDeepLinks() async {
    sub = _appLinks.uriLinkStream.listen((uri) {
      log('Uri: ${uri.toString()}' as num);
      if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'pool') {
        final id = uri.pathSegments[1];
        if (id != null && int.tryParse(id) != null) {
          _router.go('/pool/$id');
        }
      }
    });
  }

  @override
  void dispose() {
    sub?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => BottomNavCubit()),
        BlocProvider(create: (_) => AuthCubit(authService)),
        BlocProvider(create: (_) => PoolCubit(_poolService)),
      ],
      child: MaterialApp.router(
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: "Roboto",
          colorSchemeSeed: ColorConstant.colorWhite,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', 'US'), Locale('fr', 'FR')],
        // home: SplashScreen(showHome: showHome),
      ),
    );
  }
}
