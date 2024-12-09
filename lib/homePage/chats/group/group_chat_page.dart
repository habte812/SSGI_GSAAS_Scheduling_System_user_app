import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; 
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:ssgi/homePage/chats/private%20chat/chat_page.dart';

class GroupChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String currentUserId;

  const GroupChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.currentUserId,
  });

  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FocusNode _messageFocusNode = FocusNode();
  final FocusNode _editFocusNode = FocusNode();
  String? _editingMessageId;
  final TextEditingController _editMessageController = TextEditingController();
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    _setUserOnlineStatus();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _editMessageController.dispose();
    _messageFocusNode.dispose();
    _editFocusNode.dispose();
    _updateOnlineStatus(false);
    super.dispose();
  }

  Future<void> _updateOnlineStatus(bool isOnline) async {
    User? user = _auth.currentUser;
    if (user != null) {
      String collection = await _isAdmin(user.uid) ? 'admins' : 'users';
      try {
        await _firestore.collection(collection).doc(user.uid).update({
          'isOnline': isOnline,
        });
      } catch (e) {
        print("Error updating online status: $e");
      }
    }
  }

  void _setUserOnlineStatus() {
    _updateOnlineStatus(true);

    _auth.userChanges().listen((User? user) {
      if (user == null) {
        _updateOnlineStatus(false);
      }
    });
  }

  Future<bool> _isAdmin(String uid) async {
    DocumentSnapshot adminDoc =
        await _firestore.collection('admins').doc(uid).get();
    return adminDoc.exists;
  }

  Future<void> _sendNotificationToUser(
      String userId, String userName, String senderName) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String? fcmToken = userData['fcmToken']; // Access fcmToken safely
        if (fcmToken != null) {
          await _sendNotification(fcmToken,
              "New Message From Group by $senderName", userName, "group");
        }
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('groups')
            .doc(widget.groupId)
            .collection('messages')
            .add({
          'senderId': user.uid,
          'senderName': user.displayName ?? 'Admin',
          'message': _messageController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'seenBy': [], 
        });

        String senderName =
            user.displayName ?? 'Admin'; 
        _messageController.clear();
        _messageFocusNode.unfocus();

        // Fetch all users except the sender
        QuerySnapshot userSnapshot =
            await FirebaseFirestore.instance.collection('users').get();

        for (var doc in userSnapshot.docs) {
          String userId = doc.id;
          String userName = doc['name']; 

          if (userId != user.uid) {
            // Exclude the sender
            await _sendNotificationToUser(
                userId, userName, senderName); 
          }
        }
      } catch (e) {
        print("Error sending message: $e");
      }
    }
  }

  final _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

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

    final authClient =
        await clientViaServiceAccount(accountCredentials, _scopes);

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
              'channel_id':
                  _getChannelId(type), // Use a function to get the channel ID
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

  Future<List<Map<String, dynamic>>> _fetchOnlineUsersAndAdmins() async {
    List<Map<String, dynamic>> onlineUsers = [];

    try {
      // Fetch only online users
      QuerySnapshot usersSnapshot = await _firestore
          .collection('users')
          .where('isOnline', isEqualTo: true)
          .get();
      for (var user in usersSnapshot.docs) {
        // Skip the current user from the list
        if (user.id != widget.currentUserId) {
          onlineUsers.add({
            'id': user.id,
            'name': user['name'],
            'isAdmin': false,
          });
        }
      }

      // Fetch only online admins
      QuerySnapshot adminsSnapshot = await _firestore
          .collection('admins')
          .where('isOnline', isEqualTo: true)
          .get();
      for (var admin in adminsSnapshot.docs) {
        // Skip the current user from the list
        if (admin.id != widget.currentUserId) {
          onlineUsers.add({
            'id': admin.id,
            'name': admin['name'],
            'isAdmin': true,
          });
        }
      }
    } catch (e) {
      print("Error fetching online users and admins: $e");
    }

    return onlineUsers; // Return only online users and admins
  }



  void _markMessagesAsSeen(List<QueryDocumentSnapshot> messages) {
    User? user = _auth.currentUser;
    if (user == null) return;

    for (var message in messages) {
      final List<dynamic> seenBy = message['seenBy'] ?? [];
      final String senderId = message['senderId'];

      // Only update seenBy if the user is not the sender
      if (!seenBy.contains(user.uid) && user.uid != senderId) {
        _firestore
            .collection('groups')
            .doc(widget.groupId)
            .collection('messages')
            .doc(message.id)
            .update({
          'seenBy': FieldValue.arrayUnion([user.uid]),
        });
      }
    }
  }

  void _showMessageOptions(BuildContext context, String messageId,
      String messageText, bool isCurrentUser, TapDownDetails details) {
    // ignore: unused_local_variable
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        details.globalPosition & const Size(40, 40), // Using the tap position
        Offset.zero & MediaQuery.of(context).size,
      ), // Adjust position as needed
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy'),
            onTap: () {
              // Copy the message to clipboard
              Clipboard.setData(ClipboardData(text: messageText));
              Navigator.pop(context); // Close the menu
            },
          ),
        ),
        if (isCurrentUser) ...[
          PopupMenuItem(
            child: ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                // Edit message logic
                setState(() {
                  _editingMessageId = messageId;
                  _editMessageController.text = messageText;
                });
                Navigator.pop(context); // Close the menu
              },
            ),
          ),
          PopupMenuItem(
            child: ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                // Delete message logic
                _deleteMessage(messageId);
                Navigator.pop(context); // Close the menu
              },
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _editMessage(String messageId) async {
    try {
      await _firestore
          .collection('groups')
          .doc(widget.groupId)
          .collection('messages')
          .doc(messageId)
          .update({
        'message': _editMessageController.text,
      });
      setState(() {
        _editingMessageId = null; // Reset after editing
        _editMessageController.clear();
      });
    } catch (e) {
      print('Error editing message: $e');
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      await _firestore
          .collection('groups')
          .doc(widget.groupId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      print('Error deleting message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: Text(
          widget.groupName, //"Group chat",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: SizedBox(
                  height: 200, // Limit height for scrolling
                  width: 200,
                  child: Scrollbar(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future:
                          _fetchOnlineUsersAndAdmins(), // Fetch only online users and admins
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              'Error',
                              style: TextStyle(color: Colors.black),
                            ),
                          );
                        }

                        List<Map<String, dynamic>> onlineUsersList =
                            snapshot.data ?? [];

                        if (onlineUsersList.isEmpty) {
                          return const Center(
                            child: Text(
                              'No users online',
                              style: TextStyle(color: Colors.black),
                            ),
                          );
                        }

                        return ListView(
                          children: onlineUsersList.map((user) {
                            return ListTile(
                              leading:
                                  const Icon(Icons.person, color: Colors.black),
                              title: Text(
                                user['name'] ?? 'Unknown',
                                style: const TextStyle(color: Colors.black),
                              ),
                              subtitle: const Text(
                                'Status: Online',
                                style: TextStyle(color: Colors.black),
                              ),
                              onTap: () {
                                // Navigate to PrivateChatPage with currentUserId and otherUserId
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PrivateChatPage(
                                      currentUserId: widget
                                          .currentUserId, // Pass the current user's ID (clicker)
                                      otherUserId: user[
                                          'id'], // Pass the clicked user's ID
                                      otherUserName: user[
                                          'name'], // Pass the clicked user's name
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
        toolbarHeight: 70,
        backgroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0))),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];
                User? user = _auth.currentUser;

                // Mark messages as seen for the current user
                for (var message in messages) {
                  final List<dynamic> seenBy = message['seenBy'] ?? [];
                  final String senderId = message['senderId'];

                  // Add user to seenBy if they are not the sender and not already in the list
                  if (user != null &&
                      user.uid != senderId &&
                      !seenBy.contains(user.uid)) {
                    _firestore
                        .collection('groups')
                        .doc(widget.groupId)
                        .collection('messages')
                        .doc(message.id)
                        .update({
                      'seenBy': FieldValue.arrayUnion([user.uid]),
                    });
                  }
                }

                // Display messages
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isCurrentUser = message['senderId'] == user?.uid;
                    final Timestamp? timestamp = message['createdAt'];
                    final DateTime? dateTime = timestamp?.toDate();
                    final String formattedTime = dateTime != null
                        ? DateFormat('hh:mm a, MMM d').format(dateTime)
                        : '';
                    final List<dynamic>? seenBy = message['seenBy'];
                    final bool isSeenByMultiple =
                        seenBy != null && seenBy.isNotEmpty;

                    return GestureDetector(
                      onTapDown: (TapDownDetails details) {
                        if (isCurrentUser && _editingMessageId != message.id) {
                          _showMessageOptions(context, message.id,
                              message['message'] ?? '', isCurrentUser, details);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: isCurrentUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: isCurrentUser
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message['senderName'] ?? 'Unknown',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    margin: isCurrentUser
                                        ? const EdgeInsets.only(left: 50.0)
                                        : const EdgeInsets.only(right: 50.0),
                                    decoration: BoxDecoration(
                                      color: isCurrentUser
                                          ? Colors.blue[100]
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          message['message'] ?? '',
                                          style: TextStyle(
                                              color: isCurrentUser
                                                  ? Colors.black
                                                  : Colors.black),
                                        ),
                                        const SizedBox(height: 4.0),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              formattedTime,
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 10.0),
                                            ),
                                            const SizedBox(width: 4.0),
                                            if (isCurrentUser)
                                              Icon(
                                                isSeenByMultiple
                                                    ? Icons.done_all
                                                    : Icons.done,
                                                size: 16.0,
                                                color: isSeenByMultiple
                                                    ? Colors.blue
                                                    : Colors.grey[600],
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_editingMessageId != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _editMessageController,
                      focusNode: _editFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Edit your message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      maxLines: 2,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if (_editingMessageId != null) {
                        _editMessage(_editingMessageId!);
                      }
                    },
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _messageFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Send a message...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
