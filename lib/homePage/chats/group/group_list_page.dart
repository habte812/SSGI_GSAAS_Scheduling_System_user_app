import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'group_chat_page.dart';

class GroupsListPage extends StatefulWidget {
  const GroupsListPage({super.key});

  @override
  _GroupsListPageState createState() => _GroupsListPageState();
}

class _GroupsListPageState extends State<GroupsListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  @override
  Widget build(BuildContext context) {
        final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Container(
                                  width: 500,
                                  height: 400,
                                  decoration: const BoxDecoration(
                                    color: Color.fromARGB(72, 255, 255, 255),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: StreamBuilder<QuerySnapshot>(
                                          stream: _firestore
                                              .collection('groups')
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasError) {
                                              return Center(
                                                  child: Text(
                                                      'Error: ${snapshot.error}'));
                                            }

                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            }

                                            if (!snapshot.hasData ||
                                                snapshot.data!.docs.isEmpty) {
                                              return const Center(
                                                  child:
                                                      Text('No groups found.'));
                                            }

                                            final groups = snapshot.data!.docs;

                                            return ListView.builder(
                                              itemCount: groups.length,
                                              itemBuilder: (context, index) {
                                                final group = groups[index];
                                                return Card(
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 8.0),
                                                  child: ListTile(
                                                    title: Text(
                                                        group['groupName']),
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              GroupChatPage(
                                                            groupId: group.id,
                                                            groupName: group[
                                                                'groupName'],
                                                                currentUserId: currentUser!.uid,
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
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}






