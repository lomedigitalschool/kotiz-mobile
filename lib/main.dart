import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/netework/api_config.dart';
import 'package:kotiz_app/core/services/auth_service.dart';
import 'package:kotiz_app/core/services/pool_service.dart';
import 'package:kotiz_app/core/services/transaction_service.dart';
import 'package:kotiz_app/core/services/notification_service.dart';
import 'package:kotiz_app/core/utils/secure_storage.dart';
import 'package:kotiz_app/firebase_options.dart';
import 'package:kotiz_app/logic/auth_cubit.dart';
import 'package:kotiz_app/logic/bottom_nav_cubit.dart';
import 'package:kotiz_app/logic/pool_cubit.dart';
import 'package:kotiz_app/logic/transaction_cubit.dart';
import 'package:kotiz_app/logic/notification_cubit.dart';
import 'package:kotiz_app/presentation/views/auth/register_page.dart';
import 'package:kotiz_app/presentation/views/contribution_page.dart';
import 'package:kotiz_app/presentation/views/create_page.dart';
import 'package:kotiz_app/presentation/views/kyc_page.dart';
import 'package:kotiz_app/presentation/views/transaction_list.dart';
import 'package:kotiz_app/presentation/views/notifications_page.dart';
import 'package:kotiz_app/presentation/views/dashboard_page.dart';
import 'package:kotiz_app/presentation/views/home_page.dart';
import 'package:kotiz_app/presentation/views/auth/change_password_page.dart';
import 'package:kotiz_app/presentation/views/auth/login_page.dart';
import 'package:kotiz_app/presentation/views/auth/reset_password_page.dart';
import 'package:kotiz_app/presentation/views/main_page.dart';
import 'package:kotiz_app/presentation/views/onboarding.dart';
import 'package:kotiz_app/presentation/views/pool_details.dart';
import 'package:kotiz_app/presentation/views/profil_page.dart';
import 'package:kotiz_app/presentation/views/splash_screen.dart';
import 'package:kotiz_app/presentation/views/supported_pools_page.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    HttpOverrides.global = MyHttpOverrides();
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final showHome = prefs.getBool("showHome") ?? false;

  runApp(MyApp(showHome: showHome));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.showHome});
  final bool showHome;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final apiConfig = ApiConfig();

  final secureStorage = SecureStorage();

  late final authService = AuthService(apiConfig);

  late final _poolService = PoolService(apiConfig);
  late final _transactionService = TransactionService(apiConfig);
  late final _notificationService = NotificationService(apiConfig);
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

        // GoRoute(
        //   path: "/login",
        //   pageBuilder: (context, state) => CustomTransitionPage(
        //     key: state.pageKey,
        //     child: const LoginPage(),
        //     transitionDuration: const Duration(milliseconds: 600),
        //     transitionsBuilder:
        //         (context, animation, secondaryAnimation, child) =>
        //             FadeTransition(opacity: animation, child: child),
        //   ),
        // ),
        GoRoute(path: "/main", builder: (context, state) => MainPage()),
        GoRoute(path: "/register", builder: (context, state) => RegisterPage()),
        GoRoute(
          path: "/reset-password",
          builder: (context, state) => ResetPasswordPage(),
        ),
        GoRoute(
          path: "/change-password",
          builder: (context, state) => ChangePasswordPage(),
        ),
        // GoRoute(
        //   path: "/contribute",
        //   builder: (context, state) => ContributionPage(),
        // ),
        GoRoute(
          path: "/poolDetails/:id",
          builder: (context, state) {
            final String id = state.pathParameters["id"]!;
            return PoolDetails(id: id);
          },
        ),
        GoRoute(
          path: "/contribute/:poolId",
          builder: (context, state) {
            final String poolId = state.pathParameters["poolId"]!;
            return ContributionPage(poolId: poolId);
          },
        ),
        GoRoute(path: "/kyc", builder: (context, state) => const KycPage()),
        GoRoute(
          path: "/transactions",
          builder: (context, state) => const TransactionListPage(),
        ),
        GoRoute(
          path: "/notifications",
          builder: (context, state) => const NotificationsPage(),
        ),
        GoRoute(
          path: "/transaction-list",
          builder: (context, state) => const TransactionListPage(),
        ),
        GoRoute(
          path: "/supported-pools",
          builder: (context, state) => const SupportedPoolsPage(),
        ),
        GoRoute(
          path: "/pool-details/:id",
          builder: (context, state) {
            final String id = state.pathParameters["id"]!;
            return PoolDetails(id: id);
          },
        ),
        // Note: WithdrawPoolPage est accessible via navigation directe depuis PoolDetails
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
        if (int.tryParse(id) != null) {
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
        BlocProvider(create: (_) => AuthCubit(authService, _poolService)),
        BlocProvider(create: (_) => PoolCubit(_poolService)..getAll()),
        BlocProvider(create: (_) => TransactionCubit(_transactionService)),
        BlocProvider(create: (_) => NotificationCubit(_notificationService)),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          // Redirection automatique vers login lors de la déconnexion
          if (state is Unauthenticated) {
            _router.go('/login');
          }
        },
        child: MaterialApp.router(
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(fontFamily: "Roboto"),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', 'US'), Locale('fr', 'FR')],
        ),
      ),
    );
  }
}
