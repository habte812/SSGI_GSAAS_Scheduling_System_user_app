import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class PrivateChatPage extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;

  const PrivateChatPage({
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
    super.key,
  });

  @override
  _PrivateChatPageState createState() => _PrivateChatPageState();
}

class _PrivateChatPageState extends State<PrivateChatPage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference _messagesRef;
  String? _messageToEditId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _editController = TextEditingController();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    // Create a unique chat room document based on the two users
    _messagesRef = _firestore
        .collection('private_chats')
        .doc(_getChatRoomId(widget.currentUserId, widget.otherUserId))
        .collection('messages');
    _setUserOnlineStatus(true);
  }

  @override
  void dispose() {
    _updateOnlineStatus(false);
    super.dispose();
  }

  String _getChatRoomId(String currentUserId, String otherUserId) {
    // Ensure the chat room ID is unique and consistent by sorting the user IDs
    List<String> ids = [currentUserId, otherUserId];
    ids.sort();
    return ids.join('_'); // e.g., userId_adminId or adminId_userId
  }

  Future<String> _fetchUserName(String userId) async {
    // Fetch the sender's name from Firestore using currentUserId
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc[
        'name']; // Assuming the user's name is stored in the 'name' field
  }

  void _sendMessage(String text, String? imageUrl) async {
    if (text.trim().isNotEmpty || imageUrl != null) {
      String senderName = await _fetchUserName(widget.currentUserId);

      await _firestore
          .collection('private_chats')
          .doc(_getChatRoomId(widget.currentUserId, widget.otherUserId))
          .collection('messages')
          .add({
        'sender': widget.currentUserId,
        'text': text.trim(),
        'imageUrl': imageUrl, // Store image URL if present
        'timestamp': FieldValue.serverTimestamp(),
        'seenBy': [],
      });

      _controller.clear();
      await _sendNotificationToUser(
          widget.otherUserId, widget.otherUserName, senderName);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String imageUrl = await _uploadImageToFirebase(imageFile);
      _sendMessage("", imageUrl); // Send message with image URL
    }
  }

  Future<String> _uploadImageToFirebase(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('chat_images/$fileName');
      await ref.putFile(image);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return "";
    }
  }
  final _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  Future<void> _sendNotificationToUser(
      String userId, String otherUserName, String senderName) async {
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
              fcmToken,
              "You Got New Message From $senderName",
              otherUserName,
              "private");
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
        return 'your_channel_private';
      default:
        return 'your_channel_default';
    }
  }

  void _editMessage(String messageId, String currentText) {
    _editController.text = currentText;
    setState(() {
      _messageToEditId = messageId;
    });
  }

  void _updateMessage() {
    if (_editController.text.isNotEmpty && _messageToEditId != null) {
      _messagesRef.doc(_messageToEditId).update({
        'text': _editController.text,
      });
      setState(() {
        _messageToEditId = null;
        _editController.clear();
      });
    }
  }

  void _deleteMessage(String messageId) {
    _messagesRef.doc(messageId).delete();
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _markMessagesAsSeen(List<QueryDocumentSnapshot> messages) {
    User? user = _auth.currentUser;
    if (user == null) return;

    for (var message in messages) {
      final List<dynamic> seenBy = message['seenBy'] ?? [];
      final String senderId = message['sender'];

      // Only update seenBy if the user is not the sender and hasn't already seen the message
      if (!seenBy.contains(user.uid) && user.uid != senderId) {
        _firestore
            .collection('private_chats')
            .doc(_getChatRoomId(widget.currentUserId, widget.otherUserId))
            .collection('messages')
            .doc(message.id)
            .update({
          'seenBy': FieldValue.arrayUnion([user.uid]),
        });
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
          'lastSeen': isOnline
              ? null
              : FieldValue.serverTimestamp(), // Update lastSeen if offline
        });
      } catch (e) {
        print("Error updating online status: $e");
      }
    }
  }

  void _setUserOnlineStatus(bool bool) {
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatLastSeenTime(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    // Date format with short month name and year
    final dateFormat = DateFormat('d MMM yyyy, h:mm a');

    if (difference.inDays >= 1) {
      return dateFormat.format(lastSeen);
    } else {
      // If less than 1 day, show "Today" with time
      return 'Today at ${DateFormat('h:mm a').format(lastSeen)}';
    }
  }

  Future<void> _downloadImage(BuildContext context, String imageUrl) async {
    try {
      // Request storage permission
      await requestPermissions();

      // Ask user to select the directory to save the image
      String? directoryPath = await FilePicker.platform.getDirectoryPath();

      if (directoryPath == null) {
        // User canceled the directory picker
        return;
      }

      // Create file path to save the image
      String fileName = imageUrl
          .split('/')
          .last
          .split('?')
          .first; // Get the file name from the URL
      File file = File('$directoryPath/$fileName.jpg');

      // Download the image data
      http.Response response = await http.get(Uri.parse(imageUrl));

      // Check if the response is OK (status code 200)
      if (response.statusCode == 200) {
        // Write the image bytes to the file
        await file.writeAsBytes(response.bodyBytes);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image downloaded to ${file.path}')),
        );
      } else {
        // Handle any error responses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download image')),
        );
      }
    } catch (e) {
      print("Error downloading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error downloading image')),
      );
    }
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.otherUserName.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(widget.otherUserId)
                  .snapshots(),
              builder: (context, userSnapshot) {
                if (userSnapshot.hasError) {
                  return const Text('Offline',
                      style: TextStyle(color: Colors.grey));
                }

                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading...',
                      style: TextStyle(color: Colors.grey));
                }

                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  bool isOnline = userSnapshot.data!['isOnline'] ?? false;
                  Timestamp? lastSeenTimestamp =
                      userSnapshot.data!['lastSeen'] as Timestamp?;

                  if (isOnline) {
                    return const Text('Online',
                        style: TextStyle(color: Colors.green));
                  } else {
                    if (lastSeenTimestamp != null) {
                      DateTime lastSeen = lastSeenTimestamp.toDate();
                      String lastSeenTime = _formatLastSeenTime(lastSeen);
                      return Text('Last seen: $lastSeenTime',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 20));
                    } else {
                      return const Text('Offline',
                          style: TextStyle(color: Colors.grey));
                    }
                  }
                } else {
                  return StreamBuilder<DocumentSnapshot>(
                    stream: _firestore
                        .collection('admins')
                        .doc(widget.otherUserId)
                        .snapshots(),
                    builder: (context, adminSnapshot) {
                      if (adminSnapshot.hasError) {
                        return const Text('Offline',
                            style: TextStyle(color: Colors.grey));
                      }

                      if (adminSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Text('Loading...',
                            style: TextStyle(color: Colors.grey));
                      }

                      if (!adminSnapshot.hasData ||
                          !adminSnapshot.data!.exists) {
                        return const Text('Offline',
                            style: TextStyle(color: Colors.grey));
                      }

                      bool isOnline = adminSnapshot.data!['isOnline'] ?? false;
                      Timestamp? lastSeenTimestamp =
                          adminSnapshot.data!['lastSeen'] as Timestamp?;

                      if (isOnline) {
                        return const Text('Online',
                            style: TextStyle(color: Colors.green));
                      } else {
                        if (lastSeenTimestamp != null) {
                          DateTime lastSeen = lastSeenTimestamp.toDate();
                          String lastSeenTime = _formatLastSeenTime(lastSeen);
                          return Text('Last seen: $lastSeenTime',
                              style: const TextStyle(color: Colors.grey));
                        } else {
                          return const Text('Offline',
                              style: TextStyle(color: Colors.grey));
                        }
                      }
                    },
                  );
                }
              },
            ),
          ],
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
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
              stream: _messagesRef.orderBy('timestamp').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                _markMessagesAsSeen(snapshot.data!.docs);
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());
                return // Inside your ListView.builder where messages are displayed
                    ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(10),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var message = snapshot.data!.docs[index];
                    bool isUser = message['sender'] == widget.currentUserId;
                    String messageId = message.id;
                    Timestamp? timestamp = message['timestamp'];
                    String formattedTime =
                        timestamp != null ? _formatTimestamp(timestamp) : '';
                    const SizedBox(width: 5);
                    final List<dynamic>? seenBy = message['seenBy'];
                    final bool isSeenByMultiple =
                        seenBy != null && seenBy.isNotEmpty;

                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: GestureDetector(
                        onTapDown: (TapDownDetails details) {
                          // Allow showing menu for any message except the one currently being edited
                          if (_messageToEditId != messageId) {
                            showMenu(
                              context: context,
                              position: RelativeRect.fromRect(
                                details.globalPosition & const Size(40, 40),
                                Offset.zero & MediaQuery.of(context).size,
                              ),
                              items: [
                                if (isUser) // Show "Edit" option only for the user's own messages
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: ListTile(
                                      leading: Icon(Icons.edit_outlined),
                                      title: Text('Edit'),
                                    ),
                                  ),
                                PopupMenuItem(
                                  child: ListTile(
                                    leading: const Icon(Icons.copy_outlined),
                                    title: const Text('Copy'),
                                    onTap: () {
                                      Clipboard.setData(
                                          ClipboardData(text: message['text']));
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                                // Show "Download Image" option if 'imageUrl' exists in the message
                                if (message['imageUrl'] != null)
                                  const PopupMenuItem(
                                    value: 'download',
                                    child: ListTile(
                                      leading: Icon(Icons.download_outlined),
                                      title: Text('Download Image'),
                                    ),
                                  ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(Icons.delete_outline),
                                    title: Text('Delete'),
                                  ),
                                ),
                              ],
                            ).then((value) {
                              if (value == 'edit') {
                                _editMessage(messageId, message['text']);
                              } else if (value == 'delete') {
                                _deleteMessage(messageId);
                              } else if (value == 'download') {
                                if (message['imageUrl'] != null) {
                                  _downloadImage(
                                    context,
                                    message[
                                        'imageUrl'], // Call the download function
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'No image available to download'),
                                    ),
                                  );
                                }
                              }
                            });
                          }
                        },
                        child: Container(
                          constraints: const BoxConstraints(
                            maxWidth:
                                300, // Set max width for message container
                          ),
                          padding: const EdgeInsets.all(10.0),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Colors.blue[100]
                                : Colors.grey[
                                    200], // Background color for the main container
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Container for the image without any background color
                              if (message['imageUrl'] != null &&
                                  message['imageUrl']
                                      .isNotEmpty) // Check for image URL
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      8.0), // Keep the same border radius
                                  child: Image.network(
                                    message['imageUrl'], // Load image from URL
                                    width: double
                                        .infinity, // Make image container take full width
                                    height: 200, // Set height for the image
                                    fit: BoxFit
                                        .contain, // Cover the entire container without clipping
                                  ),
                                ),
                              const SizedBox(
                                  height: 8.0), // Space between image and text
                              // Separate Container for the text
                              Container(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  message['text'] ?? '',
                                  style: TextStyle(
                                    color: isUser ? Colors.black : Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 10.0,
                                    ),
                                  ),
                                  const SizedBox(width: 4.0),
                                  if (isUser)
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
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_messageToEditId != null)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _editController,
                      decoration: const InputDecoration(
                        hintText: 'Edit message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: _updateMessage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () {
                      setState(() {
                        _messageToEditId = null;
                        _editController.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickImage, // Pick an image
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_controller.text, null),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
