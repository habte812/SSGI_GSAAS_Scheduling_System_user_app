import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => _auth.currentUser;

  Future<void> _updateFCMToken(String uid) async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();

      if (token != null) {
        await _firestore.collection('users').doc(uid).update({
          'fcmToken': token,
        });
        print('FCM Token updated successfully');
      } else {
        print('Failed to get FCM token');
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      
      if (user != null) {
        // Update FCM Token
        await _updateFCMToken(user.uid);

        return user;
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }
}
