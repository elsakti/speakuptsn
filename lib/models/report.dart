import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String id;
  final DateTime createdAt;
  final String description;
  final String photoPath;
  final int reportId;
  final int reporterId;
  final String status;
  final String title;
  final DateTime updatedAt;
  final String verificationNotes;
  final DateTime? verifiedAt;
  final int verifiedByTeacherId;

  Report({
    required this.id,
    required this.createdAt,
    required this.description,
    required this.photoPath,
    required this.reportId,
    required this.reporterId,
    required this.status,
    required this.title,
    required this.updatedAt,
    required this.verificationNotes,
    this.verifiedAt,
    required this.verifiedByTeacherId,
  });

  // Factory constructor for creating new reports
  factory Report.create({
    required String title,
    required String description,
    required int reporterId,
    String photoPath = '',
    int reportId = 0,
  }) {
    final now = DateTime.now();
    return Report(
      id: '', // Will be set by Firestore
      createdAt: now,
      description: description,
      photoPath: photoPath,
      reportId: reportId,
      reporterId: reporterId,
      status: 'pending',
      title: title,
      updatedAt: now,
      verificationNotes: '',
      verifiedAt: null,
      verifiedByTeacherId: 0,
    );
  }

  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Report(
      id: doc.id,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      description: data['description'] ?? '',
      photoPath: data['photo_path'] ?? '',
      reportId: data['report_id'] ?? 0,
      reporterId: data['reporter_id'] ?? 0,
      status: data['status'] ?? '',
      title: data['title'] ?? '',
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      verificationNotes: data['verification_notes'] ?? '',
      verifiedAt: data['verified_at'] != null
          ? (data['verified_at'] as Timestamp).toDate()
          : null,
      verifiedByTeacherId: data['verified_by_teacher_id'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'created_at': Timestamp.fromDate(createdAt),
      'description': description,
      'photo_path': photoPath,
      'report_id': reportId,
      'reporter_id': reporterId,
      'status': status,
      'title': title,
      'updated_at': Timestamp.fromDate(updatedAt),
      'verification_notes': verificationNotes,
      'verified_at': verifiedAt != null
          ? Timestamp.fromDate(verifiedAt!)
          : null,
      'verified_by_teacher_id': verifiedByTeacherId,
    };
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
