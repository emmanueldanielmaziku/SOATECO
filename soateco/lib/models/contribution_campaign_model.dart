import 'package:cloud_firestore/cloud_firestore.dart';

class ContributionCampaign {
  final String id;
  final String title;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final String createdBy;
  final DateTime createdAt;
  final DateTime deadline;
  final bool isActive;

  ContributionCampaign({
    required this.id,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.createdBy,
    required this.createdAt,
    required this.deadline,
    required this.isActive,
  });

  factory ContributionCampaign.fromMap(Map<String, dynamic> map, String id) {
    return ContributionCampaign(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0).toDouble(),
      currentAmount: (map['currentAmount'] ?? 0).toDouble(),
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      deadline: (map['deadline'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'deadline': deadline,
      'isActive': isActive,
    };
  }
}
