import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/logic/pool_cubit.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:share_plus/share_plus.dart';

class PoolDetails extends StatefulWidget {
  const PoolDetails({super.key, required this.id});
  final String id;
  @override
  State<PoolDetails> createState() => _PoolDetailsState();
}

class _PoolDetailsState extends State<PoolDetails> {
  final String? url = null;

  @override
  void initState() {
    super.initState();
    context.read<PoolCubit>().getPoolDetails(widget.id);
  }

  void sharePool(String poolId) {
    final url = 'https://kotiz.app/pool/$poolId';
    Share.share("Rejoins ma cagnotte $url");
  }

  String initialLetter(String name) {
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return initial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstant.colorWhite,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              sharePool(widget.id);
            },
            icon: Icon(Icons.share, size: 32),
          ),
        ],
        title: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Image.asset("assets/images/Logo-Text.png", width: 100),
        ),
      ),
      backgroundColor: ColorConstant.colorWhite,
      body: BlocBuilder<PoolCubit, PoolState>(
        builder: (context, state) {
          if (state is PoolLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PoolError) return Text('Erreur: ${state.message}');
          if (state is PoolDetailsLoaded) {
            final pool = state.pool;
            final DateTime now = DateTime.now();
            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 15,

                  children: [
                    Image.network(
                      pool.imageUrl,

                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Container(
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/Logo.png',

                        fit: BoxFit.fill,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        pool.title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        spacing: 16,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 36,
                            child: pool.owner["url"] == null
                                ? Text(
                                    initialLetter(pool.owner["name"]),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Image.network("${pool.owner["url"]}"),
                          ),
                          Text(
                            "Crée par ${pool.owner["name"]}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: AppButton(
                        backgroundColor: ColorConstant.colorGreen,
                        text: "Contribuer",
                        onPressed: () {
                          context.push('/contribute');
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            pool.goalAmount.toString(),
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 07,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(12),
                          child: LinearProgressIndicator(
                            value: pool.progressPercentage.toDouble(),
                            color: ColorConstant.colorGreen,
                            backgroundColor: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          Text("12 contributeurs"),
                          Text(
                            "Description",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: ColorConstant.colorGreen,
                            ),
                          ),

                          Text(
                            pool.description,
                            softWrap: true,
                            maxLines: 4,
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "Details",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: ColorConstant.colorGreen,
                            ),
                          ),
                          Column(
                            spacing: 45,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Contributeurs",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "12",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total collecter",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    pool.contributionCount.toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Jours restants ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    now
                                        .difference(pool.deadline)
                                        .inDays
                                        .toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 41),

                          Text(
                            "Contributeurs",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: ColorConstant.colorGreen,
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  spacing: 16,
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      child: url == null
                                          ? Text(
                                              initialLetter("Zaibre"),
                                              style: const TextStyle(
                                                fontSize: 32,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : Image.asset("$url"),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Crée par Zaibre ",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text('July 15,2021'),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
