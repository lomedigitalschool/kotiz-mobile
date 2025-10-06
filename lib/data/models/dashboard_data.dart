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
    try {
      return DashboardData(
        totalCollected: (json['totalCollected'] as num?)?.toDouble() ?? 0.0,
        activePullsCount: json['activePullsCount'] ?? 0,
        contributorsCount: json['contributorsCount'] ?? 0,
        myPools: _parsePoolsList(json['myPulls']),
        myContributions: _parseContributionsList(json['myContributions']),
      );
    } catch (e) {
      print('Erreur parsing dashboard: $e');
      return DashboardData(
        totalCollected: 0.0,
        activePullsCount: 0,
        contributorsCount: 0,
        myPools: [],
        myContributions: [],
      );
    }
  }

  static List<Pool> _parsePoolsList(dynamic data) {
    try {
      if (data == null) return [];
      if (data is! List) return [];
      return data
          .where((item) => item != null)
          .map((item) {
            try {
              return Pool.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              print('Erreur parsing pool: $e');
              return null;
            }
          })
          .where((pool) => pool != null)
          .cast<Pool>()
          .toList();
    } catch (e) {
      print('Erreur parsing pools list: $e');
      return [];
    }
  }

  static List<Contribution> _parseContributionsList(dynamic data) {
    try {
      if (data == null) return [];
      if (data is! List) return [];
      return data
          .where((item) => item != null)
          .map((item) {
            try {
              return Contribution.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              print('Erreur parsing contribution: $e');
              return null;
            }
          })
          .where((contribution) => contribution != null)
          .cast<Contribution>()
          .toList();
    } catch (e) {
      print('Erreur parsing contributions list: $e');
      return [];
    }
  }
}
