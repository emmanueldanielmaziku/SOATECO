import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String targetGroup;
  final String authorId;
  final String authorEmail;
  final DateTime createdAt;
  final List<String> read;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.targetGroup,
    required this.authorId,
    required this.authorEmail,
    required this.createdAt,
    required this.read,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      targetGroup: map['targetGroup'] ?? 'all',
      authorId: map['authorId'] ?? '',
      authorEmail: map['authorEmail'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      read: List<String>.from(map['read'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'targetGroup': targetGroup,
      'authorId': authorId,
      'authorEmail': authorEmail,
      'createdAt': createdAt,
      'read': read,
    };
  }
}
