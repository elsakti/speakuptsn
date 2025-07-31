import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? anonymousName;
  final Timestamp? createdAt;
  final String email;
  final String? googleId;
  final int id;
  final bool isBlocked;
  final String? password;
  final String realName;
  final int rejectedReportsCount;
  final int totalPoints;
  final Timestamp? updatedAt;
  final int userType;

  UserModel({
    this.anonymousName,
    this.createdAt,
    required this.email,
    this.googleId,
    required this.id,
    this.isBlocked = false,
    this.password,
    required this.realName,
    this.rejectedReportsCount = 0,
    this.totalPoints = 0,
    this.updatedAt,
    required this.userType,
  });

  // Factory constructor from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      anonymousName: data['anonymous_name'],
      createdAt: data['created_at'],
      email: data['email'] ?? '',
      googleId: data['google_id'],
      id: data['id'] ?? 0,
      isBlocked: data['is_blocked'] ?? false,
      password: data['password'],
      realName: data['real_name'] ?? '',
      rejectedReportsCount: data['rejected_reports_count'] ?? 0,
      totalPoints: data['total_points'] ?? 0,
      updatedAt: data['updated_at'],
      userType: data['user_type'] ?? 0,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    final now = Timestamp.now();
    return {
      'anonymous_name': anonymousName,
      'created_at': createdAt ?? now,
      'email': email,
      'google_id': googleId,
      'id': id,
      'is_blocked': isBlocked,
      'password': password,
      'real_name': realName,
      'rejected_reports_count': rejectedReportsCount,
      'total_points': totalPoints,
      'updated_at': now,
      'user_type': userType,
    };
  }

  // Generate anonymous name for students
  static String generateAnonymousName() {
    final prefixes = ['Anonim', 'Student'];
    final random = DateTime.now().millisecondsSinceEpoch;
    final prefix = prefixes[random % prefixes.length];
    final number = (random % 9999).toString().padLeft(4, '0');
    return '$prefix$number';
  }

  // User types
  static const int teacherType = 1;
  static const int studentType = 2;

  bool get isTeacher => userType == teacherType;
  bool get isStudent => userType == studentType;

  UserModel copyWith({
    String? anonymousName,
    Timestamp? createdAt,
    String? email,
    String? googleId,
    int? id,
    bool? isBlocked,
    String? password,
    String? realName,
    int? rejectedReportsCount,
    int? totalPoints,
    Timestamp? updatedAt,
    int? userType,
  }) {
    return UserModel(
      anonymousName: anonymousName ?? this.anonymousName,
      createdAt: createdAt ?? this.createdAt,
      email: email ?? this.email,
      googleId: googleId ?? this.googleId,
      id: id ?? this.id,
      isBlocked: isBlocked ?? this.isBlocked,
      password: password ?? this.password,
      realName: realName ?? this.realName,
      rejectedReportsCount: rejectedReportsCount ?? this.rejectedReportsCount,
      totalPoints: totalPoints ?? this.totalPoints,
      updatedAt: updatedAt ?? this.updatedAt,
      userType: userType ?? this.userType,
    );
  }
}
