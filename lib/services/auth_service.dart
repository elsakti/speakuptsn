import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Web Client ID untuk server authentication (dari google-services.json)
  static const String _webClientId = '1098574382087-q06sgiv08vt2nf95esu2lrp73uc15p5d.apps.googleusercontent.com';

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Get current user data from Firestore
  Future<UserModel?> getCurrentUserData() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      print('Auth: Getting user data for UID: ${user.uid}');
      print('Auth: User email: ${user.email}');
      print('Auth: Provider data: ${user.providerData.map((p) => p.providerId).toList()}');
      
      // Try to find user by Google ID first
      if (user.providerData.any((info) => info.providerId == 'google.com')) {
        print('Auth: Querying by google_id: ${user.uid}');
        
        // Force refresh token before query
        await user.getIdToken(true);
        
        final querySnapshot = await _firestore
            .collection('users')
            .where('google_id', isEqualTo: user.uid)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          return UserModel.fromFirestore(querySnapshot.docs.first);
        }
      }

      // Try to find user by email
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email ?? '')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return UserModel.fromFirestore(querySnapshot.docs.first);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }

  // Sign in with real_name and password (for teachers only)
  Future<UserModel> signInWithRealNameAndPassword(
    String realName,
    String password,
  ) async {
    try {
      // First, find the user in Firestore by real_name and user_type = teacher
      final querySnapshot = await _firestore
          .collection('users')
          .where('real_name', isEqualTo: realName)
          .where('user_type', isEqualTo: UserModel.teacherType)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Invalid credentials. Only teachers can login with username and password.');
      }

      final userDoc = querySnapshot.docs.first;
      final userData = UserModel.fromFirestore(userDoc);

      if (userData.isBlocked) {
        throw Exception('Your account has been blocked. Please contact administrator.');
      }

      // Check if user has email for Firebase Auth
      if (userData.email.isNotEmpty) {
        try {
          await _auth.signInWithEmailAndPassword(
            email: userData.email,
            password: password,
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found') {
            // Create Firebase Auth user if not exists
            await _auth.createUserWithEmailAndPassword(
              email: userData.email,
              password: password,
            );
          } else {
            throw _handleAuthException(e);
          }
        }
      } else {
        // Create a temporary email for Firebase Auth
        final tempEmail = 'teacher${userData.id}@speakuptsn.local';
        try {
          await _auth.createUserWithEmailAndPassword(
            email: tempEmail,
            password: password,
          );
          
          // Update user with the temp email
          await _firestore.collection('users').doc(userDoc.id).update({
            'email': tempEmail,
            'updated_at': Timestamp.now(),
          });
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            await _auth.signInWithEmailAndPassword(
              email: tempEmail,
              password: password,
            );
          } else {
            throw _handleAuthException(e);
          }
        }
      }

      return userData;
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw _handleAuthException(e);
      }
      rethrow;
    }
  }

  // Legacy method for backward compatibility
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Platform-aware Google Sign In (for students)
  Future<UserModel> signInWithGoogle() async {
    UserCredential userCredential;
    
    if (kIsWeb) {
      userCredential = await _signInWithGoogleWeb();
    } else {
      userCredential = await _signInWithGoogleMobile();
    }

    final user = userCredential.user;
    if (user == null) {
      throw Exception('Google sign in failed: No user data received');
    }

    // Check if user already exists in Firestore
    final existingUserQuery = await _firestore
        .collection('users')
        .where('google_id', isEqualTo: user.uid)
        .limit(1)
        .get();

    UserModel userData;

    if (existingUserQuery.docs.isNotEmpty) {
      // User exists, update login time
      final userDoc = existingUserQuery.docs.first;
      userData = UserModel.fromFirestore(userDoc);
      
      if (userData.isBlocked) {
        await signOut();
        throw Exception('Your account has been blocked. Please contact administrator.');
      }

      // Update last login time
      await _firestore.collection('users').doc(userDoc.id).update({
        'updated_at': Timestamp.now(),
      });
    } else {
      // New user, create student account
      final nextId = await _getNextUserId();
      
      userData = UserModel(
        anonymousName: UserModel.generateAnonymousName(),
        email: user.email ?? '',
        googleId: user.uid,
        id: nextId,
        realName: user.displayName ?? 'Student',
        userType: UserModel.studentType,
      );

      // Save to Firestore
      await _firestore.collection('users').add(userData.toFirestore());
    }

    return userData;
  }

  // Get next available user ID
  Future<int> _getNextUserId() async {
    final querySnapshot = await _firestore
        .collection('users')
        .orderBy('id', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return 1;
    }

    final lastUser = UserModel.fromFirestore(querySnapshot.docs.first);
    return lastUser.id + 1;
  }

  // Google Sign In for web
  Future<UserCredential> _signInWithGoogleWeb() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      return await _auth.signInWithPopup(googleProvider);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  // Google Sign In for mobile
  Future<UserCredential> _signInWithGoogleMobile() async {
    try {
      // Sign out first to clear any cached credentials
      await GoogleSignIn.instance.signOut();
      
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();
      
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled by user');
      }

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      
      if (googleAuth.idToken == null) {
        throw Exception('Failed to obtain Google authentication tokens');
      }

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      if (kIsWeb) {
        await _auth.signOut();
      } else {
        await Future.wait([
          _auth.signOut(),
          GoogleSignIn.instance.signOut(),
        ]);
      }
    } catch (e) {
      print('Error during sign out: $e');
    }
  }

  // Create account with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'invalid-credential':
        return 'The provided credential is invalid.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in credentials.';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different user account.';
      default:
        return 'An error occurred: ${e.message ?? 'Unknown error'}';
    }
  }
}


