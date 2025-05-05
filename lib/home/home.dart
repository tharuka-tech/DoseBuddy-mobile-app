import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mydose/home/caregiverr/caremenu.dart';
import 'package:mydose/home/profile/profile.dart';
import 'package:mydose/home/sleep/sleeping.dart';


import '../bmi/bmi_cal.dart';
import 'medicine/add_medice.dart';
import 'medicine/view.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Home extends StatefulWidget {


  // Modify the constructor to accept the role as a parameter
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String medicationName = "";
  String dosage = "";
  String type = "";
  String perDay = "";

  @override
  void initState() {
    super.initState();
    fetchMedication();
  }

  Future<void> fetchMedication() async {
    User? user = FirebaseAuth.instance.currentUser; // Get current user
    if (user == null) {
      print("No user logged in.");
      return;
    }

    print("User ID: ${user.uid}"); // Debugging

    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await db
          .collection("medications")
          .where("uid", isEqualTo: user.uid) // Use authenticated user's UID
          .get();

      print("Query result count: ${querySnapshot.docs.length}");

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data() as Map<String, dynamic>;

        print("Fetched Data: $data"); // Debugging

        setState(() {
          medicationName = data["medicine_name"] ?? "Unknown";
          dosage = data["medicine_amount"] ?? "Unknown";
          type = data["taken_type"] ?? "Unknown";
          perDay = data["medicine_type"] ?? "Unknown";
        });

        print("Updated State: $medicationName, $dosage, $type, $perDay"); // Debugging
      } else {
        print("No medication records found for this user.");
      }
    } catch (e) {
      print("Error fetching medication: $e");
    }
  }





  /// **Fetch medicine log data, retrieve medication names, and generate a PDF report**
  static Future<void> generateMedicineLogReport() async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      print("User is not authenticated.");
      return;
    }

    // Fetch medicine logs for the authenticated user
    QuerySnapshot<Map<String, dynamic>> logSnapshot = await FirebaseFirestore.instance
        .collection('medicine_logs')
        .where('uid', isEqualTo: uid)
        .get();

    if (logSnapshot.docs.isEmpty) {
      print("No medicine log found for this user.");
      return;
    }

    // Prepare a list to store log entries with medication names
    List<Map<String, dynamic>> medicineLogEntries = [];

    for (var doc in logSnapshot.docs) {
      Map<String, dynamic> logData = doc.data();

      // Ensure notificationId is treated as a String
      String notificationId = logData['notificationId'].toString();

      // Fetch the medication name where id1 matches notificationId
      QuerySnapshot<Map<String, dynamic>> medSnapshot = await FirebaseFirestore.instance
          .collection('medications')
          .where('id1', isEqualTo: notificationId) // Ensure id1 is stored as String in Firestore
          .get();

      String medicationName = 'Unknown';
      if (medSnapshot.docs.isNotEmpty) {
        medicationName = medSnapshot.docs.first['medication_name'] ?? 'Unknown';
      }

      // Add log data with medication name to the list
      medicineLogEntries.add({
        'medicationName': medicationName,
        'notificationId': notificationId,
        'status': logData['status'],
        'timestamp': (logData['timestamp'] as Timestamp).toDate(),
      });
    }

    // Create the PDF document
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Medicine Schedule Report', style: pw.TextStyle(fontSize: 30)),
                pw.SizedBox(height: 20),
                pw.Text('User ID: $uid', style: pw.TextStyle(fontSize: 18)),
                pw.SizedBox(height: 10),
                pw.Text('Log Entries:', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),

                // Iterate over all fetched medicine logs and display them
                ...medicineLogEntries.map((entry) {
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Medication Name: ${entry['medicationName']}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Notification ID: ${entry['notificationId']}', style: pw.TextStyle(fontSize: 18)),
                      pw.Text('Status: ${entry['status']}', style: pw.TextStyle(fontSize: 18)),
                      pw.Text('Time: ${entry['timestamp']}', style: pw.TextStyle(fontSize: 18)),
                      pw.Divider(), // Adds a line separator between logs
                      pw.SizedBox(height: 10),
                    ],
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );

    // Print or save the PDF
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 215, 160, 1),
      body: SingleChildScrollView(

       child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              'asset/logo.png',
              height: 150,
            ),
          ),
          
          // Today's Activity Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Today\'s Activities',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            color: const Color.fromARGB(184, 249, 213, 135),
            elevation: 4.0,
            child: ListTile(
              leading: Image.asset(
                'asset/capsule.png',
                height: 250,
                width: 80,
              ),
              title: Text(
                medicationName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$perDay, $dosage'),
                  Divider(),
                  Text(
                    type,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 24, 27, 28),
                    ),
                  ),
                ],
              ),
              ),
            ),


          // Wellness Tools Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Wellness Tools',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
          ),
          
          // Grid view for wellness tools
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.0,
              children: [
                
                wellnessToolButton(
                  imagePath: 'asset/bmi.png',
                  label: 'Track Your Fitness',
                  onTap: () {
                    Get.to(
                      ()=>const BmiCal(),
                      transition: Transition.downToUp,
                      duration: const Duration(microseconds: 500)
                    );
                  },
                ),
                wellnessToolButton(
                  imagePath: 'asset/sleep.png',
                  label: 'Nighttime Wellness',
                  onTap: () {
                    Get.to(
                      ()=>const Sleeping(),
                      transition: Transition.downToUp,
                      duration: const Duration(microseconds: 500)
                    );
                  },
                ),


              ],
            ),

          ),


          const SizedBox(height: 30),

          Center(
            child:
            ElevatedButton(
              onPressed: () =>generateMedicineLogReport(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(184, 249, 213, 135),
                padding:
                const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Medicine Report',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

        ],
      ),
      ),

      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 214, 155, 65),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 255, 149, 0),
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

  // Wellness Tool Button Widget
  Widget wellnessToolButton({required String imagePath, required String label, required Function onTap}) {
    return InkWell(
      onTap: () => onTap(),
      child: Card(
        color: const Color.fromARGB(184, 249, 213, 135),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                imagePath,
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
