import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/logo');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initSettings);

    // 🔑 Request permission on Android 13+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'channel_id',
          'Default Channel',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Scheduled Notifications',
      channelDescription: 'Notifications about product expiry',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    final now = DateTime.now();

    if (scheduledDate.isAfter(now)) {
      final durationToWait = scheduledDate.difference(now);
      print('Waiting ${durationToWait.inSeconds} seconds before showing notification...');
      await Future.delayed(durationToWait); // ⏳ Hold until scheduled time
    }

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }

  /*
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'channel_id',
          'Scheduled Notifications',
          channelDescription: 'Notifications about product expiry',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          showWhen: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    final now = DateTime.now();

    if (scheduledDate.isBefore(now)) {
      // If the scheduled time is in the past, show the notification immediately
      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
      );
    } else {

      // Otherwise, schedule it for the future (using zonedSchedule if time zones matter)
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    }
  }*/

  static Future<void> checkAndScheduleExpiryNotifications(String userId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    log("🕒 Checking ALL products for user: $userId");

    try {
      final productsSnapshot =
          await FirebaseFirestore.instance
              .collection(
                'user',
              ) // 🔁 Ensure this is 'users' if your Firestore collection is plural
              .doc(userId)
              .collection('products')
              .get();

      log("📦 Found ${productsSnapshot.docs.length} products.");

      for (final doc in productsSnapshot.docs) {
        final data = doc.data();
        final productName = data['productName'] ?? 'Unnamed';
        final expiryTimestamp = data['expiryDate'];

        if (expiryTimestamp is Timestamp) {
          final expiryDate = DateTime(
            expiryTimestamp.toDate().year,
            expiryTimestamp.toDate().month,
            expiryTimestamp.toDate().day,
          );

          final daysLeft = expiryDate.difference(today).inDays;

          if (daysLeft >= 0 && daysLeft <= 2) {
            final scheduledTime = now.add(const Duration(seconds: 10));

          await scheduleNotification(
              id: 852,
              title: 'Product Reminder!',
              body: '$productName → Expires in $daysLeft day(s)',
              scheduledDate: scheduledTime,
            );

            log(
              "✅ Notification scheduled for $productName at $scheduledTime and id is $doc.id.hashCode",
            );
          } else {
            log("⏳ Skipped $productName: expires in $daysLeft day(s)");
          }
        } else {
          log("❌ Invalid expiryDate for $productName");
        }
      }
    } catch (e) {
      log("🚨 Error while sending notifications: $e");
    }
  }
}
