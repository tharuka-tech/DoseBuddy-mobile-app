import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../home.dart';

class ProfileInfo extends StatefulWidget {
  const ProfileInfo({super.key});

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  final user = FirebaseAuth.instance.currentUser;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? selectedGender;
  String? role;

  @override
  void initState() {
    super.initState();
    fetchUserRole(user!.uid).then((userRole) {
      setState(() {
        role = userRole;
      });
    });
  }

  // Fetch role from the 'users' collection
  Future<String?> fetchUserRole(String uid) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      return userDoc['role'] as String?;
    }
    return null;
  }



  Future<void> saveProfile() async {
    final ageRegex = RegExp(r'^[1-9][0-9]?$|^100$');
    final phoneRegex = RegExp(r'^(?:\+94|94|0)?[1-9]\d{8}$');
    final nameRegex = RegExp(r"^[A-Za-z]+(?:[ '-][A-Za-z]+)*$");



    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unauthorized User Try Again!"),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }
      
    if (nameController.text.isEmpty|| !nameRegex.hasMatch(nameController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("The Usre Name field is empty or not valid!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (phoneController.text.isEmpty || !phoneRegex.hasMatch(phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The phone number is not valid or field is empty!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }



      // Skip age validation for caregivers
      if (role != 'caregiver') {
        if (ageController.text.isEmpty || !ageRegex.hasMatch(ageController.text)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('The age is not valid or field is empty!'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        const SizedBox(height: 20,);

        if (selectedGender == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please select your gender!"),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }






    // Save profile data to Firestore
    await FirebaseFirestore.instance.collection('userinfo').doc(user!.uid).set({
      'name': nameController.text,
      'age': ageController.text,
      'gender': selectedGender,
      'phone': phoneController.text,
      'profileCompleted': true,
    });

 

    if (role != null) {
      // Navigate to the Home screen and pass the role
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Home(),
        ),
      );
    }
  }

  

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color.fromRGBO(250, 215, 160, 1),title: const Text('Complete Your Profile')),
      backgroundColor: const Color.fromRGBO(250, 215, 160, 1),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(250, 215, 160, 1),
            borderRadius: BorderRadius.circular(20),
         
          ),
          child: Column(
            children: [
                Lottie.asset(
                  "asset/profile.json", // Replace with your Lottie file
                  height: 280,
                  width: 350,
                ),
                  
                  TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'User Name',
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
                  
                  // Age Field (conditionally hidden)
                  if (role != 'caregiver')
                    TextFormField(
                      controller: ageController,
                      decoration: InputDecoration(
                        labelText: 'Age',
                        prefixIcon: const Icon(Icons.cake_rounded),
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

                  TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: const Icon(Icons.phone),
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
              
              
              
                 // Gender Selection (conditionally hidden)
                if (role != 'caregiver') ...[
                  ListTile(
                    title: const Text("Male"),
                    leading: Radio<String>(
                      value: 'Male',
                      groupValue: selectedGender,
                      onChanged: (String? value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text("Female"),
                    leading: Radio<String>(
                      value: 'Female',
                      groupValue: selectedGender,
                      onChanged: (String? value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                    ),
                  ),
                ],

               const SizedBox(height: 20.0),
              

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // Background color
                    minimumSize: const Size(double.infinity, 50.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () {
                    saveProfile();
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
            ],
          ),
        ),
      ),  
    );
  }
}
