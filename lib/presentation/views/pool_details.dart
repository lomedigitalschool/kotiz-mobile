import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/core/utils/date_format.dart';
import 'package:kotiz_app/logic/pool_cubit.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/views/contribution_page.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';
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

  int? toCeil({required String amount}) {
    int? ceilNumber = int.tryParse(amount);

    return ceilNumber;
  }

  String initialLetter(String name) {
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return initial;
  }

  Future<double?> showContributionBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const ContributionPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
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
            if (state is PoolError)
              return Center(child: Text('Erreur: ${state.message}'));
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                pool.title,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.green.shade200,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  width: 1,
                                  color: Colors.green.shade200,
                                ),
                              ),
                              padding: EdgeInsets.all(8),
                              child: Text(
                                pool.type,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
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
                            Expanded(
                              child: Text(
                                "Crée par ${pool.owner["name"]}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: AppButton(
                          backgroundColor: ColorConstant.colorGreen,
                          text: "Contribuer",
                          onPressed: () async {
                            await showContributionBottomSheet(context);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "${pool.goalAmount.toString()} ${pool.currency}",
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: LinearPercentIndicator(
                          animation: true,
                          animationDuration: 600,
                          lineHeight: 20,
                          percent: pool.progressPercentage / 100,
                          progressColor: ColorConstant.colorGreen,
                          backgroundColor: Colors.green.shade100,
                          barRadius: Radius.circular(8),
                          center: Text(
                            "${(pool.progressPercentage).toStringAsFixed(0)}%",
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "${(((pool.progressPercentage / 100) * pool.goalAmount)).ceil().toString()} ${pool.currency}  collecté",
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 25, right: 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 12,
                          children: [
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
                                      "Total collecter",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      "${(((pool.progressPercentage / 100) * pool.goalAmount)).ceil().toString()} ${pool.currency} ",
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
                                      (now.difference(pool.deadline).inDays *
                                                      -1)
                                                  .toInt() ==
                                              0
                                          ? "Aucune limites"
                                          : (now
                                                          .difference(
                                                            pool.deadline,
                                                          )
                                                          .inDays *
                                                      -1)
                                                  .toInt()
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
                            pool.recentContributions.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 9.0,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Aucune contribution pour le moment ",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 18.0,
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount:
                                          pool.recentContributions.length,
                                      itemBuilder: (context, index) {
                                        final contributor =
                                            pool.recentContributions[index];
                                        return Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Row(
                                            spacing: 16,
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: Colors.grey,
                                                radius: 30,
                                                child: url == null
                                                    ? Text(
                                                        initialLetter(
                                                          contributor["contributorName"] ??
                                                              "Anonyme",
                                                        ),
                                                        style: const TextStyle(
                                                          fontSize: 32,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      )
                                                    : Image.asset("$url"),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          contributor["contributorName"] ??
                                                              "Anonyme",
                                                          style: TextStyle(
                                                            color: ColorConstant
                                                                .colorBlue,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),

                                                        Text(
                                                          contributor["amount"] +
                                                                  " ${pool.currency}" ??
                                                              "*****",
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      contributor["message"] ??
                                                          "",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),

                                                    Text(
                                                      formatDate(
                                                        contributor["createdAt"]
                                                            .toString(),
                                                      ),
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
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
      ),
    );
  }
}
