import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/data/models/dashboard_data.dart';
import 'package:kotiz_app/data/models/pool.dart';
import 'package:kotiz_app/logic/auth_cubit.dart';
import 'package:kotiz_app/logic/bottom_nav_cubit.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/components/cagnotte_tiles_dashboard.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.colorWhite,
      appBar: AppBar(
        backgroundColor: ColorConstant.colorWhite,
        title: Text("Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(LucideIcons.bell),
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
                        "BIENVENU SUR VOTRE \nDASHBOARD ${state.user.name.toUpperCase()}",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        height: 110,
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Color(0xffF0F2F5),
                          borderRadius: BorderRadiusGeometry.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            spacing: 12,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Collecter",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: ColorConstant.colorGreen,
                                ),
                              ),
                              Text(
                                dashboard != null
                                    ? dashboard.totalCollected.toString()
                                    : "0",
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
                    ),
                    SizedBox(height: 18),
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
                    dashboard == null || dashboard.myPools.isNotEmpty
                        ? Center(
                            child: Text(
                              "Vous ne possédez aucunes cagnottes pour le moment",
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: dashboard.myPools.length,
                              itemBuilder: (context, index) {
                                final String title =
                                    dashboard.myPools[index].title;
                                final String id = dashboard.myPools[index].id
                                    .toString();
                                final String image =
                                    dashboard.myPools[index].imageUrl;
                                return Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: CagnotteTilesDashboard9(
                                    title: title,
                                    poolId: id,
                                    image: image,
                                  ),
                                );
                              },
                            ),
                          ),
                    Center(
                      child: AppButton(
                        text: "Créer une cagnotte",
                        backgroundColor: ColorConstant.colorGreen,
                        onPressed: () =>
                            context.read<BottomNavCubit>().setIndex(2),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(left: 20.0),
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
                AppButton(
                  text: "Se connecter",
                  backgroundColor: ColorConstant.colorGreen,
                  onPressed: () => context.push("/login"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
