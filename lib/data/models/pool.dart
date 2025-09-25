// import 'dart:io';

// import 'package:flutter/foundation.dart';

class Pool {
  final int id;
  final String title;
  final String description;
  final int goalAmount;
  final String currency;
  final DateTime deadline;
  final String type;
  final String imageUrl;
  // final int participantLimit;
  final String status;
  final int contributionCount;
  final int progressPercentage;
  final Map<String, dynamic> owner;
  // final List<Map<String, dynamic>> recentContributions;
  // final String? shareLink;
  // final String? qrCodeUrl;
  // final bool? isApproved;

  Pool({
    // required this.recentContributions,
    required this.contributionCount,
    required this.progressPercentage,
    required this.id,
    required this.title,
    required this.description,
    required this.goalAmount,
    required this.currency,
    required this.deadline,
    required this.type,
    required this.imageUrl,
    // required this.participantLimit,
    required this.status,
    required this.owner,
    // this.shareLink,
    // this.qrCodeUrl,
    // this.isApproved,
  });
  factory Pool.fromJson(Map<String, dynamic> json) {
    return Pool(
      id: json["id"],
      title: json["title"],
      description: json["description"] ?? "",
      goalAmount: json["goalAmount"] ?? 0,
      currency: json["currency"] ?? "XOF",
      deadline: json["deadline"] == null
          ? DateTime.now()
          : DateTime.parse(json["deadline"]),
      type: json["type"] ?? "public",
      imageUrl: json["imageUrl"] ?? "",
      // participantLimit: json["participantLimit"],
      status: json["status"] ?? "active",
      contributionCount: json["contributionCount"],
      progressPercentage: json["progressPercentage"],
      owner: json["owner"],
      // recentContributions: json['recentContributions'],

      // shareLink: json["shareLink"],
      // qrCodeUrl: json["qrCodeUrl"],
      // isApproved: json["isApproved"],
    );
  }
}
