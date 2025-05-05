
import 'package:flutter/material.dart';
import 'age_weight.dart';
import 'high.dart';

class BmiCal extends StatefulWidget {
  const BmiCal({super.key});

  @override
  State<BmiCal> createState() => _BmiCalState();
}

class _BmiCalState extends State<BmiCal> {
  double height = 150; // Initial height value
  String gender = 'Male'; // Initial gender value
  int age = 30;
  int weight = 50;

  // Function to update height value
  void updateHeight(int newHeight) {
    setState(() {
      height = newHeight.toDouble();
    });
  }

  // Function to update gender
  void updateGender(String newGender) {
    setState(() {
      gender = newGender;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 215, 160, 1), // Background color
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Logo Image
            Image.asset(
              'asset/logo.png',
              height: 150,
            ),
            // Gender and Height selection
            Container(
              padding: const EdgeInsets.all(12),
              child: Card(
                color: const Color.fromARGB(255, 241, 193, 121),
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Optional rounded corners
                ),
                child: Column(
                  children: [
                    // Gender selection widget
                    Height(
                      onChange: updateHeight, // Pass function to update height
                    ),
              
                    HeightWeight(
                      title: "Weight (Kg)",
                      initValue: weight,
                      min: 20,
                      max: 200,
                      onChange: (weightVal) {
                        setState(() {
                          weight = weightVal;
                        });
                      },
                    ),
                    
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
                    // Calculate BMI button
                    ElevatedButton(
                      onPressed: () {
                        // Calculate BMI
                        double bmi = weight / ((height / 100) * (height / 100));
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Your BMI'),
                            content: Text('BMI: ${bmi.toStringAsFixed(2)}'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                       // Orange color
                       // Text color
                        backgroundColor: const Color.fromARGB(255, 235, 151, 17),
                        shadowColor: Colors.orangeAccent, // Shadow color
                        elevation: 8, // Elevation for 3D effect
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Rounded corners
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ), // Padding inside the button
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ), // Text styling
                      ),
                      child: const Text('Calculate BMI'),
                    ),
                    const SizedBox(height: 20,)
          ],
        ),
      ), 
    );
  }
}