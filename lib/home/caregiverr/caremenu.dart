import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:mydose/home/caregiverr/careaddmedi.dart';
import 'package:mydose/home/caregiverr/careview.dart';

class CareMenuScreen extends StatefulWidget {
  const CareMenuScreen({super.key});

  @override
  State<CareMenuScreen> createState() => _CareMenuScreenState();
}

class _CareMenuScreenState extends State<CareMenuScreen> {
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  String? email;
  String? role;
  String? caregiverId;
  String? patientId;
  final TextEditingController reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
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

    } catch (e) {
      print('Error fetching user data: $e');
    }
  }






  Future<String?> checkCaregiverStatus() async {
    final requestDoc = await FirebaseFirestore.instance
        .collection('requests')
        .where('caregiverId', isEqualTo: uid)
        .where('status', isEqualTo: 'approved')
        .get();

    if (requestDoc.docs.isNotEmpty) {
      patientId = requestDoc.docs.first['patientId'].toString();
      print('Patient ID: $patientId');
    } else {
      print('No approved caregiver found for this patient.');
    }


    return requestDoc.docs.isNotEmpty ? 'approved' : null;
  }






  Future<void> sendDeleteRequest() async {
    try {
      final deleteDoc = await FirebaseFirestore.instance
          .collection('requests')
          .where('patientId', isEqualTo: uid)
          .where('status', isEqualTo: 'approved')
          .get();

      if (deleteDoc.docs.isNotEmpty) {
        caregiverId = deleteDoc.docs.first['caregiverId'].toString();
        print('Caregiver ID: $caregiverId');
      } else {
        print('No approved caregiver found for this patient.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You do not have an assigned caregiver to delete.')),
        );
        return;
      }

      // Validate caregiverId and reason
      if (reasonController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please provide a reason.')),
        );
        return;
      }

      // Send delete request to Firestore
      await FirebaseFirestore.instance.collection('delete_requests').add({
        'patientId': uid,
        'caregiverId': caregiverId,
        'patient_email': email,
        'reason': reasonController.text.trim(),
        'status': 'pending',
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delete request sent to admin.')),
      );

      reasonController.clear();
    } catch (e) {
      print('Error sending delete request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send delete request.')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 215, 160, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(250, 215, 160, 1),
        leading: const BackButton(),
        title: const Text(
          'Welcome, to CareMenu',
        ),
      ),
      body: Center(
        child: Column(
          children: [

            if(role == 'caregiver') ...[
              FutureBuilder<String?>(
                future: checkCaregiverStatus(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.data == 'approved') {
                    return Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                          Get.to(() =>  CareAddScreen(patientId: patientId!),
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
                            "Add Medicine for Care Receiver",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),



                        ElevatedButton(
                          onPressed: () {
                            Get.to(() =>  CareViewScreen(patientId: patientId!),
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
                            "View Caregiver Medic",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),


                  const Text("Hi care giver bro"),

                      ],
                    );


                  }
                  if (snapshot.data == 'pending') {
                    return const Text("Your request is pending.");
                  }
                  return const Text("Please Send Patient Request First...");
                },
              ),


            ],
          if(role=='carereceiver')...[
            // Caregiver ID Display
            if (caregiverId != null)
              Text("Assigned Caregiver ID: $caregiverId",
                  style: const TextStyle(fontSize: 16, color: Colors.black54)),

            const SizedBox(height: 10),

            // Reason Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Reason for Deleting Caregiver",
                ),
                maxLines: 3,
              ),
            ),

            const SizedBox(height: 10),

            // Submit Button
            ElevatedButton(
              onPressed: sendDeleteRequest,
              child: const Text("Send Delete Request"),
            ),
          ]
        ]

        ),
      ),
    );
  }
}
