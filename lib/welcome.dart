import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'guide.dart';

class WelcomeScrren extends StatefulWidget {
  const WelcomeScrren({super.key});

  @override
  State<WelcomeScrren> createState() => _WelcomeScrrenState();
}

class _WelcomeScrrenState extends State<WelcomeScrren> {

  @override
  void initState() {
    super.initState();
    // Set up a timer to navigate to the second page after 6 seconds
    Timer(
      const Duration(seconds: 7),
      () {
        // Navigate to the Guide screen
        Get.to(() => const Guide(), transition: Transition.fadeIn);
      },
    );
  }



  @override
  Widget build(BuildContext context) {
        return Scaffold(
      body: Container(
        color: const Color.fromRGBO(250, 215, 160, 1),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'asset/logo.gif',
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 5), // Adding space between the logo and animation
              SizedBox(
                width: 100, // Set the width of the Lottie animation
                height: 100, // Set the height of the Lottie animation
                child: Lottie.asset('asset/wel.json'), // Assuming you have an animation file
              ),
            ],
          ),
        ),
      ),
    );
  }
}