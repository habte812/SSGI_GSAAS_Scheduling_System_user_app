import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:ssgi/homePage/home_page.dart';
import 'package:ssgi/homePage/notificationPage/data_table.dart';
import 'package:ssgi/reusableWidgets/reusable_widget.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late String userUID = '';
  List<DocumentSnapshot> notifications = [];
  DocumentSnapshot? _selectedNotification;

  @override
  void initState() {
    super.initState();
    _fetchUserUID();
  }

  String _formatDateTime(String timestamp) {
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      // Convert to local time and format
      return dateTime.toLocal().toString();
    } catch (e) {
      // Handle parsing error
      return 'Invalid date';
    }
  }

  Future<void> _fetchUserUID() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userUID = user.uid;
      });
      _fetchNotifications();
    } else {
      print("No user logged in");
    }
  }

  Future<void> _fetchNotifications() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('UserDataHistory')
          .doc(userUID)
          .collection('files')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        notifications = snapshot.docs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error fetching notifications: $e",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _moveToPastTasks(DocumentSnapshot notification) async {
    try {
      // Add the notification to the "PastTasks" collection
      await FirebaseFirestore.instance
          .collection('PastTasks')
          .doc(userUID)
          .collection('files')
          .doc(notification.id)
          .set(notification.data() as Map<String, dynamic>);

      // Remove the notification from the "UserDataHistory" collection
      await FirebaseFirestore.instance
          .collection('UserDataHistory')
          .doc(userUID)
          .collection('files')
          .doc(notification.id)
          .delete();

      // Remove the notification from the local list
      setState(() {
        notifications.remove(notification);
        _selectedNotification = null;
      });
    } catch (e) {
      print("Error moving notification: $e");
    }
  }

  Future<String?> _fetchCurrentUserName() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid) // Use the current user's UID
            .get();

        if (doc.exists) {
          return doc['name'] as String; // Return the user's name
        }
      }
    } catch (e) {
      print("Error fetching current user name: $e");
    }
    return null; // Return null if there was an error or user not found
  }

  Future<void> _fetchUserNames() async {
    String? senderName = await _fetchCurrentUserName(); // Get the sender's name

    if (senderName != null) {
      try {
        QuerySnapshot snapshot =
            await FirebaseFirestore.instance.collection('users').get();

        // Filter out the sender's name from the list of user names
        List<String> userNames = snapshot.docs
            .map((doc) => doc['name'] as String)
            .where((name) => name != senderName) // Exclude the sender
            .toList();

        _showUserNamesDialog(userNames, senderName);
      } catch (e) {
        print("Error fetching user names: $e");
      }
    } else {
      print("Current user not found.");
    }
  }

  void _showUserNamesDialog(List<String> userNames, String senderName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Select User to Share',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: userNames.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.black,
                  child: ListTile(
                    title: Text(
                      userNames[index],
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      // Share the selected task with the chosen user
                      _shareTaskWithUser(userNames[index], senderName);
                      // After sharing, move the task to PastTasks
                      // _moveToPastTasks(_selectedNotification!);
                      // Close the dialog after the selection

                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const HomePage()));
                      // Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _shareTaskWithUser(String userName, String senderName) async {
    try {
      // Ensure a task is selected
      if (_selectedNotification == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No task selected'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Fetch the user UID based on the user name
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: userName)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        String userUID = userSnapshot.docs.first.id;

        // Add the selected task to the SharedDataUsers collection under the user's UID
        await FirebaseFirestore.instance
            .collection('SharedDataUsers')
            .doc(userUID)
            .collection('tasks')
            .doc(_selectedNotification!.id) // Using task ID as the document ID
            .set({
          ..._selectedNotification!.data()
              as Map<String, dynamic>, // Copy task data
          'sharedWithUID': userUID, // Add the receiver's UID
          'sharedWithName': userName, // Add the receiver's name
          'sharedAt': Timestamp.now(), // Timestamp for when the task was shared
        });
              

        // After sharing, move the task to PastTasks
        await _moveToPastTasks(_selectedNotification!);
        await _sendNotificationToUser(userUID, userName, senderName);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Task shared with $userName and moved to Past Tasks',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Optionally, navigate back to home page
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        // Handle the case where the user is not found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User not found: $userName',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      print("Error sharing task: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error sharing task: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  final _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  Future<void> _sendNotificationToUser(String userId, String userName, String senderName ) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String? fcmToken = userData['fcmToken'];

// Access fcmToken safely
        if (fcmToken != null) {
          await _sendNotification(
              fcmToken, "You Got Help Task From $senderName", userName,"share");
        }
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }


Future<void> _sendNotification(
    String fcmToken, String message, String userName, String type) async {
  final accountCredentials = ServiceAccountCredentials.fromJson(r'''
      {
  "type": "service_account",
  "project_id": "ssgi11",
  "private_key_id": "06614e530931afb8b39715a5bfad05556ca9f669",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCnFFwbgrPQx/ZA\nqcVeZJ/3/LLJ9IdkcasRrYPl7Tf8xasVs9a++AjT86uduz7fgFUkmCjQIkCQBO+4\nGjvXAzP3LgYEIsYHjAMKhmojRWVfQ5CaH9Jsas+e9pFfgsT1frzbe8I878NFJU6k\nLfnD0zEHUlu4pC8aF45PyWi0fnYeTPNKzh1aTNr5bb0PrOeazm5ePZNFeTt9ckaj\n0OgPdnRDX1V5P7TDsdjuKQVhn19zQE4R5yALXRnKytQBBwtJS4myBYAs0TqgARie\n3Zhh7afNjYnnZMfA113OsurYtyd4o/nmRpATiSzFawuw6Qr+ErFMwhMov/IrXd1d\nZhcvARgHAgMBAAECggEABN/bMBJIHLc4v/oz/+T/pcSBktLHgG6whvuA9ZxOHdnG\nfAObKEckOsrJHvjvhKXB1id6SVg2ef0q4TwissstIPD+y/AXxvCWxh/VyOGla3oV\nJen3waH8HK8k3px6Eo94Aw9BQ3XbRJEqEjAlMUlgDM6iTmi71w8I39sIavulhoy8\nFrMNfVWkwJ14spM0fppfpbdb+iVy0zHHW1RSO9IYn6AW/6rhZllSVkUxoFK/lnne\naPNgMrT35HfoIaakSFx18f+i7tSVVvLLIZ7YViwSDjMN76HPT2IYDBPkAGFtUIrW\nX+Wo6CAghWF5rzwLIE9+wOiNFX2td9Azzsy9GX/OwQKBgQDaGKt5vVAukRHOm3la\nrXCCZGQCMYl8kPTerT2j28V6OnPZmilZS6cCuTF+5g4FkJz9tUVMfGrY7Rusc4ZX\nbUEaPbLRs1MS97kiSGsC8a8hZNIgwkNjZyCpf6UHJuRGorI9GHijyR0libZM//zd\nMLD1f/B52irks6ysAAYrYevJZQKBgQDEHeYYUIRtcbOWnXPxXw7kd04X1rD0ZOk/\npb+CTvYBTWBr1kRF4bhEloCkzoe5DUnBhirG9id2OuY8xEtsOjNdc5NcM+8i5mOI\nfdCUxEX+EluGxuexT+KyaU4liGTcSZse+1KireYM7CzWKTF8e5/8A4oaGsxa7MHY\nmDayMi76+wKBgBl9wK0d/30x347yhSCgHQJgkX/gIl2446YTQZ0hVteOdXP9nM+f\nFAoxcyON6B2mZXMR+OOTtzlbnVxutEkLsAxNIdV4zEDvS2hCZp+VeA7DJfxGOHIp\n35twG+3WEeBfq82QSql6HDoC+pfNY9TGmChZp9XWNiU9CvWfmxj+/PwxAoGBALi/\nmcUKBNa9J/sY9OJLNFJRecXHQAfbEEgfMlvlWqY7aDvuK37Rdq9WQHYBAaZ4OCUQ\n6TdpKB+euMpB+PNJmJ3OhOF1Iy/zbYxlSZr7kxwX2xUKR7Wnld2QikedR7aluHXl\nOCF8RJ2j11EgmTe1li7ofq681ApLwwjxy4Tu9YcFAoGASYLAMCsA6vtYwu+6LZuI\nF+FtrSx2EaNa0ybuUt4ys2QwtzQ7BdoTDwRdYtIrJNGgupvqkkJN+1w0uVkKmK2Y\nAGT9p6UIAsPj3iLHujEwhyqt3x4SHw6ElhL564BdYsEKzKEhwbsFY9qPOKEMNgGX\nYDiQde96hcg46F9OOdJoQ78=\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-54m7g@ssgi11.iam.gserviceaccount.com",
  "client_id": "103699599047455721111",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-54m7g%40ssgi11.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
  ''');

  final authClient = await clientViaServiceAccount(accountCredentials, _scopes);

  const url = 'https://fcm.googleapis.com/v1/projects/ssgi11/messages:send';
  final response = await authClient.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'message': {
        'token': fcmToken,
        'notification': {
          'title': 'Hello, $userName',
          'body': message,
        },
        'data': {
          'type': type, // Add the type to the data payload
        },
        'android': {
          'priority': 'high',
          'notification': {
            'channel_id': _getChannelId(type), // Use a function to get the channel ID
          },
        },
        'apns': {
          'headers': {
            'apns-priority': '10',
          },
        },
      },
    }),
  );

  if (response.statusCode == 200) {
    print('Notification sent successfully');
  } else {
    print('Failed to send notification: ${response.body}');
  }
}

