import 'package:cloud_firestore/cloud_firestore.dart';

class RequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if patient exists
  Future<bool> patientExists(String patientId) async {
    var snapshot = await _firestore.collection('users').doc(patientId).get();
    return snapshot.exists;
  }

// Send request to specific patient
  Future<String> sendRequest(String caregiverId, String patientId) async {
    bool exists = await patientExists(patientId);
    if (!exists) {
      return "Error: Patient ID not found!";
    }

    await _firestore.collection('requests').doc(patientId).set({
      'caregiverId': caregiverId,
      'patientId': patientId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    return "Request sent successfully!";
  }


  // Get pending requests for a patient
  Stream<QuerySnapshot> getPendingRequests(String patientId) {
    return _firestore
        .collection('requests')
        .where('patientId', isEqualTo: patientId)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  // Approve or Reject Request
  Future<void> updateRequestStatus(String requestId, String newStatus) async {
    await _firestore.collection('requests').doc(requestId).update({'status': newStatus});
  }
}
