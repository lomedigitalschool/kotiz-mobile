import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/core/utils/date_format.dart';
import 'package:kotiz_app/logic/pool_cubit.dart';
import 'package:kotiz_app/logic/auth_cubit.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/views/withdraw_pool_page.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';
import 'package:share_plus/share_plus.dart';

class PoolDetails extends StatefulWidget {
  const PoolDetails({super.key, required this.id});
  final String id;
  @override
  State<PoolDetails> createState() => _PoolDetailsState();
}

class _PoolDetailsState extends State<PoolDetails> {
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

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorConstant.colorGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: ColorConstant.colorGreen),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context);
        }
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
            if (state is PoolError) {
              return Center(child: Text('Erreur: ${state.message}'));
            }
            if (state is PoolDetailsLoaded) {
              final pool = state.pool;
              final DateTime now = DateTime.now();
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image avec overlay gradient
                    Stack(
                      children: [
                        SizedBox(
                          height: 250,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                            child: Image.network(
                              pool.imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return SizedBox(
                                      height: 250,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 250,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(24),
                                        bottomRight: Radius.circular(24),
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.image,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        // Gradient overlay
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.3),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Titre et badge
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  pool.title,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: ColorConstant.colorGreen,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  pool.type.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Créateur
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: ColorConstant.colorGreen,
                                  radius: 24,
                                  child: pool.owner["url"] == null
                                      ? Text(
                                          initialLetter(pool.owner["name"]),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : ClipOval(
                                          child: Image.network(
                                            "${pool.owner["url"]}",
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Créé par",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        pool.owner["name"],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Section progression
                    Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Montants
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Collecté",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "${(((pool.progressPercentage / 100) * pool.goalAmount)).ceil()} ${pool.currency}",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: ColorConstant.colorGreen,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    "Objectif",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "${pool.goalAmount} ${pool.currency}",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Barre de progression
                          LinearPercentIndicator(
                            animation: true,
                            animationDuration: 800,
                            lineHeight: 12,
                            percent: (pool.progressPercentage / 100).clamp(
                              0.0,
                              1.0,
                            ),
                            progressColor: ColorConstant.colorGreen,
                            backgroundColor: Colors.grey.shade200,
                            barRadius: const Radius.circular(6),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${pool.progressPercentage.toStringAsFixed(1)}% de l'objectif atteint",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Boutons d'action
                          BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, authState) {
                              bool isOwner = false;
                              if (authState is AuthSuccess) {
                                isOwner =
                                    authState.user.id.toString() ==
                                    pool.owner["id"].toString();
                              }

                              // Bouton contribuer toujours visible
                              List<Widget> buttons = [
                                SizedBox(
                                  width: double.infinity,
                                  child: AppButton(
                                    backgroundColor: ColorConstant.colorGreen,
                                    text: "Contribuer maintenant",
                                    onPressed: () {
                                      context.push('/contribute/${widget.id}');
                                    },
                                  ),
                                ),
                              ];

                              if (isOwner) {
                                // Boutons supplémentaires pour le propriétaire
                                buttons.addAll([
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: AppButton(
                                      backgroundColor: Colors.orange,
                                      text: "Retirer les fonds",
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                WithdrawPoolPage(pool: pool),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: AppButton(
                                      backgroundColor: ColorConstant.colorGreen,
                                      text: "Partager ma cagnotte",
                                      onPressed: () {
                                        sharePool(widget.id);
                                      },
                                    ),
                                  ),
                                ]);
                              }

                              return Column(children: buttons);
                            },
                          ),
                        ],
                      ),
                    ),

                    // Description
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Description",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ColorConstant.colorGreen,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            pool.description,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Détails
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Détails",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ColorConstant.colorGreen,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            "Contributeurs",
                            pool.contributionCount.toString(),
                            Icons.people,
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            "Total collecté",
                            "${(((pool.progressPercentage / 100) * pool.goalAmount)).ceil()} ${pool.currency}",
                            Icons.account_balance_wallet,
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            "Jours restants",
                            (now.difference(pool.deadline).inDays * -1)
                                        .toInt() <=
                                    0
                                ? "Aucune limite"
                                : "${(now.difference(pool.deadline).inDays * -1).toInt()} jours",
                            Icons.schedule,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Contributeurs
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                color: ColorConstant.colorGreen,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Contributeurs",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: ColorConstant.colorGreen,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: ColorConstant.colorGreen.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "${pool.recentContributions.length}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: ColorConstant.colorGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          pool.recentContributions.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "Aucune contribution pour le moment",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: pool.recentContributions.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final contributor =
                                        pool.recentContributions[index];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor:
                                                ColorConstant.colorGreen,
                                            radius: 20,
                                            child: Text(
                                              initialLetter(
                                                contributor["contributorName"] ??
                                                    "Anonyme",
                                              ),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
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
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: ColorConstant
                                                            .colorGreen
                                                            .withValues(
                                                              alpha: 0.1,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        "${contributor["amount"]} ${pool.currency}",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: ColorConstant
                                                              .colorGreen,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (contributor["message"] !=
                                                        null &&
                                                    contributor["message"]
                                                        .toString()
                                                        .isNotEmpty)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 4,
                                                        ),
                                                    child: Text(
                                                      contributor["message"],
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                    ),
                                                  ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 4,
                                                      ),
                                                  child: Text(
                                                    formatDate(
                                                      contributor["createdAt"]
                                                          .toString(),
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
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
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 100,
                    ), // Espace pour éviter que le contenu soit caché
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
