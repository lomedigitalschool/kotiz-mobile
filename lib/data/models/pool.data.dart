import 'dart:io';

class PoolData {
  String? title;
  String? description;
  double? goalAmount;
  DateTime? deadline;
  String? type;
  int? participantLimit;
  String? currency;
  File? image;

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
    "goalAmount": goalAmount,
    "currency": currency,
    "deadline": deadline?.toIso8601String(),
    "type": type,
    "participantLimit": participantLimit,
  };
}
