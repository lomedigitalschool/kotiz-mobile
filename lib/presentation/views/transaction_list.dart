import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/logic/transaction_cubit.dart';
import 'package:kotiz_app/logic/auth_cubit.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionCubit>().getAllTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstant.colorWhite,
        centerTitle: true,
        title: Text(
          "Mes Transactions",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(LucideIcons.arrowLeft),
        ),
      ),
      backgroundColor: ColorConstant.colorWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistiques des contributions
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                if (authState is AuthSuccess) {
                  final dashboard = authState.dashboardData;
                  final totalContributions =
                      dashboard?.myContributions.length ?? 0;
                  final totalAmount =
                      dashboard?.myContributions.fold(
                        0.0,
                        (sum, c) => sum + c.amount,
                      ) ??
                      0.0;

                  return Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorConstant.colorGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ColorConstant.colorGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Contributions",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: ColorConstant.colorGreen,
                                ),
                              ),
                              Text(
                                totalContributions.toString(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Montant Total",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: ColorConstant.colorGreen,
                                ),
                              ),
                              Text(
                                "${totalAmount.toStringAsFixed(0)} XOF",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return SizedBox();
              },
            ),
            Expanded(
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  if (authState is AuthSuccess) {
                    final contributions =
                        authState.dashboardData?.myContributions ?? [];

                    if (contributions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.heart,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Aucune contribution",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Vous n'avez encore contribué à aucune cagnotte",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: contributions.length,
                      itemBuilder: (context, index) {
                        final contribution = contributions[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: ColorConstant.colorGreen,
                              child: Icon(
                                LucideIcons.heart,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              "Contribution #${contribution.id}",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Cagnotte: ${contribution.pullId}"),
                                Text(
                                  "${contribution.amount.toStringAsFixed(0)} XOF",
                                  style: TextStyle(
                                    color: ColorConstant.colorGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (contribution.message?.isNotEmpty == true)
                                  Text(
                                    "Message: ${contribution.message}",
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.check,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                Text(
                                  "Réussi",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => context.push(
                              "/poolDetails/${contribution.pullId}",
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      color: ColorConstant.colorGreen,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
