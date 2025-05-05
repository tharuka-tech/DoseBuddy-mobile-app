import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'guide2.dart';

class Guide extends StatefulWidget {
  const Guide({super.key});

  @override
  State<Guide> createState() => _GuideState();
}

class _GuideState extends State<Guide> {
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
                  "asset/getstarted.json", // Replace with your Lottie file
                  height: 300,
                  width: 300,
                ),
              ],
            ),
            // Text Section
            const Column(
              children: [
                Text(
                  "Ensure to Keep Track of\nYour Medicine",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10), // Space between texts
                Text(
                  "Enjoy the Convenience of Getting a Better\nExperience",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                SizedBox(height: 20), // Space for the progress indicator
                // Progress Indicator Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.circle, size: 10, color: Colors.orange),
                    SizedBox(width: 5),
                    Icon(Icons.circle, size: 10, color: Colors.grey),
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
                     Get.to(() => const Guide2(),
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
