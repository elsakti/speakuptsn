import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class CoinService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Get current user's coins
  Future<int> getCurrentUserCoins() async {
    try {
      final userData = await _authService.getCurrentUserData();
      return userData?.totalPoints ?? 0;
    } catch (e) {
      return 0; // Return 0 if error or no user
    }
  }

  // Add coins to current user
  Future<void> addCoins(int amount, String reason) async {
    try {
      final userData = await _authService.getCurrentUserData();
      if (userData == null) return;

      // Find user document in Firestore
      final querySnapshot = await _firestore
          .collection('users')
          .where('id', isEqualTo: userData.id)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final currentCoins = userData.totalPoints;
        final newCoins = currentCoins + amount;

        // Update coins in Firestore
        await _firestore.collection('users').doc(userDoc.id).update({
          'total_points': newCoins,
          'updated_at': Timestamp.now(),
        });

        // TODO: Add transaction log
        await _logCoinTransaction(userData.id, amount, reason, newCoins);
      }
    } catch (e) {
      throw Exception('Failed to add coins: ${e.toString()}');
    }
  }

  // Subtract coins from current user
  Future<bool> subtractCoins(int amount, String reason) async {
    try {
      final userData = await _authService.getCurrentUserData();
      if (userData == null) return false;

      final currentCoins = userData.totalPoints;
      if (currentCoins < amount) {
        return false; // Insufficient coins
      }

      // Find user document in Firestore
      final querySnapshot = await _firestore
          .collection('users')
          .where('id', isEqualTo: userData.id)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final newCoins = currentCoins - amount;

        // Update coins in Firestore
        await _firestore.collection('users').doc(userDoc.id).update({
          'total_points': newCoins,
          'updated_at': Timestamp.now(),
        });

        // TODO: Add transaction log
        await _logCoinTransaction(userData.id, -amount, reason, newCoins);
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to subtract coins: ${e.toString()}');
    }
  }

  // Log coin transactions for audit trail
  Future<void> _logCoinTransaction(
    int userId,
    int amount,
    String reason,
    int newBalance,
  ) async {
    try {
      await _firestore.collection('coin_transactions').add({
        'user_id': userId,
        'amount': amount,
        'reason': reason,
        'new_balance': newBalance,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      // Silently fail transaction logging to not affect main operation
      print('Failed to log coin transaction: $e');
    }
  }

  // Get coin transaction history for current user
  Future<List<Map<String, dynamic>>> getCoinHistory() async {
    try {
      final userData = await _authService.getCurrentUserData();
      if (userData == null) return [];

      final querySnapshot = await _firestore
          .collection('coin_transactions')
          .where('user_id', isEqualTo: userData.id)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'amount': data['amount'] ?? 0,
          'reason': data['reason'] ?? '',
          'new_balance': data['new_balance'] ?? 0,
          'timestamp': data['timestamp'] as Timestamp?,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Reward points for different actions
  static const Map<String, int> actionRewards = {
    'report_submitted': 10,
    'report_verified': 25,
    'helpful_comment': 5,
    'daily_login': 2,
    'profile_completed': 50,
  };

  // Helper method to award coins for specific actions
  Future<void> awardCoinsForAction(String action) async {
    final points = actionRewards[action] ?? 0;
    if (points > 0) {
      await addCoins(points, 'Reward for: $action');
    }
  }
}
