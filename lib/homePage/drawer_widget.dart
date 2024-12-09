import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ssgi/homePage/about%20this%20app/about_this_app.dart';
import 'package:ssgi/homePage/chats/private%20chat/chat_tabbar.dart';
import 'package:ssgi/homePage/drawer_heder.dart';
import 'package:ssgi/homePage/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ssgi/homePage/notepad/notepad_page.dart';
import 'package:ssgi/homePage/notificationPage/notification_page.dart';
import 'package:ssgi/homePage/notificationPage/shared_data_users_page.dart';
import 'package:ssgi/homePage/profile/profile.dart';
import 'package:ssgi/welcomepages/loginPages/login_page.dart';

class Drawerwidget extends StatefulWidget {
  const Drawerwidget({super.key});

  @override
  State<Drawerwidget> createState() => _DrawerwidgetState();
}

class _DrawerwidgetState extends State<Drawerwidget> {
  String? accountName;
  String? accountEmail;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Function to fetch user data from Firestore
  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('UserProfile')
            .doc(user.uid) // Fetching user data using UID as the document ID
            .get();

        if (userData.exists) {
          setState(() {
            accountName =
                userData['fullName']; // Field name in Firestore for name
            accountEmail =
                userData['email']; // Field name in Firestore for email
            _imageUrl = userData['imageUrl']; // Fetch the profile image URL
          });
        } else {
          print("User data not found in Firestore");
        }
      }
    } catch (e) {
      print("Failed to fetch user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // final currentUser = FirebaseAuth.instance.currentUser;
    return Drawer(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(25))),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          AnimatedDrawerHeader(
              imageUrl: _imageUrl,
              accountName: accountName,
              accountEmail: accountEmail),

          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 30, 0),
            child: Container(
              height: 60,
              width: 10,
              decoration: BoxDecoration(
                  //  color: Colors.grey,
                  border: Border.all(color: Colors.black), // Corrected line
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                  leading: SizedBox(
                    width: 40,
                    height: 40,
                    child: Lottie.asset(
                      'assets/images/homeAni.json', // Add your Lottie animation file here
                      height: 50,
                      width: 50,
                      repeat: true,
                    ),
                  ),
                  title: const Text('Home',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ));
                  }),
            ),
          ),
          // Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 30, 0),
            child: Container(
              height: 60,
              width: 10,
              decoration: BoxDecoration(
                  //  color: Colors.grey,
                  border: Border.all(color: Colors.black), // Corrected line
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                  leading: SizedBox(
                    width: 45,
                    height: 45,
                    child: Lottie.asset(
                      'assets/images/profileAnimation.json', // Add your Lottie animation file here
                      height: 50,
                      width: 50,
                      repeat: true,
                    ),
                  ),
                  title: const Text(
                    'Profile',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnimatedProfilePage(),
                        ));
                  }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 30, 0),
            child: Container(
              height: 60,
              width: 10,
              decoration: BoxDecoration(
                  //  color: Colors.grey,
                  border: Border.all(color: Colors.black), // Corrected line
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                  leading: SizedBox(
                    width: 40,
                    height: 40,
                    child: Lottie.asset(
                      'assets/images/taskAni.json', // Add your Lottie animation file here
                      height: 50,
                      width: 50,
                      repeat: true,
                    ),
                  ),
                  title: const Text('Tasks',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationsPage(),
                        ));
                  }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 30, 0),
            child: Container(
              height: 60,
              width: 10,
              decoration: BoxDecoration(
                  //  color: Colors.grey,
                  border: Border.all(color: Colors.black), // Corrected line
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                  leading: SizedBox(
                    width: 40,
                    height: 40,
                    child: Lottie.asset(
                      'assets/images/shareAnim1.json', // Add your Lottie animation file here

                      height: 50,
                      width: 50,
                      repeat: true,
                    ),
                  ),
                  title: const Text('Shared Tasks From Friend',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SharedDataUsersPage(),
                        ));
                  }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 30, 0),
            child: Container(
              height: 60,
              width: 10,
              decoration: BoxDecoration(
                  //  color: Colors.grey,
                  border: Border.all(color: Colors.black), // Corrected line
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                    width: 40,
                    height: 40,
                    child: Lottie.asset(
                      'assets/images/chatAnim2.json', // Add your Lottie animation file here
                      height: 50,
                      width: 50,
                      repeat: true,
                    ),
                  ),
                  title: const Text('Chat',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChatTabbar()
                            // GroupsListPage(),
                            ));
                  }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 30, 0),
            child: Container(
              height: 60,
              width: 10,
              decoration: BoxDecoration(
                  //  color: Colors.grey,
                  border: Border.all(color: Colors.black), // Corrected line
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                    width: 50,
                    height: 70,
                    child: Lottie.asset(
                      'assets/images/noteAni.json', // Add your Lottie animation file here
                      height: 70,
                      width: 70,
                      repeat: true,
                    ),
                  ),
                  title: const Text('Notepad',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotepadPage(),
                        ));
                  }),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 30, 0),
            child: Container(
              height: 60,
              width: 10,
              decoration: BoxDecoration(
                  //  color: Colors.grey,
                  border: Border.all(color: Colors.black), // Corrected line
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                    width: 40,
                    height: 40,
                    child: Lottie.asset(
                      'assets/images/aboutAni.json', // Add your Lottie animation file here
                      height: 50,
                      width: 50,
                      repeat: true,
                    ),
                  ),
                  title: const Text('About',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AboutThisApp()
                            // GroupsListPage(),
                            ));
                  }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 30, 0),
            child: Container(
              height: 60,
              width: 10,
              decoration: BoxDecoration(
                  //  color: Colors.grey,
                  border: Border.all(color: Colors.black), // Corrected line
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                    width: 40,
                    height: 40,
                    child: Lottie.asset(
                      'assets/images/logoutAni.json', // Add your Lottie animation file here
                      height: 40,
                      width: 40,
                      repeat: true,
                    ),
                  ),
                  title: const Text('Log out',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ));
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
