import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/data/models/pool.dart';
import 'package:kotiz_app/data/models/user.dart';
import 'package:kotiz_app/logic/auth_cubit.dart';
import 'package:kotiz_app/logic/bottom_nav_cubit.dart';
import 'package:kotiz_app/logic/pool_cubit.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/components/cagnotte_tile.dart';
import 'package:kotiz_app/presentation/views/create_page.dart';
import 'package:kotiz_app/presentation/views/dashboard_page.dart';
import 'package:kotiz_app/presentation/views/profil_page.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> pages = const [
    DashboardPage(),
    CreatePage(),
    ProfilPage(),
  ];

  @override
  void initState() {
    super.initState();

    context.read<AuthCubit>().checkAuthStatus();
    context.read<PoolCubit>().getAll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
    if (isCurrent) {
      context.read<PoolCubit>().getAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<PoolCubit>().getAll(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: ColorConstant.colorWhite,
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Image.asset("assets/images/Logo-Text.png", width: 100),
          ),
          actions: [
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  return Text(
                    " Bienvenue,${state.user.name}",
                    style: TextStyle(
                      color: ColorConstant.colorBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                return TextButton(
                  onPressed: () => context.push("/login"),
                  child: Text(
                    "Se connecter",
                    style: TextStyle(
                      color: ColorConstant.colorBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: ColorConstant.colorWhite,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30, top: 64),
                  child: Text(
                    "Récentes cagnottes",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 12),

                BlocBuilder<PoolCubit, PoolState>(
                  builder: (context, state) {
                    if (state is PoolLoading) {
                      return Container(
                        height: 550,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: ColorConstant.colorGreen,
                          ),
                        ),
                      );
                    }

                    if (state is PoolLoaded) {
                      return SizedBox(
                        height: 550,
                        child: ListView.builder(
                          itemCount: state.pools.length,
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final Pool pool = state.pools[index];
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8.0,
                                    right: 8,
                                  ),
                                  child: CagnotteTile(
                                    poolId: pool.id.toString(),
                                    image: pool.imageUrl,
                                    title: pool.title,
                                    currency: pool.currency,
                                    amount: pool.goalAmount.toString(),
                                  ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.only(left: 8.0),
                                //   child: CagnotteTile(
                                //     image: "assets/images/Logo-Text.png",
                                //     title: "Fluffy's Vet Bills",
                                //     currency: r'$',
                                //     amount: "200",
                                //   ),
                                // ),
                              ],
                            );
                          },
                        ),
                      );
                    }
                    if (state is PoolError) {
                      return Container(
                        child: Center(child: Text(state.message)),
                      );
                    }
                    return SizedBox();
                  },
                ),
                // SizedBox(height: 189),
                Padding(
                  padding: const EdgeInsets.all(32),

                  child: Column(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            AppButton(
                              text: "Créer une cagnotte",
                              onPressed: () {
                                context.read<BottomNavCubit>().setIndex(2);
                              },
                              backgroundColor: ColorConstant.colorGreen,
                            ),
                            SizedBox(height: 12),
                            AppButton(
                              text: "Créer un compte",
                              onPressed: () {
                                context.push("/register");
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 72),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
