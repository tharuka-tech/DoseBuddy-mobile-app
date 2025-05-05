import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:mydose/home/caregiverr/careedit.dart';
import '../home.dart';
import '../medicine/add_medice.dart';
import '../medicine/view.dart';
import '../profile/profile.dart';

class CareViewScreen extends StatefulWidget {
  final String patientId;
  const CareViewScreen({super.key,required this.patientId});

  @override
  State<CareViewScreen> createState() => _CareViewScreenState();
}

class _CareViewScreenState extends State<CareViewScreen> {

  String? currentUid;

  @override
  void initState() {
    super.initState();
    currentUid = FirebaseAuth.instance.currentUser?.uid; // Fetch current user's UID
  }

// Function to delete medication with confirmation
  Future<void> deleteMedication(String id) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel deletion
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirm deletion
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await FirebaseFirestore.instance.collection('medications').doc(id).delete();
        showSnackbar('Medication deleted successfully!', Colors.red);
      } catch (e) {
        showSnackbar('Failed to delete medication: $e', Colors.red);
      }
    }
  }

// Function to show a Snackbar with a message
  void showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 215, 160, 1),
      appBar: AppBar(
        title: const Text(''),
        leading: const BackButton(),
        backgroundColor: const Color.fromRGBO(250, 215, 160, 1),
      ),
      body: SingleChildScrollView(  // Wrapping the body in SingleChildScrollView
        child: Column(
          children: [
            Center(
              child: Image.asset(
                'asset/logo.png',
                height: 150,
              ),
            ),
            currentUid == null
                ? const Center(child: Text('User not logged in.'))
                : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('medications')
                  .where('uid', isEqualTo: widget.patientId) // Filter by UID
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong!'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data?.docs ?? [];
                if (data.isEmpty) {
                  return const Center(child: Text('No medications found for this user.'));
                }

                return ListView.builder(
                  shrinkWrap: true, // Ensures the ListView doesn't take infinite space
                  physics: const NeverScrollableScrollPhysics(),  // Disables scrolling on ListView
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final medication = data[index];
                    final medicationData = medication.data() as Map<String, dynamic>;

                    return Card(
                      color: const Color.fromARGB(255, 254, 187, 100),
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: ListTile(
                        title: Text(
                          medicationData['medicine_name'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Type: ${medicationData['medicine_type'] ?? 'Unknown'}, '
                              'Amount: ${medicationData['medicine_amount'] ?? 'Unknown'}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Get.to(() => CareEditScreen(
                                  medicationId: medication.id,
                                  initialData: medicationData,
                                ));
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteMedication(medication.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(const MedicineSchedule());
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
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
                color: Color.fromARGB(255, 255, 149, 0),
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
                icon: const Icon(Icons.search_rounded),
                hoverColor: const Color.fromARGB(255, 243, 181, 110),
                highlightColor: const Color.fromARGB(255, 242, 71, 20),
                onPressed: () {
                  /* Get.to(
                    () => const MapScreen(),
                    transition: Transition.leftToRight,
                    duration: const Duration(milliseconds: 500),
                  );*/
                },
              ),
            ),
            Container(
              decoration: const BoxDecoration(
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
}
