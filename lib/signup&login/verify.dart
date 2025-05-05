import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'auth.dart';

class Verify extends StatefulWidget {
  const Verify({super.key});

  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {

  @override
  void initState() {
    sendverfylink();
    super.initState();
  }

  sendverfylink() async {
    final user = FirebaseAuth.instance.currentUser!;
    await user.sendEmailVerification().then((value) =>{
      Get.snackbar('Link Sent', 'A link has been send to your email',margin: const EdgeInsets.all(30),snackPosition:SnackPosition.BOTTOM, )
    });
  }

  reload() async {
    // ignore: avoid_types_as_parameter_names
    await FirebaseAuth.instance.currentUser!.reload().then((Value)=> {Get.offAll(const Auth())});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 215, 160, 1),
      appBar: AppBar(title: const Text('Verification'),backgroundColor:const Color.fromRGBO(250, 215, 160, 1),),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'asset/logo.png',
                height: 150,
              ),

              Lottie.asset(
                'asset/verify.json',
                width: 300,
                height: 300,
              ),

              const SizedBox(height: 20,),

              const Center(
                child: Text(
                   'Open your mail and click on the link provided to verify email & reload this page',
                  textAlign: TextAlign.center, // Ensures the text is centered horizontally
                  style: TextStyle(
                    fontSize: 16, // Change the font size
                    fontWeight: FontWeight.bold, // Make the text bold
                  ),
                ),
              )
            ]
          )
        ),
    
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: (()=>reload()),
          child:const Icon(Icons.restart_alt_rounded) ,
          ),

    );
  }
}