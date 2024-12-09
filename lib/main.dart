import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ssgi/welcomepages/welcome_pages.dart';
import 'package:ssgi/Service/push_notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Added for FCM

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only once, based on platform
  if (Firebase.apps.isEmpty) {
    if (Platform.isAndroid) {
      // Firebase initialization for Android
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyAxSuzukn4w0L3-JJFuoLZi4OclreMHB3Q',
          appId: '1:592811644074:android:43a3a8334718133c4dacd3',
          messagingSenderId: '592811644074',
          storageBucket: "ssgi11.appspot.com",
          projectId: 'ssgi11',
        ),
      );
    } else if (Platform.isIOS) {
      // Firebase initialization for iOS
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyAxSuzukn4w0L3-JJFuoLZi4OclreMHB3Q',
          appId: '1:592811644074:ios:e333ca370b9e97854dacd3', 
          messagingSenderId: '592811644074',
          storageBucket: "ssgi11.appspot.com",
          projectId: 'ssgi11',
        ),
      );
    } else {
      // Default initialization for other platforms
      await Firebase.initializeApp();
    }
  }

  // Initialize Push Notifications (FCM)
  FCMHandler fcmHandler = FCMHandler();
  fcmHandler.initializeFCM();

  // Initialize background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const App());
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateOnlineStatus(true); // Set online when the app is opened
    _requestNotificationPermissions(); // Request notification permissions
    _setupFCM(); // Setup FCM token handling
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _updateOnlineStatus(false); // Set offline when the app is backgrounded or closed
    }
  }

  Future<void> _requestNotificationPermissions() async {
    // Request permission for iOS
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );
    }
  }

  Future<void> _setupFCM() async {
    // Get the FCM token
    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $token");
    // Optionally, send the token to your server or store it in Firestore
    await _saveFCMTokenToFirestore(token);
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received a foreground message: ${message.notification?.title}");
      // Show a dialog or a snackbar with the message
    });
  }

  Future<void> _saveFCMTokenToFirestore(String? token) async {
    User? user = _auth.currentUser;
    if (user != null && token != null) {
      String collection = await _isAdmin(user.uid) ? 'admins' : 'users';
      try {
        await _firestore.collection(collection).doc(user.uid).update({
          'fcmToken': token,
        });
      } catch (e) {
        print("Error saving FCM token: $e");
      }
    }
  }

  Future<void> _updateOnlineStatus(bool isOnline) async {
    User? user = _auth.currentUser;
    if (user != null) {
      String collection = await _isAdmin(user.uid) ? 'admins' : 'users';
      try {
        await _firestore.collection(collection).doc(user.uid).update({
          'isOnline': isOnline,
          'lastSeen': isOnline ? null : FieldValue.serverTimestamp(), // Update lastSeen if offline
        });
      } catch (e) {
        print("Error updating online status: $e");
      }
    }
  }

  Future<bool> _isAdmin(String uid) async {
    // Check if the user is an admin
    DocumentSnapshot adminSnapshot = await _firestore.collection('admins').doc(uid).get();
    return adminSnapshot.exists;
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Welcomepage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
