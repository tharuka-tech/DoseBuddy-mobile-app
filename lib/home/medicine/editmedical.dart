import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'noti/mynotification.dart';
import 'noti/notid.dart';

class Editmedical extends StatefulWidget {
  final String medicationId;
  final Map<String, dynamic> initialData;

  const Editmedical({
    required this.medicationId,
    required this.initialData,
    super.key,
  });

  @override
  State<Editmedical> createState() => _EditmedicalState();
}

class _EditmedicalState extends State<Editmedical> {
  late TextEditingController medicineNameController;
  late TextEditingController medicineAmountController;
  late String selectedMedicineType;
  late String? selectedDose;
  late DateTime selectedDate;
  late DateTime selectedEndDate;
  late TimeOfDay selectedTime1;
  late TimeOfDay? selectedTime2;
  late TimeOfDay? selectedTime3;
  late String selectedTakenType;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    medicineNameController = TextEditingController(text: widget.initialData['medicine_name'] ?? '');

    medicineAmountController = TextEditingController(text: widget.initialData['medicine_amount'] ?? '');

    selectedMedicineType = widget.initialData['medicine_type'] ?? 'Pill';

    selectedDose = widget.initialData['doses_per_day'] ?? '1';

    selectedDate = DateTime.parse(widget.initialData['start_date']);

    selectedEndDate = DateTime.parse(widget.initialData['end_date']);

    selectedTime1 = _parseTime(widget.initialData['time1'] ?? '12:00 AM');

    selectedTime2 = widget.initialData['time2'] != null
      ? _parseTime(widget.initialData['time2'])
      : null;
   
