import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/logic/auth_cubit.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SupportedPoolsPage extends StatelessWidget {
  const SupportedPoolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.colorWhite,
      appBar: AppBar(
        backgroundColor: ColorConstant.colorWhite,
        title: Text(
          "Cagnottes Soutenues",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(LucideIcons.arrowLeft),
        ),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthSuccess) {
            final dashboard = state.dashboardData;
            final supportedPools =
                dashboard?.myContributions
                    .map((contribution) => contribution.pullId)
                    .toSet()
                    .toList() ??
                [];

            if (supportedPools.isEmpty) {
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
                      "Aucune cagnotte soutenue",
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

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Vous avez soutenu ${supportedPools.length} cagnotte(s)",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ColorConstant.colorGreen,
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: supportedPools.length,
                      itemBuilder: (context, index) {
                        final poolId = supportedPools[index];
                        final contributions = dashboard!.myContributions
                            .where((c) => c.pullId == poolId)
                            .toList();
                        final totalContributed = contributions.fold(
                          0.0,
                          (sum, c) => sum + c.amount,
                        );

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
                              "Cagnotte #$poolId",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${contributions.length} contribution(s)"),
                                Text(
                                  "Total: ${totalContributed.toStringAsFixed(0)} XOF",
                                  style: TextStyle(
                                    color: ColorConstant.colorGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Icon(LucideIcons.chevronRight),
                            onTap: () => context.push("/pool-details/$poolId"),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: CircularProgressIndicator(color: ColorConstant.colorGreen),
          );
        },
      ),
    );
  }
}
