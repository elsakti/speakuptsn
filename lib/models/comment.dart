import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String reportId;
  final int userId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? deletedBy; // Teacher name who deleted the comment
  final bool isDeleted;
  final List<String> mentionedUsers; // User IDs mentioned with @

  Comment({
    required this.id,
    required this.reportId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.deletedBy,
    this.isDeleted = false,
    this.mentionedUsers = const [],
  });

  factory Comment.create({
    required String reportId,
    required int userId,
    required String content,
    List<String> mentionedUsers = const [],
  }) {
    final now = DateTime.now();
    return Comment(
      id: '',
      reportId: reportId,
      userId: userId,
      content: content,
      createdAt: now,
      updatedAt: now,
      mentionedUsers: mentionedUsers,
    );
  }

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Comment(
      id: doc.id,
      reportId: data['report_id'] ?? '',
      userId: data['user_id'] ?? 0,
      content: data['content'] ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      deletedBy: data['deleted_by'],
      isDeleted: data['is_deleted'] ?? false,
      mentionedUsers: List<String>.from(data['mentioned_users'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'report_id': reportId,
      'user_id': userId,
      'content': content,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'deleted_by': deletedBy,
      'is_deleted': isDeleted,
      'mentioned_users': mentionedUsers,
    };
  }

  Comment copyWith({
    String? id,
    String? reportId,
    int? userId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deletedBy,
    bool? isDeleted,
    List<String>? mentionedUsers,
  }) {
    return Comment(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      mentionedUsers: mentionedUsers ?? this.mentionedUsers,
    );
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}
