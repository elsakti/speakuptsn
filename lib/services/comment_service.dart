import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';
import 'user_service.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  Stream<List<Comment>> getCommentsForReport(String reportId) {
    return _firestore
        .collection('comments')
        .where('report_id', isEqualTo: reportId)
        .snapshots()
        .map((snapshot) {
      var comments = snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
      comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return comments;
    });
  }

  Future<void> addComment(Comment comment) async {
    try {
      await _firestore.collection('comments').add(comment.toFirestore());
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      final teacherName = _userService.getDisplayName();
      
      await _firestore.collection('comments').doc(commentId).update({
        'is_deleted': true,
        'deleted_by': teacherName,
        'updated_at': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  List<String> extractMentions(String content) {
    final regex = RegExp(r'@(\w+)');
    final matches = regex.allMatches(content);
    return matches.map((match) => match.group(1)!).toList();
  }

  String formatContentWithMentions(String content) {
    // This can be used to highlight mentions in the UI
    return content.replaceAllMapped(
      RegExp(r'@(\w+)'),
      (match) => '@${match.group(1)}',
    );
  }
}
