import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class FCMHandler {
  static final FCMHandler _instance = FCMHandler._internal();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory FCMHandler() {
    return _instance;
  }

  FCMHandler._internal() {
    initializeLocalNotifications();
    initializeFCM();
  }

  void initializeFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle FCM message in the foreground by showing a notification
      if (message.notification != null) {
        _handleNotification(message);
      }
      print("FCM message received in the foreground: $message");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle FCM message click in the background
      print("FCM message clicked from the background: $message");
    });

    _firebaseMessaging.requestPermission();
  }

  void initializeLocalNotifications() async {
    // Initialize settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Use your app icon here

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotificationsPlugin.initialize(initializationSettings);
  }

  void _handleNotification(RemoteMessage message) {
    String notificationType = message.data['type'] ?? 'default';
  int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    switch (notificationType) {
      case 'group':
        _showNotification(
          message.notification!.title ?? 'Group Notification',
          message.notification!.body ?? '',
          'your_channel_group',
          notificationId,
        );
        break;
      case 'private':
        _showNotification(
          message.notification!.title ?? 'Private Notification',
          message.notification!.body ?? '',
          'your_channel_private',
          notificationId,
        );
        break;
      case 'share':
        _showNotification(
          message.notification!.title ?? 'Private Notification',
          message.notification!.body ?? '',
          'your_channel_share',
          notificationId,
        );
        break;
      case 'sendFile':
        _showNotification(
          message.notification!.title ?? 'Private Notification',
          message.notification!.body ?? '',
          'your_channel_sendFile',
          notificationId,
        );
        break;
      default:
        _showNotification(
          message.notification!.title ?? 'Notification',
          message.notification!.body ?? '',
          'your_channel_default',
          notificationId,
        );
        break;
    }
  }

  Future<void> _showNotification(String title, String body, String channelId,int notificationId) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId, // channel ID
      'Your Channel Name', // channel name
      importance: Importance.high,
      priority: Priority.high,
    );

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotificationsPlugin.show(
     notificationId, // Notification ID
      title, // Notification title
      body, // Notification body
      platformChannelSpecifics,
      payload: 'Notification Payload', // Optional, can be used for further actions
    );
  }
}
