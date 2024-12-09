import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ssgi/homePage/chats/group/group_list_page.dart';
import 'package:ssgi/homePage/chats/private%20chat/private_chat_user_list.dart';


class ChatTabbar extends StatelessWidget {
  const ChatTabbar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          title: const Text(
            ' Chat ',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'F2'),
          ),
          backgroundColor: Colors.black,
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.person, color: Colors.white),
                child: Text('Personal', style: TextStyle(color: Colors.white)),
              ),
              Tab(
                icon: Icon(Icons.group, color: Colors.white),
                child: Text('Groups', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        // backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        body: TabBarView(
          children: [
            UserListPage(
              currentUserId: currentUser!.uid,
            ),
            const GroupsListPage(),
          ],
        ),
      ),
    );
  }
}
