import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CoinService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<int> getCurrentUserCoins() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No authenticated user');
        return 0;
      }

      print('Getting coins for user: ${user.uid}');
      
      // Find user by email like AuthService does
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email ?? '')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        final coins = userData['total_points'] ?? 0;
        print('User data found: $userData');
        print('Total points from Firestore: $coins');
        return coins;
      }
      
      print('User document does not exist');
      return 0;
    } catch (e) {
      print('Error getting user coins: $e');
      return 0;
    }
  }

  Future<void> addCoins(String userEmail, int coinsToAdd) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Find user by email first
        final querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: userEmail)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final userDoc = querySnapshot.docs.first.reference;
          final userSnapshot = await transaction.get(userDoc);
          
          if (userSnapshot.exists) {
            final currentCoins = userSnapshot.data()?['total_points'] ?? 0;
            final newTotal = currentCoins + coinsToAdd;
            
            transaction.update(userDoc, {
              'total_points': newTotal,
              'updated_at': FieldValue.serverTimestamp(),
            });
          }
        }
      });
    } catch (e) {
      print('Error adding coins: $e');
      throw Exception('Failed to add coins: $e');
    }
  }
}
