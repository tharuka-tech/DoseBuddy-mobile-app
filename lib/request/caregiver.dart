import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mydose/request/service.dart';

class CaregiverScreen extends StatefulWidget {
  const CaregiverScreen({super.key});

  @override
  State<CaregiverScreen> createState() => _CaregiverScreenState();
}

class _CaregiverScreenState extends State<CaregiverScreen> {
  final TextEditingController _patientIdController = TextEditingController();
  final RequestService _requestService = RequestService();
  String _statusMessage = "";
  // Get the current user UID
  String caregiverId = FirebaseAuth.instance.currentUser!.uid;

  void _sendRequest() async {
    String patientId = _patientIdController.text.trim();
    if (patientId.isEmpty) {
      setState(() {
        _statusMessage = "Please enter a patient ID!";
      });
      return;
    }

    String result = await _requestService.sendRequest(caregiverId, patientId);
    setState(() {
      _statusMessage = result;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Caregiver Panel")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _patientIdController,
              decoration: const InputDecoration(
                labelText: "Enter Patient ID",
                border: OutlineInputBorder(),
              ),
              enableInteractiveSelection: true, // This ensures the text can be selected for copy/paste
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendRequest,
              child: const Text("Send Request"),
            ),
            const SizedBox(height: 10),
            Text(
              _statusMessage,
              style: TextStyle(color: _statusMessage.contains("Error") ? Colors.red : Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