    selectedTime3 = widget.initialData['time3'] != null
        ? _parseTime(widget.initialData['time3'])
        : null;
    selectedTakenType = widget.initialData['taken_type'] ?? 'Before Meal';
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1].split(' ')[0]);
    final isPM = timeString.toLowerCase().contains('pm');
    return TimeOfDay(hour: isPM ? (hour % 12) + 12 : hour, minute: minute);
  }

  Future<void> updateMedication() async {
    if (medicineNameController.text.isEmpty ||
        medicineAmountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('medications')
          .doc(widget.medicationId)
          .update({
        'medicine_name': medicineNameController.text,
        'medicine_amount': medicineAmountController.text,
        'medicine_type': selectedMedicineType,
        'doses_per_day': selectedDose,
        'start_date': selectedDate.toIso8601String(),
        'end_date': selectedEndDate.toIso8601String(),
        'time1': selectedTime1.format(context),
        'time2': selectedTime2?.format(context),
        'time3': selectedTime3?.format(context),
        'taken_type': selectedTakenType,
      });


      void editNotificationExample() {
        if (id1 != null) {
          NotificationService.editNotification(
            notificationId: id1!,
            newTime: selectedTime1, // Example time
            title: 'Updated Reminder',
            body: 'Your medicine reminder has been updated.',
          );
        }

        if (id2 != null && selectedTime2 != null) {
          NotificationService.editNotification(
            notificationId: id2!,
            newTime: selectedTime2!,
            title: 'Updated Reminder',
            body: 'Your medicine reminder has been updated.',
          );
        }

        if (id3 != null && selectedTime3 != null) {
          NotificationService.editNotification(
            notificationId: id3!,
            newTime: selectedTime3!,
            title: 'Updated Reminder',
            body: 'Your medicine reminder has been updated.',
          );
        }
      }

      editNotificationExample();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating medication: $e')),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 215, 160, 1),
      appBar: AppBar(
        title: const Text('Edit Medication'),
        backgroundColor: const Color.fromRGBO(250, 215, 160, 1),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        'asset/logo.png',
                        height: 150,
                      ),
                    ),
                    // Medicine Name
                    TextField(
                      controller: medicineNameController,
                      decoration: const InputDecoration(
                        labelText: 'Medicine Name',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color.fromARGB(255, 255, 254, 255),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Medicine Amount (mg/ml)
                    TextField(
                      controller: medicineAmountController,
                      decoration: InputDecoration(
                        labelText: selectedMedicineType == 'Syrup'
                            ? 'Amount (ml)'
                            : 'Amount (mg)',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 251, 250, 252),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Medicine Type Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedMedicineType,
                      items: ['Pill', 'Syrup', 'Capsule'].map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Image.asset(
                                'asset/${type.toLowerCase()}.png',
                                width: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(type),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() {
                        selectedMedicineType = value!;
                      }),
                      decoration: const InputDecoration(
                        labelText: 'Medicine Type',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color.fromARGB(255, 247, 247, 248),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Doses Per Day Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedDose,
                      hint: const Text('Select Doses Per Day'),
                      decoration: const InputDecoration(
                        labelText: 'Doses Per Day',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color.fromARGB(255, 251, 250, 252),
                      ),
                      items: ['1', '2', '3']
                          .map((dose) => DropdownMenuItem(
                                value: dose,
                                child: Text('$dose Times'),
                              ))
                          .toList(),
                       onChanged: (value) {
                        setState(() {
                          selectedDose = value;
                          if (value == '1') {
                            // Reset Time 2 and Time 3 to null when '1' dose per day is selected
                            selectedTime2 = null;
                            selectedTime3 = null;
                          }else if (value == '2') {
                            // Initialize Time 2 with a default value
                            selectedTime2 = TimeOfDay(hour: 12, minute: 0);
                            selectedTime3 = null;
                          } else if (value == '3') {
                            // Initialize Time 2 and Time 3 with default values
                            selectedTime2 = TimeOfDay(hour: 12, minute: 0);
                            selectedTime3 = TimeOfDay(hour: 12, minute: 0);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    // Start Date Picker
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 223, 158, 52),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: TextEditingController(
                            text: selectedDate.toString().split(' ')[0]),
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Color.fromARGB(255, 243, 194, 17),
                        ),
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // End Date Picker
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 235, 151, 49),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: TextEditingController(
                            text: selectedEndDate.toString().split(' ')[0]),
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Color.fromARGB(255, 223, 158, 52),
                        ),
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedEndDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedEndDate = pickedDate;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Time Pickers based on Doses Per Day
                    if (selectedDose == '1') ...[
                      // Time1
                      _buildTimePicker('Time 1', selectedTime1, (time) {
                        setState(() {
                          selectedTime1 = time;
                        });
                      }),
                    ] else if (selectedDose == '2') ...[
                      // Time1 and Time2
                      _buildTimePicker('Time 1', selectedTime1, (time) {
                        setState(() {
                          selectedTime1 = time;
                        });
                      }),
                      _buildTimePicker('Time 2', selectedTime2!, (time) {
                        setState(() {
                          selectedTime2 = time;
                        });
                      }),
                      
                    ] else if (selectedDose == '3') ...[
                      // Time1, Time2 and Time3
                      _buildTimePicker('Time 1', selectedTime1, (time) {
                        setState(() {
                          selectedTime1 = time;
                        });
                      }),
                      _buildTimePicker('Time 2', selectedTime2!, (time) {
                        setState(() {
                          selectedTime2 = time;
                        });
                      }),
                      _buildTimePicker('Time 3', selectedTime3!, (time) {
                        setState(() {
                          selectedTime3 = time;
                        });
                      }),
                    ],
                    const SizedBox(height: 16),

                    // Taken Type Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedTakenType,
                      decoration: const InputDecoration(
                        labelText: 'Taken Type',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color.fromARGB(255, 251, 250, 252),
                      ),
                      items: ['Before Meal', 'After Meal']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedTakenType = value!),
                    ),
                    const SizedBox(height: 16),

                    // Update Button
                  ElevatedButton(
                      onPressed: updateMedication,
                      
                        
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange, // Button color
                        minimumSize: const Size(300, 50), // Button size
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25), // Rounded corners
                        ),
                      ),
                      child: const Text(
                        "Update Shedule",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),

                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, Function(TimeOfDay) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 243, 73, 6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: TextEditingController(text: time.format(context)),
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          filled: true,
          fillColor: const Color.fromARGB(255, 237, 182, 63),
        ),
        readOnly: true,
        onTap: () async {
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: time,
          );
          if (pickedTime != null) {
            onChanged(pickedTime);
          }
        },
      ),
    );
  }
}
