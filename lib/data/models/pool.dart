import 'dart:io';

import 'package:flutter/foundation.dart';

class Pool {
  final int id;
  final String title;
  final String description;
  final String goalAmount;
  final String currency;
  final DateTime deadline;
  final String type;
  final String imageUrl;
  final int participantLimit;
  final String status;
  final String shareLink;
  final String qrCodeUrl;
  final bool isApproved;

  Pool({
    required this.id,
    required this.title,
    required this.description,
    required this.goalAmount,
    required this.currency,
    required this.deadline,
    required this.type,
    required this.imageUrl,
    required this.participantLimit,
    required this.status,
    required this.shareLink,
    required this.qrCodeUrl,
    required this.isApproved,
  });

  factory Pool.fromJson(Map<String, dynamic> json) {
    return Pool(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      goalAmount: json["goalAmount"],
      currency: json["currency"],
      deadline: json["deadline"],
      type: json["type"],
      imageUrl: json["imageUrl"],
      participantLimit: json["participantLimit"],
      status: json["status"],
      shareLink: json["shareLink"],
      qrCodeUrl: json["qrCodeUrl"],
      isApproved: json["isApproved"],
    );
  }
}
