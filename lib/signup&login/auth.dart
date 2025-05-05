import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mydose/signup&login/verify.dart';

import '../home/profile/profileinfo.dart';
import 'login.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print (snapshot.data);

            if (snapshot.data!.emailVerified) {
              // Redirect directly to ProfileInfoScreen after email verification
              return const ProfileInfo();
            } else {
              // Show verify page if email is not verified
              return const Verify();
            }
          } else {
            // Show login screen if user is not logged in
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
