import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'guide3.dart';

class Guide2 extends StatefulWidget {
  const Guide2({super.key});

  @override
  State<Guide2> createState() => _GuideState2();
}

class _GuideState2 extends State<Guide2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromRGBO(250, 215, 160, 1), // Background color
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distributes widgets
          children: [
            // Top Logo and Lottie Animation
            Column(
              children: [
                const SizedBox(height: 50), // Spacing at the top
                Image.asset(
                  'asset/logo.png', // Replace with your logo
                  height: 150,
                ),
                const SizedBox(height: 5), // Space between logo and animation
                Lottie.asset(
                  "asset/get2.json", // Replace with your Lottie file
                  height: 300,
                  width: 450,
                ),
              ],
            ),
            // Text Section
            const Column(
              children: [
                Text(
                  "Never Miss a Dose Again",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10), // Space between texts
                Text(
                  "Set personalized medication reminders to stay on \ntrack with your health goals effortlessly",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                SizedBox(height: 20), // Space for the progress indicator
                // Progress Indicator Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.circle, size: 10, color: Colors.grey),
                    SizedBox(width: 5),
                    Icon(Icons.circle, size: 10, color: Colors.orange),
                    SizedBox(width: 5),
                    Icon(Icons.circle, size: 10, color: Colors.grey),
                  ],
                ),
              ],
            ),
            // Bottom Button
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: ElevatedButton(
                 onPressed: () {
                     Get.to(() => const Guide3(),
                      transition: Transition.rightToLeft, // Specify the transition type
                      duration: const Duration(milliseconds: 500), // Set the duration
                    );
                  },
                
                  
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Button color
                  minimumSize: const Size(300, 50), // Button size
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25), // Rounded corners
                  ),
                ),
                child: const Text(
                  "NEXT",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
