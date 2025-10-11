import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/data/models/pool.dart';
import 'package:kotiz_app/logic/auth_cubit.dart';
import 'package:kotiz_app/logic/bottom_nav_cubit.dart';
import 'package:kotiz_app/logic/pool_cubit.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/components/build_pool_loading_shimmer.dart';
import 'package:kotiz_app/presentation/components/cagnotte_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  // late final GoRouter _router;
  // VoidCallback? _routeListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final poolCubit = context.read<PoolCubit>();
      // final authCubit = context.read<AuthCubit>();

      // Page d'accueil : charger toutes les cagnottes publiques pour tous les utilisateurs
      if (poolCubit.state is! AllPoolsLoaded) {
        poolCubit
            .getAllPools(); // ✅ Page d'accueil = toutes les cagnottes publiques
      }

      // Écouter les changements de route pour rafraîchir les données
      // _router = GoRouter.of(context);
      // _routeListener = () {
      //   final location = _router.routeInformationProvider.value.location;
      //   if (location == '/home') {
      //     // Rafraîchir les cagnottes publiques
      //     poolCubit.getAllPools();
      //     // Si utilisateur connecté, rafraîchir aussi ses cagnottes et le dashboard
      //     if (authCubit.state is AuthSuccess) {
      //       poolCubit.getAll();
      //       authCubit.refreshDashboard();
      //     }
      //   }
      // };
      // _router.routeInformationProvider.addListener(_routeListener!);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route?.isCurrent ?? false) {
      final poolCubit = context.read<PoolCubit>();
      // final authCubit = context.read<AuthCubit>();
      final currentState = poolCubit.state;

      // Page d'accueil : s'assurer qu'on a toutes les cagnottes publiques
      if (currentState is! AllPoolsLoaded) {
        poolCubit.getAllPools();
      }
    }
  }

  @override
  void dispose() {
    // if (_routeListener != null) {
    //   _router.routeInformationProvider.removeListener(_routeListener!);
    // }
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, authState) {
        final poolCubit = context.read<PoolCubit>();
        // Page d'accueil : toujours charger toutes les cagnottes publiques
        if (poolCubit.state is! AllPoolsLoaded) {
          poolCubit.getAllPools();
        }
      },
      child: RefreshIndicator(
        onRefresh: () {
          return context.read<PoolCubit>().getAllPools();
        },
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
                  if (state is AuthSuccess) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        onPressed: () => context.push('/profil'),
                        child: Text(
                          state.profil?.name ?? state.user.name,
                          style: TextStyle(
                            color: ColorConstant.colorBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  } else {
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
                  }
                },
              ),
            ],
          ),
          backgroundColor: ColorConstant.colorWhite,
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Rechercher une cagnotte…',
                          prefixIcon: Icon(
                            Icons.search,
                            color: ColorConstant.colorBlue,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, top: 20),
                      child: Text(
                        "Récentes cagnottes",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),

                    BlocBuilder<PoolCubit, PoolState>(
                      builder: (context, state) {
                        debugPrint(
                          '🏠 HomePage - État PoolCubit: ${state.runtimeType}',
                        );

                        if (state is PoolLoading) {
                          debugPrint('🏠 HomePage - Chargement en cours...');
                          return buildPoolLoadingShimmer();
                        }

                        if ((state is AllPoolsLoaded &&
                                state.allPools.isNotEmpty) ||
                            (state is UserPoolsLoaded &&
                                state.userPools.isNotEmpty)) {
                          final pools = state is AllPoolsLoaded
                              ? state.allPools
                              : (state as UserPoolsLoaded).userPools;
                          debugPrint(
                            '🏠 HomePage - ${pools.length} cagnottes chargées',
                          );
                          final filteredPools = _searchQuery.isEmpty
                              ? pools
                              : pools
                                    .where(
                                      (p) => p.title.toLowerCase().contains(
                                        _searchQuery,
                                      ),
                                    )
                                    .toList();

                          final List<Pool> firstRow = filteredPools.length > 4
                              ? filteredPools.sublist(
                                  0,
                                  (filteredPools.length / 2).toInt(),
                                )
                              : filteredPools;
                          final List<Pool> secondRow = filteredPools.length > 4
                              ? filteredPools.sublist(
                                  (filteredPools.length / 2).toInt(),
                                )
                              : [];
                          return Column(
                            children: [
                              SizedBox(
                                height: 250,
                                child: ListView.builder(
                                  itemCount: firstRow.length,
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    final Pool pool = firstRow[index];
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
                                            amount: pool.currentAmount
                                                .toInt()
                                                .toString(),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 10),
                              SizedBox(
                                height: 250,
                                child: ListView.builder(
                                  itemCount: secondRow.length,
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    final Pool pool = secondRow[index];
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
                                            amount: pool.currentAmount
                                                .toInt()
                                                .toString(),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }
                        if ((state is AllPoolsLoaded &&
                                state.allPools.isEmpty) ||
                            (state is UserPoolsLoaded &&
                                state.userPools.isEmpty)) {
                          return SizedBox(
                            height: 500,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Aucune cagnottes disponibles  pour le moment ",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 22),
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ),
                          );
                        }
                        if (state is PoolError) {
                          return SizedBox(
                            height: 500,
                            child: Center(
                              child: Column(
                                children: [
                                  Text(
                                    state.message,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 22),
                                  ),
                                  SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () =>
                                        context.read<PoolCubit>().getAllPools(),
                                    child: Text(
                                      "Ressayer",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: ColorConstant.colorBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                                BlocBuilder<AuthCubit, AuthState>(
                                  builder: (context, authState) {
                                    if (authState is AuthSuccess) {
                                      return Column(
                                        children: [
                                          AppButton(
                                            text: "Créer une cagnotte",
                                            onPressed: () {
                                              context.push('/create');
                                            },
                                            backgroundColor:
                                                ColorConstant.colorGreen,
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Column(
                                        children: [
                                          AppButton(
                                            text: "Créer une cagnotte",
                                            onPressed: () {
                                              context.push('/register');
                                            },
                                            backgroundColor:
                                                ColorConstant.colorGreen,
                                          ),
                                          const SizedBox(height: 12),
                                          AppButton(
                                            text: "Se connecter",
                                            onPressed: () {
                                              context.push("/login");
                                            },
                                          ),
                                        ],
                                      );
                                    }
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
        ),
      ),
    );
  }
}
