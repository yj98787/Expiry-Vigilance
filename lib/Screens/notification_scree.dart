import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:expiry_vigilance/Services/notification_services.dart'; // make sure this path is correct

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Optional: Ask for notification permission (for Android 13+)
    requestNotificationPermission();
  }

  void requestNotificationPermission() async {
    // You can also use the permission_handler package if you want runtime control
    // Or this could be handled globally in your main file
  }

  void sendNotification() {
    NotificationServices.showInstantNotification(
      id: 1,
      title: 'New Alert!',
      body: 'You just triggered an instant notification 🚀',
    );
  }

  void schedule() async {
    final scheduledTime = DateTime.now()
        .add(const Duration(seconds: 1));

    await NotificationServices.scheduleNotification(
      id: 1234,
      title: 'Test Reminder',
      body: 'This is a scheduled notification',
      scheduledDate: scheduledTime,
    );

    log("✅ Scheduled notification for: $scheduledTime");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notification Test")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("No Notification Yet"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendNotification,
              child: Text("Send Notification"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: schedule,
              child: Text("Send Scheduled Notification"),
            ),
          ],
        ),
      ),
    );
  }
}
