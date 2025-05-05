import 'package:flutter/material.dart';

class Height extends StatefulWidget {
  final Function(int) onChange;

  const Height({super.key, required this.onChange});

  @override
  State<Height> createState() => _HeightState();
}

class _HeightState extends State<Height> {
  double _height = 150; // Set initial height value

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0), // Padding for the whole widget
      child: Card(
        elevation: 12, // Shadow effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Optional rounded corners
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Wrap content in the smallest size
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Height",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 10), // Space between text and the value
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _height.toStringAsFixed(0), // Display height value as integer
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  "cm",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10), // Space between value and slider
            Slider(
              min: 0,
              max: 240,
              value: _height,
              thumbColor: Colors.red,
              onChanged: (value) {
                setState(() {
                  _height = value.toInt().toDouble(); // Update height value
                  widget.onChange(_height.toInt()); // Pass height value to parent widget
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
