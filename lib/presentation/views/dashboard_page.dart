import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/data/models/pool.dart';
import 'package:kotiz_app/data/models/profil_user.dart';
import 'package:kotiz_app/logic/auth_cubit.dart';
import 'package:kotiz_app/logic/bottom_nav_cubit.dart';
import 'package:kotiz_app/logic/notification_cubit.dart';
import 'package:kotiz_app/logic/pool_cubit.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/components/cagnotte_tiles_dashboard.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  ProfilUser? profil;

  late final GoRouter _router;
  VoidCallback? _routeListener;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authCubit = context.read<AuthCubit>();
      if (authCubit.state is AuthSuccess) {
        final poolCubit = context.read<PoolCubit>();
        if (poolCubit.state is! UserPoolsLoaded) {
          poolCubit.getAll();
        }
      }

      // Écouter les changements de route pour rafraîchir les données
      _router = GoRouter.of(context);
      _routeListener = () {
        final location = _router.routeInformationProvider.value.location;
        if (location == '/explore') {
          // Rafraîchir les données du dashboard
          if (authCubit.state is AuthSuccess) {
            context.read<PoolCubit>().getAll();
            context.read<NotificationCubit>().fetchNotifications();
            authCubit.refreshDashboard();
          }
        }
      };
      _router.routeInformationProvider.addListener(_routeListener!);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route?.isCurrent ?? false) {
      final authCubit = context.read<AuthCubit>();
      if (authCubit.state is AuthSuccess) {
        final poolCubit = context.read<PoolCubit>();
        // Toujours recharger les cagnottes utilisateur quand on revient sur le dashboard
        poolCubit.getAll();
      }
    }
  }

  @override
  void dispose() {
    if (_routeListener != null) {
      _router.routeInformationProvider.removeListener(_routeListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Charger les notifications et les cagnottes utilisateur quand l'utilisateur est connecté
        if (state is AuthSuccess) {
          context.read<NotificationCubit>().fetchNotifications();
          context.read<PoolCubit>().getAll();
          profil = state.profil;
        }
      },
      child: Scaffold(
        backgroundColor: ColorConstant.colorWhite,
        appBar: AppBar(
          backgroundColor: ColorConstant.colorWhite,
          title: Text(
            "Dashboard",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                // Forcer le rechargement des cagnottes utilisateur
                context.read<PoolCubit>().getAll();
              },
              icon: Icon(LucideIcons.refreshCw),
              tooltip: "Actualiser mes cagnottes",
            ),
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: ColorConstant.colorGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ColorConstant.colorGreen.withValues(alpha: 0.3),
                ),
              ),
              child: IconButton(
                onPressed: () {
                  if (profil?.isVerified == false) {
                    context.push("/kyc");
                  } else {
                    context.read<BottomNavCubit>().setIndex(3);
                  }
                },
                icon: profil?.isVerified == true
                    ? Icon(
                        LucideIcons.shieldCheck,
                        color: ColorConstant.colorGreen,
                      )
                    : Icon(LucideIcons.shieldQuestionMark, color: Colors.amber),
                tooltip: "🛡️ Vérifier mon identité",
              ),
            ),
            BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, notificationState) {
                final unreadCount = context
                    .read<NotificationCubit>()
                    .unreadCount;

                return Stack(
                  children: [
                    IconButton(
                      onPressed: () => context.push("/notifications"),
                      icon: Icon(LucideIcons.bell),
                      tooltip: "Notifications",
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            if (authState is AuthSuccess) {
              return BlocBuilder<PoolCubit, PoolState>(
                builder: (context, poolState) {
                  final dashboardData = authState.dashboardData;
                  final List<Pool> userPools = poolState is UserPoolsLoaded
                      ? poolState.userPools
                      : [];

                  // Utiliser les statistiques du dashboard depuis AuthCubit
                  final totalCollected = dashboardData?.totalCollected ?? 0.0;
                  final contributorsCount =
                      dashboardData?.contributorsCount ?? 0;

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Text(
                              "BIENVENU SUR VOTRE \nDASHBOARD ${(authState.profil?.name ?? authState.user.name).toUpperCase()}",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              softWrap: true,
                            ),
                          ),
                          // Statistiques en grille
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                // Première ligne - Total collecté
                                Container(
                                  height: 110,
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Color(0xffF0F2F5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      spacing: 12,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Total Collectés",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: ColorConstant.colorGreen,
                                          ),
                                        ),
                                        Text(
                                          "${totalCollected.toStringAsFixed(0)} XOF",
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12),
                                // Deuxième ligne - Contributeurs et Moyenne
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 97,
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: ColorConstant.colorBlue
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Nombres de Contributeurs",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: ColorConstant.colorBlue,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              contributorsCount.toString(),
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Container(
                                        height: 97,
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade50,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Moyenne des Dons",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.orange.shade700,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              contributorsCount > 0
                                                  ? (totalCollected /
                                                            contributorsCount)
                                                        .toStringAsFixed(0)
                                                  : "0",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                // Boutons de navigation
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppButton(
                                        text: "Mes Transactions",
                                        backgroundColor:
                                            ColorConstant.colorGreen,
                                        onPressed: () =>
                                            context.push("/transaction-list"),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: AppButton(
                                        text: "Cagnottes Soutenues",
                                        backgroundColor:
                                            ColorConstant.colorBlue,
                                        onPressed: () =>
                                            context.push("/supported-pools"),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Text(
                              "Mes cagnottes",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          userPools.isEmpty
                              ? Center(
                                  child: Text(
                                    "Vous ne possédez aucunes cagnottes pour le moment",
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: userPools.length,
                                    itemBuilder: (context, index) {
                                      final pool = userPools[index];
                                      return Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: CagnotteTilesDashboard9(
                                          title: pool.title,
                                          poolId: pool.id.toString(),
                                          image: pool.imageUrl,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            child: Center(
                              child: AppButton(
                                text: "Créer une cagnotte",
                                backgroundColor: ColorConstant.colorGreen,
                                onPressed: () =>
                                    context.read<BottomNavCubit>().setIndex(2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber),
                      Text(
                        "Vous n’êtes pas connecter",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: AppButton(
                      text: "Se connecter",
                      backgroundColor: ColorConstant.colorGreen,
                      onPressed: () => context.push("/login"),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
