import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../home.dart';
import '../medicine/add_medice.dart';
import '../medicine/noti/mynotification.dart';
import '../medicine/view.dart';
import '../profile/profile.dart';

class CareAddScreen extends StatefulWidget {
  final String patientId;

  const CareAddScreen({super.key,required this.patientId});

  @override
  State<CareAddScreen> createState() => _CareAddScreenState();
}

class _CareAddScreenState extends State<CareAddScreen> {

  // Variables for text fields
  final TextEditingController medicineNameController = TextEditingController();
  final TextEditingController medicineAmountController = TextEditingController();

  // Variables for dates and times
  DateTime selectedDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  TimeOfDay time1 = TimeOfDay.now();
  TimeOfDay? time2;
  TimeOfDay? time3;


  // Other variables
  String? selectedDose;
  String selectedMedicineType = 'Pill';
  double durationInWeeks = 1;
  String? takenType = 'After Meal';



  // Functions to handle time selection
  Future<void> _selectTime(BuildContext context, Function(TimeOfDay) onTimeSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      onTimeSelected(picked);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedEndDate,
      firstDate: selectedDate,
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => selectedEndDate = picked);
  }

  void addMedication() async {

    CollectionReference medications = FirebaseFirestore.instance.collection('medications');

    String medicineName = medicineNameController.text;
    String medicineAmount = medicineAmountController.text;
    String dosesPerDay = selectedDose ?? '1';
    String medicineType = selectedMedicineType;
    String dynamicUnit = (medicineType == 'Syrup') ? 'ml' : 'Number of Pills';




    if (medicineNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("The Medicine Name field is empty!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (medicineAmount.isEmpty || !RegExp(r'^\d+$').hasMatch(medicineAmount)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medicine amount must be a numeric value or field is empty!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (selectedDose == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select the doses per day!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }




    try {
      await medications.add({
        'uid': widget.patientId,
        'medicine_name': medicineName,
        'medicine_amount': '$medicineAmount $dynamicUnit',
        'doses_per_day': dosesPerDay,
        'start_date': selectedDate.toIso8601String(),
        'end_date': selectedEndDate.toIso8601String(),
        'time1': time1.format(context),
        'time2': time2?.format(context),
        'time3': time3?.format(context),
        'taken_type':takenType,
        'medicine_type': medicineType,
        'created_at': FieldValue.serverTimestamp(),
      });



      void scheduleMedicineNotifications() {
        int id1 = DateTime.now().millisecondsSinceEpoch.remainder(100000);
        int id2 = id1 + 1; // Ensuring uniqueness
        int id3 = id2 + 1; // Ensuring uniqueness

        // Schedule the notifications based on the times selected
        NotificationService.scheduleNotification(
          notificationId: id1,
          time: time1,
          title: 'Time to take your $medicineName',
          body: 'It\'s time to take your $medicineAmount $medicineType of $medicineName.',
        );

        if (time2 != null) {
          NotificationService.scheduleNotification(
            notificationId: id2,
            time: time2!,
            title: 'Time to take your $medicineName',
            body: 'It\'s time to take your $medicineAmount $medicineType of $medicineName.',
          );
        }

        if (time3 != null) {
          NotificationService.scheduleNotification(
            notificationId: id3,
            time: time3!,
            title: 'Time to take your $medicineName',
            body: 'It\'s time to take your $medicineAmount $medicineType of $medicineName.',
          );
        }
      }


      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medication added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }




    // Clear all fields after adding medication
    medicineNameController.clear();
    medicineAmountController.clear();
    setState(() {
      selectedDose = null;
      selectedDate = DateTime.now();
      selectedEndDate = DateTime.now();
      time1 = TimeOfDay.now();
      time2 = null;
      time3 = null;
      selectedMedicineType = 'Pill';
      takenType = 'After Meal';
    });
  }








  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 215, 160, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(250, 215, 160, 1),
        title: const Text('Medication Reminder'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Column(
          children: [

            Center(
              child: Image.asset(
                'asset/logo.png',
                height: 150,
              ),
            ),


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _medicineTypeButton('Syrup', 'asset/syrup.png'),
                _medicineTypeButton('Pill', 'asset/pill.png'),
                _medicineTypeButton('Capsule', 'asset/capsule.png'),
              ],
            ),
            const SizedBox(height: 20),

            _textField('Medicine Name', medicineNameController),

            const SizedBox(height: 20),

            _textField(
              'Medicine Amount (${selectedMedicineType == 'Syrup' ? 'ml' : 'Number of Pills'})',
              medicineAmountController,
            ),


            const SizedBox(height: 20),


            DropdownButton<String>(
              value: selectedDose,
              hint: const Text('Select Doses Per Day'),
              items: ['1', '2', '3']
                  .map((dose) => DropdownMenuItem(
                value: dose,
                child: Text('$dose Times'),
              ))
                  .toList(),
              onChanged: (value) => setState(() => selectedDose = value),
            ),

            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 229, 160, 58),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _dateTimeButton(
                          'Start Date',
                          '${selectedDate.month}/${selectedDate.day}/${selectedDate.year}',
                          _selectDate,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _dateTimeButton(
                          'End Date',
                          '${selectedEndDate.month}/${selectedEndDate.day}/${selectedEndDate.year}',
                          _selectEndDate,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),


                  if (selectedDose != null) ...[
                    SizedBox(
                      height: 40,
                      child: _timePickerRow('Time 1', time1, (picked) => setState(() => time1 = picked)),
                    ),
                    if (selectedDose == '2' || selectedDose == '3')
                      SizedBox(
                        height: 40,
                        child: _timePickerRow('Time 2', time2, (picked) => setState(() => time2 = picked)),
                      ),
                    if (selectedDose == '3')
                      SizedBox(
                        height: 40,
                        child: _timePickerRow('Time 3', time3, (picked) => setState(() => time3 = picked)),
                      ),
                  ],





                ],
              ),
            ),

            const SizedBox(height: 20),


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space items evenly
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                      value: 'Before Meal',
                      groupValue: takenType,
                      onChanged: (String? value) {
                        setState(() {
                          takenType = value;
                        });
                      },
                    ),
                    const Text("Before Meal"),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                      value: 'After Meal',
                      groupValue: takenType,
                      onChanged: (String? value) {
                        setState(() {
                          takenType = value;
                        });
                      },
                    ),
                    const Text("After Meal"),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20.0),






            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 228, 163, 11),
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.02,
                  horizontal: size.width * 0.3,
                ),
              ),
              onPressed: addMedication,
              child: const Text(
                'Add Shedule',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),

      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 214, 155, 65),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.home_rounded),
                hoverColor: const Color.fromARGB(255, 243, 181, 110),
                highlightColor: const Color.fromARGB(255, 242, 71, 20),
                onPressed: () {
                  Get.to(
                        () => const Home(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 500),
                  );
                },
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.medication_rounded),
                hoverColor: const Color.fromARGB(255, 243, 181, 110),
                highlightColor: const Color.fromARGB(255, 242, 71, 20),
                onPressed: () {
                  Get.to(
                        () => const MedicationManagerPage(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 500),
                  );
                },
              ),
            ),
            Transform.scale(
              scale: 2.0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 149, 0),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.add_alert_rounded),
                  hoverColor: const Color.fromARGB(255, 243, 181, 110),
                  highlightColor: const Color.fromARGB(255, 242, 71, 20),
                  onPressed: () {
                    Get.to(
                          () => const MedicineSchedule(),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 500),
                    );

                  },
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.search_rounded),
                hoverColor: const Color.fromARGB(255, 243, 181, 110),
                highlightColor: const Color.fromARGB(255, 242, 71, 20),
                onPressed: () {
                  /* Get.to(
                    () => const MapScreen(),
                    transition: Transition.leftToRight,
                    duration: const Duration(milliseconds: 500),
                  );*/
                },
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.person_rounded),
                hoverColor: const Color.fromARGB(255, 243, 181, 110),
                highlightColor: const Color.fromARGB(255, 242, 71, 20),
                onPressed: () {
                  Get.to(
                        () => const ProfileScreen(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 500),

                  );
                },
              ),
            ),
          ],
        ),
      ),




    );
  }

  Widget _timePickerRow(String label, TimeOfDay? time, Function(TimeOfDay) onTimeSelected) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () => _selectTime(context, onTimeSelected),
          child: Text(time?.format(context) ?? 'Select Time'),
        ),
      ],
    );
  }

  Widget _medicineTypeButton(String type, String assetPath) {
    return GestureDetector(
      onTap: () => setState(() => selectedMedicineType = type),
      child: Container(
        padding: const EdgeInsets.all(8), // Optional: Add padding around the content
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedMedicineType == type ? Colors.orange : const Color.fromRGBO(250, 215, 160, 1), // Change border color based on selection
            width: 2.0, // Optional: Adjust border width
          ),
          borderRadius: BorderRadius.circular(8), // Optional: Add rounded corners
        ),
        child: Column(
          children: [
            Image.asset(assetPath, height: 50),
            Text(type),
          ],
        ),
      ),
    );
  }


  Widget _textField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _dateTimeButton(String label, String value, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Column(
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }

}
