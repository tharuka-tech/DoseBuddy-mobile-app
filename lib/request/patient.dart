import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mydose/request/request_list.dart';
import 'package:mydose/request/service.dart';

class PatientScreen extends StatefulWidget {
  const PatientScreen({super.key});

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {

  final RequestService _requestService = RequestService();
  String patientId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Patient Panel")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _requestService.getPendingRequests(patientId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return RequestList(
            requests: snapshot.data!.docs,
            onUpdateStatus: (requestId, status) {
              _requestService.updateRequestStatus(requestId, status);
            },
          );
        },
      ),
    );
  }
}
