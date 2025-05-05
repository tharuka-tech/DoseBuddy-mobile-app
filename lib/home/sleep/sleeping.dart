import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Sleeping extends StatefulWidget {
  const Sleeping({super.key});

  @override
  State<Sleeping> createState() => _SleepingState();
}

class _SleepingState extends State<Sleeping> {
  TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 30);
  bool isLoggedIn = false; // Login state
  String userSchedule = ''; // Initialize userSchedule with an empty string
  final String userId = "2"; // Replace with actual user ID logic

  // Function to pick time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  // Function to save sleep schedule to Firestore
  Future<void> _saveSleepSchedule() async {
    try {
      CollectionReference sleepSchedules =
      FirebaseFirestore.instance.collection('sleepSchedules');

      await sleepSchedules.add({
        'last_logged_in': FieldValue.serverTimestamp(),
        'hour': selectedTime.hour,
        'minute': selectedTime.minute,
        'created_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sleep schedule saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save sleep schedule: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Function to simulate user login and display last schedule and current time
  void _login() async {
    setState(() {
      isLoggedIn = true;
    });

    try {
      // Get the current time
      final now = DateTime.now();
      final currentTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      // Update the state with current time
      setState(() {
        userSchedule = 'Last Schedule: $currentTime';
      });

      // Save the last login time
      await _saveLastLoginForUser(userId);
    } catch (error) {
      setState(() {
        userSchedule = 'Failed to fetch or save last login time: $error';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch or save last login time: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Function to save the last login time for a user
  Future<void> _saveLastLoginForUser(String userId) async {
    try {
      DocumentReference userDoc =
      FirebaseFirestore.instance.collection('users').doc(userId);

      await userDoc.set({
        'last_logged_in': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Merge updates with existing data

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Last login time saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save last login time: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Function to log out
  void _logout() {
    setState(() {
      isLoggedIn = false;
      userSchedule = ''; // Reset user schedule
    });
  }

  // Function to generate PDF
  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    // Manually format the time string
    String formattedTime = "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Sleep Schedule', style: pw.TextStyle(fontSize: 30)),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Time: $formattedTime',
                  style: pw.TextStyle(fontSize: 20),
                ),
                pw.SizedBox(height: 20),
                pw.Text('User ID: $userId', style: pw.TextStyle(fontSize: 18)),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color.fromRGBO(250, 215, 160, 1), // Light orange background
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(250, 215, 160, 1),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [


              const Text(
                'New Sleep Schedule',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              Center(
                child: Lottie.asset(
                  "asset/sleep.json", // Replace with your Lottie file
                  height: 250,
                  width: 350,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Set Your Sleep Goal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'With a goal we recommend you set optimal bed time and wake up alarm',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(137, 7, 7, 7),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        selectedTime.hour.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Text(
                        'Hours',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    children: [
                      Text(
                        selectedTime.minute.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Text(
                        'Minutes',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  _selectTime(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA500),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '+ Set Sleep Schedule',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveSleepSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save Schedule',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoggedIn ? _logout : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  isLoggedIn ? Colors.red : Colors.blue, // Different colors
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isLoggedIn ? 'Logout' : 'Login',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _generatePDF,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Generate PDF',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (userSchedule.isNotEmpty)
                Text(
                  userSchedule,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
