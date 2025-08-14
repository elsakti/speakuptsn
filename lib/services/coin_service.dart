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
        return 100;
      }

      print('Getting coins for user: ${user.uid}');
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data()!;
        final coins = userData['total_points'] ?? 0;
        print('User data: $userData');
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
}
