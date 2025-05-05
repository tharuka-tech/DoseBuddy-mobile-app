import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? role ;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();


  // Regex for email validation
  final RegExp emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

  // Sign up function
  signup() async {
     
     // Validate Email
    if (!emailRegex.hasMatch(email.text)||email.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("The Email Field is empty or not valid!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate Password (ensure minimum 6 characters)
    if (password.text.length < 6||password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 6 characters long."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select the role!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
  
    try {
      // Creating user with email and password
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text, 
        password: password.text
      );

      // Retrieve the current user's UID
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Saving user info in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'userid': uid,
        'email': email.text,
        'role': role, // Ensure `role` is set in the form
      });

      // Redirect to Auth screen after successful registration
      Get.offAll(const Auth());

      print("User registered successfully!");

    } catch (e) {
      // Displaying error message to the user
      Get.snackbar("Error", "Registration failed: $e", snackPosition: SnackPosition.BOTTOM);
      print("Error during signup: $e");
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 215, 160, 1),
      appBar: AppBar(title: const Text('Register'),backgroundColor:const Color.fromRGBO(250, 215, 160, 1),),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  'asset/logo.png', // Replace with your logo asset
                  height: 150,
                ),
              ),
              const SizedBox(height: 20.0),

              // Welcome Text
              const Text(
                'Welcome to Doesbuddy Family',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                  color: Colors.deepOrange,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20.0),

              // Subtitle
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Register to your account',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Color.fromARGB(255, 73, 70, 68),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),

              // Username Field
              TextFormField(
                controller: email,
                decoration: InputDecoration(
                  labelText: 'Enter Your Email',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.deepOrange, width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                ),
               
              ),
              const SizedBox(height: 20.0),

              
              // Role Selection Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select a Role',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.deepOrange, width: 2),
                  ),
                ),
                
                
                items: const [
                DropdownMenuItem(value: 'carereceiver', child: Text("Care Receiver")),
                DropdownMenuItem(value: 'caregiver', child: Text("Care Giver")),
                ],
              
                onChanged: (String? value) {
                  setState(() {
                    role = value!;
                  });
                },
              ),

            


            const SizedBox(height: 20.0),



            
              // Password Field
              TextFormField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.deepOrange, width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                ),
              ),

              const SizedBox(height: 30.0),

              // Register Button
              ElevatedButton(
                onPressed: () {
                  signup();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 15, horizontal: 80),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
