import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ssgi/homePage/home_page.dart';
import 'package:ssgi/homePage/notificationPage/data_table.dart';
import 'package:ssgi/reusableWidgets/reusable_widget.dart';

class SharedDataUsersPage extends StatefulWidget {
  const SharedDataUsersPage({super.key});

  @override
  _SharedDataUsersPageState createState() => _SharedDataUsersPageState();
}

class _SharedDataUsersPageState extends State<SharedDataUsersPage> {
  List<Map<String, dynamic>> sharedTasks = [];
  String? userUID;
  Map<String, dynamic>? _selectedNotification;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserUID();
    // _setupFCM();
  }

  Future<void> _fetchCurrentUserUID() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        userUID = user.uid;
      });
      _fetchSharedDataForUser(user.uid);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not logged in.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchSharedDataForUser(String userUID) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('SharedDataUsers')
          .doc(userUID)
          .collection('tasks')
          .get();

      setState(() {
        sharedTasks = snapshot.docs
            .map((doc) => {
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id, // Add document ID to the task data
                })
            .toList();
      });
    } catch (e) {
      print("Error fetching shared data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching shared tasks: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await FirebaseFirestore.instance
          .collection('SharedDataUsers')
          .doc(userUID)
          .collection('tasks')
          .doc(taskId)
          .delete();
          

      setState(() {
        sharedTasks.removeWhere((task) => task['id'] == taskId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: const Text('Task deleted successfully.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.black,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),

              ),
        ),
      );

      // Navigate back to the homepage
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const SharedDataUsersPage()));
    } catch (e) {
      print("Error deleting task: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting task: $e',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        'Shared Tasks',
        IconButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const HomePage()));
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: userUID == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : sharedTasks.isEmpty
              ? const Center(
                  child: Text('No tasks shared yet'),
                )
              : ListView.builder(
                  itemCount: sharedTasks.length,
                  itemBuilder: (context, index) {
                    final task = sharedTasks[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedNotification = task;
                        });
                      },
                      child: Card(
                        child: ListTile(
                          title: Text(task['title'] ?? 'Task'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Shared by: ${task['sentTo'] ?? 'Unknown'}'),
                              Text(
                                  'Shared on: ${task['sharedAt']?.toDate() ?? 'Unknown'}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTask(task['id']),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      bottomSheet: _selectedNotification == null
          ? null
          : SharedDataTables(selectedNotification: _selectedNotification),
    );
  }
}

