import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../request/caregiver.dart';
import '../../request/patient.dart';
import '../../signup&login/login.dart';
import '../caregiverr/caremenu.dart';
import '../home.dart';
import '../medicine/add_medice.dart';
import '../medicine/view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  String? email;
  String? role;
  String? name = 'N/A';
  String? phone = 'N/A';
  String? age = 'N/A';
  String? gender = 'N/A';

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch data from both collections
  }

  Future<void> fetchUserData() async {
    if (uid.isEmpty) return;

    try {
      // Fetch data from 'users' collection
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        setState(() {
          role = userDoc.data()?['role'] ?? 'N/A';
          email = userDoc.data()?['email'] ?? 'N/A';
        });
      }

      // Fetch data from 'userinfo' collection
      final userInfoDoc = await FirebaseFirestore.instance.collection('userinfo').doc(uid).get();
      if (userInfoDoc.exists) {
        setState(() {
          name = userInfoDoc.data()?['name'] ?? 'N/A';
          phone = userInfoDoc.data()?['phone'] ?? 'N/A';
          age = userInfoDoc.data()?['age'] ?? 'N/A';
          gender = userInfoDoc.data()?['gender'] ?? 'N/A';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 215, 160, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(250, 215, 160, 1),
        leading: const BackButton(),
        title: Text(
          'Welcome, ${role ?? 'User'} Profile',
          style: const TextStyle(color: Color.fromARGB(255, 220, 134, 35)),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color.fromARGB(255, 230, 47, 166),
                child: Text(
                  name?.substring(0, 1).toUpperCase() ?? '',
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),

              // Name
              Text(
                name ?? 'N/A',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Role
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 240, 181, 63),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  role ?? 'N/A',
                  style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 255, 255, 255)),
                ),
              ),
              const SizedBox(height: 20),



            if (role != 'carereceiver') ...[
              // Details
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.email, color:  Color.fromARGB(255, 230, 47, 166),),
                  title: Text('Email: ${email ?? 'N/A'}'),
                ),
              ),
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.phone, color:  Color.fromARGB(255, 230, 47, 166),),
                  title: Text('Phone: ${phone ?? 'N/A'}'),
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  Get.to(() =>  const CaregiverScreen(),
                    transition: Transition.rightToLeft, // Specify the transition type
                    duration: const Duration(milliseconds: 500), // Set the duration
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Button color
                  minimumSize: const Size(300, 50), // Button size
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25), // Rounded corners
                  ),
                ),
                child: const Text(
                  "Send Request",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 30),
            ],



              if (role != 'caregiver') ...[
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.email, color:  Color.fromARGB(255, 230, 47, 166),),
                    title: Text('Email: ${email ?? 'N/A'}'),
                  ),
                ),
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.phone, color:  Color.fromARGB(255, 230, 47, 166),),
                    title: Text('Phone: ${phone ?? 'N/A'}'),
                  ),
                ),



                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.cake, color:  Color.fromARGB(255, 230, 47, 166),),
                    title: Text('Age: ${age ?? 'N/A'}'),
                  ),
                ),
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.person, color:  Color.fromARGB(255, 230, 47, 166),),
                    title: Text('Gender: ${gender ?? 'N/A'}'),
                  ),
                ),


                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(
                      Icons.lock,
                      color: Color.fromARGB(255, 230, 47, 166),
                    ),
                    title: SelectableText(
                      'Patient Id: ${uid ?? 'N/A'}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () {
                    Get.to(() =>  const PatientScreen(),
                      transition: Transition.rightToLeft, // Specify the transition type
                      duration: const Duration(milliseconds: 500), // Set the duration
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // Button color
                    minimumSize: const Size(300, 50), // Button size
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25), // Rounded corners
                    ),
                  ),
                  child: const Text(
                    "Approve Request",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),


              ],
              const SizedBox(height: 30),  

            ],
          ),
        ),
      ),
      
      
      // Sign-out button
      floatingActionButton: FloatingActionButton(
        onPressed: signout,
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.logout_rounded),
      ),


       
       bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 214, 155, 65),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              decoration: const BoxDecoration(
                
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.home_rounded),
                hoverColor: const Color.fromARGB(255, 243, 181, 110),
                highlightColor: const Color.fromARGB(255, 242, 71, 20),
                onPressed: () {
                  Get.to(
                    () => const Home(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 500),
                     );
                },
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.medication_rounded),
                hoverColor: const Color.fromARGB(255, 243, 181, 110),
                highlightColor: const Color.fromARGB(255, 242, 71, 20),
                onPressed: () {
                  Get.to(
                    () => const MedicationManagerPage(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 500),
                     );
                },
              ),
            ),
            Transform.scale(
              scale: 2.0,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.add_alert_rounded),
                  hoverColor: const Color.fromARGB(255, 243, 181, 110),
                  highlightColor: const Color.fromARGB(255, 242, 71, 20),
                  onPressed: () {
                     Get.to(
                    () => const MedicineSchedule(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 500),
                     );
                    
                  },
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.emergency),
                hoverColor: const Color.fromARGB(255, 243, 181, 110),
                highlightColor: const Color.fromARGB(255, 242, 71, 20),
                onPressed: () {
                  Get.to(
                        () => const CareMenuScreen(),
                    transition: Transition.leftToRight,
                    duration: const Duration(milliseconds: 500),
                  );
                },
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 255, 149, 0),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.person_rounded),
                hoverColor: const Color.fromARGB(255, 243, 181, 110),
                highlightColor: const Color.fromARGB(255, 242, 71, 20),
                onPressed: () {
                  Get.to(
                    () => const ProfileScreen(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 500),

                  );
                },
              ),
            ),
          ],
        ),
      ),

    );
  }

  void signout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAll(const LoginScreen());
  }
}
