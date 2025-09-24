import 'package:kotiz_app/data/models/contribution.dart';
import 'package:kotiz_app/data/models/pool.dart';

class DashboardData {
  final double totalCollected;
  final int activePullsCount;
  final int contributorsCount;
  final List<Pool> myPools;
  final List<Contribution> myContributions;
  DashboardData({
    required this.totalCollected,
    required this.activePullsCount,
    required this.contributorsCount,
    required this.myPools,
    required this.myContributions,
  });
  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalCollected: (json['totalCollected'] as num?)?.toDouble() ?? 0.0,
      activePullsCount: json['activePullsCount'] ?? 0,
      contributorsCount: json['contributorsCount'] ?? 0,
      myPools:
          (json['myPulls'] as List<dynamic>?)
              ?.map((item) => Pool.fromJson(item))
              .toList() ??
          [],
      myContributions:
          (json['myContributions'] as List<dynamic>?)
              ?.map((item) => Contribution.fromJson(item))
              .toList() ??
          [],
    );
  }
}
