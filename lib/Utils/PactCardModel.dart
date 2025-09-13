import 'package:myresolve/Utils/PactStatusEnum.dart';
class PactApiResponse {
  final List<PactApiModel> pacts;
  final int totalJoined;
  final int streak;

  PactApiResponse({required this.pacts, required this.totalJoined, required this.streak});

  factory PactApiResponse.fromJson(Map<String, dynamic> json) {
    return PactApiResponse(
      pacts: (json['pacts'] as List<dynamic>?)?.map((e) => PactApiModel.fromJson(e)).toList() ?? [],
      totalJoined: json['totalJoined'] ?? 0,
      streak: json['streak'] ?? 0,
    );
  }
}

class PactApiModel {
  final String id;
  final String name;
  final String description;
  final String challengeMode;
  final String verificationType;
  final int members;
  final String status;
  final int daysDone;
  final int totalDays;
  final DateTime createdAt;
  final String createdBy;
  final String groupCode;

  PactApiModel({
    required this.id,
    required this.name,
    required this.description,
    required this.challengeMode,
    required this.verificationType,
    required this.members,
    required this.status,
    required this.daysDone,
    required this.totalDays,
    required this.createdAt,
    required this.createdBy,
    required this.groupCode,
  });

  factory PactApiModel.fromJson(Map<String, dynamic> json) {
    return PactApiModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      challengeMode: json['rules']?['challengeMode'] ?? '',
      verificationType: json['verificationType'] ?? '',
      members: json['members'] ?? 0,
      status: json['status'] ?? '',
      daysDone: json['daysDone'] ?? 0,
      totalDays: json['totalDays'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      createdBy: json['createdBy'] ?? '',
      groupCode: json['groupCode'] ?? '',
    );
  }
}

class Pact {
  final String title;
  final String creator;
  final DateTime createdAt;
  final int days;
  final PactStatus status;

  const Pact({
    required this.title,
    required this.creator,
    required this.createdAt,
    required this.days,
    required this.status,
  });
}