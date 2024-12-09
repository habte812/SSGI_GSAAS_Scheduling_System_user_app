// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:ssgi/Service/auth_service.dart';
// // import 'package:ssgi/homePage/home_page.dart';
// // import 'package:ssgi/welcomepages/forgetPasswordPage/forget_password.dart';

// // class Loginpage extends StatefulWidget {
// //   const Loginpage({super.key});

// //   @override
// //   State<Loginpage> createState() => _LoginpageState();
// // }

// // class _LoginpageState extends State<Loginpage> {
// //   final TextEditingController _emailController = TextEditingController();
// //   final TextEditingController _passwordController = TextEditingController();
// //   final AuthService _authService = AuthService();

// //   bool _isLoading = false;
// //   bool _isExpanded = false;

// //  Future<void> _login(BuildContext context) async {
// //     try {
// //       setState(() {
// //         _isLoading = true;
// //       });

// //       // Use AuthService to sign in
// //       User? user = await _authService.signInWithEmailAndPassword(
// //         _emailController.text,
// //         _passwordController.text,
// //       );

// //       if (user != null) {
// //         Navigator.pushReplacement(
// //           context,
// //           MaterialPageRoute(builder: (context) => const HomePage()),
// //         );
// //       }
// //       } catch (e) {
// //         setState(() {
// //           _isLoading = false;
// //                     ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(
// //               content:  Text(
// //                 'Error signing in: ${e.toString()} Or Email must contain "example@gmail.com"',
// //                 style: const TextStyle(color: Colors.white),
// //               ),
// //               backgroundColor: Colors.black,
// //               behavior: SnackBarBehavior.floating,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //             ),
// //           );
// //         });
// //       }

// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: () {
// //         setState(() {
// //           _isExpanded = !_isExpanded;
// //         });
// //       },
// //       child: AnimatedContainer(
// //         duration: const Duration(seconds: 1),
// //         curve: Curves.easeInOut,
// //         padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
// //         decoration: BoxDecoration(
// //           border: Border.all(color: Colors.black),
// //           borderRadius: BorderRadius.circular(_isExpanded ? 30 : 10),
// //           color: _isExpanded ? Color.fromARGB(76, 72, 47, 1) : Colors.white,
// //         ),
// //         child: Column(
// //           children: [
// //             const Icon(
// //               Icons.person,
// //               size: 80,
// //               color: Colors.black,
// //               weight: 10,
// //             ),
// //             Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 TextField(
// //                   controller: _emailController,
// //                   decoration: const InputDecoration(labelText: 'Email'),
// //                   keyboardType: TextInputType.emailAddress,
// //                 )
// //               ],
// //             ),
// //             const SizedBox(
// //               height: 10,
// //             ),
// //             TextField(
// //               controller: _passwordController,
// //               decoration: const InputDecoration(labelText: 'Password'),
// //               obscureText: true,
// //             ),
// //             // const ReusablePassTextField(),
// //             const Padding(
// //               padding: EdgeInsets.fromLTRB(178, 10, 0, 10),
// //               child: ForgetPassword(),
// //             ),
// //             if (_isLoading)
// //               const CircularProgressIndicator()
// //             else
// //               SizedBox(
// //                 width: 380,
// //                 height: 40,
// //                 child: ElevatedButton(
// //                   style: const ButtonStyle(
// //                     shape: WidgetStatePropertyAll(RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.all(Radius.zero))),
// //                     backgroundColor: WidgetStatePropertyAll(
// //                       Color.fromARGB(255, 8, 5, 48),
// //                     ),
// //                     mouseCursor: WidgetStateMouseCursor.clickable,
// //                   ),
// //                   onPressed: () => _login(context),
// //                   child: const Text(
// //                     "Login",
// //                     style: TextStyle(
// //                       color: Colors.white,
// //                       fontSize: 20,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:ssgi/Service/auth_service.dart';
// // import 'package:ssgi/homePage/home_page.dart';
// // import 'package:ssgi/welcomepages/forgetPasswordPage/forget_password.dart';

// // class Loginpage extends StatefulWidget {
// //   const Loginpage({super.key});

// //   @override
// //   State<Loginpage> createState() => _LoginpageState();
// // }

// // class _LoginpageState extends State<Loginpage> {
// //   final TextEditingController _emailController = TextEditingController();
// //   final TextEditingController _passwordController = TextEditingController();
// //    final AuthService _authService = AuthService();

// //   bool _isLoading = false;
// //   bool _isExpanded = false;

