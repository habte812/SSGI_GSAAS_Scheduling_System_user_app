import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ssgi/homePage/articles_from_admin.dart';
import 'package:ssgi/homePage/carousel-slider-widget.dart';
import 'package:ssgi/homePage/drawer_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ssgi/homePage/notificationPage/notification_page.dart';
import 'package:ssgi/homePage/past_task_lists.dart';
import 'package:ssgi/homePage/profile/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? accountName;
  String? accountEmail;
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Widget divider() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
      child: Divider(),
    );
  }

  Future<String> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('UserProfile')
            .doc(user
                .uid) // Assuming user data is stored with UID as the document ID
            .get();

        if (userData.exists) {
          // Cast data to Map<String, dynamic>
          var data = userData.data() as Map<String, dynamic>;
          String accountName =
              data['fullName'] ?? 'Default Name'; // Field name in Firestore
          // String accountEmail =
          //     data['email'] ?? 'Default Email'; // Field name in Firestore

          // Optionally use or return both values as needed
          return accountName; // Return full name or any other relevant data
        } else {
          print("No user data found for UID: ${user.uid}");
          return 'User, Please fill in your information in the profile';
        }
      } else {
        return 'No User Logged In';
      }
    } catch (e) {
      print("Failed to fetch user data: $e");
      return 'Error Fetching Data';
    }
  }

  Future<String> _getGreeting() async {
    final hour = DateTime.now().hour;
    final accountName = await _fetchUserData();

    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return '$greeting, $accountName ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'F2'),
        ),
        toolbarHeight: 80,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        actions: <Widget>[
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.refresh_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AnimatedProfilePage()),
                  );
                },
              ),
            ],
          ),
        ],
        backgroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.zero,
            bottomRight: Radius.zero,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            FutureBuilder<String>(
              future: _getGreeting(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Hello, User',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'F2'));
                } else {
                  return Text(
                    snapshot.data!,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'F2'),
                  );
                }
              },
            ),
            divider(),
            const SizedBox(height: 20),
            const CarouselSliderWidget(),
            const SizedBox(height: 20),
            const SizedBox(height: 40),
            const Text(
              'Recent Task',
              style: TextStyle(
                  fontSize: 30, fontWeight: FontWeight.bold, fontFamily: 'F2'),
            ),
            divider(),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('UserDataHistory')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('files')
                  .orderBy('timestamp', descending: true)
                  .limit(1) // Fetch only the most recent task
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  // No recent tasks, display the message inside the container

                  return Container(
                    height: 250,
                    width: 350,
                    decoration: BoxDecoration(
                      // color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        // Lottie animation as the background
                        Center(
                          child: Opacity(
                            opacity: 0.3,
                            child: Lottie.asset(
                              'assets/images/NoTaskAnimation.json', // Replace with your Lottie animation file
                              fit: BoxFit.cover,
                              height: 250,
                              width: 300,
                            ),
                          ),
                        ),
                        // Text overlay
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'No recent tasks available.',
                            style: TextStyle(
                                color: Colors
                                    .black, // Ensure text is visible over animation
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'F2'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                var mostRecentTask = snapshot.data!.docs.first;
                var timestamp = mostRecentTask['timestamp'];

                DateTime arrivalDateTime;
                if (timestamp is Timestamp) {
                  arrivalDateTime = timestamp.toDate();
                } else if (timestamp is String) {
                  arrivalDateTime = DateTime.parse(timestamp);
                } else {
                  arrivalDateTime = DateTime.now();
                }

                return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationsPage()),
                      );
                    },
                    child: Container(
                      height: 250,
                      width: 350,
                      decoration: BoxDecoration(
                        // color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          // Lottie animation as the background

                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 25, 0, 10),
                            child: Opacity(
                              opacity: 0.3,
                              child: Lottie.asset(
                                'assets/images/TaskArrivedAnimation.json', // Replace with your Lottie animation file
                                fit: BoxFit.cover,
                                height: 200,
                                width: 200,
                              ),
                            ),
                          ),
                          // Text overlay
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'New Task is arrived \n at: ${arrivalDateTime.toLocal()} \n click here to see your task',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'F2'),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ));
              },
            ),
            const SizedBox(height: 20),
            const Center(
                child: Text(
              'Articles',
              style: TextStyle(
                fontSize: 30,
                fontFamily: 'F2',
                fontWeight: FontWeight.bold,
              ),
            )),
            divider(),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: ArticlesFromAdmin(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Past Tasks',
              style: TextStyle(
                  fontSize: 30, fontWeight: FontWeight.bold, fontFamily: 'F2'),
            ),
            divider(),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('PastTasks')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('files')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No past tasks available.'));
                }

                var pastTasks = snapshot.data!.docs;

                return Column(
                  children: pastTasks.map((task) {
                    var timestamp = task['timestamp'];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PastTasksPage(task: task),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 4.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.history_outlined, size: 30),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'Past Task ${pastTasks.indexOf(task) + 1}   Received at: $timestamp',
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'F2',
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
      drawer: const Drawerwidget(),
    );
  }
}
