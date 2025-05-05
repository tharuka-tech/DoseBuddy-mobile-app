import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestList extends StatelessWidget {
  final List<QueryDocumentSnapshot> requests;
  final Function(String, String) onUpdateStatus;

  RequestList({required this.requests, required this.onUpdateStatus});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        var request = requests[index];
        return ListTile(
          title: Text("Caregiver: ${request['caregiverId']}"),
          subtitle: Text("Status: ${request['status']}"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.check, color: Colors.green),
                onPressed: () {
                  onUpdateStatus(request.id, "approved");
                },
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  onUpdateStatus(request.id, "rejected");
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