// //   Future<void> _login(BuildContext context) async {
// //     try {
// //       setState(() {
// //         _isLoading = true;
// //       });

// //       User? user = await _authService.signInWithEmailAndPassword(
// //         _emailController.text,
// //         _passwordController.text,
// //       );
// //       if (user != null) {
// //       Navigator.pushReplacement(
// //         context,
// //         MaterialPageRoute(builder: (context) => const HomePage()),
// //       );
// //         }
// //     } catch (e) {
// //       setState(() {
// //         _isLoading = false;
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text(
// //               'Error signing in: ${e.toString()}',
// //               style: const TextStyle(color: Colors.white),
// //             ),
// //             backgroundColor: Colors.black,
// //             behavior: SnackBarBehavior.floating,
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(10),
// //             ),
// //           ),
// //         );
// //       });
// //     } finally {
// //       setState(() {
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: () {
// //         setState(() {
// //           _isExpanded = !_isExpanded;
// //         });
// //       },
// //       child: AnimatedContainer(
// //         duration: const Duration(seconds: 1),
// //         curve: Curves.easeInOut,
// //         padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
// //         decoration: BoxDecoration(
// //           border: Border.all(color: Colors.black),
// //           borderRadius: BorderRadius.circular(_isExpanded ? 30 : 10),
// //           color: _isExpanded ? Color.fromARGB(76, 72, 47, 1) : Colors.white,
// //         ),
// //         child: Column(
// //           children: [
// //             const Icon(
// //               Icons.person,
// //               size: 80,
// //               color: Colors.black,
// //               weight: 10,
// //             ),
// //             Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 TextField(
// //                   controller: _emailController,
// //                   decoration: const InputDecoration(labelText: 'Email'),
// //                   keyboardType: TextInputType.emailAddress,
// //                 )
// //               ],
// //             ),
// //             const SizedBox(
// //               height: 10,
// //             ),
// //             TextField(
// //               controller: _passwordController,
// //               decoration: const InputDecoration(labelText: 'Password'),
// //               obscureText: true,
// //             ),
// //             // const ReusablePassTextField(),
// //             const Padding(
// //               padding: EdgeInsets.fromLTRB(178, 10, 0, 10),
// //               child: ForgetPassword(),
// //             ),
// //             if (_isLoading)
// //               const CircularProgressIndicator()
// //             else
// //               SizedBox(
// //                 width: 380,
// //                 height: 40,
// //                 child: ElevatedButton(
// //                   style: const ButtonStyle(
// //                     shape: WidgetStatePropertyAll(RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.all(Radius.zero))),
// //                     backgroundColor: WidgetStatePropertyAll(
// //                       Color.fromARGB(255, 8, 5, 48),
// //                     ),
// //                     mouseCursor: WidgetStateMouseCursor.clickable,
// //                   ),
// //                   onPressed: () => _login(context),
// //                   child: const Text(
// //                     "Login",
// //                     style: TextStyle(
// //                       color: Colors.white,
// //                       fontSize: 20,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:ssgi/Service/auth_service.dart';
// // import 'package:ssgi/homePage/home_page.dart';
// // import 'package:ssgi/welcomepages/forgetPasswordPage/forget_password.dart';

// // class Loginpage extends StatefulWidget {
// //   const Loginpage({super.key});

// //   @override
// //   State<Loginpage> createState() => _LoginpageState();
// // }

// // class _LoginpageState extends State<Loginpage> {
// //   final TextEditingController _emailController = TextEditingController();
// //   final TextEditingController _passwordController = TextEditingController();
// //   final AuthService _authService = AuthService();

// //   bool _isLoading = false;
// //   bool _isExpanded = false;

// //   void _showSnackBar(BuildContext context, String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(
// //           message,
// //           style: const TextStyle(color: Colors.white),
// //         ),
// //         backgroundColor: Colors.black,
// //         behavior: SnackBarBehavior.floating,
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(10),
// //         ),
// //       ),
// //     );
// //   }

// //   Future<void> _login(BuildContext context) async {
// //     final String email = _emailController.text.trim();
// //     final String password = _passwordController.text;

// //     if (email.isEmpty || password.isEmpty) {
// //       _showSnackBar(context, 'Email and password cannot be empty.');
// //       return;
// //     }

// //     if (!email.endsWith('@gmail.com')) {
// //       _showSnackBar(context, 'Please use a @gmail.com email address.');
// //       return;
// //     }

// //     if (password.length < 6) {
// //       _showSnackBar(context, 'Password must be at least 6 characters long.');
// //       return;
// //     }
// //     try {
// //       setState(() {
// //         _isLoading = true;
// //       });

// //       User? user = await _authService.signInWithEmailAndPassword(
// //         email,
// //         password,
// //       );

// //       if (user != null) {
// //         Navigator.pushReplacement(
// //           context,
// //           MaterialPageRoute(builder: (context) => const HomePage()),
// //         );
// //       }
// //     } catch (e) {
// //       _showSnackBar(context, 'Error signing in: ${e.toString()}');
// //     } finally {
// //       setState(() {
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _emailController.dispose();
// //     _passwordController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: () {
// //         setState(() {
// //           _isExpanded = !_isExpanded;
// //         });
// //       },
// //       child: AnimatedContainer(
// //         duration: const Duration(seconds: 1),
// //         curve: Curves.easeInOut,
// //         padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
// //         decoration: BoxDecoration(
// //           border: Border.all(color: Colors.black),
// //           borderRadius: BorderRadius.circular(_isExpanded ? 30 : 10),
// //           color: _isExpanded ? const Color.fromARGB(76, 72, 47, 1) : Colors.white,
// //         ),
// //         child: Column(
// //           children: [
// //             const Icon(
// //               Icons.person,
// //               size: 80,
// //               color: Colors.black,
// //               weight: 10,
// //             ),
// //             Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 TextField(
// //                   controller: _emailController,
// //                   decoration: const InputDecoration(labelText: 'Email'),
// //                   keyboardType: TextInputType.emailAddress,
// //                 )
// //               ],
// //             ),
// //             const SizedBox(
// //               height: 10,
// //             ),
// //             TextField(
// //               controller: _passwordController,
// //               decoration: const InputDecoration(labelText: 'Password'),
// //               obscureText: true,
// //             ),
// //             // const ReusablePassTextField(),
// //             const Padding(
// //               padding: EdgeInsets.fromLTRB(178, 10, 0, 10),
// //               child: ForgetPassword(),
// //             ),
// //             if (_isLoading)
// //               const CircularProgressIndicator()
// //             else
// //               SizedBox(
// //                 width: 380,
// //                 height: 40,
// //                 child: ElevatedButton(
// //                   style: ButtonStyle(
// //                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
// //                       RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.zero,
// //                       ),
// //                     ),
// //                     backgroundColor: const MaterialStatePropertyAll(
// //                       Color.fromARGB(255, 8, 5, 48),
// //                     ),
// //                     mouseCursor: MaterialStatePropertyAll(
// //                       SystemMouseCursors.click,
// //                     ),
// //                   ),
// //                   onPressed: () => _login(context),
// //                   child: const Text(
// //                     "Login",
// //                     style: TextStyle(
// //                       color: Colors.white,
// //                       fontSize: 20,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'dart:io';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart'; // Import Lottie package
// import 'package:ssgi/Service/auth_service.dart';
// import 'package:ssgi/homePage/home_page.dart';
// import 'package:ssgi/welcomepages/forgetPasswordPage/forget_password.dart';

// class Loginpage extends StatefulWidget {
//   const Loginpage({super.key});

//   @override
//   State<Loginpage> createState() => _LoginpageState();
// }

// class _LoginpageState extends State<Loginpage> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final AuthService _authService = AuthService();

//   bool _isLoading = false;
//   bool _isExpanded = false;

//   void _showSnackBar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: const TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.black,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//     );
//   }
// Future<bool> _checkNetworkConnection() async {
//   try {
//     // This is just a mockup, replace with actual network status check
//     final result = await InternetAddress.lookup('google.com');
//     return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//   } catch (_) {
//     return false;
//   }
// }
//   Future<void> _login(BuildContext context) async {
//     final String email = _emailController.text.trim();
//     final String password = _passwordController.text;

//     if (email.isEmpty || password.isEmpty) {
//       _showSnackBar(context, 'Email and password cannot be empty.');
//       return;
//     }

//     if (!email.endsWith('@gmail.com')) {
//       _showSnackBar(context, 'Please use a @gmail.com email address.');
//       return;
//     }

//     if (password.length < 6) {
//       _showSnackBar(context, 'Password must be at least 6 characters long.');
//       return;
//     }
//     final bool isNetworkAvailable = await _checkNetworkConnection();
//     if (!isNetworkAvailable) {
//       _showSnackBar(context, 'Network connection failed. Please check your internet.');
//       return;
//     }
//     try {
//       setState(() {
//         _isLoading = true;
//       });

//       User? user =
//           await _authService.signInWithEmailAndPassword(email, password);

//       if (user != null) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const HomePage()),
//         );
//       }
//     } catch (e) {
//       _showSnackBar(context, 'Error signing in: ${e.toString()}');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _isExpanded = !_isExpanded;
//         });
//       },
//       child: AnimatedContainer(
//         duration: const Duration(seconds: 1),
//         curve: Curves.easeInOut,
//         padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.black),
//           borderRadius: BorderRadius.circular(_isExpanded ? 30 : 10),
//           color:
//               _isExpanded ? const Color.fromARGB(76, 72, 47, 1) : Colors.white,
//         ),
//         child: Column(
//           children: [
//             const Icon(
//               Icons.person,
//               size: 80,
//               color: Colors.black,
//               weight: 10,
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TextField(
//                   controller: _emailController,
//                   decoration: const InputDecoration(labelText: 'Email'),
//                   keyboardType: TextInputType.emailAddress,
//                 )
//               ],
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _passwordController,
//               decoration: const InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             const Padding(
//               padding: EdgeInsets.fromLTRB(178, 10, 0, 10),
//               child: ForgetPassword(),
//             ),
//             if (_isLoading)
//               Lottie.asset(
//                 'assets/images/loadingAnimation.json',
//                 width: 100,
//                 height: 100,
//                 fit: BoxFit.cover,
//               )
//             else
//               SizedBox(
//                 width: 380,
//                 height: 40,
//                 child: ElevatedButton(
//                   style: ButtonStyle(
//                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                       RoundedRectangleBorder(
//                         borderRadius: BorderRadius.zero,
//                       ),
//                     ),
//                     backgroundColor: const MaterialStatePropertyAll(
//                       Color.fromARGB(255, 8, 5, 48),
//                     ),
//                     mouseCursor: MaterialStatePropertyAll(
//                       SystemMouseCursors.click,
//                     ),
//                   ),
//                   onPressed: () => _login(context),
//                   child: const Text(
//                     "Login",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package
import 'package:shared_preferences/shared_preferences.dart'; // Add SharedPreferences
import 'package:ssgi/Service/auth_service.dart';
import 'package:ssgi/homePage/home_page.dart';
import 'package:ssgi/welcomepages/forgetPasswordPage/forget_password.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isExpanded = false;
  bool _rememberMe = false; // Add Remember Me state

  @override
  void initState() {
    super.initState();
    _loadSavedEmail(); // Load saved email when initializing the screen
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
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

  Future<void> _loadSavedEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('saved_email');
    if (savedEmail != null) {
      setState(() {
        _emailController.text = savedEmail;
        _rememberMe = true; // Mark the checkbox as checked if email is saved
      });
    }
  }

  Future<void> _saveEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_email', email);
    } else {
      await prefs
          .remove('saved_email'); // Remove email if Remember Me is unchecked
    }
  }

  Future<void> _login(BuildContext context) async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar(context, 'Email and password cannot be empty.');
      return;
    }

    if (!email.endsWith('@gmail.com')) {
      _showSnackBar(context, 'Please use a @gmail.com email address.');
      return;
    }

    if (password.length < 6) {
      _showSnackBar(context, 'Password must be at least 6 characters long.');
      return;
    }

    final bool isNetworkAvailable = await _checkNetworkConnection();
    if (!isNetworkAvailable) {
      _showSnackBar(
          context, 'Network connection failed. Please check your internet.');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      User? user =
          await _authService.signInWithEmailAndPassword(email, password);

      if (user != null) {
        await _saveEmail(email); // Save the email if "Remember Me" is checked
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      _showSnackBar(context, 'Error signing in: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _checkNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(_isExpanded ? 30 : 10),
          color:
              _isExpanded ? const Color.fromARGB(76, 72, 47, 1) : Colors.white,
        ),
        child: Column(
          children: [
            const Icon(
              Icons.person,
              size: 80,
              color: Colors.black,
              weight: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 10, 0, 10),
              child: Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (bool? value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                  ),
                  const Text('Remember me'),
                  const SizedBox(
                    width: 60,
                  ),
                  const ForgetPassword(),
                ],
              ),
            ),
            if (_isLoading)
              Lottie.asset(
                'assets/images/loadingAnimation.json',
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
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    backgroundColor: const WidgetStatePropertyAll(
                      Color.fromARGB(255, 8, 5, 48),
                    ),
                    mouseCursor: const WidgetStatePropertyAll(
                      SystemMouseCursors.click,
                    ),
                  ),
                  onPressed: () => _login(context),
                  child: const Text(
                    "Login",
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
    );
  }
}
