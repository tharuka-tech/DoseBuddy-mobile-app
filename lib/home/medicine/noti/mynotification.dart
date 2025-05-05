import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        try {
          print("Notification Clicked: ${response.id}");
          print("Action ID: ${response.actionId}");
          print("Payload: ${response.payload}");

          if (response.id == null) {
            throw ArgumentError("Notification ID is NULL!");
          }

          if (response.actionId == 'approve') {
            print("Marking as TAKEN");
            markMedicineTaken(response.id ?? 0);
          } else if (response.actionId == 'missed') {
            print("Marking as MISSED");
            markMedicineMissed(response.id ?? 0);
          } else {
            throw Exception("Unknown action: ${response.actionId}");
          }
        } catch (e) {
          print("Error occurred: ${e.toString()}");
          // Here, you can also log the error to a monitoring service or show an alert to the user.
        }
      },
    );

    print("🔥 Notification Service Initialized");
    tz.initializeTimeZones();
  }

  static Future<void> scheduleNotification({
    required int notificationId,
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    final now = DateTime.now();
    final scheduledDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    final tz.TZDateTime scheduledTime =
    tz.TZDateTime.from(scheduledDateTime, tz.local);

// Define Action Buttons
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'channel_id',
      'Scheduled Notifications',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder, // Add category
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'approve',
          'Approve',
          showsUserInterface: true, //  Ensure UI is shown
        ),
        AndroidNotificationAction(
          'missed',
          'Missed',
          showsUserInterface: true,
        ),
      ],
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledTime,
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }


  /// Edit an existing notification
  static Future<void> editNotification({
    required int notificationId,
    required TimeOfDay newTime,
    required String title,
    required String body,
  }) async {
    final now = DateTime.now();
    DateTime newDateTime = DateTime(now.year, now.month, now.day, newTime.hour, newTime.minute);

    // Check if the new time is in the past and adjust accordingly (schedule for the next day if necessary)
    if (newDateTime.isBefore(now)) {
      newDateTime = newDateTime.add(Duration(days: 1)); // Adjust to the next day if time has already passed
    }

    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(newDateTime, tz.local);

    // Cancel the existing notification
    await _notificationsPlugin.cancel(notificationId);

    // Reschedule with the new time
    await scheduleNotification(
      notificationId: notificationId,
      time: TimeOfDay.fromDateTime(scheduledTime),
      title: title,
      body: body,
    );

    print("Notification ID $notificationId updated to new time: ${newTime.hour}:${newTime.minute}");
  }






  /// **Mark Medicine as Taken**
  static Future<void> markMedicineTaken(int notificationId) async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      await FirebaseFirestore.instance.collection('medicine_logs').add({
        'uid': uid, // Store user ID
        'notificationId': notificationId,
        'status': 'Taken',
        'timestamp': Timestamp.now(),
      });
    } else {
      print("User is not authenticated.");
    }
  }



  /// **Mark Medicine as Missed**
  static Future<void> markMedicineMissed(int notificationId) async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      await FirebaseFirestore.instance.collection('medicine_logs').add({
        'uid': uid, // Store user ID
        'notificationId': notificationId,
        'status': 'Missed',
        'timestamp': Timestamp.now(),
      });
    } else {
      print("User is not authenticated.");
    }
  }
}
