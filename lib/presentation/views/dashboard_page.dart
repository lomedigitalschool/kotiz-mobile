import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/data/models/dashboard_data.dart';
import 'package:kotiz_app/logic/auth_cubit.dart';
import 'package:kotiz_app/logic/bottom_nav_cubit.dart';
import 'package:kotiz_app/logic/notification_cubit.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/components/cagnotte_tiles_dashboard.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Charger les notifications quand l'utilisateur est connecté
        if (state is AuthSuccess) {
          context.read<NotificationCubit>().fetchNotifications();
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
              onPressed: () => context.read<AuthCubit>().refreshDashboard(),
              icon: Icon(LucideIcons.refreshCw),
              tooltip: "Actualiser",
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
                onPressed: () => context.push("/kyc"),
                icon: Icon(
                  LucideIcons.shieldCheck,
                  color: ColorConstant.colorGreen,
                ),
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
          builder: (context, state) {
            if (state is AuthSuccess) {
              final DashboardData? dashboard = state.dashboardData;

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
                          "BIENVENU SUR VOTRE \nDASHBOARD ${(state.profil?.name ?? state.user.name).toUpperCase()}",
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Total Collecté",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: ColorConstant.colorGreen,
                                      ),
                                    ),
                                    Text(
                                      dashboard != null
                                          ? "${dashboard.totalCollected.toStringAsFixed(0)} XOF"
                                          : "0 XOF",
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
                                    height: 90,
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: ColorConstant.colorBlue.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Contributeurs",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: ColorConstant.colorBlue,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          dashboard?.contributorsCount
                                                  .toString() ??
                                              "0",
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
                                    height: 90,
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Moy. Don",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.orange.shade700,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          dashboard != null &&
                                                  dashboard.contributorsCount >
                                                      0
                                              ? (dashboard.totalCollected /
                                                        dashboard
                                                            .contributorsCount)
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
                                    text: "Mes Participations",
                                    backgroundColor: ColorConstant.colorGreen,
                                    onPressed: () =>
                                        context.push("/transaction-list"),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: AppButton(
                                    text: "Cagnottes Soutenues",
                                    backgroundColor: ColorConstant.colorBlue,
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
                      dashboard?.myPools == null || dashboard!.myPools.isEmpty
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
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: dashboard.myPools.length,
                                itemBuilder: (context, index) {
                                  final pool = dashboard.myPools[index];
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
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
