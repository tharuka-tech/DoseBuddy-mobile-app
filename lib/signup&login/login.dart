import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/home.dart';
import 'forgot.dart';
import 'register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  
  Future<String?> fetchUserRole(String uid) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      return userDoc['role'] as String?;
    }
    return null;
  }

signIn() async {
  if (email.text.isEmpty || password.text.isEmpty) {
    Get.snackbar('Error', 'Email and password cannot be empty');
    return;
  }
  
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.text, 
      password: password.text,
    );

    // Get the current user UID
    String uid = FirebaseAuth.instance.currentUser!.uid;

    // Fetch the user role from Firestore
    String? role = await fetchUserRole(uid);

    // Navigate based on the user's role
    if (role == 'caregiver') {
      Get.offAll(() => const Home());
    } else if (role == 'carereceiver') {
      Get.offAll(() => const Home());
    } else {
      Get.snackbar('Error', 'User role is not recognized');
    }
  } catch (e) {
    Get.snackbar('Login Failed', e.toString());
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color.fromRGBO(250, 215, 160, 1),  // Clean white background
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView( // To allow scrolling if keyboard is visible
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10.0),
              // Logo
              Image.asset(
                'asset/logo.png', // Replace with your logo asset
                height: 150,
              ),
             
              // Heading Text
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 30.0),
             Container(
                margin: const EdgeInsets.all(16.0), // Adds margin around the container
                padding: const EdgeInsets.all(16.0),

              child:Column(
               children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                      child:  Text(
                      'Login to your account',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Color.fromARGB(255, 73, 70, 68),
                      ),
                    ),
                  ),
              

                  const SizedBox(height: 10.0),
                  
                  // Username field with modern design
                  TextFormField(
                    controller: email,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  
                  // Password field with modern design
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
                        borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    ),
                  ),
                
                  const SizedBox(height: 30.0),
                  
                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                       Get.to(() => const Forgot(),
                        transition: Transition.downToUp,
                        duration: const Duration(microseconds: 500),
                       );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.deepOrange),
                      ),
                    ),
                  ),
                                
                const SizedBox(height: 30.0),
              
              // Login Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Background color
                  minimumSize: const Size(double.infinity, 50.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {
                   signIn();
                },
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 18),
                ),
              ),
                  ]  ,  
                )
              ),


              
              const SizedBox(height: 20.0),
              
              // Register Section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Are you new?'),
                  TextButton(
                    onPressed: () {
                      Get.to(() =>  const RegisterScreen(),
                      transition: Transition.downToUp, // Specify the transition type
                      duration: const Duration(milliseconds: 500), // Set the duration
                      );
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(color: Colors.deepOrange),
                    ),
                  ),
                  
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
