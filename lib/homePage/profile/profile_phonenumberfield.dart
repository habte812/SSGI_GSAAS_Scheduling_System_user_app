

import 'package:flutter/material.dart';

class ProfilePhoneNOformatfield extends StatefulWidget {
  final TextEditingController
      mobile; // Receive the mobile controller from parent

  const ProfilePhoneNOformatfield({super.key, required this.mobile});

  @override
  State<ProfilePhoneNOformatfield> createState() =>
      _ProfilePhoneNOformatfieldState();
}

class _ProfilePhoneNOformatfieldState extends State<ProfilePhoneNOformatfield> {
  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextFormField(
          controller: widget.mobile, // Use the controller passed from parent
          maxLength: 10,
          validator: (value) {
            if (value == null || value.isEmpty || value.length != 10) {
              return "Please enter a valid mobile number";
            }
            return null;
          },
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Enter your mobile number",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            prefixIcon: const Icon(
              Icons.phone,
              size: 18,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
