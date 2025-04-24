import 'package:cloud_firestore/cloud_firestore.dart';

class PollModel {
  final String id;
  final String title;
  final Map<String, int> options;
  final DateTime startDate;
  final DateTime endDate;
  final String createdBy;
  final DateTime createdAt;
  final bool active;
  final Map<String, String> userVotes;

  PollModel({
    required this.id,
    required this.title,
    required this.options,
    required this.startDate,
    required this.endDate,
    required this.createdBy,
    required this.createdAt,
    required this.active,
    required this.userVotes,
  });

  factory PollModel.fromMap(Map<String, dynamic> map, String id) {
    final optionsMap = map['options'] as Map<String, dynamic>;
    final options = optionsMap.map((key, value) => MapEntry(key, value as int));
    
    Map<String, String> userVotes = {};
    if (map['userVotes'] != null) {
      final userVotesMap = map['userVotes'] as Map<String, dynamic>;
      userVotes = userVotesMap.map((key, value) => MapEntry(key, value as String));
    }

    return PollModel(
      id: id,
      title: map['title'] ?? '',
      options: options,
      startDate: map['startDate']?.toDate() ?? DateTime.now(),
      endDate: map['endDate']?.toDate() ?? DateTime.now(),
      createdBy: map['createdBy'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      active: map['active'] ?? true,
      userVotes: userVotes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'options': options,
      'startDate': startDate,
      'endDate': endDate,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'active': active,
      'userVotes': userVotes,
    };
  }
}
