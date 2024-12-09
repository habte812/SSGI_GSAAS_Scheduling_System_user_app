import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ssgi/homePage/chats/private%20chat/chat_page.dart';

class UserListPage extends StatefulWidget {
  final String currentUserId;

  const UserListPage({required this.currentUserId, super.key});

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _fetchUsersAndAdmins() async {
    List<Map<String, dynamic>> tempUsers = [];

    try {
      // Fetch regular users
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      for (var user in usersSnapshot.docs) {
        if (user.id != widget.currentUserId) {
          DocumentSnapshot userProfile = await _firestore
              .collection('UserProfile')
              .doc(user.id)
              .get(); // Fetch profile image from UserProfile collection

          // Ensure user data exists and assign an empty imageUrl if missing
          tempUsers.add({
            'id': user.id,
            'name': user['name'],
            'imageUrl': userProfile.data() != null
                ? userProfile['imageUrl'] ?? ''
                : '', // Default empty if imageUrl is not found
            'isAdmin': false,
          });
        }
      }

      // Fetch admins
      QuerySnapshot adminsSnapshot =
          await _firestore.collection('admins').get();
      for (var admin in adminsSnapshot.docs) {
        if (admin.id != widget.currentUserId) {
          // Fetch image from 'admins' collection using 'imageUrl'
          tempUsers.add({
            'id': admin.id,
            'name': admin['name'],
            'imageUrl': admin['imageUrl'] ?? '', // Fetch admin image
            'isAdmin': true,
          });
        }
      }
    } catch (e) {
      print("Error fetching users and admins: $e");
    }

    return tempUsers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchUsersAndAdmins(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loading indicator while fetching data
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            // Display an error message if something went wrong
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          // Get the list of users from the snapshot data
          List<Map<String, dynamic>>? users = snapshot.data;

          if (users == null || users.isEmpty) {
            // Display "No users to chat with" if the list is empty
            return const Center(
              child: Text("No users to chat with."),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              bool isAdmin = user['isAdmin'];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user['imageUrl'].isNotEmpty
                        ? NetworkImage(user['imageUrl'])
                        : const AssetImage('assets/images/BGicon.png')
                            as ImageProvider, // Placeholder image
                  ),
                  title: Text(user['name']),
                  subtitle: isAdmin ? const Text('Admin') : null,
                  onTap: () {
                    // Navigate to the chat with the selected user
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrivateChatPage(
                          currentUserId: widget.currentUserId,
                          otherUserId: user['id'],
                          otherUserName: user['name'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
