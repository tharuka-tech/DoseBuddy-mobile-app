import 'package:flutter/material.dart';

class HeightWeight extends StatefulWidget {
  final Function(int) onChange;
  final String title;
  final int initValue;
  final int min;
  final int max;

  const HeightWeight({
    super.key,
    required this.onChange,
    required this.title,
    required this.initValue,
    required this.min,
    required this.max,
  });

  @override
  State<HeightWeight> createState() => _HeightWeightState();
}

class _HeightWeightState extends State<HeightWeight> {
  late int currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.initValue; // Set initial value
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0), // Padding for the whole widget
      child: Card(
        elevation: 12, // Shadow effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Optional rounded corners
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wrap content in the smallest size
            children: [
              Text(
                widget.title, // Title passed to the widget
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$currentValue', // Display current value
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: currentValue.toDouble(),
                min: widget.min.toDouble(),
                max: widget.max.toDouble(),
                divisions: widget.max - widget.min,
                label: currentValue.toString(),
                onChanged: (double newValue) {
                  setState(() {
                    currentValue = newValue.toInt();
                  });
                  widget.onChange(currentValue); // Trigger callback
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}