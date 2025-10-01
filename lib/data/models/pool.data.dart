import 'dart:io';

class PoolData {
  String? title;
  String? description;
  double? goalAmount;
  String? deadline;
  String? type;
  int? participantLimit;
  String? currency;
  File? image;

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
    "goalAmount": goalAmount,
    "currency": currency,
    "deadline": deadline,
    "type": type,
    "participantLimit": participantLimit,
  };
}
