import 'package:flutter/foundation.dart';
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
    debugPrint('DashboardData.fromJson: $json');
    try {
      return DashboardData(
        totalCollected:
            (json['total_collected'] as num?)?.toDouble() ??
            (json['totalCollected'] as num?)?.toDouble() ??
            0.0,
        activePullsCount:
            json['active_pulls_count'] ?? json['activePullsCount'] ?? 0,
        contributorsCount:
            json['contributors_count'] ?? json['contributorsCount'] ?? 0,
        myPools: _parsePoolsList(json['my_pulls'] ?? json['myPulls']),
        myContributions: _parseContributionsList(
          json['my_contributions'] ?? json['myContributions'],
        ),
      );
    } catch (e) {
      debugPrint('Erreur parsing dashboard: $e');
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
              debugPrint('Erreur parsing pool: $e');
              return null;
            }
          })
          .where((pool) => pool != null)
          .cast<Pool>()
          .toList();
    } catch (e) {
      debugPrint('Erreur parsing pools list: $e');
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
              debugPrint('Erreur parsing contribution: $e');
              return null;
            }
          })
          .where((contribution) => contribution != null)
          .cast<Contribution>()
          .toList();
    } catch (e) {
      debugPrint('Erreur parsing contributions list: $e');
      return [];
    }
  }
}
