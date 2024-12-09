import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth for UID
import 'package:ssgi/homePage/Profile/profile_phonenumberfield.dart';
import 'package:ssgi/reusableWidgets/reusable_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _fnamecontroller = TextEditingController();
  final TextEditingController _emailcontroller = TextEditingController();
  TextEditingController mobile = TextEditingController();
  Uint8List? _image; // Store the selected image in memory
  String? _imageUrl; // Store the image URL fetched from Firestore
  bool _isLoading = false;

  final String uid =
      FirebaseAuth.instance.currentUser!.uid; // Get the current user's UID

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch existing profile data when the page loads
  }

  Future<Uint8List?> pickImage(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: source);

    if (file != null) {
      return await file.readAsBytes(); // Return the image bytes
    } else {
      print('No image selected!');
      return null; // Return null if no image is selected
    }
  }

  void _fetchUserData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('UserProfile')
          .doc(uid) // Fetch the document using the current user's UID
          .get();

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        setState(() {
          _fnamecontroller.text = data['fullName'] ?? '';
          _emailcontroller.text = data['email'] ?? '';
          mobile.text = data['phone'] ?? '';
          _imageUrl = data['imageUrl'] != 'No image'
              ? data['imageUrl']
              : null; // Set to null if 'No image'
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to fetch profile data: $e',
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

  // Select an image from the gallery
  void selectImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);

    if (img != null) {
      setState(() {
        _image = img; // This updates the state with the selected image
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No image selected!'),
        ),
      );
    }
  }

  // Upload image to Firebase Storage and get the download URL
  Future<String> _uploadImageToStorage(Uint8List image) async {
    String imageId = uid; // Use the user's UID for the image path
    Reference storageRef =
        FirebaseStorage.instance.ref().child('user_profiles/$imageId.jpg');
    UploadTask uploadTask = storageRef.putData(image); // Upload the image
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL(); // Return the download URL
  }

  void _submitForm() async {
    if (_fnamecontroller.text.isEmpty ||
        _emailcontroller.text.isEmpty ||
        !RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$')
            .hasMatch(_emailcontroller.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please fill all fields correctly. Email must include @gmail.com',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? imageUrl = _imageUrl; // Keep the current image URL

    if (_image != null) {
      // If a new image is selected
      try {
        imageUrl =
            await _uploadImageToStorage(_image!); // Upload it and get the URL
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
          ),
        );
        print('Failed to upload image: $e');
        return;
      }
    }

    try {
      // Check if the document exists
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('UserProfile')
          .doc(uid)
          .get();

      if (doc.exists) {
        // If the document exists, update it
        await FirebaseFirestore.instance
            .collection('UserProfile')
            .doc(uid)
            .update({
          'fullName': _fnamecontroller.text,
          'email': _emailcontroller.text,
          'phone': mobile.text,
          'imageUrl': imageUrl ?? 'No image',
          'updatedAt': Timestamp.now(),
        });
      } else {
        // If the document does not exist, create it
        await FirebaseFirestore.instance
            .collection('UserProfile')
            .doc(uid)
            .set({
          'fullName': _fnamecontroller.text,
          'email': _emailcontroller.text,
          'phone': mobile.text,
          'imageUrl': imageUrl ?? 'No image',
          'createdAt': Timestamp.now(), // Add creation timestamp
        });
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Profile saved successfully',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update profile: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      print('Failed to update profile: $e');
    }
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
      body: Form(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: boxDecoration(),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Profile Image (fetch from Firestore or select new one)
                  Stack(
                    children: [
                      _image != null
                          ? CircleAvatar(
                              radius: 65,
                              backgroundImage: MemoryImage(
                                  _image!), // Display the picked image
                            )
                          : _imageUrl != null
                              ? CircleAvatar(
                                  radius: 65,
                                  backgroundImage: NetworkImage(
                                      _imageUrl!), // Display image from the URL if no new image is picked
                                )
                              : const CircleAvatar(
                                  radius: 65,
                                  backgroundImage: AssetImage(
                                      'assets/images/BGicon.png'), // Default placeholder
                                ),
                      Positioned(
                        bottom: -10,
                        left: 80,
                        child: IconButton(
                          onPressed: selectImage,
                          icon: const Icon(Icons.add_a_photo),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                  SizedBox(
                    height: 80,
                    width: 380,
                    child: reusableTextFormField('Full Name',
                        Icons.person_outline, false, _fnamecontroller),
                  ),
                  ProfilePhoneNOformatfield(mobile: mobile),
                  SizedBox(
                    height: 80,
                    width: 380,
                    child: reusableTextFormField('Enter Your Email Address',
                        Icons.mail_outline, false, _emailcontroller),
                  ),
                  if (_isLoading)
                    Lottie.asset(
                      'assets/images/loadingAnimation.json', // Correct path for your Lottie file
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  else
                    SizedBox(
                      width: 380,
                      height: 40,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(0)),
                            ),
                          ),
                          backgroundColor: WidgetStateProperty.all(
                            const Color.fromARGB(255, 8, 5, 48),
                          ),
                          mouseCursor: WidgetStateProperty.all(
                            SystemMouseCursors.click,
                          ),
                        ),
                        onPressed: _submitForm,
                        child: const Text(
                          "Submit",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
