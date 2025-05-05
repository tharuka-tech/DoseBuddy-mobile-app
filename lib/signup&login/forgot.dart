import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Forgot extends StatefulWidget {
  const Forgot({super.key});

  @override
  State<Forgot> createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {

  TextEditingController email = TextEditingController();

    reset() async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color.fromRGBO(250, 215, 160, 1), 
      appBar: AppBar(title: const Text('Froget Password'),backgroundColor:const Color.fromRGBO(250, 215, 160, 1),),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [

            Image.asset(
              'asset/logo.png',
              height: 150, 
              ),

            Lottie.asset(
              "asset/reset.json",
                height: 300,
                width: 350,
            ),

            const SizedBox(height: 30,),

            TextFormField(
              controller: email,
              decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              ),
                      
              focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    ),
              ),
        
                const SizedBox(height: 30,),

                ElevatedButton(
                  onPressed: (()=>reset()),
                  
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(300, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    )
                  ),
                  child: const Text('Sent Link')
                )
          ],
        ),
      ),
    );
  }
}