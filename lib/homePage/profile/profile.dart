import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ssgi/homePage/profile/profile_page.dart';
import 'package:ssgi/reusableWidgets/reusable_widget.dart';

class AnimatedProfilePage extends StatefulWidget {
  const AnimatedProfilePage({super.key});

  @override
  _AnimatedProfilePageState createState() => _AnimatedProfilePageState();
}

class _AnimatedProfilePageState extends State<AnimatedProfilePage>
    with SingleTickerProviderStateMixin {
  String? _imageUrl;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  // Animation controller variables
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  bool _isDetailsExpanded = false; // Track if the details section is expanded

  @override
  void initState() {
    super.initState();

    // Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // SlideIn Animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Rotation Animation
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticInOut),
    );

    _controller.forward(); // Start the animations
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        'Profile',
        IconButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Use StreamBuilder to listen for real-time updates
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('UserProfile')
                .doc(uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.data!.exists) {
                // No user data exists, show 'No information'
                return const Center(
                  child: Text(
                    'No information',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                );
              }

              var data = snapshot.data!.data() as Map<String, dynamic>?;
              if (data == null || data.isEmpty) {
                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No information',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              }

              String fullName = data['fullName'] ?? 'No name';
              String email = data['email'] ?? 'No email';
              String phone = data['phone'] ?? 'No phone';
              _imageUrl =
                  data['imageUrl'] != 'No image' ? data['imageUrl'] : null;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Animated Profile Picture with rotation
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isDetailsExpanded =
                                !_isDetailsExpanded; // Toggle details section
                          });
                        },
                        child: RotationTransition(
                          turns: _rotationAnimation,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 800),
                            height: 120,
                            width: 120,
                            child: CircleAvatar(
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: _imageUrl != null
                                  ? NetworkImage(_imageUrl!)
                                  : const AssetImage('assets/images/BGicon.png')
                                      as ImageProvider,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // SlideIn Animation for Profile Details
                      SlideTransition(
                        position: _slideAnimation,
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                fullName.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                email,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                phone,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Positioned Section to Expand Profile Details
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            bottom: _isDetailsExpanded ? 0 : -300,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              color: Colors.deepPurpleAccent.withOpacity(0.1),
              padding: const EdgeInsets.all(20),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Profile Details Expanded',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.deepPurpleAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'More profile information can be shown here...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          // Animated Scale for Button
          Align(
            child: ScaleTransition(
              scale:
                  CurvedAnimation(parent: _controller, curve: Curves.easeOut),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const ProfilePage()));
                },
                label: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
