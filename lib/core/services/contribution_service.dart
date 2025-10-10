import 'package:kotiz_app/core/netework/api_config.dart';

class ContributionService {
  final ApiConfig _app;
  ContributionService(this._app);

  Future<Map<String, dynamic>> contribute({
    required String poolId,
    required int amount,
    String? message,
    bool? isAnonymous,
  }) async {
    final response = await _app.post(
      "pulls/$poolId/contribute",
      data: {
        "amount": amount,
        "message": message ?? "",
        "isAnonymous": isAnonymous ?? false,
      },
    );
    return response;
  }
}
