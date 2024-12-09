// import 'package:flutter/material.dart';
// import 'package:ssgi/reusableWidgets/reusable_widget.dart';

// class ForgetPassword extends StatefulWidget {
//   const ForgetPassword({super.key});

//   @override
//   State<ForgetPassword> createState() => _ForgetPasswordState();
// }

// class _ForgetPasswordState extends State<ForgetPassword> {
//   final TextEditingController _emailcontroller = TextEditingController();
//   bool _isloading = false;

//   void _forgetpassword() {
//     setState(() {
//       _isloading = true;
//     });

//     Future.delayed(const Duration(seconds: 2), () {
//       setState(() {
//         _isloading = false;
//       });
//       if (_emailcontroller.text.isEmpty ||
//           !RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$')
//               .hasMatch(_emailcontroller.text)) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//               'Please Enter Your Email. Email must include @gmail.com',
//               style: TextStyle(
//                 color: Colors.white,
//               ),
//             ),
//             backgroundColor: Colors.black,
//           ),
//         );
//       } else {
        
//         showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//                 shadowColor: Colors.black,
//                 content: SingleChildScrollView(
//                     child: Column(
//                   children: [
//                     const SizedBox(
//                       height: 30,
//                     ),
//                     const Text(
//                       'You will receive reset password soon.',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     IconButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                         icon: const Icon(Icons.cancel_outlined))
//                   ],
//                 )))).then((value) {
//           Navigator.pop(context);
//         });
//         // Proceed with login
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       style: const ButtonStyle(
//         backgroundColor: WidgetStateColor.transparent,
//         shadowColor: WidgetStateColor.transparent,
//         mouseCursor: WidgetStateMouseCursor.clickable,
//       ),
//       onPressed: () {
//         showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//                 shadowColor: Colors.black,
//                 content: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 10),
//                       const Text(
//                         "Enter your email address",
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 18),
//                       reusableTextFormField("Email Address", Icons.mail_outline,
//                           false, _emailcontroller),
//                       const SizedBox(height: 15),
//                       ElevatedButton(
//                         style: const ButtonStyle(
//                           shape: WidgetStatePropertyAll(RoundedRectangleBorder(
//                               borderRadius: BorderRadius.all(Radius.zero))),
//                           backgroundColor: WidgetStatePropertyAll(Colors.black),
//                           mouseCursor: WidgetStateMouseCursor.clickable,
//                         ),
//                         onPressed: _forgetpassword,
//                         child: _isloading
//                             ? const CircularProgressIndicator(
//                                 color: Colors.white,
//                               )
//                             : const Text(
//                                 "Send Reset Link",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                       ),
//                     ],
//                   ),
//                 )));
//       },
//       child: const Text("Forget Password?",
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 15,
//             fontWeight: FontWeight.bold,
//           )),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ssgi/reusableWidgets/reusable_widget.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController _emailcontroller = TextEditingController();
  bool _isloading = false;

  // Function to send a password reset email
  Future<void> _resetPassword() async {
    setState(() {
      _isloading = true;
    });

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailcontroller.text);
      
      // Show a success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shadowColor: Colors.black,
          content: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Text(
                  'You will receive a reset password link soon.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.cancel_outlined),
                ),
              ],
            ),
          ),
        ),
      ).then((_) {
        Navigator.pop(context); // Close the dialog
      });
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'An error occurred. Please try again.',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isloading = false;
      });
    }
  }

  void _forgetpassword() {
    if (_emailcontroller.text.isEmpty ||
        !RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$')
            .hasMatch(_emailcontroller.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please Enter a valid email. Email must include @gmail.com',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.black,
        ),
      );
    } else {
      _resetPassword(); // Call the reset password function
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: const ButtonStyle(
        backgroundColor: WidgetStateColor.transparent,
        shadowColor: WidgetStateColor.transparent,
        mouseCursor: WidgetStateMouseCursor.clickable,
      ),
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                shadowColor: Colors.black,
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "Enter your email address",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      reusableTextFormField("Email Address", Icons.mail_outline,
                          false, _emailcontroller),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        style: const ButtonStyle(
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.zero))),
                          backgroundColor: WidgetStatePropertyAll(Colors.black),
                          mouseCursor: WidgetStateMouseCursor.clickable,
                        ),
                        onPressed: _forgetpassword,
                        child: _isloading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Send Reset Link",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                )));
      },
      child: const Text("Forget Password?",
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          )),
    );
  }
}