String _getChannelId(String type) {
  switch (type) {
    case 'group':
      return 'your_channel_group';
    case 'private':
      return 'your_channel_private';
    case 'share':
      return 'your_channel_share';
    case 'sendFile':
      return 'your_channel_sendFile';
    default:
      return 'your_channel_default';
  }
}

  @override
  Widget build(BuildContext context) {
    if (userUID.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: appBar(
        'Tasks',
        IconButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const HomePage()));
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('No tasks available.'))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                var notification = notifications[index];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedNotification = notification;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Task ${index + 1} \n Arrive at: ${_formatDateTime(notification['timestamp'])}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: _selectedNotification == null
          ? null
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed:
                      _fetchUserNames,
                  backgroundColor: Colors.blue,
                  tooltip: 'Share Task', // Fetch user names when the share button is pressed
                  child: const Icon(Icons.share),
                ),
                const SizedBox(width: 5), // Spacing between buttons
                FloatingActionButton(
                  onPressed: () {
                    if (_selectedNotification != null) {
                      _moveToPastTasks(_selectedNotification!);
                    }
                  },
                  backgroundColor: Colors.green,
                  tooltip: 'Mark as Done',
                  child: const Icon(Icons.check),
                ),
              ],
            ),
      bottomSheet: _selectedNotification == null
          ? null
          : NotificationPageDataTable(
              selectedNotification: _selectedNotification),
    );
  }
}
